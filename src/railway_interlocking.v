`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 28.08.2026 23:17:44
// Design Name:
// Module Name: rail_hack
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Railway Interlocking System
//
// Dependencies:
// Revision:
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////

module rail_hack #(
    parameter SIM_MODE = 0
)(
    input  clk,
    input reset,              // Active-Low reset

    input route_a_req,
    input route_b_req,
    input emergency_req,
    input track_clear,

    output reg route_a_green,
    output reg route_b_green,
    output reg emergency_green,

    output reg route_a_red,
    output reg route_b_red,
    output reg emergency_red,

    output reg system_fault,
    output reg fault_blink
);

    // ============================================================
    // ACTIVE-LOW RESET
    // reset = 0 -> RESET
    // reset = 1 -> NORMAL OPERATION
    // ============================================================

    wire rst_internal;

    assign rst_internal = ~reset;


    // ============================================================
    // CLOCK AND TIMING PARAMETERS
    // ============================================================

    localparam integer CLK_FREQ_HZ = 100_000_000;

    // Simulation timing
    // DELAY_CYCLES    = 30 cycles
    // WATCHDOG_CYCLES = 100 cycles
    // BLINK_CYCLES    = 10 cycles

    localparam integer DELAY_CYCLES =
                    SIM_MODE ? 30 : (CLK_FREQ_HZ * 3);

    localparam integer WATCHDOG_CYCLES =
                    SIM_MODE ? 100 : (CLK_FREQ_HZ * 10);

    localparam integer BLINK_CYCLES =
                    SIM_MODE ? 10 : (CLK_FREQ_HZ / 2);


    // ============================================================
    // FSM STATES
    // ============================================================

    localparam [2:0]
        IDLE             = 3'b000,
        ROUTE_A          = 3'b001,
        ROUTE_B          = 3'b010,
        EMERGENCY_DELAY  = 3'b011,
        EMERGENCY_ACTIVE = 3'b100,
        FAULT            = 3'b101;


    // ============================================================
    // FSM REGISTERS
    // ============================================================

    reg [2:0] state;
    reg [2:0] next_state;

    reg [31:0] timer_cnt;

    reg [31:0] blink_cnt;
    reg        blink_toggle;


    // ============================================================
    // BLINK GENERATOR
    // Used for FAULT indication
    // ============================================================

    always @(posedge clk or posedge rst_internal) begin

        if (rst_internal) begin

            blink_cnt    <= 32'd0;
            blink_toggle <= 1'b0;

        end

        else begin

            if (blink_cnt >= BLINK_CYCLES - 1) begin

                blink_cnt    <= 32'd0;
                blink_toggle <= ~blink_toggle;

            end

            else begin

                blink_cnt <= blink_cnt + 1'b1;

            end
        end
    end


    // ============================================================
    // STATE REGISTER + TIMER
    // ============================================================

    always @(posedge clk or posedge rst_internal) begin

        if (rst_internal) begin

            state     <= IDLE;
            timer_cnt <= 32'd0;

        end

        else begin

            state <= next_state;

            // Reset timer whenever FSM changes state
            if (next_state != state) begin

                timer_cnt <= 32'd0;

            end

            // Count while inside timed states
            else if ((state == EMERGENCY_DELAY) ||
                     (state == ROUTE_A) ||
                     (state == ROUTE_B) ||
                     (state == EMERGENCY_ACTIVE)) begin

                timer_cnt <= timer_cnt + 1'b1;

            end

            else begin

                timer_cnt <= 32'd0;

            end
        end
    end


    // ============================================================
    // NEXT STATE LOGIC
    // ============================================================

    always @(*) begin

        // Default: remain in current state
        next_state = state;

        case (state)

            // ====================================================
            // IDLE
            // ====================================================

            IDLE: begin

                // Emergency has highest priority
                if (emergency_req) begin

                    next_state = EMERGENCY_DELAY;

                end

                // Simultaneous normal route request
                else if (route_a_req && route_b_req) begin

                    next_state = FAULT;

                end

                // Route A request
                else if (route_a_req) begin

                    next_state = ROUTE_A;

                end

                // Route B request
                else if (route_b_req) begin

                    next_state = ROUTE_B;

                end
            end


            // ====================================================
            // ROUTE A
            // ====================================================

            ROUTE_A: begin

                // Emergency preemption
                if (emergency_req) begin

                    next_state = EMERGENCY_DELAY;

                end

                // Train has cleared track
                else if (track_clear) begin

                    next_state = IDLE;

                end

                // Watchdog timeout
                else if (timer_cnt >= WATCHDOG_CYCLES - 1) begin

                    next_state = FAULT;

                end
            end


            // ====================================================
            // ROUTE B
            // ====================================================

            ROUTE_B: begin

                // Emergency preemption
                if (emergency_req) begin

                    next_state = EMERGENCY_DELAY;

                end

                // Train has cleared track
                else if (track_clear) begin

                    next_state = IDLE;

                end

                // Watchdog timeout
                else if (timer_cnt >= WATCHDOG_CYCLES - 1) begin

                    next_state = FAULT;

                end
            end


            // ====================================================
            // EMERGENCY DELAY
            // All signals remain RED
            // ====================================================

            EMERGENCY_DELAY: begin

                // Emergency request cancelled
                if (!emergency_req) begin

                    next_state = IDLE;

                end

                // Clearance delay completed
                else if (timer_cnt >= DELAY_CYCLES - 1) begin

                    next_state = EMERGENCY_ACTIVE;

                end
            end


            // ====================================================
            // EMERGENCY ACTIVE
            // ====================================================

            EMERGENCY_ACTIVE: begin

                // Emergency train cleared
                if (track_clear || !emergency_req) begin

                    next_state = IDLE;

                end

                // Emergency watchdog timeout
                else if (timer_cnt >= WATCHDOG_CYCLES - 1) begin

                    next_state = FAULT;

                end
            end


            // ====================================================
            // FAULT
            // Latched state
            // ====================================================

            FAULT: begin

                // Remain in FAULT until reset
                next_state = FAULT;

            end


            // ====================================================
            // DEFAULT
            // ====================================================

            default: begin

                next_state = IDLE;

            end

        endcase
    end


    // ============================================================
    // OUTPUT LOGIC
    // MOORE FSM
    // ============================================================

    always @(*) begin

        // --------------------------------------------------------
        // SAFE DEFAULTS
        // --------------------------------------------------------

        route_a_green   = 1'b0;
        route_b_green   = 1'b0;
        emergency_green = 1'b0;

        route_a_red     = 1'b1;
        route_b_red     = 1'b1;
        emergency_red   = 1'b1;

        system_fault    = 1'b0;
        fault_blink     = 1'b0;


        // --------------------------------------------------------
        // STATE-DEPENDENT OUTPUTS
        // --------------------------------------------------------

        case (state)

            // ====================================================
            // IDLE
            // ====================================================

            IDLE: begin

                // All signals remain RED
                // Safe condition

            end


            // ====================================================
            // ROUTE A ACTIVE
            // ====================================================

            ROUTE_A: begin

                route_a_green = 1'b1;
                route_a_red   = 1'b0;

            end


            // ====================================================
            // ROUTE B ACTIVE
            // ====================================================

            ROUTE_B: begin

                route_b_green = 1'b1;
                route_b_red   = 1'b0;

            end


            // ====================================================
            // EMERGENCY DELAY
            // ====================================================

            EMERGENCY_DELAY: begin

                // All RED during safety clearance delay

            end


            // ====================================================
            // EMERGENCY ACTIVE
            // ====================================================

            EMERGENCY_ACTIVE: begin

                emergency_green = 1'b1;
                emergency_red   = 1'b0;

            end


            // ====================================================
            // FAULT
            // ====================================================

            FAULT: begin

                system_fault = 1'b1;
                fault_blink  = blink_toggle;

                // Blink red LEDs
                route_a_red   = blink_toggle;
                route_b_red   = blink_toggle;
                emergency_red = blink_toggle;

            end


            // ====================================================
            // DEFAULT
            // ====================================================

            default: begin

                // Safe all-RED condition

            end

        endcase
    end

endmodule
