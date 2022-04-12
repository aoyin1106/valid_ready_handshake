module node_async_valid #(
    parameter WIDTH=32
) (
    input                      clk, 
    input                      rst_n,
    input        [WIDTH-1 : 0] data_in,
    input                      up_valid_in,     // from upstream node
    output                     up_ready_out,    // to upstream node

    output logic [WIDTH-1 : 0] data_out,
    output                     dn_valid_out,    // to downstream node
    input                      dn_ready_in      // from downstream node
);
    // internal wire
    wire up_fire, dn_fire;
    logic up_valid_in_buf;

    // comb logic
    assign up_fire = up_ready_out & up_valid_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign dn_fire = dn_ready_in  & dn_valid_out;  // handshake of this node to downstream fired, logic as a master/transmitter

    assign up_ready_out = dn_ready_in | (~dn_valid_out);
    assign dn_valid_out = up_valid_in_buf;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out         <= 0;
            up_valid_in_buf  <= 0;
        end else begin
            if (up_ready_out) begin
                data_out         <= data_in;
                up_valid_in_buf  <= up_valid_in;
            end
        end
    end

endmodule