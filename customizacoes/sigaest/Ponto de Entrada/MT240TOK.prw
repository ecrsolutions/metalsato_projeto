#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "TbiConn.ch"

User Function MT240TOK()
    Local lRet := .T.

    If FUNNAME() == "MATA185" 
        If Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_XINFETI") == "1"

            If empty(M->D3_XETIQUE)
                cTitulo  := "ATEN��O!"
                cErro    := "Etiqueta n�o informada."
                cSolucao := "Informe uma etiqueta v�lida para este produto."
                Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                lRet := .F.
                return
            EndIf

            If !empty(M->D3_XETIQUE)
                
                If !(lRet := ExistCpo("CB0", M->D3_XETIQUE))
                    cTitulo  := "ATEN��O!"
                    cErro    := "C�digo de etiqueta informado inexistente."
                    cSolucao := "Informe uma etiqueta v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                /*
                If SearchEtiq() <> 0
                    cTitulo  := "ATEN��O!"
                    cErro    := "Etiqueta ja utilizada anteriormente."
                    cSolucao := "Informe uma etiqueta v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
                */

                If M->D3_COD <> Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_CODPRO")
                    cTitulo  := "ATEN��O!"
                    cErro    := "Etiqueta informada n�o pertence ao produto que est� sendo baixado."
                    cSolucao := "Informe uma etiqueta v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                If M->D3_QUANT - Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_QTDE") > 0
                    cTitulo  := "ATEN��O!"
                    cErro    := "Quantidade da baixa informada diverge da quantidade da etiqueta."
                    cSolucao := "Informe uma etiqueta v�lida para este produto ou corrija a quantidade baixada ."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
            EndIf

            If empty(M->D3_XOP)
                cTitulo  := "ATEN��O!"
                cErro    := "Ordem de Produ��o n�o informada."
                cSolucao := "Informe uma ordem de produ��o v�lida para este produto."
                Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                lRet := .F.
                return
            Else
                SC2->(DbSelectArea("SC2"))
                SC2->(DbSetOrder(1))
                If SC2->(dbSeek(xFilial("SC2")+M->D3_XOP))
                    If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF)
                        cTitulo  := "ATEN��O!"
                        cErro    := "Ordem de Produ��o j� encerrada."
                        cSolucao := "Informe uma ordem de produ��o v�lida para este produto."
                        Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                        lRet := .F.
                        return
                    EndIf
                Else
                    cTitulo  := "ATEN��O!"
                    cErro    := "Ordem de Produ��o n�o encontrada."
                    cSolucao := "Informe uma ordem de produ��o v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
                SC2->(DbCloseArea())
            EndIf
        EndIf

        If Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_XINFETI") == "2"
            If empty(M->D3_XETIQUE)
                cTitulo  := "ATEN��O!"
                cErro    := "Etiqueta n�o informada."
                cSolucao := "Informe uma etiqueta v�lida para este produto."
                Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                lRet := .F.
                return
            EndIf

            If !empty(M->D3_XETIQUE)
                
                If !(lRet := ExistCpo("CB0", M->D3_XETIQUE))
                    cTitulo  := "ATEN��O!"
                    cErro    := "C�digo de etiqueta informado inexistente."
                    cSolucao := "Informe uma etiqueta v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                /*
                If SearchEtiq() <> 0
                    cTitulo  := "ATEN��O!"
                    cErro    := "Etiqueta ja utilizada anteriormente."
                    cSolucao := "Informe uma etiqueta v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
                */

                If M->D3_COD <> Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_CODPRO")
                    cTitulo  := "ATEN��O!"
                    cErro    := "Etiqueta informada n�o pertence ao produto que est� sendo baixado."
                    cSolucao := "Informe uma etiqueta v�lida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                If M->D3_QUANT - Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_QTDE") > 0
                    cTitulo  := "ATEN��O!"
                    cErro    := "Quantidade da baixa informada diverge da quantidade da etiqueta."
                    cSolucao := "Informe uma etiqueta v�lida para este produto ou corrija a quantidade baixada ."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
            EndIf
        EndIf
    EndIf
    Return lRet

Static Function SearchEtiq()
    Local nRet := 0

    BeginSql Alias "TMPQRY"
        SELECT 
            ISNULL(SUM(QTD),0) AS 'QTD' 
        FROM
        (
            SELECT D3_QUANT*-1 AS QTD FROM %table:SD3%
            WHERE
                D_E_L_E_T_ = ''
                D3_FILIAL = %Exp:xFilial("SD3")%
                AND D3_XETIQUE = %Exp:M->D3_XETIQUE%
                AND LEFT(D3_CF,2) = 'RE'
            UNION ALL
            SELECT D3_QUANT FROM %table:SD3%
            WHERE
                D_E_L_E_T_ = ''
                D3_FILIAL = %Exp:xFilial("SD3")%
                AND D3_XETIQUE = %Exp:M->D3_XETIQUE%
                AND LEFT(D3_CF,2) = 'DE'
        ) A
    EndSql

    nRet := TMPQRY->QTD

    TMPQRY->(DbCloseArea())
Return  nRet