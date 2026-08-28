`timescale 1ns / 1ps

module railway_interlocking_tb;

    // 1. Declare testbench registers for inputs to DUT
    reg clk;
    reg reset;
    reg route_a_req;
    reg route_b_req;
    reg emergency_req;
    reg track_clear;

    // 2. Declare wires for outputs from DUT
    wire route_a_green;
    wire emergency_green;
    wire route_a_red;

    // 3. Instantiate the Device Under Test (DUT)
    railway_interlocking uut (
        .clk(clk),
        .reset(reset),
        .route_a_req(route_a_req),
        .route_b_req(route_b_req),
        .emergency_req(emergency_req),
        .track_clear(track_clear),
        .route_a_green(route_a_green),
        .emergency_green(emergency_green),
        .route_a_red(route_a_red)
    );

    // 4. Generate 100MHz clock signal (10ns period)
    always #5 clk = ~clk;

    // 5. Test stimulus sequence
    initial begin
        // Initialize all inputs
        clk = 0;
        reset = 1;
        route_a_req = 0;
        route_b_req = 0;
        emergency_req = 0;
        track_clear = 0;

        // Hold Reset active for 20ns
        #20;
        reset = 0;
        #10;

        // Test Case 1: Route A requested with track clear
        route_a_req = 1;
        track_clear = 1;
        #30;

        // Test Case 2: Route B requested
        route_a_req = 0;
        route_b_req = 1;
        #30;

        // Test Case 3: Emergency request override
        emergency_req = 1;
        #30;

        // Test Case 4: Clear all inputs
        emergency_req = 0;
        route_b_req = 0;
        track_clear = 0;
        #30;

        $stop; // Finish/Pause simulation
    end

endmodule
