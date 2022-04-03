module node #(
    parameter WIDTH=32
) (
    input                      clk, 
    input                      rst_n,
    input        [WIDTH-1 : 0] data_in,
    input                      valid_up_in,   // from upstream node
    input                      ready_down_in, // from downstream node

    output logic [WIDTH-1 : 0] data_out,
    output logic               valid_down_out,// to downstream node
    output logic               ready_up_out   // to upstream node
);
    // internal logic
    wire up_fire, down_fire;
    logic [WIDTH-1 : 0] data_reg, data_buf;

    // comb logic
    assign up_fire   = ready_up_out  & valid_up_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign down_fire = ready_down_in & valid_down_out;// handshake of this node to downstream fired, logic as a master/transmitter

    // assume ready&valid input are async, buffer it a cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_up_out   <= 0;
            valid_down_out <= 0;
        end else begin 
            ready_up_out   <= ready_down_in;
            valid_down_out <= valid_up_in;
        end
    end

    // internal mem node, logic as a slave/receiver
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_buf  <= 0;
            data_reg  <= 0;
        end else begin 
            data_buf  <= data_in;
            if (up_fire)
                data_reg  <= data_buf;
        end
    end

    // output reg, logic as a master/transmitter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            data_out  <= 0;
        else if (down_fire)
            data_out  <= data_reg;
    end

endmodule