
`timescale 1ns / 1ps
module railway_interlocking (
    input  clk,
    input  reset,
    input  route_a_req,
    input  route_b_req,
    input  emergency_req,
    input  track_clear,

    output reg route_a_green,
    output reg emergency_green,
    output reg route_a_red,
    output reg route_b_red,
    output reg emergency_red,
    output reg system_fault,
    output reg fault_blink,
    output reg route_b_green
);

    // Route states
    localparam IDLE = 2'b00;
    localparam ROUTE_A = 2'b01;
    localparam ROUTE_B = 2'b10;
    localparam FAULT = 2'b11;

    reg [1:0] state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else begin

            // Emergency has highest priority
            if (emergency_req)
                state <= FAULT;

            else begin
                case (state)

                    IDLE: begin
                        // Both routes requested = conflict
                        if (route_a_req && route_b_req)
                            state <= FAULT;

                        else if (route_a_req && track_clear)
                            state <= ROUTE_A;

                        else if (route_b_req && track_clear)
                            state <= ROUTE_B;

                        else
                            state <= IDLE;
                    end

                    ROUTE_A: begin
                        // Release Route A
                        if (!route_a_req)
                            state <= IDLE;

                        // New conflicting request
                        else if (route_b_req)
                            state <= FAULT;

                        else
                            state <= ROUTE_A;
                    end

                    ROUTE_B: begin
                        // Release Route B
                        if (!route_b_req)
                            state <= IDLE;

                        // New conflicting request
                        else if (route_a_req)
                            state <= FAULT;

                        else
                            state <= ROUTE_B;
                    end

                    FAULT: begin
                        // Stay in fault until all requests are removed
                        if (!emergency_req &&
                            !route_a_req &&
                            !route_b_req)
                            state <= IDLE;
                        else
                            state <= FAULT;
                    end

                    default:
                        state <= IDLE;

                endcase
            end
        end
    end

    // Output logic
    always @(*) begin

        // Default outputs
        route_a_green = 1'b0;
        route_b_green = 1'b0;

        route_a_red = 1'b1;
        route_b_red = 1'b1;

        emergency_green = 1'b0;
        emergency_red = 1'b1;

        system_fault = 1'b0;
        fault_blink = 1'b0;

        case (state)

            IDLE: begin
                route_a_red = 1'b1;
                route_b_red = 1'b1;
            end

            ROUTE_A: begin
                route_a_green = 1'b1;
                route_a_red = 1'b0;

                route_b_red = 1'b1;
            end

            ROUTE_B: begin
                route_b_green = 1'b1;
                route_b_red = 1'b0;

                route_a_red = 1'b1;
            end

            FAULT: begin
                route_a_red = 1'b1;
                route_b_red = 1'b1;

                emergency_red = 1'b1;
                system_fault = 1'b1;
                fault_blink = 1'b1;
            end

        endcase

        // Emergency overrides everything
        if (emergency_req) begin
            route_a_green = 1'b0;
            route_b_green = 1'b0;

            route_a_red = 1'b1;
            route_b_red = 1'b1;

            emergency_green = 1'b0;
            emergency_red = 1'b1;

            system_fault = 1'b1;
            fault_blink = 1'b1;
        end
    end

endmodule
