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

    //node#(.WIDTH(WIDTH)) master(
    //node_async_valid#(.WIDTH(WIDTH)) master(
    //node_async_ready#(.WIDTH(WIDTH)) master(
    node_async_validready#(.WIDTH(WIDTH)) master(
                            //input 
                            .clk(clk), 
                            .rst_n(rst_n),
                            .data_in(tb_master_data),
                            .valid_up_in(tb_master_valid), 
                            .ready_down_in(slave_master_ready),
                            //output
                            .data_out(master_slave_data),
                            .valid_down_out(master_slave_valid),
                            .ready_up_out(master_tb_ready)
                        );

    node#(.WIDTH(WIDTH)) slave(
                            //input 
                            .clk(clk), 
                            .rst_n(rst_n),
                            .data_in(master_slave_data),
                            .valid_up_in(master_slave_valid), 
                            .ready_down_in(tb_slave_ready),
                            //output
                            .data_out(slave_tb_data),
                            .valid_down_out(slave_tb_valid),
                            .ready_up_out(slave_master_ready)
                        );

    always #(PERIOD/2) clk = ~clk;

    integer i,j;

    initial begin
        #1
        $dumpfile("wave.vcd");
		$dumpvars;
        clk             = 1'b1;
        rst_n           = 1'b0;
        tb_slave_ready  = 1'b0;
        tb_master_valid = 1'b0;

        repeat (10) @(negedge clk);
        rst_n           = 1'b1;
        tb_slave_ready  = 1'b1;
        tb_master_valid = 1'b1;
        tb_master_data  = 0;

        //TODO: task for vld-invalid-valid pattern

        for (i=0; i<20; i=i+1) begin
            @(negedge clk);
            tb_master_valid = ~tb_master_valid;
            tb_master_data  = tb_master_data + 1;
        end

        //TODO: task for sequential pattern
        tb_master_valid = 1;
        for (i=0; i<20; i=i+1) begin
            @(negedge clk);
            tb_master_data  = tb_master_data + 1;
        end

        repeat (10) @(negedge clk);
        $display("Simulation Finish");
        $finish();
    end
    
endmodule