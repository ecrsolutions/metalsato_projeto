#Include "Rwmake.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATE02   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de montagem do pedido de venda de beneficiamento       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATE02(cCodCli,cLjCli,vItensPA,vAll,lJunta)
	Local x, y, cQry, nQtdAtu, nQtdAcu, cAlias, aAux, nP
	Local vPA  := If( lJunta == Nil .Or. lJunta , {}, Nil)
	Local vBN  := {}
	Local vRet := {}
	Local nDec := TamSX3("C6_VALOR")[2]
	
	Private cFilSB1 := SB1->(XFILIAL("SB1"))
	Private cFilSG1 := SG1->(XFILIAL("SG1"))
	
	If ValType(vAll) <> "A"
		vAll := {}
	Endif
	
	// Acumula por Codigo de Produto, caso ainda não tenha sido feito
	Acumula(vItensPA,@vPA)
	
	// Busca os produtos Beneficiamento usados em cada PA
	If lJunta
		aEval( vPA , {|x| GetBN(x[1],x[2],@vBN,x[3],x[4]) } )
	Else
		// Processa o cálculo do Beneficiamento individualmente
		aAux := {}
		For x:=1 To Len(vPA)
			AAdd( aAux , {} )
			GetBN(vPA[x,1],vPA[x,2],@aAux[x],vPA[x,3],vPA[x,4])
		Next
		
		// Adiciona os produtos de forma separada
		For x:=1 To Len(aAux)
			For y:=1 To Len(aAux[x])
				AAdd( vBN , { aAux[x][y,1], aAux[x][y,2], aAux[x][y,3], aAux[x][y,4]})
			Next
		Next
	Endif
	
	// Cria variável para controle saldo por notaa
	If Type("aSB6") == "U"
		aSB6 := {}
	Endif

	ASort( vBN ,,, {|x,y| x[1] < y[1] })  // Ordena o vetor por Produto
	
	cAlias := Alias()
	For x:=1 To Len(vBN)
		// Pesquisa o produto no vetor de acumulados para buscar a quantidade acumulada
		If (nPos := AScan( vAll , {|y| y[1] == vBN[x,1] } )) > 0
			nQtdAcu := vAll[nPos,2]
		Else
			nQtdAcu := 0
		Endif
		
		nQtdAtu := vBN[x,2]   // Quantidade do BN no Pedido
		
		If AScan( aSB6 , {|y| y[1]+y[2]+y[3] == vBN[x,1]+cCodCli+cLjCli } ) == 0
			cQry := "SELECT B6_IDENT, B6_SALDO, B6_PRUNIT "
			cQry += " FROM "+RetSQLName("SB6")+" SB6"
			cQry += " WHERE SB6.D_E_L_E_T_ = ' ' AND SB6.B6_PRODUTO = '"+vBN[x,1]+"'"
			cQry += " AND SB6.B6_CLIFOR = '"+cCodCli+"' AND SB6.B6_LOJA = '"+cLjCli+"'"
			cQry += " AND SB6.B6_SALDO > 0"
			cQry += " AND SB6.B6_TES < '500'"  // Filtra os TES de entrada
			cQry += " AND SB6.B6_TIPO = 'D'"   // Filtra as notas de terceiros
			cQry += " AND SB6.B6_TPCF = 'C'"   // Filtra as notas do cliente
			cQry += " ORDER BY B6_IDENT"
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "QRY", .T., .F. )
			While !Eof()
				AAdd( aSB6 , { vBN[x,1], cCodCli, cLjCli, QRY->B6_IDENT, QRY->B6_SALDO, QRY->B6_PRUNIT} )
				dbSkip()
			Enddo
			dbCloseArea()
			
			// Ordena o vetor por PRODUTO + CLIENTE + LOJA + IDENT
			ASort( aSB6 ,,, {|a,b| a[1]+a[2]+a[3]+a[4] < b[1]+b[2]+b[3]+b[4] } )
		Endif
		
		nP := 1
		While nP <= Len(aSB6) .And. nQtdAtu > 0
			
			If aSB6[nP,1]+aSB6[nP,2]+aSB6[nP,3] <> vBN[x,1]+cCodCli+cLjCli .Or. aSB6[nP,5] <= 0     // Caso o registro não possua mais saldo
				nP++
				Loop
			Endif
			
			// Identifica os itens já usados nos acumulados (anteriores)
			nQtdAcu := If( nQtdAcu > 0 , nQtdAcu - aSB6[nP,5], 0)
			
			// Após identificar todos os itens usados nos acumulados, a quantidade acumulada fica zero
			If nQtdAcu <= 0
				// O saldo disponível é o restante do item ou o saldo total do próprio item
				nSalDis := If( nQtdAcu < 0 , Abs(nQtdAcu), aSB6[nP,5])
				
				// Se o saldo disponível é maior que a quantidade atual
				If nSalDis > nQtdAtu
					nSalDis := nQtdAtu   // Atribui a quantidade atual para os saldo disponíveis
				Endif
				
				// Guarda o item encontrado
				AAdd( vRet , { vBN[x,1], aSB6[nP,4], nSalDis, aSB6[nP,6], Round(nSalDis * aSB6[nP,6],nDec), vBN[x,3], vBN[x,4]})
				
				// Subtrai da quantidade atual o saldo disponível do item
				nQtdAtu -= nSalDis

				aSB6[nP,5] -= nSalDis    // Atualiza o saldo do registro
			Endif
			
			nP++
		Enddo
		
		// Se ainda tem saldo, então não existe saldo suficiente no SB6
		If nQtdAtu > 0
			Aviso( "Saldo de Terceiros", "O produto não será incluído no pedido por falta de saldo. Verifique!" , {"Ok"}  ,, "Produto: " + vBN[x,1] )
			vRet := {}   // Limpa o vetor de saldos encontrados
			Exit
		Endif
	Next
	dbSelectArea(cAlias)
	
	// Se conseguiu encontrar saldo para os itens
	If !Empty(vRet)
		Acumula(vBN,@vAll)   // Acumula os itens solicitantes
	Endif
	
