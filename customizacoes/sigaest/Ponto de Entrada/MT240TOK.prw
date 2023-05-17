#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "TbiConn.ch"

User Function MT240TOK()
    Local lRet := .T.

    If FUNNAME() == "MATA185" 
        If Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_XINFETI") == "1"

            If empty(M->D3_XETIQUE)
                cTitulo  := "ATENÇÃO!"
                cErro    := "Etiqueta não informada."
                cSolucao := "Informe uma etiqueta válida para este produto."
                Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                lRet := .F.
                return
            EndIf

            If !empty(M->D3_XETIQUE)
                
                If !(lRet := ExistCpo("CB0", M->D3_XETIQUE))
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Código de etiqueta informado inexistente."
                    cSolucao := "Informe uma etiqueta válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                /*
                If SearchEtiq() <> 0
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Etiqueta ja utilizada anteriormente."
                    cSolucao := "Informe uma etiqueta válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
                */

                If M->D3_COD <> Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_CODPRO")
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Etiqueta informada não pertence ao produto que está sendo baixado."
                    cSolucao := "Informe uma etiqueta válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                If M->D3_QUANT - Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_QTDE") > 0
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Quantidade da baixa informada diverge da quantidade da etiqueta."
                    cSolucao := "Informe uma etiqueta válida para este produto ou corrija a quantidade baixada ."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
            EndIf

            If empty(M->D3_XOP)
                cTitulo  := "ATENÇÃO!"
                cErro    := "Ordem de Produção não informada."
                cSolucao := "Informe uma ordem de produção válida para este produto."
                Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                lRet := .F.
                return
            Else
                SC2->(DbSelectArea("SC2"))
                SC2->(DbSetOrder(1))
                If SC2->(dbSeek(xFilial("SC2")+M->D3_XOP))
                    If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF)
                        cTitulo  := "ATENÇÃO!"
                        cErro    := "Ordem de Produção já encerrada."
                        cSolucao := "Informe uma ordem de produção válida para este produto."
                        Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                        lRet := .F.
                        return
                    EndIf
                Else
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Ordem de Produção não encontrada."
                    cSolucao := "Informe uma ordem de produção válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
                SC2->(DbCloseArea())
            EndIf
        EndIf

        If Posicione("SB1",1,xFilial("SB1")+M->D3_COD,"B1_XINFETI") == "2"
            If empty(M->D3_XETIQUE)
                cTitulo  := "ATENÇÃO!"
                cErro    := "Etiqueta não informada."
                cSolucao := "Informe uma etiqueta válida para este produto."
                Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                lRet := .F.
                return
            EndIf

            If !empty(M->D3_XETIQUE)
                
                If !(lRet := ExistCpo("CB0", M->D3_XETIQUE))
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Código de etiqueta informado inexistente."
                    cSolucao := "Informe uma etiqueta válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                /*
                If SearchEtiq() <> 0
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Etiqueta ja utilizada anteriormente."
                    cSolucao := "Informe uma etiqueta válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf
                */

                If M->D3_COD <> Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_CODPRO")
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Etiqueta informada não pertence ao produto que está sendo baixado."
                    cSolucao := "Informe uma etiqueta válida para este produto."
                    Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
                    lRet := .F.
                    return
                EndIf

                If M->D3_QUANT - Posicione("CB0",1,xFilial("CB0")+M->D3_XETIQUE,"CB0_QTDE") > 0
                    cTitulo  := "ATENÇÃO!"
                    cErro    := "Quantidade da baixa informada diverge da quantidade da etiqueta."
                    cSolucao := "Informe uma etiqueta válida para este produto ou corrija a quantidade baixada ."
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