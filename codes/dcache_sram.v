module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;      // dcache sram index
input    [24:0]    tag_i;       // cpu tag
input    [255:0]   data_i;      // data from memory
input              enable_i;
input              write_i;

output reg  [24:0]    tag_o;       // {v,d,23-tagbits}
output reg  [255:0]   data_o;
output reg            hit_o;
// code snippets from dcache_controller.v:
// assign    sram_valid = sram_cache_tag[24];
// assign    sram_dirty = sram_cache_tag[23];
// assign    sram_tag   = sram_cache_tag[22:0];

// Memory
reg      [24:0]    tag [15:0][1:0]; // 16 sets, 2-way
reg      [255:0]   data[15:0][1:0];
reg                     ref [15:0];   // if tag[i][0] is older set to 1
wire                    read_match;
integer                        i, j;
reg                           valid;
reg   to_evict, hasWritten, hasReadHit;
reg [24:0]                 sram_tag;
// Write Data (write only at posedge)
// 1. Write hit
// 2. Read miss: Read from memory
// cache can only be written under 2 circumstances
// (1) write hit, directly modify the correct memory block
// (2) write miss, after enable
initial begin
    hit_o = 0;
    hasWritten = 0;
    hasReadHit = 0;
end
always@(posedge clk_i or posedge rst_i) begin
    hasWritten = 0;
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            ref[i] <= 1'b0;
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        // originally a write hit
        for (j=0; j<2;j+=1) begin
            valid <= tag[addr_i][j][24];
            if ((tag[addr_i][j][22:0] == tag_i[22:0]) && valid) begin
                hasWritten <= 1'b1;
                hit_o <= 1'b1;
                tag_o <= tag[addr_i][j]; // {v,d,23-tagbits}
                data_o <= data[addr_i][j]; // a cpu modified w_hit_data
                // write-hit
                tag[addr_i][j] <= tag_i;
                data[addr_i][j] <= data_i; //w-hit data
                // LRU
                if (j == 0)ref[addr_i] = 1'b1;
                else ref[addr_i] = 1'b0;
                end
            end

        //if no write hit and no invalid slots, evict a block
        if (~hasWritten && tag[addr_i][0][24] && tag[addr_i][1][24])begin
            // both valid
            to_evict <= ref[addr_i];
            // send out the evicted cache line
            tag_o <= tag[addr_i][to_evict];
            data_o <= data[addr_i][to_evict];
            // write in the new data
            tag[addr_i][j] <= tag_i;
            data[addr_i][j] <= data_i;
            // hit_o <= 1'b1; // data is ready, stop cpu_stall_o signal
            hasWritten <= 1'b1;
            if (to_evict == 0)ref[addr_i] = 1'b1;
                else ref[addr_i] = 1'b0;
        end
        // if 1 or more invalid slots are available, put it in
        for (j=0; j<2;j+=1) begin
            if (~hasWritten) begin
                valid <= tag[addr_i][j][24];
                if (~valid) begin
                    // hit_o <= 1'b1;
                    tag_o <= tag[addr_i][j]; // {v,d,23-tagbits}
                    data_o <= data[addr_i][j];
                    data[addr_i][j] <= data_i;
                    tag[addr_i][j] <= tag_i;
                    if (j == 0) ref[addr_i] = 1'b1;
                    else ref[addr_i] = 1'b0;
                    hasWritten <= 1'b1;
                end
            end
        end
    end
end
// Read data is OUTSIDE?
// TODO: tag_o=? data_o=? hit_o=?
always@(*)begin
    hit_o = 0;
    for (j=0; j<2;j+=1) begin
        valid = tag[addr_i][j][24];
        if (tag[addr_i][j][22:0] == tag_i[22:0] && valid) begin
            tag_o = tag[addr_i][j];
            data_o = data[addr_i][j];
            hit_o = 1;
            // if it's a hit, renew reference bit for LRU
            // if LRU tag[i][0], set to 1, if LRU tag[i][1] set to 0.
            if (j == 0) ref[addr_i] = 1'b1;
            else ref[addr_i] = 1'b0;
            end

end
endmodule