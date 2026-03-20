`timescale 1ns / 1ps


module trafficcontrol #(
parameter RED=2'b00,
GREEN=2'b01,
YELLOW=2'b10,
WALK=2'b11,
GREEN_TIME=15,
RED_TIME=15,
YELLOW_TIME=5,
WALK_TIME=10
)(
input clk, rst,
input pedestrian,
output reg red, green, yellow, walk);

reg [1:0] current_state, next_state;
reg[3:0]timer;
reg pedestrian_req;

//current state logic
always @(posedge clk or posedge rst)
begin
    if (rst)
    current_state<=RED;
    else
    current_state<=next_state;
 end
 
 // Pedestrian request storing latch
 always @(posedge clk or posedge rst)
begin
    if (rst)
        pedestrian_req <= 0;

    else if (pedestrian)
        pedestrian_req <= 1;   // latch request anytime

    // clear only when request is actually being served
    else if (current_state==WALK && next_state==GREEN)  //RED
        pedestrian_req <= 0;
end

 
 //timer logic
 always@ (posedge clk or posedge rst)
 begin
    if(rst)
        timer<=0;   //1
    else if (current_state!=next_state) begin
        timer<=0;
    end
    else begin
        timer<=timer+1;
    end
  end        
            
    
 //next_state logic
 always@ (*)
 begin
     case(current_state)
         RED:begin
            if(pedestrian_req && timer>=WALK_TIME)
                next_state=WALK;
             else if(timer==RED_TIME)
                next_state=GREEN;
              else
                next_state=RED;
         end
         GREEN:begin
            if(pedestrian_req &&timer>= WALK_TIME)
                next_state=YELLOW;
            else if(timer==GREEN_TIME)
                next_state=YELLOW; //early exit for pedestrian
             else
                next_state=GREEN;
         end
         YELLOW:begin
            if(timer==YELLOW_TIME) begin
                if(pedestrian_req)
                    next_state=WALK;
                else
                    next_state=RED;
             end
             else
                next_state=YELLOW;
             end
         WALK: begin
            if(timer==WALK_TIME)
            	next_state=GREEN;
             else
                next_state=WALK;
         end
         default: next_state=RED;
     endcase
 end

//Output logic
always@(*)
begin
    red=1'b0;
    green=1'b0;
    yellow=1'b0;
    walk=1'b0;
    case(current_state)
        RED: red=1'b1;
        GREEN: green=1'b1;
        YELLOW:yellow=1'b1;
        WALK: begin
            walk=1'b1;
            red=1'b1;
        end
        default: red=1'b1;
    endcase
end

endmodule
