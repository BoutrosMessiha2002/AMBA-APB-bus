module RAM_slave #(parameter ADDRESS=8, parameter DATA=8, parameter LOCATION=64, parameter STATES=3)(
input PWRITE,PCLK,PRESETn,
input PSEL1,
input PENABLE,
input [ADDRESS-1:0] paddr,
input [DATA-1:0] pwdata,
output reg [DATA-1:0] prdata,
output reg PREADY
);

parameter IDLE=2'b00;
parameter TRANSFER=2'b01;
parameter WRITE=2'b11;
parameter READ=2'b10;


reg [STATES-1:0] current_state,next_state;
reg [DATA-1:0] memory [0:LOCATION-1];
integer i;

always @(posedge PCLK or negedge PRESETn )
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
if(PSEL1==1'b1)
next_state=TRANSFER;
else 
next_state=IDLE;

TRANSFER:
if(PENABLE==1'b1&&PWRITE==1'b0)
next_state=READ;
else if(PENABLE==1'b1&&PWRITE==1'b1)
next_state=WRITE;
else
next_state=TRANSFER;

READ:
next_state=IDLE;

WRITE:
next_state=IDLE;

default:
next_state=IDLE;
endcase
end

always @(*)
if(!PRESETn)
begin
prdata='b0;
PREADY=1'b0;
end
else
begin
    case(current_state)
    IDLE:
    begin
        prdata='b0;
        PREADY=1'b0;
    end
    TRANSFER:
    begin
        prdata='b0;
        PREADY=1'b0;
    end
    READ:
    begin
        prdata=memory[paddr];
        PREADY=1'b1;
    end
    WRITE:
    begin
        PREADY=1'b1;
    end
    endcase
end
always @(posedge PCLK or negedge PRESETn)
begin
if(!PRESETn)
begin
    for(i=0;i<LOCATION;i=i+1)
    memory[i]<='b0;
end
else if(current_state==WRITE)
memory[paddr]<=pwdata;
end
endmodule
