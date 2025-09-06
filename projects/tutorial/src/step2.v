// Tutorial Step 2: 2-bit Comparator (A > B)
// Implements the function F(A,B) = A > B using K-map simplified logic

module step2 (
    input [1:0] A,      // 2-bit input A (A[1] = A₁, A[0] = A₀)
    input [1:0] B,      // 2-bit input B (B[1] = B₁, B[0] = B₀)  
    output F            // Output: 1 when A > B, 0 otherwise
);

    // K-map simplified Boolean expression:
    // F = A₁·B₁' + A₀·B₁'·B₀' + A₁·A₀·B₀'
    // 
    // Breaking this down:
    // Term 1: A[1] & ~B[1]           - A₁ is 1 and B₁ is 0 (A is 2 or 3, B is 0 or 1)
    // Term 2: A[0] & ~B[1] & ~B[0]   - A₀ is 1, B is 0 (A is 1 or 3, B is 0) 
    // Term 3: A[1] & A[0] & ~B[0]    - A is 3, B₀ is 0 (A is 3, B is 0 or 2)
    
    assign F = (A[1] & ~B[1]) |                    // Term 1
               (A[0] & ~B[1] & ~B[0]) |            // Term 2  
               (A[1] & A[0] & ~B[0]);              // Term 3

endmodule
