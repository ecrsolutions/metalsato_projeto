#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTC01           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Retorna informações dos apontamentos realizados na tabela SH6  ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 11/01/2020         ¦ Last Modified time ¦  11/01/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTC01(nOpc)
    Local cOrdem := ""
    Local cProdt := ""
    Local cEmiss := ""
    Local cOper  := ""
    Local aArea  := GetArea()
    Local aCols  := {}
    Local aField := {}
    Local ahead  := {}
    Local aAlter := {}
    Local nLin   := 0
    Local oTFont := TFont():New('Times New Roman',,20,,.T.)
    Local aTamanho := MsAdvSize() 
    Local nJanAltu := aTamanho[6]

    cOrdem := SH6->H6_OP

    cProdt := rtrim(SH6->H6_PRODUTO)
	cProdt += " - "
	cProdt += rtrim(Posicione("SB1",1,xFilial("SB1")+SH6->H6_PRODUTO,"B1_DESC"))

	nAltIni := aTamanho[1]
    nAltFim := nJanAltu/2

    //monta aHead

	aAdd(aField, { "H6_OPERAC" , "Operação"         ,"OPERACAO"  })
    aAdd(aField, { "G2_DESCRI" , "Descrição"        ,"DESCRICAO" })
    aAdd(aField, { "H6_QTDPROD", "Qtd. Produzida"   ,"DESCRICAO" })
    aAdd(aField, { "C2_QUJE"   , "Saldo a Produzir" ,"VALOR"     })

    aHead  := GetAheader(aField)

    //monta acols
    DbSelectArea("SC2")
    DbSetOrder(1)
    If dbSeek(xFilial("SC2")+cOrdem)
        nQtdOp := SC2->C2_QUANT
        cEmiss := DTOC(SC2->C2_EMISSAO)
        
        SH6->(dbSelectArea("SH6"))
        SH6->(dbSetOrder(1))
        If SH6->(dbSeek(xFilial("SH6")+cOrdem))
            While !SH6->(EOF()) .and. SH6->H6_OP == cOrdem
                If SH6->H6_OPERAC <> cOper
                    cOper := SH6->H6_OPERAC
                    cDesc := Posicione("SG2",3,xFilial("SG2")+SH6->H6_PRODUTO+cOper,"G2_DESCRI")
                    aAdd(aCols,{SH6->H6_OPERAC,cDesc,SH6->H6_QTDPROD,SC2->C2_QUANT-SH6->H6_QTDPROD,.F.})
                Else
                    aCols[len(aCols),3] += SH6->H6_QTDPROD
                    aCols[len(aCols),4] := (SC2->C2_QUANT-aCols[len(aCols),3])
                EndIf
                SH6->(DbSkip())
            Enddo
        EndIf

        cOrdem += " - Qtd: "+rtrim(cValtoChar(SC2->C2_QUANT))
    EndIf

    cTitulo := "Detalhamento Ordem de Produção"
    
    DEFINE MSDIALOG oDlg2 TITLE cTitulo From 0,0 TO 700,850 OF oMainWnd PIXEL
		
		oSayBase:= tSay():New(nLin+=40,10,{||"Op: "+cOrdem},oDlg2,,oTFont,,,,.T.,CLR_RED,CLR_WHITE,250,100)
		
		oSayData:= tSay():New(nLin+=20,10,{||"Data: "+cEmiss},oDlg2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,250,100)

		oSayProd:= tSay():New(nLin+=20,10,{||"Produto: "+cProdt},oDlg2,,oTFont,,,,.T.,CLR_BLACK,CLR_WHITE,250,100)

		oBrw3:= MsNewGetDados():New(nAltFim*0.40,2,nAltFim*0.92,420,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter,0,99,"AllwaysTrue",,"AllwaysTrue",oDlg2,aHead,aCols)

    ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT EnchoiceBar(oDlg2, {|| }, {||oDlg2:End()} )


    DbCloseArea()
    RestArea(aArea)

Return


Static Function GetAheader(aCampos)
    Local aHead := {}
    Local nI := 0

    //monta array padrao aHeader
        dbSelectArea("SX3")
        SX3->(dbSetOrder(2))
        For nI := 1 to Len(aCampos)
    	    If dbSeek(aCampos[nI][1],.T.) 
                AADD(aHead,{IIF(!Empty(aCampos[nI][2]),rtrim(aCampos[nI][2]),rtrim(X3Titulo())),;
                            aCampos[nI][3] ,;  //SX3->X3_CAMPO,;                                                                                                                                                                                              
                            SX3->X3_PICTURE,;
                            SX3->X3_TAMANHO,;
                            SX3->X3_DECIMAL,;
                            SX3->X3_VALID,;
                            SX3->X3_USADO,;    //reservado
                            SX3->X3_TIPO,;
                            SX3->X3_F3,;       //reservado
                            SX3->X3_CONTEXT,;
                            SX3->X3_CBOX,;
                            SX3->X3_RELACAO,;
                            SX3->X3_WHEN})     //reservado
		    Endif
	    Next
	
Return aHead