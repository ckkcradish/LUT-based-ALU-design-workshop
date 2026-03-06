// The following opcodes are mapped to [9:8] Ci, [7:4] G, [3:0] P
// ADD  : 10'b00_0001_0110  (A + B)
// ADDC : 10'b10_0001_0110  (A + B + CI)
// SUB  : 10'b01_0010_1001  (A - B)
// SUBR : 10'b01_0100_1001  (B - A)
// XOR  : 10'b00_0000_0110  (A ^ B)
// XNOR : 10'b00_0000_1001  ~(A ^ B)

`timescale 1ns / 1ps

module lut_alu (
    input  logic        clk,
    input  logic        reset,
    input  logic [9:0]  opcode,
    input  logic [7:0]  A,
    input  logic [7:0]  B,
    input  logic        CI,
    output logic [7:0]  Z,
    output logic        CO
);

    // Internal signal declarations
    logic [7:0] P, G, Ci;
    reg [7:0]   z_d;
    reg         co_d;
    logic [7:0] pp, gg;

    // Propagate function design (using opcode[3:0])
    function automatic logic [7:0] Pf(
        input logic [9:0] opcd,
        input logic [7:0] A_in,
        input logic [7:0] B_in
    );
        logic [7:0] p;
        for(int ix=0; ix<8; ix+=1) begin
            p[ix] = (~A_in[ix]) & (~B_in[ix]) & opcd[3] |
                    (~A_in[ix]) & ( B_in[ix]) & opcd[2] |
                    ( A_in[ix]) & (~B_in[ix]) & opcd[1] |
                    ( A_in[ix]) & ( B_in[ix]) & opcd[0];
        end
        return p;
    endfunction : Pf

    // Generate function design (using opcode[7:4])
    function automatic logic [7:0] Gf(
        input logic [9:0] opcd,
        input logic [7:0] A_in,
        input logic [7:0] B_in
    );
        logic [7:0] g;
        for(int ix=0; ix<8; ix+=1) begin
            g[ix] = (~A_in[ix]) & (~B_in[ix]) & opcd[7] |
                    (~A_in[ix]) & ( B_in[ix]) & opcd[6] |
                    ( A_in[ix]) & (~B_in[ix]) & opcd[5] |
                    ( A_in[ix]) & ( B_in[ix]) & opcd[4];
        end
        return g;
    endfunction : Gf

    // Combinational logic section
    always_comb begin
        pp = Pf(opcode, A, B);
        gg = Gf(opcode, A, B);

        // Carry-in selection (using opcode[9:8])
        case(opcode[9:8])
            2'b00   : Ci[0] = 1'b0; // For bitwise logic or basic ADD
            2'b01   : Ci[0] = 1'b1; // For SUB and SUBR (+1 for 2's complement)
            2'b10, 
            2'b11   : Ci[0] = CI;   // External carry-in for ADDC
            default : Ci[0] = 1'bX;
        endcase

        // Ripple carry chain calculation
        for(int ix=1; ix<8; ix+=1) begin
            Ci[ix] = gg[ix-1] | (pp[ix-1] & Ci[ix-1]);
        end

        // Calculate final outputs
        co_d = gg[7] | (pp[7] & Ci[7]); 
        z_d  = pp ^ Ci;
    end

    // Sequential logic section
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            Z  <= 8'h00;
            CO <= 1'b0;
        end else begin
            Z  <=  z_d;
            CO <=  co_d;
        end
    end

endmodule : lut_alu
