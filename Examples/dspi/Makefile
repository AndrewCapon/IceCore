TTY   = /dev/cu.usbmodem00000000001A1
#DEBUG = -D DEBUG=1

chip.bin: chip.v QSPI_TX_RX.v DSPIMemory.v pll80.v Makefile
#	yosys -q -p "synth_ice40 -blif chip.blif" chip.v QSPI_TX_RX.v DSPIMemory.v pll80.v
#	arachne-pnr -m 100 -r -d 8k -P tq144:4k -p chip.pcf chip.blif -o chip.txt
#	icepack chip.txt chip.bin
	yosys $(DEBUG) -q -p "synth_ice40 -top chip -json chip.json" chip.v QSPI_TX_RX.v DSPIMemory.v pll80.v
	nextpnr-ice40 --package tq144:4k --hx8k --json chip.json --pcf chip.pcf --asc chip.asc --freq 80
	icepack chip.asc chip.bin                                      

.PHONY: upload
upload:
	stty -f $(TTY) raw
	cat chip.bin > $(TTY)

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin
