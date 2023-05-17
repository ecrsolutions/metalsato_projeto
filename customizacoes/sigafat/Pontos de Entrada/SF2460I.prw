#Include "Protheus.ch"
#Include "Rwmake.ch"

/*_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Programa  ¦ SF2460I    ¦ Autor ¦ Ronilton O. Barros     ¦ Data ¦ 17/12/2019 ¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada após gravação do documento de saída            ¦¦¦
¦¦+-----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SF2460I()
	Local oDlg, cNomeCli, oVolume, oEspecie, oPeso, oPesoB, oTPFrete, oVeiculo, oMotoris, oNomMoto
	Local nOpcA    := 0
	Local cObsNFE1 := AllTrim( If( SF2->(FieldPos("F2_XMSGNF")) > 0 , SF2->F2_XMSGNF, TamSX3('F2_XMSGNF')[01]) )
	Local cTransp  := SF2->F2_TRANSP
	Local bNomTran := {|| Posicione("SA4",1,XFILIAL("SA4")+cTransp,"A4_NOME") }
	Local cNomTran := Eval(bNomTran)
	Local cVeiculo := SF2->F2_XVEICUL
	Local cMotoris := SF2->F2_XMOTORI
	Local bNomMoto := {|| Posicione("DA4",1,XFILIAL("FA4")+cMotoris,"DA4_NOME") }
	Local cNomMoto := Eval(bNomMoto)
	Local cTPFrete := Space(20)
	Local nPFrete  := 0
	Local aTPFrete := TipoFrete(SF2->F2_TPFRETE,@cTPFrete,@nPFrete)
	Local nVolume  := SF2->F2_VOLUME1
	Local cEspecie := SF2->F2_ESPECI1
	Local nPeso    := 0   //SF2->F2_PLIQUI
	Local nPesoB   := 0   //SF2->F2_PBRUTO
	Local nLin     := 0
	Local cPedClis := ""
	Local cPedidos := ""

	If SF2->F2_TIPO $ "DB"
		cNomeCli := Posicione('SA2',1,xFilial('SA2') + SF2->F2_CLIENTE + SF2->F2_LOJA , "A2_NOME" )
	Else
		cNomeCli := Posicione('SA1',1,xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA , "A1_NOME" )
	Endif
	
	If Empty(cObsNFE1)
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(XFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.))
		While !SD2->(Eof()) .And. XFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE
			// Posiciona no cadastro do produto
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(XFILIAL("SB1")+SD2->D2_COD))
			
			// Posiciona no cadastro do TES
			SF4->(DbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES ))
			
			// Posiciona no item do pedido de venda
			SC6->(DbSetOrder(2))
			If SC6->(dbSeek(xFilial("SC6") + SD2->D2_COD + SD2->D2_PEDIDO + SD2->D2_ITEMPV ))
				// Adiciona os números dos pedidos do cliente
				If !(AllTrim(SC6->C6_PEDCLI) $ cPedClis)
					cPedClis += AddConteudo(cPedClis,SC6->C6_PEDCLI,", ")
				Endif
				// Adiciona os números do pedido de venda gerados
				If !(AllTrim(SC6->C6_NUM) $ cPedidos)
					cPedidos += AddConteudo(cPedidos,SC6->C6_NUM,", ")
				Endif
			Endif
			
			// Adiciona informações da mensagem legal
			If !(AllTrim(SF4->F4_XCARFIS) $ cObsNFE1)
				cObsNFE1 += AddConteudo(cObsNFE1,SF4->F4_XCARFIS,", ")
			Endif
			
			SD2->(dbSkip())
		Enddo
		
		// Monta as mensagens específicas do cliente
		If !Empty(cPedClis)
			cObsNFE1 := "Pedido(s): " + cPedClis + " Ref. nosso pedido " + cPedidos + " " + AllTrim(cObsNFE1)
		Endif
	Endif
	
	cObsNFE1 := If( Type("__cMensNF") <> "U" .And. !Empty(__cMensNF) , __cMensNF + If( Empty(cObsNFE1) , "", " - "), "") + cObsNFE1
	
	DEFINE MSDIALOG oDlg TITLE "Complemento da Nota Fiscal" From 0,0 TO 440,400 OF oMainWnd PIXEL
	
	@ nLin,010 SAY "Documento : " + SF2->F2_DOC + '/' + SF2->F2_SERIE PIXEL OF oDlg
	@ nLin,160 SAY "Filial : " + SF2->F2_FILIAL PIXEL OF oDlg
	nLin += 10
	@ nLin,010 SAY "Cliente : " + SF2->F2_CLIENTE + '/' + SF2->F2_LOJA + ' - ' + cNomeCli PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Transportadora" PIXEL OF oDlg
	@ nLin,050 MSGET oTransp  VAR cTransp  F3 "SA4" VALID Vazio(cTransp) .Or. ExistCpo("SA4",cTransp) SIZE 40,7 PIXEL OF oDlg
	oTransp:bLostFocus := {|| cNomTran := Eval(bNomTran), oNomTran:Refresh() }
	@ nLin,090 MSGET oNomTran VAR cNomTran SIZE 100,7 WHEN .F. PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Veiculo" PIXEL OF oDlg
	@ nLin,050 MSGET oVeiculo  VAR cVeiculo  F3 "DA3" VALID Vazio(cVeiculo) .Or. ExistCpo("DA3",cVeiculo) SIZE 40,7 PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Motorista" PIXEL OF oDlg
	@ nLin,050 MSGET oMotoris  VAR cMotoris  F3 "DA4" VALID Vazio(cMotoris) .Or. ExistCpo("DA4",cMotoris) SIZE 40,7 PIXEL OF oDlg
	oMotoris:bLostFocus := {|| cNomMoto := Eval(bNomMoto), oNomMoto:Refresh() }
	@ nLin,090 MSGET oNomMoto VAR cNomMoto SIZE 100,7 WHEN .F. PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Volume" PIXEL OF oDlg
	@ nLin,030 MSGET oVolume  VAR nVolume  Picture "@E 99999" VALID Vazio(nVolume) .Or. Positivo(nVolume) SIZE 60,7 PIXEL OF oDlg
	@ nLin,100 SAY "Especie" PIXEL OF oDlg
	@ nLin,130 MSGET oEspecie VAR cEspecie SIZE 60,7 PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Peso" PIXEL OF oDlg
	@ nLin,030 MSGET oPeso  VAR nPeso  Picture "@E 999999.9999" VALID Vazio(nPeso) .Or. Positivo(nPeso) SIZE 60,7 PIXEL OF oDlg
	@ nLin,100 SAY "Peso Bruto" PIXEL OF oDlg
	@ nLin,130 MSGET oPesoB VAR nPesoB Picture "@E 999999.9999" VALID Vazio(nPesoB) .Or. Positivo(nPesoB) SIZE 60,7 PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Tipo Frete" PIXEL OF oDlg
	@ nLin,040 COMBOBOX oTPFrete VAR cTPFrete ITEMS aTPFrete SIZE 70,7 PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Observação" PIXEL OF oDlg
	nLin += 10
	@ nLin,010 GET cObsNFE1 SIZE 180,75 MEMO PIXEL OF oDlg
	nLin += 80
	@ nLin,165 BMPBUTTON TYPE 01 ACTION If(!Empty(cObsNFE1),(nOpcA := 1,oDlg:End()),)
	
	oTpFrete:nAt := nPFrete
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If nOpcA == 1
		RecLock("SF2",.F.)
		SF2->F2_TRANSP  := cTransp
		SF2->F2_XVEICUL := cVeiculo
		SF2->F2_VEICUL1 := cVeiculo
		SF2->F2_XMOTORI := cMotoris
		SF2->F2_TPFRETE := cTPFrete
		SF2->F2_VOLUME1 := nVolume
		SF2->F2_ESPECI1 := cEspecie
		SF2->F2_PLIQUI  := nPeso
		SF2->F2_PBRUTO  := nPesoB
		SF2->F2_XMSGNF  := AllTrim(cObsNFE1)
		MsUnLock()
	Endif
	
Return

Static Function AddConteudo(cString,cConteudo,cSepara)
	Default cSepara := " - "
Return If( Empty(cString) .Or. Empty(cConteudo) , "", cSepara) + AllTrim(cConteudo)

Static Function TipoFrete(cTPFrete,cFrete,nPos)
	Local aSX3BOX := RetSx3Box(GetSX3Cache("C5_TPFRETE","X3_CBOX"),,,1)
	Local aRet    := {}
	
	nPos := AScan( aSX3BOX , {|x| x[2] == cTPFrete } )
	
	// Monta a lista de opções do Frete
	AEval( aSX3BOX , {|x| AAdd( aRet , x[1] ) } )
	
	If nPos > 0
		cFrete := aRet[nPos]
	Endif
	
Return aRet