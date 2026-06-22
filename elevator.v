`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company      : SVNIT
// Engineer     : Vishal Shiyal
//
// Design Name  : 7-Floor Elevator Controller
// Module Name  : elevator_7
// Target Device: Basys 3 FPGA
//
// Description:
// FSM-based 7-floor elevator controller implemented in Verilog HDL.
//
// Features:
//   - Supports floor movement from Floor 0 to Floor 7
//   - Internal floor selection
//   - External floor call request
//   - Door open and close control
//   - Emergency return-to-ground-floor operation
//   - Current floor display on 7-segment display
//
//////////////////////////////////////////////////////////////////////////////////

module elevator_7(
    input  [2:0] open_out,        // External floor request
    input  [2:0] floor_number,    // Internal floor selection
    input        emergency,
    input        clk,

    output reg motor_up,
    output reg motor_down,
    output reg motor_stop,
    output reg motor_door_open,
    output reg motor_door_close,

    // Seven-segment display outputs
    output reg [6:0] seg,
    output reg [3:0] an,
    output           dp
);

    // Decimal point OFF
    assign dp = 1'b1;

    //----------------------------------------------------------------------
    // Internal Registers
    //----------------------------------------------------------------------

    reg [2:0] current_floor;
    reg [2:0] state;

    reg [2:0] delay_count;
    reg [2:0] delay_count_move;
    reg [2:0] delay_count_door;

    reg target_set;

    //----------------------------------------------------------------------
    // State Encoding
    //----------------------------------------------------------------------

    localparam IDLE       = 3'b000;
    localparam MOVE_UP    = 3'b001;
    localparam MOVE_DOWN  = 3'b010;
    localparam DOOR_OPEN  = 3'b011;
    localparam DOOR_CLOSE = 3'b100;

    //----------------------------------------------------------------------
    // Initial Conditions
    //----------------------------------------------------------------------

    initial begin
        current_floor    = 3'b000;
        state            = IDLE;

        delay_count_move = 3;
        delay_count_door = 1;

        target_set       = 1'b1;

        motor_up         = 1'b0;
        motor_down       = 1'b0;
        motor_stop       = 1'b1;
        motor_door_open  = 1'b0;
        motor_door_close = 1'b0;
    end

    //----------------------------------------------------------------------
    // Main Elevator Controller
    //----------------------------------------------------------------------

    always @(posedge clk) begin

        // Determine initial movement direction
        if (target_set) begin

            if (floor_number > current_floor) begin
                state       <= MOVE_UP;
                delay_count <= delay_count_move;
            end
            else if (floor_number < current_floor) begin
                state       <= MOVE_DOWN;
                delay_count <= delay_count_move;
            end
            else begin
                state       <= DOOR_OPEN;
                delay_count <= delay_count_door;
            end

            target_set <= 1'b0;
        end

        //------------------------------------------------------------------
        // Emergency Mode
        // Elevator returns to ground floor and opens the door
        //------------------------------------------------------------------

        if (emergency) begin

            motor_up         <= 1'b0;
            motor_door_open  <= 1'b0;

            if (current_floor > 3'b000) begin

                current_floor    <= current_floor - 1'b1;

                motor_down       <= 1'b1;
                motor_door_close <= 1'b1;
                motor_stop       <= 1'b0;

            end
            else begin

                current_floor    <= 3'b000;

                motor_down       <= 1'b0;
                motor_door_close <= 1'b0;
                motor_door_open  <= 1'b1;
                motor_stop       <= 1'b1;
            end
        end

        //------------------------------------------------------------------
        // Normal FSM Operation
        //------------------------------------------------------------------

        else begin

            case (state)

                //----------------------------------------------------------
                // IDLE State
                //----------------------------------------------------------

                IDLE: begin

                    motor_up         <= 1'b0;
                    motor_down       <= 1'b0;
                    motor_stop       <= 1'b1;
                    motor_door_open  <= 1'b0;
                    motor_door_close <= 1'b0;

                    if (floor_number != current_floor)
                        target_set <= 1'b1;
                end

                //----------------------------------------------------------
                // Move Up State
                //----------------------------------------------------------

                MOVE_UP: begin

                    motor_up         <= 1'b1;
                    motor_down       <= 1'b0;
                    motor_stop       <= 1'b0;
                    motor_door_open  <= 1'b0;
                    motor_door_close <= 1'b1;

                    if (delay_count > 0 && current_floor < 3'b111) begin

                        delay_count <= delay_count - 1'b1;

                    end
                    else begin

                        delay_count  <= delay_count_move;
                        current_floor <= current_floor + 1'b1;

                        if ((current_floor + 1'b1) == open_out ||
                            (current_floor + 1'b1) == floor_number) begin

                            state       <= DOOR_OPEN;
                            delay_count <= delay_count_door;
                        end
                    end
                end

                //----------------------------------------------------------
                // Move Down State
                //----------------------------------------------------------

                MOVE_DOWN: begin

                    motor_up         <= 1'b0;
                    motor_down       <= 1'b1;
                    motor_stop       <= 1'b0;
                    motor_door_open  <= 1'b0;
                    motor_door_close <= 1'b0;

                    if (delay_count > 0 && current_floor > 3'b000) begin

                        delay_count <= delay_count - 1'b1;

                    end
                    else begin

                        current_floor <= current_floor - 1'b1;
                        delay_count   <= delay_count_move;

                        if ((current_floor - 1'b1) == open_out ||
                            (current_floor - 1'b1) == floor_number) begin

                            state       <= DOOR_OPEN;
                            delay_count <= delay_count_door;
                        end
                    end
                end

                //----------------------------------------------------------
                // Door Open State
                //----------------------------------------------------------

                DOOR_OPEN: begin

                    motor_up         <= 1'b0;
                    motor_down       <= 1'b0;
                    motor_stop       <= 1'b1;
                    motor_door_open  <= 1'b1;
                    motor_door_close <= 1'b0;

                    if (delay_count > 0) begin

                        delay_count <= delay_count - 1'b1;

                    end
                    else begin

                        motor_door_open <= 1'b0;

                        state       <= DOOR_CLOSE;
                        delay_count <= delay_count_door;
                    end
                end

                //----------------------------------------------------------
                // Door Close State
                //----------------------------------------------------------

                DOOR_CLOSE: begin

                    motor_up         <= 1'b0;
                    motor_down       <= 1'b0;
                    motor_stop       <= 1'b1;
                    motor_door_close <= 1'b1;
                    motor_door_open  <= 1'b0;

                    if (delay_count > 0) begin

                        delay_count <= delay_count - 1'b1;

                    end
                    else begin

                        motor_door_close <= 1'b0;

                        if (floor_number == current_floor) begin

                            state <= IDLE;

                        end
                        else if (floor_number > current_floor) begin

                            state       <= MOVE_UP;
                            delay_count <= delay_count_move;

                        end
                        else begin

                            state       <= MOVE_DOWN;
                            delay_count <= delay_count_move;

                        end
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

    //----------------------------------------------------------------------
    // Seven-Segment Display Logic
    // Displays Current Floor Number
    //----------------------------------------------------------------------

    always @(*) begin

        an = 4'b1110;      // Enable first display digit

        case (current_floor)

            3'b000: seg = 7'b1000000; // 0
            3'b001: seg = 7'b1111001; // 1
            3'b010: seg = 7'b0100100; // 2
            3'b011: seg = 7'b0110000; // 3
            3'b100: seg = 7'b0011001; // 4
            3'b101: seg = 7'b0010010; // 5
            3'b110: seg = 7'b0000010; // 6
            3'b111: seg = 7'b1111000; // 7

            default: seg = 7'b1111111;

        endcase
    end

endmodule

