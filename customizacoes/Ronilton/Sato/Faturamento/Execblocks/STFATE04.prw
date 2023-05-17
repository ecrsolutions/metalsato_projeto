#Include "Rwmake.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATE04   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de geração da nota fiscal de venda de beneficiamento   ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATE04(cDoc,cSer,aPvlNfs)
	Local x, a, b, aItem
	Local aAux         := {}
	Local aPedAux      := aClone(aPvlNfs)
	Local cSerie       := If( Type("__cSerBen") == "U" , cSer, __cSerBen)
	Local lMostraCtb   := .F.
	Local lAglutCtb    := .F.
	Local lCtbOnLine   := .F.
	Local lCtbCusto    := .F.
	Local lReajusta    := .F.
	Local nCalAcrs     := 0
	Local nArredPrcLis := 0
	Local lAtuSA7      := .F.
	Local lECF         := .F.
	
	// Se as N.F. de Beneficiamento forem por nota origem, gera uma nota para cada nota+serie (origem)
	If SA1->(FieldPos("A1_XNFXNF")) > 0 .And. SA1->A1_XNFXNF == "S"
		// Quebra os itens por: nota origem + serie origem
		For x:=1 To Len(aPvlNfs)
			SC6->(dbSetOrder(1))
			If SC6->(dbSeek(XFILIAL("SC6")+aPvlNfs[x,1]+aPvlNfs[x,2]))
				nPos := AScan( aAux , {|y| y[1] == SC6->C6_NFORI+SC6->C6_SERIORI })
				If nPos == 0
					AAdd( aAux , { SC6->C6_NFORI+SC6->C6_SERIORI, {}})
					nPos := Len(aAux)
				Endif
				AAdd( aAux[nPos,2] , {SC6->C6_ITEM, x} )
			Endif
		Next
		
		ASort( aAux ,,, {|a,b| a[1] < b[1] })  // Ordena por nota origem + serie origem
		
		For x:=1 To Len(aAux)
			cNumero := BuscaNota(cSerie)  // Busca a próxima nota
			aItem   := aClone(aAux[x,2])  // Captura os itens
			aPvlNfs := {}                 // Inicializa o vetor de itens a faturar
			
			StaticCall(STFATA01,RefreshMonitor,"1",{ "1" , "", cNumero, cSerie, "Gerando nota de Retorno Simbólico na filial "+cFilAnt+"..."} )
			
			ASort(aItem,,,{|a,b| a[1] < b[1] }) // Ordena por item
			
			aEval( aItem , {|y| AAdd( aPvlNfs , aClone(aPedAux[y[2]]) ) } )   // Adiciona os itens da nota
			
			MaPvlNfs(aPvlNfs,cSerie,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajusta,nCalAcrs,nArredPrcLis,lAtuSA7,lECF)
			GravaNota(cNumero,cSerie,cDoc,cSer)
		Next
	Else
		cNumero := BuscaNota(cSerie)   // Busca a próxima nota
		
		StaticCall(STFATA01,RefreshMonitor,"1",{ "1" , "", cNumero, cSerie, "Gerando nota de Retorno Simbólico na filial "+cFilAnt+"..."} )
		
		MaPvlNfs(aPvlNfs,cSerie,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajusta,nCalAcrs,nArredPrcLis,lAtuSA7,lECF)
		GravaNota(cNumero,cSerie,cDoc,cSer)
	Endif
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ GravaNota  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Efetua gravação da nota de origem na nota de beneficiamento   ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GravaNota(cNota,cSer,cNFOri,cSerOri)
	// Atualiza a nota de beneficiamento com os dados da nota principal
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(XFILIAL("SF2")+cNota+cSer))
		RecLock("SF2",.F.)
		SF2->F2_XNFORI  := cNFOri
		SF2->F2_XSERORI := cSerOri
		MsUnLock()
		
		// Posiciona nos itens da nota fiscal
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(XFILIAL("SD2")+cNota+cSer))
		
		// Atualiza a nota + serie originais no pedido de beneficiamento
		SC5->(dbSetOrder(1))
		If SC5->(dbSeek(XFILIAL("SC5")+SD2->D2_PEDIDO))
			If Empty(SC5->C5_XNFORI)
				RecLock("SC5",.F.)
				SC5->C5_XNFORI  := cNFOri
				SC5->C5_XSERORI := cSerOri
				MsUnLock()
			Endif
		Endif
	Endif
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ BuscaNota  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Retornar o número da próxima nota a ser gerada                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BuscaNota(cSerie)
Return AllTrim(Posicione("SX5",1,XFILIAL("SX5")+"01"+cSerie,"X5_DESCRI"))