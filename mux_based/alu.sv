`timescale 1ns / 1ps

module alu(
    input  wire       clk, 
    input  wire       rst,       // Active-high asynchronous reset
    input  wire [7:0] operand1,  // Input A
    input  wire [7:0] operand2,  // Input B
    input  wire       c_i,       // External Carry-in (Required for ADDC)
    input  wire [3:0] operator,  // Instruction Opcode
    output reg        c_o,       // Carry-out (High for overflows in Addition)
    output reg        b_o,       // Borrow-out (High when A < B in Subtraction)
    output reg  [7:0] finalOutput
);

    reg [8:0] result; // 9-bit register to capture Carry/Borrow bit at index [8]
    reg carry;
    reg borrow;

    // Instruction Encoding (4-bit Binary)
    localparam OP_ADD  = 4'b0000;
    localparam OP_ADDC = 4'b0001;
    localparam OP_SUB  = 4'b0010; // Result = A - B
    localparam OP_SUBR = 4'b0011; // Result = B - A
    localparam OP_XOR  = 4'b0100; // Bitwise XOR
    localparam OP_XNOR = 4'b0101; // Bitwise XNOR

    // Combinational Logic: Operation selection via Multiplexer
    always @(*) begin
        // Default assignments to prevent unintended latches
        result = 9'd0;
        carry  = 1'b0;
        borrow = 1'b0;

        case(operator)
            OP_ADD: begin
                // Concatenate with 0 to detect overflow in the 9th bit
                result = {1'b0, operand1} + {1'b0, operand2};
                carry  = result[8];
            end
            
            OP_ADDC: begin
                // Addition with external Carry-in
                result = {1'b0, operand1} + {1'b0, operand2} + c_i;
                carry  = result[8];
            end
            
            OP_SUB: begin
                // Standard subtraction: A - B
                // result[8] = 1 indicates a borrow occurred (negative result)
                result = {1'b0, operand1} - {1'b0, operand2};
                borrow = result[8]; 
            end
            
            OP_SUBR: begin
                // Reverse subtraction: B - A
                result = {1'b0, operand2} - {1'b0, operand1};
                borrow = result[8]; 
            end
            
            OP_XOR: begin
                result = {1'b0, operand1 ^ operand2};
                // Logic operations do not affect carry/borrow
            end
            
            OP_XNOR: begin
                result = {1'b0, ~(operand1 ^ operand2)};
            end
            
            default: begin
                result = 9'd0;
                carry  = 1'b0;
                borrow = 1'b0;
            end
        endcase
    end

    // Sequential Logic: Registering outputs on clock edge
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            c_o         <= 1'b0;
            b_o         <= 1'b0;
            finalOutput <= 8'd0;
        end
        else begin
            // Synchronize internal combinational results to output registers
            c_o         <= carry;
            b_o         <= borrow;
            finalOutput <= result[7:0];
        end
    end

endmodule
