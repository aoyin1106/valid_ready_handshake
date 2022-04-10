module node_async_valid #(
    parameter WIDTH=32
) (
    input                clk, 
    input                rst_n,
    input  [WIDTH-1 : 0] data_in,
    input                valid_up_in,   // from upstream node
    input                ready_down_in, // from downstream node

    output [WIDTH-1 : 0] data_out,
    output               valid_down_out, // to downstream node
    output               ready_up_out    // to upstream node
);
    // internal wire
    wire up_fire, down_fire;
    logic valid_up_in_buf, ready_up_out_buf;
    logic [WIDTH-1 : 0] data_reg;

    // comb logic
    assign up_fire   = ready_up_out_buf & valid_up_in_buf;// handshake of upstream into this node fired, logic as a slave/receiver
    assign down_fire = ready_down_in    & valid_down_out; // handshake of this node to downstream fired, logic as a master/transmitter
    assign ready_up_out   = ready_down_in;
    assign valid_down_out = valid_up_in_buf;

    assign data_out = data_reg;

    // buffer valid_up and ready_up to ensure their phase match, so that up_fire is correct
    // if do not need correct up_fire, then do not need to buffer ready_up_out
    // usage of up_fire: func(data_reg) valid when up_fire high
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_up_in_buf  <= 0;
            ready_up_out_buf <= 0;
        end else begin 
            valid_up_in_buf  <= valid_up_in;
            ready_up_out_buf <= ready_up_out;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= 0;
        end else begin 
            data_reg <= data_in;
        end
    end

endmodule