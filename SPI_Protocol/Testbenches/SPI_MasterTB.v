module SPI_MasterTB ;

reg  load ;
reg start;
reg clk;
reg [7:0] data_in ;
reg [1:0]slave_address ;
reg cpol ;
reg cpha ;
reg MISO ;
wire SCLK ;
wire CS1 ;
wire CS2 ;
wire CS3 ;
wire MOSI ;
wire slave_start ;
wire [7:0]data_read ;
reg check;
integer i;

// For self-checking 
reg [7:0] expected_MOSI; // to store the expected MOSI output so we can check them after the communication
reg [7:0] found_MOSI; // to store the MOSI output so we can check them after the communication 
reg [7:0]Master_Memory; // 

SPI_Master 
            uut(.clk(clk) , .load(load) , .data_to_write(data_in) , .slave_address(slave_address) ,
                .cpol(cpol) , .cpha(cpha) , .MISO(MISO) ,.start(start),

                .SCLK(SCLK) , .CS1(CS1) , .CS2(CS2) , .CS3(CS3),
                .MOSI(MOSI) , .data_read(data_read)  ,.slave_start(slave_start)
            );

//the buffer that feeds MISO line, by the end of the communication session should be read into data_read
reg [7:0]MISO_Stream ;

//loop iterator
integer iterator ;

initial 
begin
     testMode0() ;

     testMode2() ;

     testMode1() ;
 
     testMode3() ;
end

task testMode0() ;
begin
$display("                        Now testing mode 0 : reading on rising edge , writing on falling edge") ;
$display("                                           ======================================");
$display("                                          || Testing MODE 0 ({CPOL,CPHA}= {0,0})||");
$display("                                           ======================================");

$display("time   clk    sclk    CS1     CS2     CS3    CPOL    CPHA   load    MOSI      data_wite     data_read  MISO slave_start");

    clk = 0;
    {cpol,cpha} = 0 ;
    data_in = 'ha5 ; 
    start = 1; 
    MISO_Stream = 'hba ;
    check=0;
    slave_address = 0 ;
#2  clk = ~clk; load =1; // +ve clk , idel state
expected_MOSI = data_in;
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b +ve clk, idel state",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);

#2  clk = ~clk; // -ve clk
    load =0; start = 0;
    for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
    begin
        #2 clk = ~clk; // +ve clk and +ve SCLK , reading from MISO
        MISO = MISO_Stream[iterator];
        if(iterator==0)
         found_MOSI[iterator]=MOSI;
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b +ve clk and +ve SCLK, reading data from MISO",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
        #2 clk = ~clk; // -ve clk
       	#2 clk = ~clk; // +ve clk and -ve SCLK , writing on MOSI
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b +ve clk and -ve SCLK, writing data on MOSI",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
        #2 clk = ~clk; // -ve clk
       if(iterator!=7)
       found_MOSI[iterator+1]=MOSI;
    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
#2
for( i=0;i<=7;i=i+1)
begin

if(data_read[i] != MISO_Stream[i])
begin
$display("|                      an error ocured, expected %b on data_read of %d and found %b |",MISO_Stream[i],i,data_read[i]);
check = 1;
end

if(expected_MOSI[i]!= found_MOSI[i]) 
begin
check=1;
$display("|                      an error ocured, expected %b on MOSI of %d and found %b |",expected_MOSI[i],i,found_MOSI[i]);
end

end

