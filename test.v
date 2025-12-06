module test();
	reg clk, rst;
  
	reg [7:0] x;
    reg [1:0] on;
    reg start;
  
	wire [7:0] y;
    wire [2:0] s;
    wire b, active;
    wire [1:0] regime;
	
	initial clk = 0;
	always #1 clk = !clk;
	
	main _main(
		.clk(clk),
		.rst(rst),
		.x(x),
		.on(on),
		.start(start),
		.y(y),
		.s(s),
		.b(b),
		.active(active),
		.regime(regime)
	);
	
	initial begin
		$dumpfile("dump.vcd");
        $dumpvars(1, test);
        x = 8'b10101010;
        
        // on = 2
        //*
        start = 0; on = 2;
        
        rst = 1;
        #2
        rst = 0;
        #4
        
        rst = 1;
        #2
        rst = 0;
        #2
        start = 1;
        #2
       	start = 0;
       	#2
       	
        rst = 1;
        #2
        rst = 0;
        #2
        start = 1;
        #4
        start = 0;
        #2
       	
       	rst = 1;
        #2
        rst = 0;
        #2
        start = 1;
        #6
        start = 0;
        #2
       	
       	rst = 1;
        #2
        rst = 0;
        #2
        start = 1;
        #8
        start = 0;
        #2
        //*/
        
        // on = 3
        //*
        on = 3;
        #2
        on = 0;
       	#6 //*/
        
        // on = 1
		//*
		on = 1;
        #2
        start = 1;
        #12 //*/
        
       	#2
        $finish;
	end
endmodule

