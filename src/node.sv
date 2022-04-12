module node #(
    parameter WIDTH=32
) (
    input                 clk, 
    input                 rst_n,
    input   [WIDTH-1 : 0] data_in,
    input                 up_valid_in,     // from upstream node
    output                up_ready_out,    // to upstream node

    output  [WIDTH-1 : 0] data_out,
    output                dn_valid_out,    // to downstream node
    input                 dn_ready_in      // from downstream node
);
    // internal wire
    wire up_fire, dn_fire;

    // comb logic
    assign up_fire = up_ready_out & up_valid_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign dn_fire = dn_ready_in  & dn_valid_out;// handshake of this node to downstream fired, logic as a master/transmitter

    assign up_ready_out = dn_ready_in;// for actual usage, ready_out = ready_in & pending, pending is a logic dependent on nodes specific design
    assign dn_valid_out = up_valid_in;// for actual usage, valid_out = valid_in & pending, pending is a logic dependent on nodes specific design

    assign data_out = data_in;

endmodule