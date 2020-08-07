module SPI_Pro_tb();

wire [7:0] data_out_master;
wire [7:0] data_out_slave;
reg [1:0] Address;
reg clk;
reg start;
integer iterator = 0;
integer i = 0;
reg load,reset1,reset2,reset3,CPOL,CPHA;
reg [7:0] data_in_master;
reg [7:0] data_in_slave;
reg [7:0] expected_MasterOut;
reg [7:0] expected_SlaveOut;
SPI_Protocol SPI(start,clk,data_in_master,data_in_slave,data_out_master,load,data_out_slave,CPOL,CPHA,Address,reset1,reset2,reset3);

initial begin 
// the delay (#2) is to make sure that self-checking is done before we start the next communication
testMode0();
#2
testMode1();
#2
testMode2();
#2 
testMode3();

end


task testMode0() ;
begin
$display("                        Now testing mode 0 : reading on rising edge , writing on falling edge") ;
$display("                                           ======================================");
$display("                                          || Testing MODE 0 ({CPOL,CPHA}= {0,0})||");
$display("                                           ======================================");

$display("time  clk    CPOL    CPHA   load      Master_out    slave_out");

Address = 00;
load = 1 ;
reset1 = 1;
CPOL = 0;
CPHA = 0;
clk = 0;
data_in_master = 'b00110110;
data_in_slave = 'b01001011;
if(load && reset1 )
begin
expected_MasterOut=data_in_slave;
expected_SlaveOut=data_in_master;
end
else if(reset1)
expected_MasterOut=data_in_slave;
else if(load)
expected_SlaveOut=data_in_master;
#2  clk = ~clk;  start =1; // +ve clk , idel state
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk, idel state",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);

#2  clk = ~clk; start = 0; reset1 = 0; load = 0;// -ve clk

for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
begin
        #2 clk = ~clk;  // +ve clk and +ve SCLK, read data 
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b   +ve clk,+ve sclk read data ",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
       	#2 clk = ~clk; // +ve clk and -ve SCLK
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk,-ve sclk, shift data out on output",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
if(expected_SlaveOut==data_out_slave || expected_MasterOut==data_out_master)
$display("Data transmitted successfully");
else
$display("Transmission failed, data_out_master should be %b, data_out_slave should be %b",expected_MasterOut,expected_SlaveOut);
end
endtask

task testMode1() ;
begin
$display("                        Now testing mode 1 : reading on falling edge , writing on rising edge ") ;
$display("                                           ======================================");
$display("                                          || Testing MODE 1 ({CPOL,CPHA}= {0,1})||");
$display("                                           ======================================");

$display("time  clk    CPOL    CPHA   load     Master_out slave_out");

Address = 01;
CPOL = 0;
CPHA = 1;
clk = 0; reset2 = 1;
data_in_slave = 'b10110100;
if(load && reset2 )
begin
expected_MasterOut=data_in_slave;
expected_SlaveOut=data_in_master;
end
else if(reset2)
expected_MasterOut=data_in_slave;
else if(load)
expected_SlaveOut=data_in_master;



#2  clk = ~clk;  start =1; // +ve clk , idel state
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk, idel state",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);

#2  clk = ~clk;start=0; reset2 = 0; load = 0;// -ve clk

    for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
    begin
        #2 clk = ~clk; // +ve clk and +ve SCLK, send data 
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b   +ve clk,+ve sclk shift data out on output ",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; load = 0; // -ve clk
       	#2 clk = ~clk; // +ve clk and -ve SCLK , read
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk,-ve sclk, read data",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");

if(expected_SlaveOut==data_out_slave || expected_MasterOut==data_out_master)
$display("Data transmitted successfully");
else
$display("Transmission failed, data_out_master should be %b, data_out_slave should be %b",expected_MasterOut,expected_SlaveOut);
end
endtask

task testMode2() ;
begin
$display("                        Now testing mode 2 : reading on rising edge , writing on falling edge, but with a skipped -ve edge") ;
$display("                                           ======================================");
$display("                                          || Testing MODE 2 ({CPOL,CPHA}= {1,0})||");
$display("                                           ======================================");

$display("time  clk    CPOL    CPHA   load     Master_out slave_out");

Address = 10;
CPOL = 1;
CPHA = 0;
clk = 0;
reset3 = 1;
data_in_slave = 'b01001110;
if(load && reset3 )
begin
expected_MasterOut=data_in_slave;
expected_SlaveOut=data_in_master;
end
else if(reset3)
expected_MasterOut=data_in_slave;
else if(load)
expected_SlaveOut=data_in_master;

#2  clk = ~clk;  start =1; // +ve clk , idel state
#2  clk = ~clk; start = 0;  reset3 = 0; load = 0;// -ve clk
#2  clk = ~clk; // +ve clk -ve sclk, skipped edge
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk, skipped edge ",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);

#2  clk = ~clk; // -ve clk
    for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
    begin
        #2 clk = ~clk; // +ve clk and +ve SCLK, read data 
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b   +ve clk,+ve sclk read data ",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
       	#2 clk = ~clk; // +ve clk and -ve SCLK
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk,-ve sclk, shift data out on output",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
if(expected_SlaveOut==data_out_slave || expected_MasterOut==data_out_master)
$display("Data transmitted successfully");
else
$display("Transmission failed, data_out_master should be %b, data_out_slave should be %b",expected_MasterOut,expected_SlaveOut);
end
endtask

task testMode3() ;
begin
$display("                        Now testing mode 3 : write on rising edge , read on falling edge but with a skipped -veedge at the beginning") ;
$display("                                           ======================================");
$display("                                          || Testing MODE 3 ({CPOL,CPHA}= {1,1})||");
$display("                                           ======================================");

$display("time  clk    CPOL    CPHA   load      Master_out    slave_out");

Address = 00;
CPOL = 1;
CPHA = 1;
clk = 0;
if(load && reset1 )
begin
expected_MasterOut=data_in_slave;
expected_SlaveOut=data_in_master;
end
else if(reset1)
expected_MasterOut=data_in_slave;
else if(load)
expected_SlaveOut=data_in_master;
else
begin
if(!load)
expected_MasterOut=data_out_slave;
if(!reset1)
expected_SlaveOut=data_out_master;
end
#2  clk = ~clk;  start =1; // +ve clk , idel state
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk, idel state",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);

#2  clk = ~clk; start = 0; load = 0; reset1 = 0;// -ve clk
#2  clk = ~clk; // +ve clk, -ve sclk, skipped falling edge
#2  clk = ~clk; // -ve clk
for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
begin
        #2 clk = ~clk; // +ve clk and +ve SCLK, write data data 
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b   +ve clk,+ve sclk shift data out on MOSI & MISO",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
       	#2 clk = ~clk; // +ve clk and -ve SCLK, read data
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b  +ve clk,-ve sclk, read data",$time,clk,CPOL,CPHA,load,data_out_master,data_out_slave);
        #2 clk = ~clk; // -ve clk
    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
if(expected_SlaveOut==data_out_slave || expected_MasterOut==data_out_master)
$display("Data transmitted successfully");
else
$display("Transmission failed, data_out_master should be %b, data_out_slave should be %b",expected_MasterOut,expected_SlaveOut);
end
endtask

endmodule
