#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"

User Function logusr()
    Local aDados := {}
    PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' /*USER 'ADMIN' PASSWORD 'MSIGA!@#'*/ MODULO 'EST'
        aDados := FWSFALLUSERS()
    RESET ENVIRONMENT
    //RestArea(aArea)
Return
