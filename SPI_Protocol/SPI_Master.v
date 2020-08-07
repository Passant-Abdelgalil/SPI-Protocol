module SPI_Master
                  (input clk ,input start,input load , input [7:0]data_to_write ,
                    input [1:0]slave_address , input cpol , input cpha , 
                    input MISO,

                    output reg SCLK , output reg CS1 , output reg CS2 , output reg CS3,
                    output reg MOSI , output reg [7:0] data_read ,output reg slave_start) ;


reg sampled = 1;
reg sclk_old;
reg communication_flag= 1;
reg CPOL ;
reg CPHA ;
reg [7:0]transmission_buffer ;

integer transmission_iterator =0 ;
integer count = 0;
integer countr = 0;

always @(posedge clk)
begin
if(load)
transmission_buffer = data_to_write;

if(count==17 && communication_flag==1)
begin
slave_start = 0;
count =0;
countr = 0;
end
if(transmission_iterator==8)
begin
sampled=0;
slave_start = 0;
end

if(start && communication_flag)
begin
communication_flag = 0;
countr = 0;
count = 0;
CPOL = cpol;
CPHA = cpha;
transmission_iterator = 0;
end
if(!communication_flag)
begin
    //1-} generating sclk from clk
    Generate_SCLK();

    read_write();
   
end
end
task Generate_SCLK();
begin
        if(count==0) // if it's the start of the communication
        begin
                SCLK=CPOL; // idel state
                count = count+1;
                sampled = 0;
{CS1,CS2,CS3} = 'b111 ;
    case(slave_address)
    0 : CS1 = 0 ;
    1 : CS2 = 0 ;
    2 : CS3 = 0 ;
    endcase
if(!CPHA)
begin
MOSI = transmission_buffer[0];
countr = countr+1;
end
        end
        else
        begin
                sclk_old=SCLK; 
                SCLK = ~SCLK;
                if(count==1)
                begin
                   if(CPOL==1)
                   sampled = 0;
                   else
                   begin
                   slave_start = 1;
                   sampled = 1;
                   end
                   count = count + 1;
                end
                else
                begin
                   if(sampled==0)
                   begin sampled = 1;
                   slave_start = 1;
                   end
                   else
                   count = count+1;
                end
        end
end
endtask

task read_write() ;
begin
	//CPHA == 1 , write on rising edge , read on falling 
if(sampled==1)
begin
	if(CPHA)
	begin

                if(countr ==2)
                begin
                transmission_iterator = transmission_iterator+1;
                countr = 0;
                end

                if(sclk_old == 0 && SCLK == 1 )
	        begin
                       MOSI = transmission_buffer[transmission_iterator] ;
                       countr = countr+1;
                end
	        if(sclk_old == 1 && SCLK == 0)
                begin
                       data_read[transmission_iterator] = MISO ;
                       transmission_buffer[transmission_iterator] = MISO;
                       countr = countr+1;
                end
        
	end

	//CPHA == 0 , read on rising , write on falling but the first bit will be read and sent at the start of the communication
	if(!CPHA)
	begin
                if(countr ==2)
                begin
                transmission_iterator = transmission_iterator+1;
                countr = 0;
                end

                if(sclk_old == 0 && SCLK == 1)
                begin
                     data_read[transmission_iterator] = MISO ;
                     transmission_buffer[transmission_iterator] = MISO;
                     countr = countr+1;
                end
                if (sclk_old == 1 && SCLK == 0 )
	        begin
                       MOSI = transmission_buffer[transmission_iterator] ;
                       countr = countr+1;
                end
               
	end

end
if(count==17)
begin
communication_flag<=1;
end
end
endtask 

endmodule 