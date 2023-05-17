#Include "rwmake.ch"
/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATE01   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Execblock de preparação para geração do retorno simbólico     ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATE01(cNFInd,cSerInd)
   	Local cPedido, vAux, lJunta
	Local aArea  := GetArea()
	Local vAcumu := {}
	Local vItens := {}
	Local vBenef := {}
	Local cTES   := GetMV("MV_XTSBEN",.F.,"506")   // TES de Saída de Devolução
	Local lRet   := .F.
	
	SF2->(dbSetOrder(1))
	If !SF2->(dbSeek(XFILIAL("SF2")+cNFInd+cSerInd))
		Return lRet
	Endif
	
	// Define se NÃO aglutina os produtos iguais de retorno simbólico em um item por produto
	lJunta := !(SF2->F2_CLIENTE $ GetMV("MV_XNAGLUT",.F.,"000005"))
	
	// Se não gerar a nota de retorno simbólico
	SA1->(dbSetOrder(1))
	If !SA1->(dbSeek(XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)) .Or. SA1->A1_XRETREM <> "1"
		Return lRet
	Endif
	
	SF4->(dbSetOrder(1))
	SC6->(dbSetOrder(1))
	
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(XFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.))
	
	cPedido := SC6->C6_PEDCLI
	
	While !SD2->(Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == XFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE
		
		// Posiciona no Iem do Pedido
		SC6->(dbSeek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD ))
		SF4->(dbSeek(XFILIAL("SF4")+SD2->D2_TES))

		If SF4->F4_XRETREM == "1" .And. SF4->F4_PODER3 == "N"
			AAdd( vItens , { SD2->D2_COD, SD2->D2_QUANT, SC6->C6_PEDCLI, SC6->C6_XLINPED})
		Endif
		
		SD2->(dbSkip())
	Enddo
	
	If Empty(vItens)  // Se encontrou itens para geração
		Return lRet
	Endif

	If !MsgYesNo("Deseja gerar a nota fiscal de Retorno Simbólico ?","Retorno Simbólico")
		Return lRet
	Endif
	
	// Valida o parâmetro do TES de retorno simbólico
	If Empty(cTES) .Or. !SF4->(dbSeek(XFILIAL("SF4")+cTES))
		Aviso("INVÁLIDO","TES informado no parâmetro MV_XTSBEN não existe !",{"OK"},1)
		Return lRet
	ElseIf SF4->F4_PODER3 <> "D"
		Aviso("INVÁLIDO","TES de Retorno simbólico ("+SF4->F4_CODIGO+") não está configurado corretamente !",{"OK"},1)
		Return lRet
	Endif
	
	vAux := u_STFATE02(SF2->F2_CLIENTE,SF2->F2_LOJA,vItens,@vAcumu,lJunta)
	
	If lRet := !Empty(vAux)  // Se encontrou itens
		If lRet := !Empty(Posicione("SA1",1,XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_COND"))
			AAdd( vBenef , { cPedido, SF2->F2_CLIENTE, SF2->F2_LOJA, aClone(vAux), cTES} )
			
			lRet := u_STGeraPedido(vBenef,.T.)
		Else
			Aviso("INVÁLIDO","Condição de pagamento inválida para o cliente "+SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+" !",{"OK"},1)
		Endif
	Else
		Aviso("INVÁLIDO","Não existe saldo suficiente para atender todos os pedidos a faturar !",{"OK"},1)
	Endif
	
	RestArea(aArea) 

Return lRet