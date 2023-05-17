#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "TbiConn.ch"

User Function MT105FIM()
    Local nOpcap := PARAMIXB
    Local cSolicitacao := SCP->CP_NUM
    
    MsgRun("Gerando pré requisição.","Aguarde",{||GeraPreReq()})

Return 

Static Function GeraPreReq()
    Local aemp := {"YY","01"}
    
    //PREPARE ENVIRONMENT EMPRESA aemp[1] filial aemp[2] USER 'Administrador' PASSWORD '' TABLES "SB2","SCQ","SC1","SAI" MODULO "EST"

    Pergunte("MTA106",.F.)
    
    cFiltraSCP := "CP_NUM <> 'B' .and. CP_NUM == '"+SCP->CP_NUM+"'"

    //não gera solicitação de compra / autorização de entraga
    MV_PAR03 := 2

    PARAMIXB1   := .F.
    PARAMIXB2   := MV_PAR01==1
    PARAMIXB3   := If(Empty(cFiltraSCP), {|| .T.}, {|| &cFiltraSCP})
    PARAMIXB4   := MV_PAR02==1
    PARAMIXB5   := MV_PAR03==1
    PARAMIXB6   := MV_PAR04==1
    PARAMIXB7   := MV_PAR05
    PARAMIXB8   := MV_PAR06
    PARAMIXB9   := MV_PAR07==1
    PARAMIXB10  := MV_PAR08==1
    PARAMIXB11  := MV_PAR09
    PARAMIXB12  := .T.
    
    /**************************************************************************************************************
    Essa função pode ser utilizada automaticamente, para isso deve-se passar o parâmetro PARAMIXB1 como Falso(.F.), 
    pois não será executada a MarkBrowse e o PARAMIXB12 como Verdadeiro(.T.).
     **************************************************************************************************************/
    MaSAPreReq(PARAMIXB1,PARAMIXB2,PARAMIXB3,PARAMIXB4,PARAMIXB5,PARAMIXB6,PARAMIXB7,PARAMIXB8,PARAMIXB9,PARAMIXB10,PARAMIXB11,PARAMIXB12)
Return