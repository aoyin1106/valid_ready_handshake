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
    logic dn_ready_in_buf;
    logic up_valid_in_buf [1:0];
    logic [WIDTH-1 : 0] data_in_buf [1:0];

    // comb logic
    assign up_fire = up_ready_out & up_valid_in;   // handshake of upstream into this node fired, logic as a slave/receiver
    assign dn_fire = dn_ready_in  & dn_valid_out;  // handshake of this node to downstream fired, logic as a master/transmitter
    
    assign up_ready_out = dn_ready_in_buf;  // ready propagate has one latency, causing one accepted input in flight

    always_comb begin
        // normal case, behave same as node_async_valid
        dn_valid_out = up_valid_in_buf[0];
        data_out     = data_in_buf[0];
        // corner case, behace like async_ready
        if (!up_ready_out) begin
            dn_valid_out = up_valid_in_buf[1];
            data_out     = data_in_buf[1];
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

    // data valid pair buffer
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_in_buf     <= {0,0};
            up_valid_in_buf <= {0,0};
        end else begin 
            if (up_ready_out) begin
                data_in_buf     <= {data_in_buf[0], data_in};
                up_valid_in_buf <= {up_valid_in_buf[0], up_valid_in};
            end 
        end
    end

endmodule