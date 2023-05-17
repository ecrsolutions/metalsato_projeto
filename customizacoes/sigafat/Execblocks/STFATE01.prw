#Include "Protheus.ch"

/*_______________________________________________________________________________
���������������������������������������������������������������������������������
��+-----------+------------+-------+----------------------+------+------------+��
��� Programa  � STFATE01   � Autor � Ronilton O. Barros   � Data � 06/01/2020 ���
��+-----------+------------+-------+----------------------+------+------------+��
��� Descri��o � Execblock de prepara��o para gera��o do retorno simb�lico     ���
��+-----------+---------------------------------------------------------------+��
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function STFATE01(cNFInd,cSerInd,vItens,cPedido,aItens)
   	Local vAux, lJunta, cCodCli, cLojaCli, lMonitor, lGeraPed
	Local aArea  := GetArea()
	Local vAcumu := {}
	Local vBenef := {}
	Local cTES   := GetMV("MV_XTSBEN",.F.,"506")   // TES de Sa�da de Devolu��o
	Local lRet   := .F.
	
	Default vItens := {}
	
	SF4->(dbSetOrder(1))
	
	// Valida o par�metro do TES de retorno simb�lico
	If Empty(cTES) .Or. !SF4->(dbSeek(XFILIAL("SF4")+cTES))
		Aviso("INV�LIDO","TES informado no par�metro MV_XTSBEN n�o existe !",{"OK"},1)
		Return lRet
	ElseIf SF4->F4_PODER3 <> "D"
		Aviso("INV�LIDO","TES de Retorno simb�lico ("+SF4->F4_CODIGO+") n�o est� configurado corretamente !",{"OK"},1)
		Return lRet
	Endif
	
	If Empty(vItens)
		SF2->(dbSetOrder(1))
		If !SF2->(dbSeek(XFILIAL("SF2")+cNFInd+cSerInd))
			Return lRet
		Endif
		
		// Se n�o gerar a nota de retorno simb�lico
		SA1->(dbSetOrder(1))
		If !SA1->(dbSeek(XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)) .Or. SA1->A1_XRETREM <> "1"
			Return lRet
		Endif
		
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
		
		If Empty(vItens)  // Se encontrou itens para gera��o
			Return lRet
		Endif
		
		If !MsgYesNo("Deseja gerar a nota fiscal de Retorno Simb�lico ?","Retorno Simb�lico")
			Return lRet
		Endif
		
		lMonitor := .T.
		lGeraPed := .T.
	Else
		lMonitor := .F.
		lGeraPed := .F.
	Endif
	
	cCodCli  := SA1->A1_COD
	cLojaCli := SA1->A1_LOJA
	
	// Define se N�O aglutina os produtos iguais de retorno simb�lico em um item por produto
	lJunta := !(cCodCli $ GetMV("MV_XNAGLUT",.F.,"000005"))
	
	vAux := u_STFATE02(cCodCli,cLojaCli,vItens,@vAcumu,lJunta)
	
	If lRet := !Empty(vAux)  // Se encontrou itens
		If lRet := !Empty(Posicione("SA1",1,XFILIAL("SA1")+cCodCli+cLojaCli,"A1_COND"))
			AAdd( vBenef , { cPedido, cCodCli, cLojaCli, aClone(vAux), cTES} )
			
			lRet := u_STGeraPedido(vBenef,lMonitor,lGeraPed,@aItens)
		Else
			Aviso("INV�LIDO","Condi��o de pagamento inv�lida para o cliente "+cCodCli+"-"+cLojaCli+" !",{"OK"},1)
		Endif
	Else
		Aviso("INV�LIDO","N�o existe saldo suficiente para atender todos os pedidos a faturar !",{"OK"},1)
	Endif
	
	RestArea(aArea) 

Return lRet
