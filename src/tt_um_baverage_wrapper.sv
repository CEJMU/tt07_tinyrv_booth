module tt_um_baverage_wrapper (
    input  logic [7:0] ui_in,    // Dedicated inputs
    output logic [7:0] uo_out,   // Dedicated outputs
    input  logic [7:0] uio_in,   // IOs: Input path
    output logic [7:0] uio_out,  // IOs: Output path
    output logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // always 1 when the design is powered, so you can ignore it
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

   logic               y;
   assign uo_out[0] = y;
   logic [1:0]         x;
   assign x = ui_in[1:0];

   assign uo_out[7:1] = 7'b0;
   assign uio_out[7:1] = 7'b0;
   assign uio_oe[7:1] = 7'b0;

    typedef enum {z0,z50,z100,z150} mystate;
    mystate state_d ; // Neuer Zustand
    (* fsm_encoding = "binary" *)
    mystate state_q ; // Alter Zustand

    always_ff @ (posedge clk) begin
        if (rst_n)
            state_q <= z0;
        else
            state_q <= state_d;
    end
    // Lambda:
    always_comb begin
        y = 0;
        if(state_q == 2'b11)
            y = 1;
    end
    // Delta
    always_comb begin
        state_d = state_q; // Default
        if(x == 2'b01) begin // 50 cent
            case(state_q)
                z0   : state_d = z50;
                z50  : state_d = z100;
                z100 : state_d = z150;
                z150 : state_d = state_q;
            endcase
        end else if(x == 2'b10) begin // 1 Euro
            case(state_q)
                z0   : state_d = z100;
                z50  : state_d = z150;
                z100 : state_d = z150;
                z150 : state_d = state_q;
            endcase
        end
    end
endmodule
