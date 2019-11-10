#include "stdlib.h"
#include "DSPI.h"


DSPI::DSPI(QSPI_HandleTypeDef *phDualSpi)
: m_phDualSpi(phDualSpi)
{

}


bool DSPI::Transmit(QSPI_CommandTypeDef &command, uint8_t *puBuffer)
{
  bool bResult = false;

  if(WaitWhileBusy())
  {
    SetBusy(true);

    if (HAL_QSPI_Command(m_phDualSpi, &command, HAL_QPSI_TIMEOUT_DEFAULT_VALUE) == HAL_OK)
  		if(HAL_QSPI_Transmit_DMA(m_phDualSpi, puBuffer) == HAL_OK)
  			bResult = true;

  	if(!bResult)
      SetBusy(false);
  }

  return bResult;
}

bool DSPI::Receive(QSPI_CommandTypeDef &command, uint8_t *puBuffer)
{
  bool bResult = false;

  if(WaitWhileBusy())
  {
    SetBusy(true);

    if (HAL_QSPI_Command(m_phDualSpi, &command, HAL_QPSI_TIMEOUT_DEFAULT_VALUE) == HAL_OK)
  		if(HAL_QSPI_Receive_DMA(m_phDualSpi, puBuffer) == HAL_OK)
  			bResult = true;

  	if(!bResult)
      SetBusy(false);
  }

  return bResult;
}

bool DSPI::Transmit(uint16_t *puBuffer, uint16_t uAddr, uint16_t uLen)
{
  QSPI_CommandTypeDef     sCommand;

  sCommand.InstructionMode   = QSPI_INSTRUCTION_2_LINES;
  sCommand.Instruction       = 0x01;
  sCommand.AlternateByteMode = QSPI_ALTERNATE_BYTES_NONE;
  sCommand.DataMode          = QSPI_DATA_2_LINES;
  sCommand.DummyCycles       = 0;
  sCommand.DdrMode           = QSPI_DDR_MODE_DISABLE;
  sCommand.DdrHoldHalfCycle  = QSPI_DDR_HHC_ANALOG_DELAY;
  sCommand.SIOOMode          = QSPI_SIOO_INST_EVERY_CMD;

  sCommand.AddressMode       = QSPI_ADDRESS_2_LINES;
  sCommand.AddressSize			 = QSPI_ADDRESS_16_BITS;

  sCommand.Address					 = uAddr;
  sCommand.NbData       		 = uLen*2;


  return(Transmit(sCommand, (uint8_t *)puBuffer));
}

bool DSPI::Receive(uint16_t *puBuffer, uint16_t uAddr, uint16_t uLen)
{
  QSPI_CommandTypeDef     sCommand;

  sCommand.InstructionMode   = QSPI_INSTRUCTION_2_LINES;
  sCommand.Instruction       = 0x02;
  sCommand.AlternateByteMode = QSPI_ALTERNATE_BYTES_NONE;
  sCommand.DataMode          = QSPI_DATA_2_LINES;
  sCommand.DummyCycles       = 8;
  sCommand.DdrMode           = QSPI_DDR_MODE_DISABLE;
  sCommand.DdrHoldHalfCycle  = QSPI_DDR_HHC_ANALOG_DELAY;
  sCommand.SIOOMode          = QSPI_SIOO_INST_EVERY_CMD;

  sCommand.AddressMode       = QSPI_ADDRESS_2_LINES;
  sCommand.AddressSize			 = QSPI_ADDRESS_16_BITS;

  sCommand.Address					 = uAddr;
  sCommand.NbData       		 = uLen*2;


  return(Receive(sCommand, (uint8_t *)puBuffer));
}

DSPI::DSPITestErrorType DSPI::Test(void)
{
  DSPITestErrorType result = DSPITestErrorType::etUnknownError;
  
  uint16_t txData[16] = {0};
  uint16_t rxData[16]	= {0};

  // randomize test data
  for(uint32_t u = 0; u < 16; u++)
    txData[u]=rand();

  // randomise address
  uint32_t uAddress = rand() % (1024*8);

  if(Transmit(txData, uAddress, 16))
  {
    if(Receive(rxData, uAddress, 16))
    {
      // wait for DMA
      WaitWhileBusy();

      // Check
      bool bDiff = false;
      for(uint32_t i =0; (!bDiff) && (i < 16); i++)
      {
      	if(txData[i] != rxData[i])
  	  	  bDiff = true;
      }
      if(bDiff)
        result = DSPITestErrorType::etDataDifferentError;
      else
        result = DSPITestErrorType::etSuccess;
    }
    else
      result = DSPITestErrorType::etReceiveError;
  }
  else
    result = DSPITestErrorType::etTransmitError;

  return result;
}
