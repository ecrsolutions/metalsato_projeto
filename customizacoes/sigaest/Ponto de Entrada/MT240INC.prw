User Function MT240INC()
    Local cProd  := SD3->D3_COD
    Local nRecno := SD3->(Recno())
    Local cEtique := ""

    //Aviso('PE: MT240INC',;       ' Produto: '+cProd+Chr(13)+ ;      ' Registro número: '+Str(nRecno)+Chr(13), {'OK'})
    If FUNNAME() == "MATA681" 
        If Posicione("SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_XINFETI") == "2" .and. SD3->D3_CF $ ('RE1,RE2')
            cEtiq := GetUltEtq()
            SD3->D3_XETIQUE := cEtiq
            SD3->D3_XOP     := SD3->D3_OP
            CBLog("06",{SD3->D3_COD,SD3->D3_QUANT,SD3->D3_LOTECTL,SD3->D3_NUMLOTE,SD3->D3_LOCAL,GetMV("MV_ENDPROC"),SD3->D3_XOP,SD3->D3_CC,SD3->D3_TM,cEtiq,"Requisição Processo"})
        EndIf
    EndIf
 
 Return 

 Static Function GetUltEtq()
    Local cEtiq := ""
        BeginSql Alias "TMPQRY"
            SELECT TOP1 D3_XETIQUE FROM %table:SD3%
            WHERE
                D_E_L_E_T_ = ''
                AND D3_FILIAL     = %Exp:xFilial("SD3")%
                AND D3_COD        = %Exp:SD3->D3_COD%
                AND LEFT(D3_CF,2) = 'RE3'
            ORDER BY D3_EMISSAO DESC
        EndSql

        cEtiq := TMPQRY->D3_XETIQUE

        TMPQRY->(DbCloseArea())
 Return cEtiq

Return