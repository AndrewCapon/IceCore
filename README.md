# IceCore
IceCore Ice40 HX based modular developement core 

**Top View**
![IceCore Module](https://github.com/folknology/IceCore/blob/master/cad/IceCore.jpg)
**Bottom View**
![IceCore Module](https://github.com/folknology/IceCore/blob/master/cad/IceCore-Bottom.jpg)


**Features**
* Ice40 HX4K - 4K Luts (8K for Yosys), 80/(128)Kbits BRAM, 2 PLLs, NVCM
* 16Mbit SDRAM 16 bits wide (143Mhz)
* 4Mbit Flash QSPI/SPI (100Mhz)
* 56 General purpose IOs, SPI, Uart, I2C/Can
* Stm32F730 200Mhz, 256KB Ram, 64KB Flash
* Triple 2.5MSPS ADCs (interleaved to 7.2MSPS)
* Dedicated Programming and debug USB 2.0FS
* Uart/Application specific USB2.0FS
* Digital video connector
* SDCard connector
* 4 Coloured Status LEDs
* 4 Coloured User LEDs
* 2 User buttons, 1 Mode/Boot buttoni

[Get it from Tindie as part of BlackIce Mx](https://www.tindie.com/products/Folknology/blackice-mx/)

![IceCore Module](https://github.com/folknology/IceCore/blob/master/cad/IceCore.png)


![Schematic](https://github.com/folknology/IceCore/blob/master/cad/IceCore-schematic.png)

Core modules can be combined with different carrier boards for example [BlackIce Mx](https://github.com/folknology/BlackIceMx)

Supports the [BlackEdge connectivity](https://github.com/folknology/BlackEdge) carriers

Some further [background information](https://forum.mystorm.uk/t/new-product-blackice-mx/551/10) can be found on the [myStorm forum](https://forum.mystorm.uk)


**DSPI Changes**

The verilog for an 8k 16bit memory via DSPI is in examples/dspi, use this for testing.

Fir the firnware there are two defines in Makefile :

-DUSE_DSPI : Adds the DSPI code and uses the DMA that the UART was using.
-DUSE_DSPI_TEST : Enables the test code, to run the test code send DSPI_TEST to the com port.

After building with these two defines and flashing the firmware you can test as follows:

cat dspiMemory.bin > <your com port>
echo "DSPI_TEST" > <your com port>
should give:

cat /dev/<your com port>
........................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................
The test runs 1000 iterations of random data to a random address and then reads it back to check it matches.

A character is printed for each iteration:

. = Success
X = Data read not the same as data written
T = Transmit Error
R = Receive Error
