module testbench;

    parameter WIDTH=32;
    parameter PERIOD=20;

    logic clk, rst_n;
    // tb - master wire
    logic [WIDTH-1 : 0]  tb_master_data;
    logic                tb_master_valid;
    logic                master_tb_ready;
    // master - slave logic
    logic [WIDTH-1 : 0]  master_slave_data;
    logic                master_slave_valid;
    logic                slave_master_ready;
    // slave - tb logic
    logic [WIDTH-1 : 0]  slave_tb_data;
    logic                slave_tb_valid;
    logic                tb_slave_ready;
    //other
    wire in_fire  = tb_master_valid & master_tb_ready;
    wire out_fire = slave_tb_valid  & tb_slave_ready;

    //node#(.WIDTH(WIDTH)) master(
    //node_async_valid#(.WIDTH(WIDTH)) master(
    //node_async_ready#(.WIDTH(WIDTH)) master(
    node_async_validready#(.WIDTH(WIDTH)) master(
                            //input 
                            .clk(clk), 
                            .rst_n(rst_n),
                            .data_in(tb_master_data),
                            .up_valid_in(tb_master_valid), 
                            .up_ready_out(master_tb_ready),
                            //output
                            .data_out(master_slave_data),
                            .dn_valid_out(master_slave_valid),
                            .dn_ready_in(slave_master_ready)
                        );

    //node#(.WIDTH(WIDTH)) slave(
    //node_async_valid#(.WIDTH(WIDTH)) slave(
    //node_async_ready#(.WIDTH(WIDTH)) slave(
    node_async_validready#(.WIDTH(WIDTH)) slave(
                            //input 
                            .clk(clk), 
                            .rst_n(rst_n),
                            .data_in(master_slave_data),
                            .up_valid_in(master_slave_valid), 
                            .up_ready_out(slave_master_ready),
                            //output
                            .data_out(slave_tb_data),
                            .dn_valid_out(slave_tb_valid),
                            .dn_ready_in(tb_slave_ready)
                        );

    always #(PERIOD/2) clk = ~clk;

    integer i,j;

    task send_value;
        input [WIDTH-1 : 0] value_in;
        begin
            @(negedge clk);
            tb_master_valid = 1'b1;
            tb_master_data  = value_in;
            #1
            while (!in_fire) begin
                $display("waiting for send %d", tb_master_data);
                @(negedge clk);
            end
        end
    endtask

    initial begin
        #1
        $dumpfile("wave.vcd");
		$dumpvars;
        clk             = 1'b1;
        rst_n           = 1'b0;
        tb_slave_ready  = 1'b0;
        tb_master_valid = 1'b0;
        $display("Simulation Start");

        repeat (10) @(negedge clk);
        rst_n           = 1'b1;
        tb_slave_ready  = 1'b1;
        tb_master_valid = 1'b1;
        tb_master_data  = 0;

        for (i=0; i<16; i=i+1) begin
            send_value(i);
        end

        @(negedge clk);
        tb_master_valid = 1'b0;
        @(posedge clk);
        tb_slave_ready  = 1'b0;

        @(negedge clk);
        tb_master_valid = 1'b1;
        tb_master_data  = 16;
        repeat (3) @(negedge clk);
        @(posedge clk);
        tb_slave_ready  = 1'b1;

        for (i=0; i<16; i=i+1) begin
            @(negedge clk);
            tb_master_valid = 1'b0;
            send_value(i + 17);
        end

        @(negedge clk);
        tb_master_valid = 1'b0;

        repeat (10) @(negedge clk);
        $display("Simulation Finish");
        $finish();
    end
    
endmodule