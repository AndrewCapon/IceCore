module chip (
  // 25Hz clock input
  input  clk,

  inout  [1:0] qd,
  input  dcs,
  input  dsck,

  // led outputs
  output [3:0] led,

`ifdef DEBUG
  output prb00,
  output prb01,
  output prb02,
  output prb03,
  output prb04,
  output prb05,
  output prb06,
  output prb07,
  output prb08,
  output prb09,
  output prb10,
  output prb11,
  output prb12,
  output prb13,
  output prb14,
  output prb15,
`endif
);

wire clk80;
wire locked;

reg rst;

reg [12:0] resetCounter;
always @ (posedge clk) begin
  if(resetCounter < 1024) begin
    rst <= 1;
    resetCounter <= resetCounter+1;
  end else begin
    rst <= 0;
  end
end 

pll80 clock_80 (
    .clock_in(clk),
    .clock_out(clk80),
    .locked(locked)
);


// tristate for qd
wire [1:0] io_qd_read, io_qd_write, io_qd_writeEnable;

SB_IO #(
  .PIN_TYPE(6'b 1010_01),
  .PULLUP(1'b0)
) qd1 [1:0] (
  .PACKAGE_PIN(qd),
  .OUTPUT_ENABLE(io_qd_writeEnable),
  .D_OUT_0(io_qd_write),
  .D_IN_0(io_qd_read)
);


// are we alive
assign led = 4'b1110;

DSPIMemory top_level( 
  .QD_READ(io_qd_read),
  .QD_WRITE(io_qd_write),
  .QD_WRITE_ENABLE(io_qd_writeEnable),

  .SS(dcs),
  .SCLK(dsck),

  .CLK(clk80),
  .RST(rst),

`ifdef DEBUG
  .DBG_IO0(prb04), 
  .DBG_IO1(prb05),
  .DBG_SS(prb06),
  .DBG_SCLK(prb07),
  
  .DBG_1(prb00),
  .DBG_2(prb01),
  .DBG_3(prb02),
  .DBG_4(prb03),

  .DBG_BYTE({prb08, prb09, prb10, prb11, prb12, prb13, prb14, prb15})
`endif
);
  
endmodule
