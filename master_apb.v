module master_apb #(parameter ADDR_WIDTH=8, parameter DATA_WIDTH =8, parameter STATE=2 )(
input PCLK,
input PRESETn,
input [ADDR_WIDTH-1:0] apb_write_paddr,
input [DATA_WIDTH-1:0] apb_write_data,
input [ADDR_WIDTH-1:0] apb_read_paddr,
input READ_WRITE,
input PREADY,
input transfer,
input [DATA_WIDTH-1:0] PRDATA,
output PWRITE,
output reg PSEL,
output reg PENABLE,
output [ADDR_WIDTH-1:0] PADDR,
output reg[DATA_WIDTH-1:0] PWDATA,
output reg [DATA_WIDTH-1:0] apb_read_data_out
);
parameter IDLE=2'b00;
parameter SETUP=2'b01;
parameter ACCESS=2'b11;

reg [STATE-1:0] current_state,next_state;
wire [DATA_WIDTH-1:0] temp_read;
always @(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
current_state<=IDLE;
else
current_state<=next_state;
end

always @(*)
begin
case (current_state)

IDLE: 
begin
if(transfer==1'b1)
next_state=SETUP;
else
next_state=IDLE;
end

SETUP:
begin
next_state=ACCESS;
end

ACCESS:
begin
if(PREADY==1'b1&&transfer==1'b1)
next_state=SETUP;
else if(PREADY==1'b1&&transfer==1'b0)
next_state=IDLE;
else
next_state=ACCESS;
end
default:
next_state=IDLE;
endcase
end

always@(*)
begin
PWDATA='b0;
case(current_state)
IDLE:
begin
PSEL=1'b0;
PENABLE=1'b0;
end

SETUP:
begin
PSEL=1'b1;
PENABLE=1'b0;
PWDATA=apb_write_data;
end

ACCESS:
begin
PSEL=1'b1;
PENABLE=1'b1;
PWDATA=apb_write_data;
end

default:
begin
PSEL=1'b0;
PENABLE=1'b0;
end
endcase
end

always @(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
apb_read_data_out<='b0;
else if (current_state==ACCESS && PWRITE==1'b0)
apb_read_data_out<=PRDATA;
end

assign PWRITE=READ_WRITE;
assign PADDR= READ_WRITE?apb_write_paddr:apb_read_paddr;
endmodule
