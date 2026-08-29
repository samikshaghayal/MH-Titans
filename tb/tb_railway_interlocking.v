`timescale 1ns / 1ps

module rail_hack_tb;

    // ============================================================
    // INPUT SIGNALS
    // ============================================================
    reg clk;
    reg reset;
    reg route_a_req;
    reg route_b_req;
    reg emergency_req;
    reg track_clear;

    // ============================================================
    // OUTPUT SIGNALS
    // ============================================================
    wire route_a_green;
    wire route_b_green;
    wire emergency_green;

    wire route_a_red;
    wire route_b_red;
    wire emergency_red;

    wire system_fault;
    wire fault_blink;


    // ============================================================
    // DUT - DEVICE UNDER TEST
    // ============================================================
    // IMPORTANT:
    // RTL module name = rail_hack
    //
    // SIM_MODE = 1
    // Delay    = 30 clock cycles
    // Watchdog = 100 clock cycles
    // ============================================================

    rail_hack #(
        .SIM_MODE(1)
    ) uut (
        .clk(clk),
        .reset(reset),

        .route_a_req(route_a_req),
        .route_b_req(route_b_req),
        .emergency_req(emergency_req),
        .track_clear(track_clear),

        .route_a_green(route_a_green),
        .route_b_green(route_b_green),
        .emergency_green(emergency_green),

        .route_a_red(route_a_red),
        .route_b_red(route_b_red),
        .emergency_red(emergency_red),

        .system_fault(system_fault),
        .fault_blink(fault_blink)
    );


    // ============================================================
    // 100 MHz CLOCK
    // Period = 10 ns
    // ============================================================

    always #5 clk = ~clk;


    // ============================================================
    // TEST SEQUENCE
    // ============================================================

    initial begin

        // ========================================================
        // INITIALIZATION
        // ========================================================

        clk = 1'b0;

        // Active-low reset
        reset = 1'b0;

        route_a_req   = 1'b0;
        route_b_req   = 1'b0;
        emergency_req = 1'b0;
        track_clear   = 1'b0;


        // ========================================================
        // MONITOR
        // ========================================================

        $display("");
        $display("==============================================================");
        $display("       RAILWAY INTERLOCKING SYSTEM SIMULATION");
        $display("==============================================================");
        $display("");

        $display("TIME\tA_G A_R B_G B_R E_G E_R FAULT BLINK");

        $monitor("%0t\t%b   %b   %b   %b   %b   %b   %b     %b",
                 $time,
                 route_a_green,
                 route_a_red,
                 route_b_green,
                 route_b_red,
                 emergency_green,
                 emergency_red,
                 system_fault,
                 fault_blink);


        // ========================================================
        // RESET
        // ========================================================

        #20;

        // Release active-low reset
        reset = 1'b1;

        #20;


        // ========================================================
        // TEST 1: IDLE STATE
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 1: IDLE STATE");
        $display("--------------------------------------------------------------");

        if ((route_a_green === 1'b0) &&
            (route_b_green === 1'b0) &&
            (emergency_green === 1'b0) &&
            (route_a_red === 1'b1) &&
            (route_b_red === 1'b1) &&
            (emergency_red === 1'b1) &&
            (system_fault === 1'b0)) begin

            $display("PASS: System is in safe IDLE state.");

        end
        else begin

            $display("FAIL: IDLE state outputs are incorrect.");

        end


        // ========================================================
        // TEST 2: ROUTE A REQUEST
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 2: ROUTE A REQUEST");
        $display("--------------------------------------------------------------");

        route_a_req = 1'b1;

        #20;

        // Release button
        route_a_req = 1'b0;

        #20;

        if (route_a_green === 1'b1 &&
            route_a_red === 1'b0) begin

            $display("PASS: Route A granted and locked.");

        end
        else begin

            $display("FAIL: Route A was not granted.");

        end


        // ========================================================
        // TEST 3: ROUTE A LOCK AFTER BUTTON RELEASE
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 3: ROUTE A LOCK");
        $display("--------------------------------------------------------------");

        #50;

        if (route_a_green === 1'b1) begin

            $display("PASS: Route A remained locked after request release.");

        end
        else begin

            $display("FAIL: Route A unlocked unexpectedly.");

        end


        // ========================================================
        // TEST 4: TRACK CLEAR
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 4: TRACK CLEAR");
        $display("--------------------------------------------------------------");

        track_clear = 1'b1;

        #10;

        track_clear = 1'b0;

        #20;

        if (route_a_green === 1'b0 &&
            route_a_red === 1'b1) begin

            $display("PASS: Route A released after track_clear.");

        end
        else begin

            $display("FAIL: Route A did not release.");

        end


        // ========================================================
        // TEST 5: ROUTE B REQUEST
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 5: ROUTE B REQUEST");
        $display("--------------------------------------------------------------");

        route_b_req = 1'b1;

        #20;

        route_b_req = 1'b0;

        #20;

        if (route_b_green === 1'b1 &&
            route_b_red === 1'b0) begin

            $display("PASS: Route B granted and locked.");

        end
        else begin

            $display("FAIL: Route B was not granted.");

        end


        // ========================================================
        // TEST 6: EMERGENCY PREEMPTION
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 6: EMERGENCY PREEMPTION");
        $display("--------------------------------------------------------------");

        emergency_req = 1'b1;

        #10;

        // Route B must become RED
        if (route_b_green === 1'b0) begin

            $display("PASS: Route B was forced RED by emergency request.");

        end
        else begin

            $display("FAIL: Route B remained GREEN during emergency.");

        end


        // Emergency must initially remain RED
        if (emergency_green === 1'b0) begin

            $display("PASS: Emergency remains RED during clearance delay.");

        end
        else begin

            $display("FAIL: Emergency became GREEN too early.");

        end


        // ========================================================
        // TEST 7: EMERGENCY CLEARANCE DELAY
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 7: EMERGENCY CLEARANCE DELAY");
        $display("--------------------------------------------------------------");

        // 30 cycles × 10 ns = 300 ns
        #310;

        if (emergency_green === 1'b1 &&
            emergency_red === 1'b0) begin

            $display("PASS: Emergency route became GREEN after delay.");

        end
        else begin

            $display("FAIL: Emergency route did not become GREEN.");

        end


        // ========================================================
        // TEST 8: EMERGENCY TRACK CLEAR
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 8: EMERGENCY TRACK CLEAR");
        $display("--------------------------------------------------------------");

        track_clear = 1'b1;

        #10;

        track_clear = 1'b0;
        emergency_req = 1'b0;

        #20;

        if (emergency_green === 1'b0 &&
            emergency_red === 1'b1) begin

            $display("PASS: Emergency route released correctly.");

        end
        else begin

            $display("FAIL: Emergency route did not release.");

        end


        // ========================================================
        // TEST 9: WATCHDOG TIMEOUT
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 9: WATCHDOG TIMEOUT");
        $display("--------------------------------------------------------------");

        // Request Route A
        route_a_req = 1'b1;

        #20;

        route_a_req = 1'b0;

        // Do NOT provide track_clear.
        // Simulate stalled train.

        // Watchdog = 100 cycles
        // 100 × 10 ns = 1000 ns

        #1100;


        if (system_fault === 1'b1) begin

            $display("PASS: Watchdog triggered SYSTEM_FAULT.");

        end
        else begin

            $display("FAIL: Watchdog did not trigger SYSTEM_FAULT.");

        end


        // ========================================================
        // TEST 10: FAULT STATE
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 10: FAULT STATE");
        $display("--------------------------------------------------------------");

        // Try to request Route B
        route_b_req = 1'b1;

        #30;

        route_b_req = 1'b0;

        if (system_fault === 1'b1) begin

            $display("PASS: FAULT state ignored new requests.");

        end
        else begin

            $display("FAIL: FAULT state responded to new request.");

        end


        // ========================================================
        // TEST 11: MANUAL RESET
        // ========================================================

        $display("");
        $display("--------------------------------------------------------------");
        $display("TEST 11: MANUAL RESET RECOVERY");
        $display("--------------------------------------------------------------");

        // Active-low reset
        reset = 1'b0;

        #20;

        // Release reset
        reset = 1'b1;

        #20;


        if ((system_fault === 1'b0) &&
            (route_a_green === 1'b0) &&
            (route_b_green === 1'b0) &&
            (emergency_green === 1'b0) &&
            (route_a_red === 1'b1) &&
            (route_b_red === 1'b1) &&
            (emergency_red === 1'b1)) begin

            $display("PASS: Manual reset cleared FAULT and returned to IDLE.");

        end
        else begin

            $display("FAIL: Manual reset did not recover system.");

        end


        // ========================================================
        // SIMULATION COMPLETE
        // ========================================================

        $display("");
        $display("==============================================================");
        $display("              ALL TESTS COMPLETED");
        $display("==============================================================");
        $display("");

        #20;

        $finish;

    end

endmodule