Return aClone(vRet)

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ Acumula    ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de busca dos itens de beneficiamento da estrutura      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Acumula(vVet1,vVet2)
	Local x, nPos
	
	If vVet2 <> Nil  // Caso o vetor já exista
		For x:=1 To Len(vVet1)
			nPos := AScan( vVet2 , {|y| y[1] == vVet1[x,1] })
			If nPos == 0
				AAdd( vVet2 , { vVet1[x,1], 0, vVet1[x,3], vVet1[x,4]})
				nPos := Len(vVet2)
			Endif
			vVet2[nPos,2] += vVet1[x,2]
		Next
	Else
		vVet2 := aClone(vVet1)
	Endif
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ GetBN      ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de busca dos itens de beneficiamento da estrutura      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GetBN(cProduto,nQuant,vBN,cPedCli,cLinPed)
	Local nReg := SG1->(Recno())
	Local lRet := .F.
	
	If ValType(vBN) <> "A"
		vBN := {}
	Endif
	
	SG1->(dbSetOrder(1))
	If lRet := SG1->(dbSeek(cFilSG1+cProduto,.T.))
		While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == cFilSG1+cProduto
			
			If dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
				If !AddItemRet(SG1->G1_COMP,nQuant,@vBN,cPedCli,cLinPed)
					//SZR->(dbSetOrder(3))
					//If SZR->(dbSeek(xFilial("SZR")+SG1->G1_COMP+SG1->G1_COD+"S"))
					//	AddItemRet(SZR->ZR_COD,nQuant,@vBN)
					//EndIf
				Endif
				
				GetBN(SG1->G1_COMP,(If( SG1->(FieldPos("G1_XQTDRET")) > 0 .And. SG1->G1_XQTDRET > 0 , SG1->G1_XQTDRET, SG1->G1_QUANT) * nQuant) * ((100 + SG1->G1_PERDA) /100), @vBN,cPedCli,cLinPed)
			Endif
			
			SG1->(dbSkip())
		Enddo
	Endif
	SG1->(dbGoTo(nReg))
	
Return lRet

Static Function AddItemRet(cProduto,nQuant,vBN,cPedCli,cLinPed)
	Local nPos, lRet
	
	// Posiciona no produto
	SB1->(dbSetOrder(1))
	If lRet := SB1->(dbSeek(cFilSB1+cProduto))
		// Se for Material de Beneficiamento e não for FANTASMA
		If lRet := (SB1->B1_TIPO $ "BN,MT" .And. SB1->B1_FANTASM <> "S")
			nPos := AScan( vBN , {|x| x[1] == cProduto })
			If nPos == 0
				AAdd( vBN , { cProduto, 0, cPedCli, cLinPed})
				nPos := Len(vBN)
			Endif
			vBN[nPos,2] += (If( SG1->(FieldPos("G1_XQTDRET")) > 0 .And. SG1->G1_XQTDRET > 0 , SG1->G1_XQTDRET, SG1->G1_QUANT)  * nQuant) * ((100 + SG1->G1_PERDA) /100)
		EndIf
	Endif
	
Return lRet