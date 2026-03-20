`timescale 1ns / 1ps

module tb_trafficcontrol( );
reg clk, rst, pedestrian;
wire red, green, yellow, walk;

trafficcontrol_mealy uut ( .clk(clk), .rst(rst), .pedestrian(pedestrian),
                           .red(red),.yellow(yellow), .green(green),
                           .walk(walk));


always #5 clk=~clk;

initial begin
    clk=0; rst=1;pedestrian=0;
    #20 rst=0;
    #200;  

    wait(green==1);
    @(posedge clk) pedestrian=1;
    #10 pedestrian=0;
    
    wait(walk==1)    
    wait(red==1 && walk==0);
    @(posedge clk) pedestrian=1;
    #10 pedestrian=0;

    wait(walk==1);
    #200 $finish;

end

    initial begin
            $monitor("T=%0t | clk=%0b | rst=%0b | pedestrian_input=%0b | red=%0b | green=%0b | yellow=%0b | walk=%0b", 
                 $time, clk, rst, pedestrian, red, green, yellow, walk);
    end

endmodule
