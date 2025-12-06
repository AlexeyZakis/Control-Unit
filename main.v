// ВНИМАНИЕ!
// Можно изменять ТОЛЬКО части кода, помеченные "(*)",
// и ТОЛЬКО так, как написано у "(*)".
module main(x, on, start, y, s, b, regime, active, clk, rst);
    // // (*) По необходимости можно добавть "reg" в объявлениях выходных точек, задающихся в управляющем автомате.
    input [7:0] x;
    input [1:0] on;
    input start;
    output [7:0] y;
    output [2:0] s;
    output b;
    output reg active;
    output reg [1:0] regime;
    input clk, rst;
  
    // (*) По необходимости можно заменить wire на reg для любых точек далее.
    reg [1:0] y_select_next, s_step;
    reg y_en, s_en, y_upd, s_sub, s_zero;
  
    // Основная часть операционного автомата.
    datapath _datapath(
        .x(x),
        .y(y),
        .s(s),
        .b(b),
        .s_en(s_en),
        .s_step(s_step),
        .s_sub(s_sub),
        .s_zero(s_zero),
        .y_en(y_en),
        .y_select_next(y_select_next),
        .y_upd(y_upd),
        .clk(clk),
        .rst(rst)
    );
    
	localparam M1_S_INC_2_TIMER_TIMEOUT = 2,
	           M2_S_VALUE_TO_INCREASE_Y = 3;
    
    wire should_inc_y;
	
	reg [3:0] state, next_state;
	reg [$clog2(M1_S_INC_2_TIMER_TIMEOUT):0] timer;
	
	localparam STATE_M0 = 0,
               STATE_M0_S1 = 1,
               STATE_M1_S1 = 2,
               STATE_M1_WAIT = 3,
               STATE_M1_S_INC_2 = 4,
               STATE_M2_INC_S = 5,
               STATE_M2_INC_SY = 6,
               STATE_M3_YX = 7,
               STATE_M3_INC_S_Y_MINUS_S = 8,
               STATE_M3_OFF = 9;
  
    // Распознавание свойств данных в операционном автомате.
    // (*) Здесь следует по необходимости объявить новые управляющие точки
    //   и реализовать задающие их подсхемы
    //   (преобразующие данные в управление).
    assign should_inc_y = s == M2_S_VALUE_TO_INCREASE_Y - 2;
  
    // Управляющий автомат.
    // (*) Здесь следует написать схему, основная часть которой - это
    //   типовая реализация управляющего символьного автомата,
    //   заставляющая схему main выполняться согласно условию.   
    
    always @(posedge clk, posedge rst)
        if(rst)
        	begin 
		    	state <= STATE_M0;
		    	timer <= 0;
			end
        else 
        	if (timer == 0) state <= next_state;
        	else timer <= timer - 1;
    		
	always @* begin
	    next_state = 1'bx;
        case(state)
            // on = 0
            STATE_M0, STATE_M0_S1:
                case(on)
                    0: next_state = STATE_M0;
                    1: if (start) next_state = STATE_M1_S1;
                       else next_state = STATE_M0;
                    2: if (start)
                           if (should_inc_y) next_state = STATE_M2_INC_SY;
                           else  next_state = STATE_M2_INC_S;
                       else next_state = STATE_M0;
                    3: next_state = STATE_M3_YX;
                endcase
            // on = 1
            STATE_M1_S1: next_state = STATE_M1_WAIT;
            STATE_M1_WAIT: next_state = STATE_M1_S_INC_2;
            STATE_M1_S_INC_2:
            	begin
            		next_state = STATE_M0_S1;
            		timer = M1_S_INC_2_TIMER_TIMEOUT;
            	end
            // on = 2
            STATE_M2_INC_S, STATE_M2_INC_SY:
                if (!start) next_state = STATE_M0;
                else if (start && should_inc_y) next_state = STATE_M2_INC_SY;
                else next_state = STATE_M2_INC_S;
            // on = 3
            STATE_M3_YX: next_state = STATE_M3_INC_S_Y_MINUS_S;
            STATE_M3_INC_S_Y_MINUS_S: next_state = STATE_M3_OFF;
            STATE_M3_OFF: next_state = STATE_M0;
        endcase
    end
    
    always @* begin
        {active, regime, s_zero, s_step, s_sub, s_en, y_select_next, y_upd, y_en} = 0;
        case(state)
            // on = 0
            STATE_M0_S1:
                begin
	                s_zero = 1;
	                s_step = 1;
	                s_en = 1;
                end
            // on = 1
            STATE_M1_S1:
                begin
                    active = 1;
	                regime = 1;
	                s_zero = 1;
	                s_step = 1;
	                s_en = 1;
                end
            STATE_M1_WAIT:
                begin
                    active = 1;
	                regime = 1;
                end
            STATE_M1_S_INC_2:
                begin
                    active = 1;
	                regime = 1;
	                s_step = 2;
	                s_en = 1;
                end
            // on = 2
            STATE_M2_INC_S:
                begin
	                regime = 2;
	                s_step = 1;
	                s_en = 1;
                end
            STATE_M2_INC_SY:
                begin
	                regime = 2;
	                s_step = 1;
	                s_en = 1;
	                y_select_next = 3;
	                y_upd = 1;
	                y_en = 1;
                end
            // on = 3
            STATE_M3_YX:
                begin
	                regime = 3;
	                y_en = 1;
                end
            STATE_M3_INC_S_Y_MINUS_S:
                begin
	                regime = 3;
	                s_step = 1;
	                s_en = 1;
	                y_select_next = 2;
	                y_upd = 1;
	                y_en = 1;
                end
            STATE_M3_OFF: regime = 3;
        endcase
    end
endmodule

