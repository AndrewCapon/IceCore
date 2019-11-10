// this code is a slight alteration of the code from rmiller, basically just fixes an issue where the RX side was always running a byte late in time.
// now requests for more data correctly.
// The original code can be found here: https://github.com/millerresearch/arduino-mystorm/blob/master/libraries/QSPI/examples/QSPIswtoleds/fpga/swtoleds.v#L103


// Receive QSPI data from master to slave
// DWIDTH (1 or 4) is number of data lines
// rxready is asserted for one clk period
//   when each input byte is available in rxdata

module qspislave_rx #(parameter DWIDTH=1) (
	input clk,
	input QCK, QSS,
	input [3:0] QD,
	output rxready,
	output [7:0] rxdata,
);

	// registers in QCK clock domain
	reg [8:0] shiftreg;
	reg inseq;

	// registers in main clk domain
	reg [7:0] inbuf;
	assign rxdata = inbuf;
	reg [2:0] insync;

	// synchronise inseq across clock domains
	always @(posedge clk)
		insync <= {inseq,insync[2:1]};
	assign rxready = (insync[1] != insync[0]);

	// wiring to load data from 1 or 4 data lines into shiftreg
	wire [8:0] shiftin = {shiftreg[8-DWIDTH:0],QD[DWIDTH-1:0]};


	// capture incoming data on rising SPI clock edge
	always @(posedge QCK or posedge QSS) begin
		if (QSS) begin
			shiftreg <= 0;
		end else begin
			if (shiftin[8]) begin
				inbuf <= shiftin[7:0];
				inseq <= ~inseq;
				shiftreg <= 0;
			end else if (shiftreg[7:0] == 0) begin
				shiftreg = {1'b1,QD[DWIDTH-1:0]};
			end else begin
				shiftreg <= shiftin;
			end
		end
	end
endmodule




// Transmit QSPI data from slave to master
// txready is asserted for one clk period
// we have till the next neg QCK to load data

module qspislave_tx #(parameter DWIDTH=1) (
	input clk,
	input QCK, QSS,
	output [3:0] QD,
	output txready,
	input [7:0] txdata
);
	// registers in QCK clock domain
	reg [8:0] shiftreg;
	reg outseq;
	assign QD[3:0] = shiftreg[8:9-DWIDTH];

	// registers in main clk domain
	reg [2:0] outsync;

	// synchronise outseq across clock domains
	always @(posedge clk)
		outsync <= {outseq,outsync[2:1]};
	assign txready = (outsync[1] != outsync[0]);

	// wiring to shift data from shiftreg into 1 or 4 data lines
	wire [8:0] shiftout = shiftreg << DWIDTH;
	wire [8:0] shiftrequest = shiftout << DWIDTH;


	// shift outgoing data on falling SPI clock edge
	always @(negedge QCK or posedge QSS) begin
		if (QSS) begin
			shiftreg <= 0;
		end else begin
			if (shiftout[7:0] == 0) begin
				shiftreg <= {txdata,1'b1};
			end else begin
				shiftreg <= shiftout;
				if (shiftrequest[7:0] == 0) begin
					outseq <= ~outseq;
				end
			end
		end
	end
endmodule

// module qspislave_tx #(parameter DWIDTH=1) (
// 	input clk,
// 	input QCK, QSS,
// 	output [3:0] QD,
// 	output txready,
// 	input [7:0] txdata,
// 	output reg [1:0] dbg
// );
// 	// reg [1:0] r_dbg;
// 	// assign dbg = r_dbg;

// 	// registers in QCK clock domain
// 	reg [8:0] shiftreg;
// 	reg outseq;
// 	assign QD[3:0] = shiftreg[8:9-DWIDTH];

// 	// registers in main clk domain
// 	reg [2:0] outsync;

// 	// synchronise outseq across clock domains
// 	always @(posedge clk)
// 		outsync <= {outseq,outsync[2:1]};
// 	assign txready = (outsync[1] != outsync[0]);

// 	// wiring to shift data from shiftreg into 1 or 4 data lines
// 	wire [8:0] shiftout = shiftreg << DWIDTH;

// 	// shift outgoing data on falling SPI clock edge
// 	always @(negedge QCK or posedge QSS) begin
// 		dbg <= 0;
// 		if (QSS) begin
// 			shiftreg <= 0;
// 		end else begin
// 			if (shiftout[7:0] == 0) begin
// 				outseq <= ~outseq;
// 				shiftreg <= {txdata,1'b1};
// 				dbg <= 1;
// 			end else begin
// 				shiftreg <= shiftout;
// 			end
// 		end
// 	end
// endmodule