#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "TbiConn.ch"

User Function M185GRV()

    If !empty(SD3->D3_XETIQUE)
        //atualiza dados da etiqueta
        CB0->(DbSetOrder(1))
		If CB0->(DbSeek(xFilial("CB0")+SD3->D3_XETIQUE))
            Reclock("CB0",.F.)
                CB0->CB0_LOCAL   := IIF(SD3->D3_CF == 'RE3',GETMV("MV_LOCPROC"),SD3->D3_LOCAL)
                CB0->CB0_USUARI  := RetCodUsr()
                CB0->CB0_NUMSEQ  := SD3->D3_NUMSEQ
                CB0->CB0_STATUS  := "1"
                CB0->CB0_LOCORIG := SD3->D3_LOCAL
                CB0->CB0_ORIGEM  := "SD3"
            MsUnlock()

            //GRAVA LOG DA ETIQUETA
               //{"06",{"CBG_CODPRO"   ,"CBG_QTDE"   ,"CBG_LOTE"   ,"CBG_SLOTE"    ,"CBG_ARM"    ,"CBG_END"          ,"CBG_OP"   ,"CBG_CC"  ,"CBG_TM"  ,"CBG_CODETI"   ,"CBG_OBS"}},;  //requisicao		
            CBLog("06",{CB0->CB0_CODPRO,CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,CB0->CB0_LOCAL,GetMV("MV_ENDPROC"),SD3->D3_XOP,SD3->D3_CC,SD3->D3_TM,CB0->CB0_CODETI,"Requisição Processo"})
        EndIf
        CB0->(dbCloseArea())
    EndIf
Return


