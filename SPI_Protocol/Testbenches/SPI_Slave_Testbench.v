`timescale 1 ns/ 10 ps 	

module Slave_testbench();

localparam PERIOD = 4;
reg [7:0] Datain;
reg reset;
reg CPOL,CPHA;
reg SCLK;
reg CS;
reg slave_start;
reg MOSI;
wire MISO;
wire [7:0] Slave_Memory;
reg [7:0] Master_Memory; //write memory
integer i;
reg [7:0] MOSI_Arr;

SPI_Slave Slave
(
 .reset(reset),
 .slaveSCLK(SCLK),
 .slaveCPOL(CPOL),
 .slaveCPHA(CPHA),
 .slaveMISO(MISO),
 .slaveMOSI(MOSI),
 .slaveCS_(CS),
 .In_Data(Datain),
 .read_data(Slave_Memory),
 .slave_start(slave_start)
);

always 
   #(PERIOD/2) SCLK = ~SCLK;


initial
begin
$monitor ("%g\t %b\t %b\t %b\t %b\t %b\t %b\t          %b\t    %b\t    %b\t  %b\t",
           $time, reset,CPOL,CPHA,SCLK,CS,slave_start,Slave_Memory,MOSI,MISO,Master_Memory);


//mode 0
{CPOL,CPHA}=0; SCLK = CPOL;  Datain = 8'b00001111;  reset = 1'b1; MOSI_Arr = 8'b10101010; CS = 1'b1;
$display("#################################################_______MODE_0___####################################################################################################");
$display ("time\t reset\t CPOL\t CPHA\t SCLK\t CS\tSlave_Start\t   Slave_Memory\t MOSI\t MISO\t Write_Memory");


#(PERIOD)  CS = 1'b0;  reset = 1'b0;
for(i=0;i<8;i=i+1)
begin
  #(PERIOD/2) // +ve sclk, reading from MOSI and writing the first bit on MISO
  MOSI = MOSI_Arr[i]; slave_start = 1;
  #(PERIOD/2) // -ve sclk , writing bits starting from 2nd bit on MISO
  Master_Memory[i]=MISO;
end

#(PERIOD/2)

  if(Master_Memory==Datain && Slave_Memory==MOSI_Arr)
    $display("Data was transmitted successfully");
    else
begin
     for(i=0;i<8;i=i+1)
     begin
     if(Master_Memory[i]!=Datain[i])
     $display("Error in write memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
     for(i=0;i<8;i=i+1)
     begin
     if(Slave_Memory[i]!=MOSI_Arr[i])
     $display("Error in slave memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
end


  //Mode 1
{CPOL,CPHA} = 1; SCLK = CPOL;  Datain = 8'b11011000;  reset = 1'b1;
 MOSI_Arr = 8'b01110110; CS = 1'b1; Master_Memory = 8'bx; slave_start=0;

$display("#################################################_______MODE_1______###########################################################################");
$display ("time\t reset\t CPOL\t CPHA\t SCLK\t CS\tSlave_Start\t   Slave_Memory\t MOSI\t MISO\t Write_Memory");

for(i=0;i<8;i=i+1)
begin
  #(PERIOD/2)
slave_start = 1;
  CS = 1'b0;  reset = 1'b0; 
 //+ve sclk
  #(PERIOD/2) // -ve sclk

  MOSI = MOSI_Arr[i]; 
   Master_Memory[i] = MISO;
 
 end
#(PERIOD)
  if(Master_Memory==Datain && Slave_Memory==MOSI_Arr)
    $display("Data was transmitted successfully");
    else
      begin
     for(i=0;i<8;i=i+1)
     begin
     if(Master_Memory[i]!=Datain[i])
     $display("Error in write memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
     for(i=0;i<8;i=i+1)
     begin
     if(Slave_Memory[i]!=MOSI_Arr[i])
     $display("Error in slave memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
end


//Mode2
{CPOL,CPHA} = 2; SCLK = CPOL;  Datain = 8'b01011001;  reset = 1'b1; 
 MOSI_Arr = 8'b00000000; CS = 1'b1; Master_Memory = 8'bx; slave_start=0;
$display("#################################################_______MODE_2______############################################################################");
$display ("time\t reset\t CPOL\t CPHA\t SCLK\t CS\tSlave_Start\t   Slave_Memory\t MOSI\t MISO\t Write_Memory");


for(i=0;i<8;i=i+1)
begin
  #(PERIOD/2)
  CS = 1'b0; reset = 1'b0;
   MOSI = MOSI_Arr[i]; slave_start = 1;
  #(PERIOD/2)
  Master_Memory[i] = MISO;
end
#(PERIOD)

  if(Master_Memory==Datain && Slave_Memory==MOSI_Arr)
    $display("Data was transmitted successfully");
    else
     begin
     for(i=0;i<8;i=i+1)
     begin
     if(Master_Memory[i]!=Datain[i])
     $display("Error in write memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
     for(i=0;i<8;i=i+1)
     begin
     if(Slave_Memory[i]!=MOSI_Arr[i])
     $display("Error in slave memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
     end

//Mode 3
{CPOL,CPHA} = 3; SCLK = CPOL;  Datain = 8'b00011011;  reset = 1'b1;
 MOSI_Arr = 8'b11111111; CS = 1'b1; Master_Memory = 8'bx; slave_start=0;
$display("#################################################_______MODE_3_______############################################################################");
$display ("time\t reset\t CPOL\t CPHA\t SCLK\t CS\tSlave_Start\t   Slave_Memory\t MOSI\t MISO\t Write_Memory");


for(i=0;i<8;i=i+1)
begin
  #(PERIOD/2)
  CS = 1'b0; reset = 1'b0; 
  slave_start = 1;
  #(PERIOD/2)
  MOSI = MOSI_Arr[i]; 
  Master_Memory[i] = MISO;
end
  #(PERIOD)
  if(Master_Memory==Datain && Slave_Memory==MOSI_Arr)
    $display("Data was transmitted successfully");
    else
     begin
     for(i=0;i<8;i=i+1)
     begin
     if(Master_Memory[i]!=Datain[i])
     $display("Error in write memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
     for(i=0;i<8;i=i+1)
     begin
     if(Slave_Memory[i]!=MOSI_Arr[i])
     $display("Error in slave memory in index %d, expected %b, found %b",i,Datain[i],Master_Memory[i]);
     end
end


$stop;
end

endmodule