if(!check)
$display("| the test was a success, the data to be sent is %b , the MOSI sequence is %b , the MISO sequence is %b and the recieved data is %b |",expected_MOSI , found_MOSI, MISO_Stream, data_read);
$display("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
end
endtask

task testMode2(); 
begin
    $strobe(" ");     

$strobe("                     Now testing mode 2 : just like mode 0 but with a skipped falling edge in the beginning");
$strobe("                                          =======================================");
$strobe("                                         || Testing MODE 2 ({CPOL,CPHA}= {1,0}) ||");
$strobe("                                          =======================================");

$strobe("time  clk    sclk    CS1     CS2     CS3    CPOL    CPHA   load    MOSI      data_wite     data_read  MISO slave_start");
 #2
    {cpol,cpha} = 2 ;
    clk = 0; start = 1;
    clk = ~clk; // +ve clk , idle state
    load =1;
    check = 0 ;
    data_in = 'hc2 ; 
    MISO_Stream = 'ha7 ;
    slave_address = 1 ;
    if(load)
       expected_MOSI = data_in;
    else
       expected_MOSI = data_read;
    #2 clk = ~clk; start = 0; load = 0; // -ve 
#2 clk=~clk; // +ve clk && -ve SCLK Skipped edge
$strobe("%g \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b  \t%b     \t%b  \t\t%b \t%b  +ve clk && -ve sclk,skipped edge",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
#2 clk = ~clk; // -ve clk
 found_MOSI[0]=MOSI;
    for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
    begin
     #2 clk = ~clk; // +ve clk and +ve SCLK , reading from MISO
        MISO = MISO_Stream[iterator];
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b +ve clk and +ve SCLK, reading data from MISO",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
        #2 clk = ~clk; // -ve clk
       	#2 clk = ~clk; // +ve clk and -ve SCLK , writing on MOSI
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b +ve clk and -ve SCLK, writing data on MOSI",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
        #2 clk = ~clk; // -ve clk
       if(iterator!=7)
       found_MOSI[iterator+1]=MOSI;

    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
#2
for(i=0;i<=7;i=i+1)
begin
 if(data_read[i]!= MISO_Stream[i])
 begin
 $display("|                      an error ocured, expected %b on data_read of %d and found %b |",MISO_Stream[i],i,data_read[i]);
 check = 1 ;
 end
 if(found_MOSI[i]!= expected_MOSI[i])
 begin
 $display("|                      an error ocured, expected %b on MOSI of %d and found %b |",expected_MOSI[i],i,found_MOSI[i]);
 check=1;
 end
end

if(!check)
$display("| the test was a success, the data to be sent is %b , the MOSI sequence is %b , the MISO sequence is %b and the recieved data is %b |",expected_MOSI , found_MOSI, MISO_Stream, data_read);
$display("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
end
endtask

task testMode1();
begin
    $strobe(" ");     
    $strobe("                         Now testing mode 1 : writing on rising edge , reading on falling edge"); 
    $strobe("                                          =====================================");
    $strobe("                                         ||Testing MODE 1 ({CPOL,CPHA}= {0,1})||");
    $strobe("                                          =====================================");

    $strobe("time  clk    sclk    CS1     CS2     CS3    CPOL    CPHA   load    MOSI      data_wite     data_read  MISO slave_start");
#2
    start = 1;
    {cpol,cpha} = 1 ;
    clk = 1;
    check = 0;
    clk=~clk; // -ve clk
    data_in = 'hb5 ; 
    MISO_Stream = 'ha4 ;
    slave_address = 1 ; 
    #2 clk = ~clk; // +ve clk && idle state
       load=1; 
    if(load)
       expected_MOSI = data_in;
    else
       expected_MOSI = data_read;
    #2 clk = ~clk; load =0; start = 0; // -ve clk
    for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
    begin
#2      clk = ~clk; // +ve clk and +ve SCLK , writing data on MOSI
       $strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b  +ve clk and +ve SCLK , writing data on MOSI",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
	#2 clk = ~clk;//-ve clk 
           found_MOSI[iterator]=MOSI;
	#2 clk = ~clk; // +ve clk and -ve SCLK , reading data from MISO
           MISO = MISO_Stream[iterator];
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b  +ve clk and -ve SCLK , reading data from MISO",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
        #2 clk = ~clk; // -ve clk
    
    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
#2
for(i=0;i<=7;i=i+1)
begin
if(data_read[i]!=MISO_Stream[i])
begin
$display("|                      an error ocured, expected %b on data_read of %d and found %b |",MISO_Stream[i],i,data_read[i]);
check = 1;
end

if(expected_MOSI[i]!=found_MOSI[i])
begin
$display("|                      an error ocured, expected %b on MOSI of %d and found %b |",expected_MOSI[i],i,found_MOSI[i]);
check = 1;
end

end
if(!check)
$display("| the test was a success, the data to be sent is %b , the MOSI sequence is %b , the MISO sequence is %b and the recieved data is %b |",expected_MOSI , found_MOSI, MISO_Stream, data_read);
$display("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
end
endtask


task testMode3();
begin
    $strobe("   ");     
    $strobe("                     Now testing mode 3 : just like mode 1 but with a skipped falling edge in the beginning") ;
    $strobe("                                          =====================================");
    $strobe("                                         ||Testing MODE 3 ({CPOL,CPHA}= {1,1})||");
    $strobe("                                          =====================================");
    $strobe("time  clk    sclk    CS1     CS2     CS3    CPOL    CPHA   load    MOSI      data_wite     data_read  MISO slave_start");
#2
start = 1;
check = 0;
    {cpol,cpha} = 3;
     clk = 0;
     clk = ~clk; load =1; // +ve clk , idel state
     data_in = 'h94 ; 
     MISO_Stream = 'hba ;
     slave_address = 2 ;
    if(load)
       expected_MOSI = data_in;
    else
       expected_MOSI = data_read;
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b  +ve clk && -ve sclk,idel state",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
 
#2  clk = ~clk; load = 0; start = 0; // -ve clk
#2  clk = ~clk; // +ve clk && -ve sclk , skipped edge
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b  +ve clk && -ve sclk,skipped edge",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
    for(iterator = 0; iterator <= 7 ; iterator = iterator + 1)
    begin
 	#2 clk = ~clk; //-ve clk
        #2 clk = ~clk; //+ve clk && +ve sclk,writing data on MOSI
$strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b  +ve clk && +ve sclk,writing data on MOSI",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);
       
        #2 clk = ~clk; //-ve clk
         found_MOSI[iterator]=MOSI;
        #2 clk = ~clk; //+ve clk && -ve sclk, reading data from MISO
           MISO = MISO_Stream[iterator];
        $strobe("%g  \t%b \t%b \t%b \t%b \t%b \t%b \t%b \t%d  \t%b     \t%b      \t%b  \t\t%b \t%b  +ve clk && +ve sclk, reading data from MISO",$time,clk,SCLK,CS1,CS2,CS3,cpol,cpha,load,MOSI,data_in,data_read,MISO,slave_start);

    end
$strobe("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
#2
for(i=0;i<=7;i=i+1)
begin
if(data_read[i]!=MISO_Stream[i])
begin
$display("|                     an error ocured, expected %b on data_read of %d and found %b |",MISO_Stream[i],i,data_read[i]);
check = 1 ;
end

if(expected_MOSI[i]!= found_MOSI[i])
begin
$display("|                     an error ocured, expected %b on MOSI of %d and found %b |",expected_MOSI[i],i,found_MOSI[i]);
check = 1;
end
end
if(!check)
$display("| the test was a success, the data to be sent is %b , the MOSI sequence is %b , the MISO sequence is %b and the recieved data is %b |",expected_MOSI , found_MOSI, MISO_Stream, data_read);
$display("|-----------------------------------------------------------------------------------------------------------------------------------------------------------|");
end
endtask

endmodule 