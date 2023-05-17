#INCLUDE 'TOTVS.ch'
 
/*/{Protheus.doc} User Function MA330TRB
    Permite alterar a ordenação do arquivo de trabalho TRB
    Obedecer a ordenação:
    DTOS(TRB_DTBASE)+TRB_SEQPRO+TRB_ORDEM+TRB_NIVEL+TRB_NIVSD3+TRB_CHAVE+TRB_SEQ
    - Para o método de apropriação sequêncial, o campo TRB_SEQPRO receberá o conteúdo
    dos campos D1_NUMSEQ, D2_NUMSEQ ou D3_NUMSEQ, de acordo com o TRB_ALIAS, ou seja,
    os movimentos são ordenados conforme a ordem de inclusão no sistema
    - Para o método de apropriação mensal ou diária, o campo TRB_SEQPRO ficará sempre vazio,
    ordenando conforme demais campos da chave
 
    @type  Function
    @author TOTVS
    /*/
User Function MA330TRB()
    
    Local aArea     := GetArea()
    Local aAreaTRB  := TRB->(GetArea())
    Local aFils     := {}
    Local cNomTRB   := "TRB"+cEmpAnt+"SP"
    Local cAlTRB    := GetNextAlias()
    Local cQuery    := ""
    Local cThreadID := Strzero(ThreadID(), 15)
    Local nFil      := 0
 
    //Realiza a filtragem das filiais selecionadas para esta execução
    cQuery := " Select TRB_FILIAL "
    cQuery += " From "+cNomTRB+" "
    cQuery += " Where TRB_THREAD = '"+cThreadID+"' " //Para obter as filiais do processamento atual
    cQuery += "   And D_E_L_E_T_ = ' ' " //filtrar pela thread
    cQuery += " Group By TRB_FILIAL  "
    cQuery := ChangeQuery(cQuery)   
 
    dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlTRB, .F., .F. )
 
    While !(cAlTRB)->(EoF())
        AAdd(aFils, (cAlTRB)->TRB_FILIAL)
        (cAlTRB)->(DbSkip())
    EndDo
    (cAlTRB)->(DbCloseArea())
 
    //            ===> IMPORTANTE <===
    //Implementar filtragem da área de trabalho conforme
    //necessidade da alteração da ordenação dos movimentos
 
    //Neste exemplo, iremos alterar a ordem 301 para 302
 
    //Montagem do where conforme índice 7 da TRB para melhor performance
    //TRB_THREAD+TRB_FILIAL+TRB_ORDEM+TRB_COD+TRB_NIVEL+TRB_NIVSD3+TRB_CHAVE+TRB_SEQ   
 
    For nFil := 1 To Len(aFils)
        cQuery := " Select R_E_C_N_O_ RECTRB "
        cQuery += " From "+cNomTRB+" "
        cQuery += " Where TRB_THREAD = '"+cThreadID+"' " //<- sempre filtrar pela thread
        cQuery += "   And TRB_FILIAL = '"+aFils[nFil]+"' "
        //cQuery += "   And TRB_ORDEM  = '300' And TRB_CF LIKE '%E4%' "
        cQuery += "   And (TRB_ORDEM  = '300' And TRB_CF LIKE '%E4%' OR TRB_ORDEM  = '300' And TRB_ALIAS IN ('SD2','SD1')) "
        cQuery += "   And TRB_COD  IN (SELECT DISTINCT B1_COD FROM SB1010  "
        cQuery += "   WHERE D_E_L_E_T_ = ' ' AND B1_TIPO IN ('PA'))  "
        cQuery += "   And D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
 
        dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAlTRB, .F., .F. )
 
        While !(cAlTRB)->(EoF())
            TRB->(DbGoTo((cAlTRB)->RECTRB))
            If RecLock('TRB', .F.)
                TRB->TRB_NIVEL := '99w' //Alterar ordem conforme necessidade
                TRB->(MsUnlock())
            EndIf
            (cAlTRB)->(DbSkip())
        EndDo
        (cAlTRB)->(DbCloseArea())
 
    Next nFil
 
    RestArea(aAreaTRB)
    RestArea(aArea)
    
Return
