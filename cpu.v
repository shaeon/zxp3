//-------------------------------------------------------------------------------------------------
// This file is part of the ZX Spectrum +3 project.
// https://github.com/kyp069/zxp3
//-------------------------------------------------------------------------------------------------
// CPU: Z80 NMOS silicon-to-RTL core by dr.Titus (https://github.com/dr-Titus/z80-silicon-rtl),
// clock-enable version (https://github.com/shaeon/z80-silicon-rtl).
// Define USE_T80 to go back to T80pa.
//-------------------------------------------------------------------------------------------------
module cpu
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire       ne,
	input  wire       pe,
	input  wire       reset,
	output wire       iorq,
	output wire       mreq,
	output wire       rfsh,
	input  wire       wayt,
	input  wire       irq,
	input  wire       nmi,
	output wire       m1,
	output wire       rd,
	output wire       wr,
	output wire[15:0] a,
	input  wire[ 7:0] d,
	output wire[ 7:0] q
);
//-------------------------------------------------------------------------------------------------
`ifdef USE_T80

T80pa Cpu
(
	.CLK    (clock  ),
	.CEN_n  (ne     ),
	.CEN_p  (pe     ),
	.RESET_n(reset  ),
	.BUSRQ_n(1'b1   ),
	.WAIT_n (wayt   ),
	.BUSAK_n(       ),
	.HALT_n (       ),
	.IORQ_n (iorq   ),
	.MREQ_n (mreq   ),
	.RFSH_n (rfsh   ),
	.INT_n  (irq    ),
	.NMI_n  (nmi    ),
	.M1_n   (m1     ),
	.RD_n   (rd     ),
	.WR_n   (wr     ),
	.A      (a      ),
	.DI     (d      ),
	.DO     (q      ),
	.DIRSet (1'b0   ),
	.DIR    (212'd0 ),
	.OUT0   (1'b0   ),
	.REG    (       ),
	.R800_mode(1'b0 )
);

`else

// dr.Titus core: control signals are active high, so invert them here.
// cep = rising edge of the Z80 clock, cen = falling edge (same as T80pa CEN_p/CEN_n).

wire cpuIorq, cpuMreq, cpuRfsh, cpuM1, cpuRd, cpuWr;

Z80 Cpu
(
	.clk       (clock   ),
	.cep       (pe      ),
	.cen       (ne      ),
	.data_in   (d       ),
	.data_out  (q       ),
	.adr       (a       ),
	.mreq      (cpuMreq ),
	.iorq      (cpuIorq ),
	.rd        (cpuRd   ),
	.wr        (cpuWr   ),
	.data_z    (        ),
	.adr_z     (        ),
	.controls_z(        ),
	.rfsh      (cpuRfsh ),
	.p_m1      (cpuM1   ),
	.halt      (        ),
	.p_wait    (!wayt   ),
	.p_int     (!irq    ),
	.nmi       (!nmi    ),
	.reset     (!reset  ),
	.busrq     (1'b0    ),
	.busack    (        )
);

assign iorq = !cpuIorq;
assign mreq = !cpuMreq;
assign rfsh = !cpuRfsh;
assign m1   = !cpuM1;
assign rd   = !cpuRd;
assign wr   = !cpuWr;

`endif
//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
