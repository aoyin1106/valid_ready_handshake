module node_async_ready #(
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
    // internal logic
    wire up_fire, dn_fire;
    logic dn_ready_in_buf, up_valid_in_buf;
    logic [WIDTH-1 : 0] data_in_buf;

    // comb logic
    assign up_fire = up_ready_out & up_valid_in;  // handshake of upstream into this node fired, logic as a slave/receiver
    assign dn_fire = dn_ready_in  & dn_valid_out; // handshake of this node to downstream fired, logic as a master/transmitter

    assign up_ready_out = dn_ready_in_buf | (!dn_valid_out);      // for actual usage, ready_out = ready_in & pending, pending is a logic dependent on nodes specific design

    always_comb begin
        // special case: new ready low while old ready high
        // need to use the buffer as output 
        if (up_ready_out & !dn_ready_in) begin 
            dn_valid_out = up_valid_in_buf;
            data_out     = data_in_buf;
        end else begin
        // normal case, direct pass through
            dn_valid_out = up_valid_in_buf;
            data_out     = data_in_buf;
        end
    end

    // input ready buffer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dn_ready_in_buf <= 0;
        end else begin 
            dn_ready_in_buf <= dn_ready_in;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_buf      <= 0;
            up_valid_in_buf  <= 0;
        end else begin
            if (up_ready_out) begin
                data_un_buf      <= data_in;
                up_valid_in_buf  <= up_valid_in;
            end
        end
    end

endmodule