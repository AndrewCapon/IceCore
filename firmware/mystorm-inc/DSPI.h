#pragma once

#include <stdint.h>
#include "mystorm.h"

class DSPI  
{
public:
  DSPI(QSPI_HandleTypeDef *phDualSpi);

  typedef enum _DSPICallbackType {cbTxComplete, cbRxComplete, cbTimeout, cbError} DSPICallbackType;
  typedef enum _DSPITestErrorType {etSuccess, etTransmitError, etReceiveError, etDataDifferentError, etUnknownError} DSPITestErrorType;

  void SetBusy(bool bBusy) 
  {
    m_bBusy = bBusy;
  }

  bool WaitWhileBusy(void)
  {
    // do we want a timeout here and return false?
    while(m_bBusy)
      ;

    return true;
  }

  void CallBack(DSPI::DSPICallbackType type)
  {
    SetBusy(false);
  }

  bool Transmit(uint16_t *puBuffer, uint16_t uAddr, uint16_t uLen);
  bool Receive(uint16_t *puBuffer, uint16_t uAddr, uint16_t uLen);

  DSPITestErrorType Test(void);

private:
  bool                m_bBusy;  
  QSPI_HandleTypeDef  *m_phDualSpi;

  bool Transmit(QSPI_CommandTypeDef &command, uint8_t *puBuffer);
  bool Receive(QSPI_CommandTypeDef &command, uint8_t *puBuffer);
};
