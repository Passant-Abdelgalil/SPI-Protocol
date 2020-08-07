module m41 ( input a, 
input b, 
input c,  
input s0, s1,
output out); 

 assign out = s1 ? (s0 ? 'bx : c) : (s0 ? b : a); 

endmodule

module m4x1 ( input[7:0] a, 
input [7:0] b, 
input [7:0] c,  
input  s0, s1,
output [7:0]out); 

 assign out = s1 ? (s0 ? 'bx : c) : (s0 ? b : a); 

endmodule

module SPI_Protocol(input start,input clk,input [7:0] data_in_master,input [7:0] data_in_slave,
output wire [7:0] data_out_master,input load,output wire [7:0] data_out_slave,input CPOL,input CPHA,
input [1:0] Address,input reset1,input reset2,input reset3);

wire SCLK;
wire MOSI;
wire MISO;
wire MISO1;
wire MISO2;
wire MISO3;
wire [7:0] data_out_slave1;
wire [7:0] data_out_slave2;
wire [7:0] data_out_slave3;
wire CS1,CS2,CS3;
wire slave_start;

m41 MUX (MISO1,MISO2,MISO3,Address[0],Address[1],MISO);
m4x1 MUX2(data_out_slave1,data_out_slave2,data_out_slave3,Address[0],Address[1],data_out_slave);

SPI_Master master (clk,start,load,data_in_master,Address,CPOL,CPHA,MISO,SCLK,CS1,CS2,CS3,MOSI,data_out_master,slave_start);

SPI_Slave slave_1 (reset1,data_in_slave,CPOL,CPHA,SCLK,CS1,MISO1,MOSI,slave_start,data_out_slave1);

SPI_Slave slave_2 (reset2,data_in_slave,CPOL,CPHA,SCLK,CS2,MISO2,MOSI,slave_start,data_out_slave2);

SPI_Slave slave_3 (reset3,data_in_slave,CPOL,CPHA,SCLK,CS3,MISO3,MOSI,slave_start,data_out_slave3);

endmodule


