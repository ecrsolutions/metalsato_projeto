#Include "rwmake.ch"
#Include "protheus.ch"

//----------------------------------------------------------
/*/{Protheus.doc} PE01NFESEFAZ
Ponto de Entrada no momento da geração da transmição da documento de saída para a SEFAZ
@param não possui
@return não possui
@since 23/05/2019
@author Ronilton Oliveira Barros
@modified by Matheus Vinícius Alves
@project Implantação Pioneiro
/*/
//----------------------------------------------------------
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function PE01NFESEFAZ()
	Local aProd      := PARAMIXB[1]
	Local cMensCli   := PARAMIXB[2]
	Local cMensFis   := PARAMIXB[3]
	Local aDest      := PARAMIXB[4]
	Local aNota      := PARAMIXB[5]
	Local aInfoItem  := PARAMIXB[6]
	Local aDupl      := PARAMIXB[7]
	Local aTransp    := PARAMIXB[8]
	Local aEntrega   := PARAMIXB[9]
	Local aRetirada  := PARAMIXB[10]
	Local aVeiculo   := PARAMIXB[11]
	Local aReboque   := PARAMIXB[12]
	Local aNfVincRur := PARAMIXB[13]
	Local aEspVol    := PARAMIXB[14]
	Local aNfVinc    := PARAMIXB[15]
	Local AdetPag    := PARAMIXB[16]
	Local aObsCont   := PARAMIXB[17]
	Local aRetorno   := {}
	Local aArea      := GetArea()
	Local nX, cPesq
	Local aAreaSD2   := SD2->(GetArea())
	Local aAreaSC6   := SC6->(GetArea())
	Local aAreaSF2   := SF2->(GetArea())
	Local lRetSimbol := .F.
	Local cCliRefNFI := GetMV("MV_XCLINFI",.F.,"000005")    // Parâmetro que controla quais clientes desejam referênciar a nota de industrialização na nota de retorno simbólico
	Local cMatchID   := ""
	Local lDescIss	 := SuperGetMV("MV_DESCISS",,.F.) //Informa ao sistema se o ISS devera ser descontado do valor do titulo financeiro caso o cliente for responsável pelo recolhimento.
	Local lTpabiss	 := SuperGetMV("MV_TPABISS",,"2") == "1"
	Local lRuleDescISS  := lDescIss .And. lTpabiss
	
	ConOut(">>> 01. ACESSANDO " + ProcName(0) +": F2_DOC = "+SF2->F2_DOC+" / F2_SERIE = "+SF2->F2_SERIE+" / aNota[4] = " + aNota[4])
	//Valida se é uma nota de Saida
	If aNota[4] == "1"
		SB1->(dbSetOrder(1))
		SD2->(DbSetOrder(3))
		SF4->(DbSetOrder(1))
		SC5->(DbSetOrder(1))
		SC6->(DbSetOrder(2))
		SA7->(DbSetOrder(1))
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		SE1->(DbSetOrder(1))
		
		//Percorre os itens da nota
		For nX := 1 to Len(aProd)
			// Posiciona no cadastro do produto
			SB1->(dbSeek(XFILIAL("SB1")+aProd[nX,2]))
		
			ConOut(">>> 02. PERCORRENDO ITENS = PRODUTO " +aProd[nX,2] + " / ITEM = |"+aInfoItem[nX,4]+"|")
			//Posiciona no Item do vetor aProd para verificar informações do item da nota
			If SD2->(DbSeek(xfilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+aProd[nX,2]+aInfoItem[nX,4]))
				// Posiciona no TES
				SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES ))
				// Posiciona no Pedido
				SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO ))
				// Posiciona no Iem do Pedido
				SC6->(dbSeek(xFilial("SC6") + SD2->D2_COD + SD2->D2_PEDIDO + SD2->D2_ITEMPV ))
				// Posiciona no Cliente x Produto
				SA7->(dbSeek(xFilial("SA7") + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD ))
				
				ConOut(">>> 03. LOCALIZOU SD2: A1_XADPROD = " +SA1->A1_XADPROD + " / D2_NFORI = "+SD2->D2_NFORI + " / cMatchID = " + SC6->C6_XMATCH)
				
				// Adiciona informações sobre os dados adicionais do produto
				If SA1->A1_XADPROD == "S"
					If !Empty(SA1->A1_XCSTCLI) .And. !Empty(SA1->A1_XARMCLI)
						aProd[nX,25] := AllTrim(SA7->A7_CODCLI)
						aProd[nX,25] += "-" + Trim(If( SubStr(SD2->D2_CF,2,3) $ "902,903" , SA1->A1_XARMCLI, SA1->A1_XCSTCLI))
						aProd[nX,25] += "-" + Trim(If( SubStr(SD2->D2_CF,2,3) $ "902,903" , SA1->A1_XCSTCLI, SA1->A1_XARMCLI))
						aProd[nX,25] += PADL(AllTrim(SC6->C6_PEDCLI),10,"0") + "CG30 DIAS DATA LIQUIDA"
					ElseIf !Empty(SD2->D2_NFORI)
						IF  (rtrim(SD2->D2_CLIENTE) + rtrim(SD2->D2_LOJA)) $ GETMV("MV_XESP014")
							aProd[nX,25] := Posicione("SF1",1,xFilial("SF1")+SD2->D2_NFORI+SD2->D2_SERIORI+SD2->D2_CLIENTE+SD2->D2_LOJA,"F1_CHVNFE")
						Else
							aProd[nX,25] := LTrim(AllTrim(aProd[nX,25]) + " " + SD2->D2_NFORI)
						EndIf
					Endif
				Endif
				
				lRetSimbol := If( lRetSimbol , .T., SubStr(SD2->D2_CF,2,3) $ "902,903" )
				
				// Adiciona os codigos Match ID para envio na NF-e
				If !Empty(SC6->C6_XMATCH) .And. !( Trim(SC6->C6_XMATCH) $ cMatchID )
					cMatchID += If( Empty(cMatchID) , "", ",") + Trim(SC6->C6_XMATCH)
				Endif
			Endif

		Next nX
		
		ConOut(">>> 04. ADICIONANDO MATCH ID: cMatchID = " + cMatchID)
			
		If !Empty(cMatchID)
			cMensCli += " MATCH ID: " + cMatchID
		Endif

		cMensCli += " Usuario: "+UsrRetName( SubStr( Embaralha( SF2->F2_USERLGI, 1 ), 3, 6 ) )
		cMensCli += " "+Trim(SF2->F2_XMSGNF)

		// Caso o cliente desejar retornar a CHAVE DA NF de Industrialização
		If SA1->A1_COD $ cCliRefNFI .And. lRetSimbol
			cPesq := "RETORNO CONF. NF "
			If (nX := At(cPesq,cMensCli)) > 0
				SF2->(dbSetOrder(1))
				If SF2->(dbSeek(XFILIAL("SF3")+StrTran(SubStr(cMensCli,nX+Len(cPesq),Len(SF2->F2_DOC+SF2->F2_SERIE)+1),"/","")))
					AAdd( aNfVinc, { SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SA1->A1_CGC, SM0->M0_ESTCOB, SF2->F2_ESPECI1, SF2->F2_CHVNFE } )
				Endif
			Endif
		Endif

		//inclui fatura 
		If len(aDupl) == 0
			If SE1->(DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC))
				While !SE1->(EOF()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_PREFIXO == SF2->F2_SERIE .AND. SE1->E1_NUM == SF2->F2_DOC
					
					nValDupl := IIF(SE1->E1_VLRREAL > 0,SE1->E1_VLRREAL,SE1->E1_VLCRUZ)

					aadd(aDupl,{SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,;
					SE1->E1_VENCORI,;
					(nValDupl-SE1->E1_PIS-SE1->E1_COFINS-SE1->E1_CSLL-SE1->E1_INSS)-SE1->E1_IRRF- IIF(!lRuleDescISS,SE1->E1_ISS,0)})	
					SE1->(DbSkip())
				Enddo
			EndIf
		EndIf
	Else
		//cMensCli +=" "+Trim(SF1->F1_XMSGCOM)
	EndIf
	
	//If IsBlind()
	//	Conout(DtoC(dDataBase)+" - "+Time()+" - PASSANDO PE01NFEZEFAZ "+If( aNota[4] == "1", SF2->F2_DOC+"-"+SF2->F2_SERIE, SF1->F1_DOC+"-"+SF1->F1_SERIE)+" - Mensagem "+ Trim(cMensCli))
	//Else
	//	Alert(DtoC(dDataBase)+" - "+Time()+" - PASSANDO PE01NFEZEFAZ "+If( aNota[4] == "1", SF2->F2_DOC+"-"+SF2->F2_SERIE, SF1->F1_DOC+"-"+SF1->F1_SERIE)+" - Mensagem "+ Trim(cMensCli))
	//Endif
	
	aadd(aRetorno,aProd)
	aadd(aRetorno,cMensCli)
	aadd(aRetorno,cMensFis)
	aadd(aRetorno,aDest)
	aadd(aRetorno,aNota)
	aadd(aRetorno,aInfoItem)
	aadd(aRetorno,aDupl)
	aadd(aRetorno,aTransp)
	aadd(aRetorno,aEntrega)
	aadd(aRetorno,aRetirada)
	aadd(aRetorno,aVeiculo)
	aadd(aRetorno,aReboque)
	aadd(aRetorno,aNfVincRur)
	aadd(aRetorno,aEspVol)
	aadd(aRetorno,aNfVinc)
	aadd(aRetorno,AdetPag)
	aadd(aRetorno,aObsCont)
	
	RestArea(aAreaSD2)
	RestArea(aAreaSC6)
	RestArea(aAreaSF2)
	RestArea(aArea)
	
RETURN aRetorno

//Static Function AddConteudo(cString,cConteudo,cSepara)
//	Default cSepara := " - "
//Return If( Empty(cString) .Or. Empty(cConteudo) , "", cSepara) + AllTrim(cConteudo)
