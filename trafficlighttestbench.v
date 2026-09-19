// Simple self-checking testbench for traffic_light_fsm
`timescale 1ns/1ps

module testbench;

    reg        clk;
    reg        rst;
    reg        ped_req;
    wire [1:0] ns_light;
    wire [1:0] ew_light;
    wire       ped_walk;

    integer errors = 0;
    integer i;

    traffic_light_fsm dut (
        .clk(clk), .rst(rst), .ped_req(ped_req),
        .ns_light(ns_light), .ew_light(ew_light), .ped_walk(ped_walk)
    );

    // Clock: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, testbench);
    end

    // Check that lights are never unsafe: no both-green, no walk unless both red
    always @(posedge clk) begin
        if (!rst) begin
            if (ns_light == 2'b10 && ew_light == 2'b10) begin
                $display("FAIL @%0t: both directions green!", $time);
                errors = errors + 1;
            end
            if (ped_walk && (ns_light != 2'b00 || ew_light != 2'b00)) begin
                $display("FAIL @%0t: ped_walk on while a vehicle light isn't red", $time);
                errors = errors + 1;
            end
        end
    end

    initial begin
        rst = 1;
        ped_req = 0;
        @(posedge clk);
        @(posedge clk);
        rst = 0;

        // check initial state after reset
        if (ns_light !== 2'b10 || ew_light !== 2'b00) begin
            $display("FAIL: expected NS_GREEN right after reset");
            errors = errors + 1;
        end else begin
            $display("PASS: NS_GREEN correct right after reset");
        end

        // Run one full normal cycle (8+3+8+3 = 22 cycles), no ped request
        for (i = 0; i < 22; i = i + 1) @(posedge clk);
        $display("PASS: completed one full normal cycle with no errors so far (errors=%0d)", errors);

        // Press the pedestrian button for one cycle
        @(posedge clk);
        ped_req = 1;
        @(posedge clk);
        ped_req = 0;
        $display("---- pedestrian request sent ----");

        // Wait long enough to pass NS_YELLOW+EW_GREEN+EW_YELLOW and reach PED_WALK
        for (i = 0; i < 22; i = i + 1) @(posedge clk);

        if (ped_walk !== 1'b1) begin
            $display("FAIL: expected ped_walk to be asserted by now");
            errors = errors + 1;
        end else begin
            $display("PASS: ped_walk correctly asserted after request");
        end

        // Wait through PED_WALK and confirm normal cycling resumes
        for (i = 0; i < 6; i = i + 1) @(posedge clk);

        if (ns_light !== 2'b10) begin
            $display("FAIL: expected NS_GREEN after PED_WALK finished");
            errors = errors + 1;
        end else begin
            $display("PASS: returned to NS_GREEN after PED_WALK");
        end

        $display("=====================================");
        if (errors == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: TESTS FAILED (errors=%0d)", errors);
        $display("=====================================");
        $finish;
    end

endmodule
