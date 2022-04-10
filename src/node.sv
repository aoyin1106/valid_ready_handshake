module node #(
    parameter WIDTH=32
) (
    input                      clk, 
    input                      rst_n,
    input        [WIDTH-1 : 0] data_in,
    input                      valid_up_in,   // from upstream node
    input                      ready_down_in, // from downstream node

    output wire  [WIDTH-1 : 0] data_out,
    output wire                valid_down_out,// to downstream node
    output wire                ready_up_out   // to upstream node
);
    // internal wire
    wire up_fire, down_fire;
    logic [WIDTH-1 : 0] data_reg;

    // comb logic
    assign up_fire   = ready_up_out  & valid_up_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign down_fire = ready_down_in & valid_down_out;// handshake of this node to downstream fired, logic as a master/transmitter

    assign ready_up_out   = ready_down_in;// for actual usage, ready_out = ready_in & pending, pending is a logic dependent on nodes specific design
    assign valid_down_out = valid_up_in;// for actual usage, valid_out = valid_in & pending, pending is a logic dependent on nodes specific design

    assign data_out = data_in;

endmodule