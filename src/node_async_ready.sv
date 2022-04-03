module node_async_ready #(
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
    logic ready_down_buf;
    logic [WIDTH-1 : 0] data_reg, data_out_buf;

    // comb logic
    assign up_fire   = ready_up_out   & valid_up_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign down_fire = ready_down_buf & valid_down_out;// handshake of this node to downstream fired, logic as a master/transmitter
    assign ready_up_out   = ready_down_buf;// for actual usage, ready_out = ready_in & pending, pending is a logic dependent on nodes specific design
    assign valid_down_out = valid_up_in;  // for actual usage, valid_out = valid_in & pending, pending is a logic dependent on nodes specific design

    // assume ready input is async, buffer it a cycle
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready_down_buf   <= 0;
        end else begin 
            ready_down_buf   <= ready_down_in;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out_buf  <= 0;
            data_reg      <= 0;
            data_out      <= 0;
        end else begin 
            data_out_buf  <= data_reg;
            if (up_fire)
                data_reg  <= data_in;
            if (down_fire)
                data_out  <= data_out_buf;
        end
    end

endmodule