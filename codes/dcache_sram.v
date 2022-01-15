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
    hit_o,
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;      // dcache sram index
input    [24:0]    tag_i;       // cpu tag
input    [255:0]   data_i;      // data from memory or data modified by cpu
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
integer                       i, j;
reg                       to_evict;

wire validw, vw0, vw1;
assign vw0 = tag[addr_i][0][24];
assign vw1 = tag[addr_i][1][24];
assign validw = ~(vw0 & vw1);
wire hit, hit_w0, hit_w1;
assign hit_w0 = vw0 & (tag_i[22:0] == tag[addr_i][0][22:0]);
assign hit_w1 = vw1 & (tag_i[22:0] == tag[addr_i][1][22:0]);
assign hit = hit_w0 | hit_w1;

// reference: https://github.com/prasadp4009/2-way-Set-Associative-Cache-Controller/blob/master/rtl/cache_2wsa.v#L426



// Write Data (write only at posedge)
// 1. Write hit
// 2. Read miss: Read from memory
// cache can only be written under 2 circumstances
// (1) write hit, directly modify the correct memory block
// (2) write miss, after enable

// always@(*)begin
//     if (~hit) hit_o = hit;
// end

// 1.14 version
always@(posedge clk_i or posedge rst_i) begin
    // 我不確定hit_o = hit要寫在always(*)還是posedge?
    // sram_ready_o = 1; // ready
    hit_o = hit;
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
        case (hit)
            1'b0: begin // Write Miss
                // Replace
                if (validw) begin
                    if (~vw0) begin
                        data[addr_i][0] <= data_i;
                        tag[addr_i][0] <= tag_i;
                        data_o <= data[addr_i][0];
                        tag_o <= tag[addr_i][0];
                        ref[addr_i] <= 1; // block to be evicted next time is 1
                    end
                    else begin // vw1
                        data[addr_i][1] <= data_i;
                        tag[addr_i][1] <= tag_i;
                        data_o <= data[addr_i][1];
                        tag_o <= tag[addr_i][1];
                        ref[addr_i] <= 0; // block to be evicted next time is 0
                    end
                end
                else begin
                    // to be evicted is 0
                    if (ref[addr_i] == 0) begin
                        // 把evicted cache line 送至dcache_controller
                        data_o <= data[addr_i][0];
                        tag_o <= tag[addr_i][0];
                        // 寫入把其他人擠掉的cache line (requested cache line)
                        tag[addr_i][0] <= tag_i;
                        data[addr_i][0] <= data_i;
                        ref[addr_i] <= 1;
                    end
                    else begin
                        data_o <= data[addr_i][1];
                        tag_o <= tag[addr_i][1];
                        // 寫入把其他人擠掉的cache line (requested cache line)
                        tag[addr_i][1] <= tag_i;
                        data[addr_i][1] <= data_i;
                        ref[addr_i] <= 0;
                    end
                    end
                end
            1'b1: begin// Write hit
                if (hit_w0) begin
                    data[addr_i][0] <= data_i;
                    tag[addr_i][0] <= tag_i;
                    data_o <= data[addr_i][0];
                    tag_o <= tag[addr_i][0];
                    ref[addr_i] <= 1; // block to be evicted next time is 1
                end
                else begin // hit_w1
                    data[addr_i][1] <= data_i;
                    tag[addr_i][1] <= tag_i;
                    data_o <= data[addr_i][1];
                    tag_o <= tag[addr_i][1];
                    ref[addr_i] <= 0; // block to be evicted next time is 0
                end
            end
        endcase
    end
end


always@(*)begin
    // Read data is OUTSIDE?
    // TODO: tag_o=? data_o=? hit_o=?
    hit_o = hit;
    if (enable_i) begin
        case(hit)
            1'b1: begin// Readhit
                if (hit_w0) begin
                    tag_o = tag[addr_i][0];
                    data_o = data[addr_i][0];
                    ref[addr_i] = 1;
                end
                else begin
                    tag_o = tag[addr_i][1];
                    data_o = data[addr_i][1];
                    ref[addr_i] = 0;
                end
            end
            1'b0: begin
                data_o = data_i;
                tag_o = tag_i;
            end
        endcase
        end
end
endmodule