`include "./Dcache/dcache_sram.v"

module dcache_controller(
    // System clock, reset and stall
    clk_i,
    rst_i,
    // to Data Memory interface
    mem_data_i,
    mem_ack_i,
    mem_data_o,
    mem_addr_o,
    mem_enable_o,
    mem_write_o,

    // to CPU interface
    // (dcache_sram and dcache_controller are inside CPU)
    cpu_data_i,
    cpu_addr_i,
    cpu_MemRead_i,
    cpu_MemWrite_i,
    cpu_data_o,
    cpu_stall_o);
//
// System clock, start
//
input                 clk_i;
input                 rst_i;

//
// to Data_Memory interface
//
input    [255:0]      mem_data_i;
input                 mem_ack_i;
output   [255:0]      mem_data_o;
output   [31:0]       mem_addr_o;
output                mem_enable_o;
output                mem_write_o;

//
// to CPU interface
//
input    [31:0]       cpu_data_i;
input    [31:0]       cpu_addr_i;
input                 cpu_MemRead_i;
input                 cpu_MemWrite_i;

output   [31:0]       cpu_data_o;
output                cpu_stall_o;

//
// to SRAM interface
//
wire    [3:0]         cache_sram_index;
wire                  cache_sram_enable;
wire    [24:0]        cache_sram_tag;
wire    [255:0]       cache_sram_data;
wire                  cache_sram_write;
wire    [24:0]        sram_cache_tag;
wire    [255:0]       sram_cache_data;
wire                  sram_cache_hit;

// cache
wire                  sram_valid;
wire                  sram_dirty;

// controller
parameter             STATE_IDLE         = 3'h0,
                      STATE_READMISS     = 3'h1,
                      STATE_READMISSOK   = 3'h2,
                      STATE_WRITEBACK    = 3'h3,
                      STATE_MISS         = 3'h4;
reg     [2:0]         state;
reg                   mem_enable; // When the enable signal of Data_Memory is turned on,
                                  // the Data_Memory will start accessing the data, and send back an ack signal
                                  // and data of corresponding address after 10 cycles.
reg                   mem_write;  // if this memory reference is a write-back or a read
reg                   cache_write;// if mem_data_o is ready to be moved into cache
wire                  cache_dirty;// cache_dirty = write_hit (if a write has been made), this signal is used as current data's dirty bit
reg                   write_back; // if sram's data_o is dirty

// regs & wires
// this implementation is completely physical (no virtual memory mapping)
wire    [4:0]         cpu_offset;   // cpu requested address offset
wire    [3:0]         cpu_index;    // cpu requested address index
wire    [22:0]        cpu_tag;      // cpu requested address tag


wire    [255:0]       r_hit_data;   // data to a read-hit
// original code: wire [21:0]        sram_tag;
wire    [22:0]        sram_tag;     // 在dcache_sram中，sram_tag和cpu_tag比對相等與否??
wire                  hit;          // 在dcache_sram中，sram_tag == cpu_tag && sram_valid
reg     [255:0]       w_hit_data;   // data to a write-hit (should be modified and stored in cache)
wire                  write_hit;
wire                  cpu_req;      // if it is a load/store instruction
reg     [31:0]        cpu_data;     // the data written by CPU (if a store instruction)
                                        // to be stored back to cache (be stored back to Data_Memory in write-back)
// assign hit = sram_ready & match;
// to CPU interface
assign    cpu_req     = cpu_MemRead_i | cpu_MemWrite_i;

assign    cpu_tag     = cpu_addr_i[31:9];
assign    cpu_index   = cpu_addr_i[8:5];
assign    cpu_offset  = cpu_addr_i[4:0];


// assign    cpu_stall_o = ~hit & cpu_req;      // load-store && a miss (no matter w or r)
assign    cpu_stall_o = ~hit & cpu_req;
assign    cpu_data_o  = cpu_data;

// to SRAM interface
assign    sram_valid = sram_cache_tag[24];
assign    sram_dirty = sram_cache_tag[23];
assign    sram_tag   = sram_cache_tag[22:0];
assign    cache_sram_index  = cpu_index;    // use to index the cache entries
assign    cache_sram_enable = cpu_req;
assign    cache_sram_write  = cache_write | write_hit; // cache can only be written when either:
                                                    // (1) [W/R MISS] cache_write: the previously missed data is readily prepared by memory
                                                    // (2) [W HIT]    write_hit: cpu's write request finds the correspnding memory block in cache
assign    cache_sram_tag    = {1'b1, cache_dirty, cpu_tag};

assign    cache_sram_data   = (hit) ? w_hit_data : mem_data_i;


// to Data_Memory interface
assign    mem_enable_o = mem_enable;
assign    mem_addr_o   = (write_back) ? {sram_tag, cpu_index, 5'b0} : {cpu_tag, cpu_index, 5'b0};
assign    mem_data_o   = sram_cache_data;
assign    mem_write_o  = mem_write;

assign    write_hit    = hit & cpu_MemWrite_i;
assign    cache_dirty  = write_hit;

// TODO: add your code here!  (r_hit_data=...?)
// reference: https://stackoverflow.com/questions/33864574/non-constant-indexing-for-a-logic-statement-in-systemverilog


assign r_hit_data = (hit)? sram_cache_data:mem_data_i;
// read data :  256-bit to 32-bit
always@(cpu_offset or r_hit_data) begin
    // TODO: add your code here! (cpu_data=...?)
    cpu_data = r_hit_data[cpu_offset*8 +:32];
end
// write data :  32-bit to 256-bit
// bit-slicing is to be done by +: operator since you have non-constant slicing index.
always@(cpu_offset or r_hit_data or cpu_data_i)
begin
    // TODO: add your code here! (w_hit_data=...?)
    w_hit_data = r_hit_data;
    w_hit_data[cpu_offset*8 +:32] = cpu_data_i;
end

// controller
always@(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin // initializing signals
        state       <= STATE_IDLE;
        mem_enable  <= 1'b0;
        mem_write   <= 1'b0;
        cache_write <= 1'b0;
        write_back  <= 1'b0;
    end
    else begin
        case(state)
            STATE_IDLE: begin
                if(cpu_req && !hit) begin      // wait for request
                    state <= STATE_MISS;
                end
                else begin
                    // rst_i 後還沒有 cpu_req
                    state <= STATE_IDLE;
                end
            end
            STATE_MISS: begin // 至少會先有一個compulsory miss
                if(sram_dirty) begin          // write back if dirty
                    // TODO: add your code here!
                    mem_enable  <= 1'b1; // ???
                    mem_write   <= 1'b1; // sram_dirty=1; the corresponding sram_cache_data is then ready to be written back
                    cache_write <= 1'b0;
                    write_back  <= 1'b1;
                    state <= STATE_WRITEBACK;
                end
                else begin                    // write allocate:
                    // write miss = read miss + write hit; read miss = read miss + read hit
                    // TODO: add your code here!
                    mem_enable  <= 1'b1;
                    mem_write   <= 1'b0;
                    cache_write <= 1'b0;
                    write_back  <= 1'b0;
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISS: begin
                if(mem_ack_i) begin            // wait for data memory acknowledge
                    // TODO: add your code here!
                    mem_enable  <= 1'b1; // 10 cycles have passed
                    mem_write   <= 1'b0;
                    cache_write <= 1'b1;
                    write_back  <= 1'b0;
                    state <= STATE_READMISSOK;
                end
                else begin
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISSOK: begin
                // TODO: add your code here!
                mem_enable  <= 1'b0;
                mem_write   <= 1'b0;
                cache_write <= 1'b0;    //........
                write_back  <= 1'b0;
                state <= STATE_IDLE;
            end
            STATE_WRITEBACK: begin
                // write back 也要等10 cycles
                if(mem_ack_i) begin            // wait for data memory acknowledge
                    // TODO: add your code here!
                    // writeback結束了
                    mem_enable  <= 1'b1; //????
                    mem_write   <= 1'b0;
                    cache_write <= 1'b0; // off, 99% sure
                    write_back  <= 1'b0;
                    state <= STATE_READMISS;
                end
                else begin
                    state <= STATE_WRITEBACK;
                end
            end
        endcase
    end
end

//
// SRAM (cache memory part)
//
dcache_sram dcache_sram
(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .addr_i     (cache_sram_index),
    .tag_i      (cache_sram_tag),
    .data_i     (cache_sram_data),
    .enable_i   (cache_sram_enable), // "Not in memory latency period"
    .write_i    (cache_sram_write),  // "can modify cache" (hit&mem_write)
    .tag_o      (sram_cache_tag),
    .data_o     (sram_cache_data),
    .hit_o      (hit)
);

endmodule
