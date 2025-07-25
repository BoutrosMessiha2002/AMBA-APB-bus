module master_apb_tb();
parameter ADDRESS=8;
parameter DATA =8;
parameter LOCATION=64;
parameter CLK=20;



reg PCLK,PRESETn,transfer,READ_WRITE;
reg [ADDRESS-1:0] apb_write_paddr,apb_read_paddr;
reg [DATA-1:0] apb_write_data;
wire [DATA-1:0] apb_read_data_out;


apb_top #(.ADDRESS(ADDRESS),.DATA(DATA),.LOCATION(LOCATION)) dut (
.PCLK(PCLK),
.PRESETn(PRESETn),
.transfer(transfer),
.READ_WRITE(READ_WRITE),
.apb_write_paddr(apb_write_paddr),
.apb_read_paddr(apb_read_paddr),
.apb_write_data(apb_write_data),
.apb_read_data_out(apb_read_data_out));



initial
begin
forever 
begin
#(CLK/2) PCLK=~PCLK;
end
end

initial begin
PCLK=1'b0;
PRESETn=1'b1;
apb_write_paddr='d2;
apb_write_data='d6;
READ_WRITE=1'b1;
transfer=1'b0;
#(CLK); 
PRESETn=1'b0;
#(CLK);
PRESETn=1'b1;
transfer=1'b1;
#(CLK*4);
apb_write_paddr='d16;
apb_write_data='d98;
#(CLK*2);
apb_write_paddr='d15;
apb_write_data='d3;
#(CLK*2);
apb_write_paddr='d20;
apb_write_data='d63;
transfer=1'b0;
#(CLK*2);
READ_WRITE=1'b0;
apb_read_paddr='d15;
transfer=1'b1;
#(CLK*4)
READ_WRITE=1'b1;
apb_write_paddr='d5;
apb_write_data='d10;
transfer=1'b1;
#(CLK*2);
transfer=1'b0;
end
endmodule
