`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company      : SVNIT
// Engineer     : Vishal Shiyal
//
// Module Name  : elevator_tb
// Description  : Testbench for 7-Floor Elevator Controller
//
// Test Cases:
//   1. Move elevator from Floor 0 to Floor 7
//   2. Stop at Floor 3 using external call request
//   3. Move to Floor 4
//   4. Trigger emergency mode and return to ground floor
//
//////////////////////////////////////////////////////////////////////////////////

module elevator_tb;

    //----------------------------------------------------------------------
    // Inputs
    //----------------------------------------------------------------------

    reg  [2:0] open_out;
    reg  [2:0] floor_number;
    reg        emergency;
    reg        clk;

    //----------------------------------------------------------------------
    // Outputs
    //----------------------------------------------------------------------

    wire motor_up;
    wire motor_down;
    wire motor_stop;

    wire motor_door_open;
    wire motor_door_close;

    //----------------------------------------------------------------------
    // Unit Under Test (UUT)
    //----------------------------------------------------------------------

    elevator_7 uut1 (
        .open_out       (open_out),
        .floor_number   (floor_number),
        .emergency      (emergency),
        .clk            (clk),

        .motor_up       (motor_up),
        .motor_down     (motor_down),
        .motor_stop     (motor_stop),

        .motor_door_open(motor_door_open),
        .motor_door_close(motor_door_close)
    );

    //----------------------------------------------------------------------
    // Clock Generation
    // Clock Period = 10 ns
    //----------------------------------------------------------------------

    always #5 clk = ~clk;

    //----------------------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------------------

    initial begin

        // Initialize Inputs
        clk          = 1'b0;
        open_out     = 3'b000;
        floor_number = 3'b000;
        emergency    = 1'b0;

        //--------------------------------------------------------------
        // Test Case 1:
        // Request Floor 7 with an external stop at Floor 3
        //--------------------------------------------------------------

        #10;
        floor_number = 3'b111;
        open_out     = 3'b011;

        //--------------------------------------------------------------
        // Test Case 2:
        // Request Floor 4
        //--------------------------------------------------------------

        #700;
        floor_number = 3'b100;

        //--------------------------------------------------------------
        // Test Case 3:
        // Activate Emergency Mode
        //--------------------------------------------------------------

        #500;
        emergency = 1'b1;

        //--------------------------------------------------------------
        // End Simulation
        //--------------------------------------------------------------

        #3000;
        $finish;

    end

endmodule
