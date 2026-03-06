This folder contains the design code for MUX-based ALU and the testbech for it.  

Simulation Result:  

--- Starting MUX-based ALU Tests ---  
--- Testing ADD ---  
[ ADD] A:   5 B:  10 CI:0 | Z:  15 (Hex:0f) Carry:0  
[ ADD] A: 255 B:   1 CI:0 | Z:   0 (Hex:00) Carry:1  

--- Testing ADDC ---  
[ADDC] A:   5 B:  10 CI:1 | Z:  16 (Hex:10) Carry:0  
[ADDC] A: 127 B: 127 CI:1 | Z: 255 (Hex:ff) Carry:0  

--- Testing SUB (A - B) ---  
[ SUB] A:  10 B:   5 | Z:   5 (Hex:05) Borrow:0  
[ SUB] A:   5 B:  10 | Z:  -5 (Hex:fb) Borrow:1 <-- Negative result (Borrow)  
[ SUB] A:   0 B:   1 | Z:  -1 (Hex:ff) Borrow:1 <-- Negative result (Borrow)  

--- Testing SUBR (B - A) ---  
[SUBR] A:   5 B:  10 | Z:   5 (Hex:05) Borrow:0  
[SUBR] A:  20 B:   5 | Z: -15 (Hex:f1) Borrow:1 <-- Negative result (Borrow)  

--- Testing Logic (XOR/XNOR) ---  
[ XOR] A:10101010 B:01010101 | Z:11111111 (Hex:ff)  
[XNOR] A:10101010 B:01010101 | Z:00000000 (Hex:00)

$finish called at time : 136 ns
