module node_async_validready #(
    parameter WIDTH=32
) (
    input                      clk, 
    input                      rst_n,
    input        [WIDTH-1 : 0] data_in,
    input                      up_valid_in,     // from upstream node
    output logic               up_ready_out,    // to upstream node

    output logic [WIDTH-1 : 0] data_out,
    output logic               dn_valid_out,    // to downstream node
    input                      dn_ready_in      // from downstream node
);
    // internal logic
    wire up_fire, dn_fire;
    logic dn_ready_in_buf, up_valid_in_buf;
    logic [WIDTH-1 : 0] data_in_buf, data_out_buf;

    // comb logic
    assign up_fire = up_ready_out & up_valid_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign dn_fire = dn_ready_in  & dn_valid_out;  // handshake of this node to downstream fired, logic as a master/transmitter
    
    assign up_ready_out = dn_ready_in_buf;  // ready propagate has one latency, causing one accepted input in flight
    // assign dn_valid_out = up_valid_in_buf;  // valid propagate has one latency, data must keep phase with valid

    // input ready buffer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dn_ready_in_buf <= 0;
        end else begin 
            dn_ready_in_buf <= dn_ready_in;
        end
    end

    // stage 0 register
    // data_in_buf and up_valid_in_buf matches in phase
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_buf     <= 0;
            up_valid_in_buf <= 0;
        end else begin 
            if (up_fire) begin
                data_in_buf     <= data_in;
                up_valid_in_buf <= up_valid_in;
            end else begin
                data_in_buf     <= 0;
                up_valid_in_buf <= 0;
            end
        end
    end

    // stage 1 register
    // data_out and dn_valid_out matches in phase
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out     <= 0;
            dn_valid_out <= 0;
        end else begin
            // update value if (1) previous stage is invalid, keep feteching 
            // or (2) downstream handshake fired, can fetch new value
            if (dn_fire | (!dn_valid_out)) begin
                data_out     <= data_in_buf;
                dn_valid_out <= up_valid_in_buf;
            end
        end
    end

endmodule