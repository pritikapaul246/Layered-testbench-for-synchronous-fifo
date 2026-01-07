interface fifo_if #(parameter WIDTH = 8)
(
    input logic clk,
    input logic rst
);

    logic             wr_en;
    logic             rd_en;
    logic [WIDTH-1:0] wdata;
    logic [WIDTH-1:0] rdata;
    logic             full;
    logic             empty;

endinterface

module fifo_dut #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR  = $clog2(DEPTH)
)(
    input  logic             clk,
    input  logic             rst,

    input  logic             wr_en,
    input  logic             rd_en,
    input  logic [WIDTH-1:0] wdata,

    output logic [WIDTH-1:0] rdata,
    output logic             full,
    output logic             empty
);

    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR:0] wr_ptr, rd_ptr;
    logic [ADDR:0] count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[ADDR-1:0]] <= wdata;
            wr_ptr <= wr_ptr + 1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            rdata  <= 0;
        end else if (rd_en && !empty) begin
            rdata <= mem[rd_ptr[ADDR-1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            count <= 0;
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

endmodule