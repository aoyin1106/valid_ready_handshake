module node_async_valid #(
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
    // internal wire
    wire up_fire, down_fire;
    logic [WIDTH-1 : 0] data_reg;

    // comb logic
    assign up_fire   = ready_up_out  & valid_up_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign down_fire = ready_down_in & valid_down_out;// handshake of this node to downstream fired, logic as a master/transmitter
    assign ready_up_out   = ready_down_in;// for actual usage, ready_out = ready_in & pending, pending is a logic dependent on nodes specific design

    // assume valid is async, buffer it a cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            valid_down_out <= 0;
        else 
            valid_down_out <= valid_up_in;
    end

    // internal mem node
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            data_reg  <= 0;
        else if (up_fire)
            data_reg  <= data_in;
    end

    // output reg
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            data_out  <= 0;
        else if (down_fire)
            data_out  <= data_reg;
    end
endmodule