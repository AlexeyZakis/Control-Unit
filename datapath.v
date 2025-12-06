// Здесь НИЧЕГО нельзя изменять
module datapath(
  x, y, s, b,
  s_en, s_step, s_sub, s_zero,
  y_en, y_select_next, y_upd,
  clk, rst
);
  input [7:0] x;
  output reg [7:0] y;
  output reg [2:0] s;
  output b;
  
  input s_en, s_sub, s_zero, y_en, y_upd;
  input [1:0] s_step, y_select_next;
  
  input clk, rst;
  
  wire [2:0] s_next;
  
  assign s_next =
    s_sub
    ? (s_zero ? 0 : s) - s_step
    : (s_zero ? 0 : s) + s_step;
  
  always @(posedge clk, posedge rst)
    if(rst) s <= 0;
    else
      if(s_en) s <= s_next;
  
  reg [7:0] y_next;
  
  always @*
    if(y_upd)
      case(y_select_next)
      0: y_next = y;
      1: y_next = y + s;
      2: y_next = y - s;
      3: y_next = y + 1;
      default: y_next = 1'sbx;
      endcase
    else
      y_next = x;
  
  always @(posedge clk, posedge rst)
    if(rst) y <= 0;
    else
      if(y_en) y <= y_next;
  
  assign b = y[s];
endmodule
