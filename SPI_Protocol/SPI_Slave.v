module SPI_Slave
(
reset,
In_Data,
slaveCPOL, 
slaveCPHA,
slaveSCLK, 
slaveCS_, 
slaveMISO, 
slaveMOSI,
slave_start,
read_data
);                   //SCLK: SPI clock; //MOSI: Master out Slave in;  
                                //MISO: Master in Slave out; //ExData: External data to be communicated
input wire [7:0] In_Data;
input wire reset;
input wire slaveSCLK, slaveCPOL, slaveCPHA; 
input wire slaveCS_;
input wire slaveMOSI; 
input wire slave_start;

output reg slaveMISO;
output wire [7:0] read_data; // output_data, the data from Master

reg [7:0] memReg;//internal memory register


always@ (posedge reset)
begin
memReg = In_Data;
end

always@(negedge slaveCS_)
 slaveMISO = memReg[0]; //sending
    
always @ (negedge slaveSCLK) 
begin
if(slaveCS_==0)
begin
    if(slave_start==1)
    begin
     if ({slaveCPOL,slaveCPHA}==0 ||{slaveCPOL,slaveCPHA}==2 ) // send on falling 
     slaveMISO = memReg[0]; //sending
     
     if ({slaveCPOL,slaveCPHA}==1 ||{slaveCPOL,slaveCPHA}==3 ) // read on falling
     memReg ={slaveMOSI,memReg[7:1]};

    end
  
 end
end
always@(posedge slaveSCLK) // rising edge
begin
if(slaveCS_==0)
begin

 if(slave_start==1)
begin
    if ({slaveCPOL,slaveCPHA}==1 ||{slaveCPOL,slaveCPHA}==3 ) // send on rising
    slaveMISO = memReg[0];
    if ({slaveCPOL,slaveCPHA}==0 ||{slaveCPOL,slaveCPHA}==2 ) // read on rising
    memReg <={slaveMOSI,memReg[7:1]};
end
end
end
assign read_data = memReg;

endmodule 
