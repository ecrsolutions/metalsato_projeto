#INCLUDE "Protheus.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATA02   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 29/01/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Consulta e Cadastro de Kanban                                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATA02()
	Local aPosObj, aSize, nLG, nAG, nLB, nAB, nPos, oFont10, nX
	Local oMainWnd  := Nil
	Local nFL       := 10 / 945.5    // Fator da largura
	Local nFA       := 10 / 71.04    // Fator da altura
	Local nCol      := 0
	Local nCl1      := 20
	Local nCl2      := 50
	Local aColunas  := {}
	Local aSemaforo := {}
	
	Private aHoras    := AFill(Array(24),0)
	Private aGetHor   := AClone(aHoras)
	Private bGetHor   := {|a,b,c,d,e,f,g,h| DrawGetHoras(a,b,c,d,e,f,g,h) }
	Private bSemaforo := {|a,b,c,d,e,f| DrawSemaforo(a,b,c,d,e,f) }
	Private aEntregas := {}
	Private cFilInd   := "01"
	Private cFilDep   := "02"
	Private nPosLin   := 1
	Private lLeQuant  := .F.
	Private oVermel   := LoadBitmap( GetResources(), "BR_VERMELHO" )
	Private oAzul     := LoadBitmap( GetResources(), "BR_AZUL"     )
	Private oVerde    := LoadBitmap( GetResources(), "BR_VERDE"    )
	Private oOrange   := LoadBitmap( GetResources(), "BR_LARANJA"  )
	Private lNovo     := .F.
	Private lLeKanban := __cUserID $ GetMV("MV_XALTKAN",.F.,"000001")    // Usuários que poderão dar manutenção no Kanban
	Private aAux      := { Ctod(""), "", ""}
	Private bFiltroOk := {|| dDtEntrega == aAux[1] .And. cCodCli == aAux[2] .And. cLojCli == aAux[3] }
	
	Private oDlg, oKan, oEnt, oCli, oLoj, oNom, oPrd, oDes, oLst, oZer, oExc
	
	Private cCadastro := "Consulta de Kanban"
	
	AAdd( aSemaforo, { "BR_VERMELHO", "Sem Estoque / Sem Fatura"} )
	AAdd( aSemaforo, { "BR_AZUL"    , "Faturado"                } )
	AAdd( aSemaforo, { "BR_VERDE"   , "Não Faturado com Estoque"} )
	AAdd( aSemaforo, { "BR_LARANJA" , "Faturado Parcial"        } )
	
	//+----------------------------------
	//| Inicia as posições dos objetos
	//+----------------------------------
	PosObjetos(@aSize,@aPosObj)
	
	nLG := Round(nFL * (aPosObj[3,4] - aPosObj[3,2]),0)  // Largura geral
	nAG := Round(nFA * (aPosObj[3,3] - aPosObj[3,1]),0)  // Altura geral
	
	nLB := Round(nLG * 7  ,0)  // Largura dos botões
	nAB := Round(nAG * 3.0,0)  // Altura dos botões

	nCl1       := nLG*2
	nCl2       := nLG*5
	oFont10    := TFont():New("Arial"      , nLG*1,1.6*nAG,.T.,.T.,5,.T.,5,.T.,.F.)
	cCodKanban := CriaVar("Z2_PEDCLI",.F.)
	dDtEntrega := Ctod("")
	cCodCli    := CriaVar("A1_COD",.F.)
	cLojCli    := CriaVar("A1_LOJA",.F.)
	cNomCli    := CriaVar("A1_NOME",.F.)
	cCodProd   := CriaVar("B1_COD",.F.)
	cDescricao := CriaVar("B1_COD",.F.)
	
	AAdd( aColunas , "Produto"   )
	AAdd( aColunas , "Estoque"   )
	AAdd( aColunas , "Loc.Entr." )
	
	For nPos:=1 To 12
		AAdd( aColunas , StrZero(nPos-1,2) + "h / " + StrZero(nPos+11,2) + "h" )
		AAdd( aColunas , "" )
	Next

	ListaProdutos()
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	//@ aPosObj[1,1]+002,aPosObj[1,2]+000 SAY "Cod. Kanban" SIZE 60,10 PIXEL OF oDlg FONT oFont10
	//@ aPosObj[1,1]+000,aPosObj[1,2]+070 MSGET oKan VAR cCodKanban PICTURE "@!" SIZE 60, 13 PIXEL OF oDlg FONT oFont10
	
	@ aPosObj[1,1]+nAG*0.2,aPosObj[1,2]+nLG*0.0 SAY "Data" SIZE nLG*4,nAG*1 PIXEL OF oDlg FONT oFont10
	@ aPosObj[1,1]+nAG*0.0,aPosObj[1,2]+nLG*4.0 MSGET oEnt VAR dDtEntrega PICTURE "@!" SIZE nLG*6, nAG*1.3 PIXEL OF oDlg FONT oFont10
	
	@ aPosObj[1,1]+nAG*1.9,aPosObj[1,2]+nLG*0.0 SAY "Cliente" SIZE nLG*5,nAG*1 PIXEL OF oDlg FONT oFont10
	@ aPosObj[1,1]+nAG*1.7,aPosObj[1,2]+nLG*4.0 MSGET oCli VAR cCodCli PICTURE "@!" F3 "SA1" Valid FilCliente() SIZE nLG*4, nAG*1.3 PIXEL OF oDlg FONT oFont10
	oCli:bLostFocus := {|| cNomCli := Posicione("SA1",1,XFILIAL("SA1")+cCodCli+If(Empty(cLojCli),"",cLojCli),"A1_NOME"), oNom:Refresh() }
	
	@ aPosObj[1,1]+nAG*1.7,aPosObj[1,2]+nLG*9.5 MSGET oLoj VAR cLojCli PICTURE "@!" Valid FilCliente() SIZE nLG*2, nAG*1.3 PIXEL OF oDlg FONT oFont10
	oLoj:bLostFocus := {|| cNomCli := Posicione("SA1",1,XFILIAL("SA1")+cCodCli+cLojCli,"A1_NOME"), oNom:Refresh() }
	
	@ aPosObj[1,1]+nAG*1.7,aPosObj[1,2]+nLG*13 MSGET oNom VAR cNomCli PICTURE "@!" F3 SIZE nLG*18, nAG*1.3 PIXEL OF oDlg FONT oFont10 WHEN .F.
	
	@ aPosObj[1,1]+nAG*1.7,aPosObj[1,2]+nLG*32 BUTTON oSai PROMPT "Filtrar"  SIZE nLG*3.5,nAG*1.6 PIXEL OF oDlg FONT oFont10 ACTION FiltraKanban()

	oLst := TCBrowse():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,4],aPosObj[2,3]-aPosObj[2,1],,/*aColunas*/,,oDlg,,,,,,,oFont10,,,,,.F.,,.T.,,.F.,,,)
	                                                                                  
	oLst:SetArray( aEntregas )
	
	oLst:AddColumn(TCColumn():New(aColunas[01], {|| aEntregas[oLst:nAt,02]   },"@!"       ,,,"LEFT"  ,nLG*21.2,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[02], {|| aEntregas[oLst:nAt,03]   },"@!"       ,,,"LEFT"  ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[03], {|| aEntregas[oLst:nAt,04]   },"@!"       ,,,"LEFT"  ,nLG*4.00,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[04], {|| aEntregas[oLst:nAt][6,01]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[05], {|| CorColuna(oLst:nAt,01)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[06], {|| aEntregas[oLst:nAt][6,02]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[07], {|| CorColuna(oLst:nAt,02)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[08], {|| aEntregas[oLst:nAt][6,03]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[09], {|| CorColuna(oLst:nAt,03)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[10], {|| aEntregas[oLst:nAt][6,04]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[11], {|| CorColuna(oLst:nAt,04)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[12], {|| aEntregas[oLst:nAt][6,05]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[13], {|| CorColuna(oLst:nAt,05)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[14], {|| aEntregas[oLst:nAt][6,06]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[15], {|| CorColuna(oLst:nAt,06)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[16], {|| aEntregas[oLst:nAt][6,07]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[17], {|| CorColuna(oLst:nAt,07)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[18], {|| aEntregas[oLst:nAt][6,08]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[19], {|| CorColuna(oLst:nAt,08)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[20], {|| aEntregas[oLst:nAt][6,09]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[21], {|| CorColuna(oLst:nAt,09)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[22], {|| aEntregas[oLst:nAt][6,10]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[23], {|| CorColuna(oLst:nAt,10)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[24], {|| aEntregas[oLst:nAt][6,11]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[25], {|| CorColuna(oLst:nAt,11)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[26], {|| aEntregas[oLst:nAt][6,12]},"@E 999999",,,"RIGHT" ,nLG*3.50,.F.,.F.,,,,.F., ) )
	oLst:AddColumn(TCColumn():New(aColunas[27], {|| CorColuna(oLst:nAt,12)   },           ,,,"CENTER",nLG*1.00,.T.,.F.,,,,.F., ) )
	
	If lLeKanban
		oLst:bLDblClick := {|| If( Eval(bFiltroOk) , (__ReadVar := "cCodProd", cCodProd := aEntregas[oLst:nAt,1], Eval(oPrd:bLostFocus), PesqKanban()), ) }
	Endif
	
	oLst:lUseDefaultColors := .F.
	
	//a propriedade SetBlkBackColor serve para colorir o fundo do grid
	//criei a função GETDCLR no qual passo a ela a linha posicionada e uma determinada cor.
	oLst:SetBlkBackColor({|| GETDCLR(oLst:nAt)})
	
	@ aPosObj[3,1],aPosObj[3,2] To aPosObj[3,3],aPosObj[3,4] PROMPT "Quantidade de Entrega de Peças por Hora" PIXEL OF oDlg
	
	@ aPosObj[3,1]+nAG*1.5,aPosObj[3,2]+nLG*0.8 SAY "Produto" SIZE nLG*4,nAG*1 PIXEL OF oDlg FONT oFont10
	@ aPosObj[3,1]+nAG*1.3,aPosObj[3,2]+nLG*5.3 MSGET oPrd VAR cCodProd   PICTURE "@!" F3 "SB1" Valid PesqKanban() SIZE nLG*9, nAG*1.3 PIXEL OF oDlg FONT oFont10 WHEN lLeKanban .And. Eval(bFiltroOk)
	oPrd:bLostFocus := {|| cDescricao := Posicione("SB1",1,XFILIAL("SB1")+cCodProd,"B1_DESC"), oDes:Refresh() }
	
	@ aPosObj[3,1]+nAG*1.3,aPosObj[3,2]+nLG*15.0 MSGET oDes VAR cDescricao PICTURE "@!" F3 SIZE nLG*22, nAG*1.3 PIXEL OF oDlg FONT oFont10 WHEN .F.

	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*45.0 BITMAP oBmp RESNAME "BR_VERMELHO" SIZE nLG*1,nAG*1 NOBORDER PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*46.5 SAY "Sem Estoque / Sem Fatura"    SIZE nLG*8,nAG*1 PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*54.0 BITMAP oBmp RESNAME "BR_AZUL"     SIZE nLG*1,nAG*1 NOBORDER PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*55.5 SAY "Faturado"                    SIZE nLG*5,nAG*1 PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*63.0 BITMAP oBmp RESNAME "BR_VERDE"    SIZE nLG*1,nAG*1 NOBORDER PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*64.5 SAY "Não Faturado com Estoque"    SIZE nLG*8,nAG*1 PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*72.0 BITMAP oBmp RESNAME "BR_LARANJA"  SIZE nLG*1,nAG*1 NOBORDER PIXEL OF oDlg
	//@ aPosObj[3,1]+nAG*1.1,aPosObj[3,2]+nLG*73.5 SAY "Faturado Parcial"            SIZE nLG*8,nAG*1 PIXEL OF oDlg

	nCl3 := aPosObj[3,2]+nLG*45.0
	For nX:=1 To Len(aSemaforo)
		nCl3 += Eval(bSemaforo,aPosObj[3,1]+nAG*1.1,nCl3,aSemaforo[nX,1],aSemaforo[nX,2],nLG,nAG)
	Next
	
	//Alert("Altura " + LTrim(Str(aPixString[1])) + " / Largura " + LTrim(Str(aPixString[2])))

	For nPos:=1 To Len(aHoras)
		
		Eval(bGetHor,aPosObj[3,1]+nAG*1.3,aPosObj[3,2]+nLG*0.8+nCol,nCl1,StrZero(nPos-1,2)+"h",nPos,oFont10,nLG,nAG) 
		
		nCol += nCl1 + nCl2
		
		If nPos == 12
			nCol := 0
			aPosObj[3,1] += nAG*2
		Endif
	Next
	
	@ aPosObj[1,1]+nAG*0.5,aPosObj[1,4]-nLG*17 BUTTON oExc PROMPT "Excluir"    SIZE nLB,nAB PIXEL OF oDlg FONT oFont10 ACTION (DeleKanban(),oLst:SetFocus()) WHEN lLeKanban .And. Eval(bFiltroOk) .And. Len(aEntregas) > 1
	@ aPosObj[1,1]+nAG*0.5,aPosObj[1,4]-nLG*08 BUTTON oSai PROMPT "Sair"       SIZE nLB,nAB PIXEL OF oDlg FONT oFont10 ACTION oDlg:End()
	@ aPosObj[3,1]+nAG*1.0,aPosObj[3,4]-nLG*08 BUTTON oZer PROMPT "Atualizar"  SIZE nLB,nAB PIXEL OF oDlg FONT oFont10 ACTION (SomaKanban(),oLst:SetFocus()) WHEN lLeQuant
	
	oEnt:SetFocus()

	oDlg:lEscClose := .F.
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

Static Function DrawSemaforo(nLin,nCol,cBitMap,cString,nLG,nAG)
	Local nSize := GetStringPixSize(cString, "Arial", 1.0*nAG)[2] / 2
	
	@ nLin,nCol+nLG*0.0 BITMAP oBmp RESNAME cBitMap SIZE nLG*1,nAG*1 NOBORDER PIXEL OF oDlg
	@ nLin,nCol+nLG*1.5 SAY cString SIZE nSize,nAG*1 PIXEL OF oDlg

Return nSize + nLG*1.5

Static Function CorColuna(nLin,nCol)
Return aEntregas[nLin][8,nCol]

Static Function GETDCLR(nPos)
Return If( aEntregas[nPos,9] < 0 , CLR_HGRAY, 16777215)

Static Function SomaKanban()
	Local nPos := AScan( aEntregas , {|x| x[1] == cCodProd })
	Local lDel := (AScan( aHoras , {|x| x > 0 }) == 0)     // Se não foi definido hora nenhuma
	
	If lDel .And. nPos > 0    // Se não informou hora e o produto existe, então apaga ele da programação
		GravaBase(@aEntregas[nPos+0,6],00,.T.)
		GravaBase(@aEntregas[nPos+1,6],12,.T.)

		// Exclui as duas linhas do produto
		ADel( aEntregas , nPos )
		ADel( aEntregas , nPos )

		aSize( aEntregas , Len(aEntregas) - 2)   // Refaz os itens

		If Empty(aEntregas)
			AddItemEntrega()
		Else
			CalcCorItens()   // Calcula a cor dos itens
		Endif
		oLst:Refresh()
	ElseIf !lDel
		If nPos == 0   // Caso não encontre, adiciona
			If Len(aEntregas) == 1
				aSize( aEntregas, 0 )
			Endif
			AddItemEntrega(cCodProd)
			CalcCorItens()   // Calcula a cor dos itens
			nPos := AScan( aEntregas , {|x| x[1] == cCodProd })
		Endif
		
		GravaBase(@aEntregas[nPos+0,6],00)
		GravaBase(@aEntregas[nPos+1,6],12)
		CalcStatus(nPos)
	Endif
	
	cCodProd   := CriaVar("B1_COD",.F.)
	cDescricao := CriaVar("B1_DESC",.F.)
	
	oPrd:Refresh()
	oDes:Refresh()
	
Return

Static Function DeleKanban()
	Local nX   := 1
	Local cAux := cCodProd

	If MsgYesNo("Confirma a exclusão de todo o Kanban ?","Exclusão do Kanban")
		While nX <= Len(aEntregas)
			cCodProd := aEntregas[nX,1]

			// Caso o produto ainda não tenha sido faturado
			If AScan( aEntregas[nX+0,7] , {|x| x > 0 } ) == 0 .And. AScan( aEntregas[nX+1,7] , {|x| x > 0 } ) == 0
				GravaBase(@aEntregas[nX+0,6],00,.T.)
				GravaBase(@aEntregas[nX+1,6],12,.T.)

				aDel( aEntregas , nX )
				aDel( aEntregas , nX )
				aSize( aEntregas , Len(aEntregas) - 2)
			Else
				nX += 2
			Endif
		Enddo

		If Empty(aEntregas)
			AddItemEntrega()
		Endif
		CalcCorItens()   // Calcula a cor dos itens

		oLst:Refresh()

		cCodProd := cAux
	Endif

Return

Static Function GravaBase(aQuant,nPos,lDel)
	Local nX
	
	Default lDel := .F.

	lLeQuant := .F.
	
	SZ2->(dbSetOrder(1))    // Z2_FILIAL+Z2_CLIENTE+Z2_LOJA+Z2_PRODUTO+DTOS(Z2_DATENT)+Z2_HORENT+Z2_SETENT
	For nX:=1 To Len(aQuant)
		If SZ2->(dbSeek(XFILIAL("SZ2")+cCodCli+cLojCli+cCodProd+DtoS(dDtEntrega)+StrZero((nX+nPos-1)*100,4)))
			RecLock("SZ2",.F.)
			If lDel
				dbDelete()
			Else
				SZ2->Z2_QUANT := aHoras[nX+nPos]
			Endif
			MsUnLock()
		ElseIf lDel
			Loop
		ElseIf aHoras[nX+nPos] > 0
			RecLock("SZ2",.T.)
			SZ2->Z2_FILIAL  := XFILIAL("SZ2")
			SZ2->Z2_CLIENTE := cCodCli
			SZ2->Z2_LOJA    := cLojCli
			SZ2->Z2_PRODUTO := cCodProd
			SZ2->Z2_DATENT  := dDtEntrega
			SZ2->Z2_HORENT  := StrZero((nX+nPos-1)*100,4)
			SZ2->Z2_PEDCLI  := cCodKanban
			SZ2->Z2_QUANT   := aHoras[nX+nPos]
			MsUnLock()
		Endif
		
		aQuant[nX] := aHoras[nX+nPos]
		aHoras[nX+nPos] := 0
		aGetHor[nX+nPos]:Refresh()
	Next
	
Return

Static Function DrawGetHoras(nLin,nCol,nCl1,cLegenda,nPos,oFonte,nLG,nAG)
	@ nLin+nAG*1.9,nCol+0000 SAY cLegenda SIZE nLG*2,nAG*1 PIXEL OF oDlg FONT oFonte COLOR CLR_HBLUE
	@ nLin+nAG*1.7,nCol+nCl1 MSGET aGetHor[nPos] VAR aHoras[nPos] PICTURE "@E 999999" Valid TestaSaldo(aHoras,nPos) SIZE nLG*4, nAG*1.3 PIXEL OF oDlg FONT oFonte WHEN lLeQuant
Return

Static Function TestaSaldo(aTempo,nPos)
	Local nLin := oLst:nAt - If( oLst:nAt == 1 .Or. Mod(oLst:nAt,2) > 0 , 0, 1) + If( nPos > 12 , 1, 0)
	Local nHor := nPos - If( nPos > 12 , 12, 0)
	Local lRet := lNovo .Or. (aTempo[nPos] >= aEntregas[nLin,7][nHor])

	If !lRet
		Alert("Quantidade não pode ser menor que a quantidade já faturada para esse horário !")
	Endif

Return lRet

Static Function FilCliente()
Return Vazio() .Or. ExistCpo("SA1",cCodCli+If(Empty(cLojCli),"",cLojCli))

Static Function FiltraKanban()
	If !Empty(cCodCli) .And. !Empty(cLojCli) .And. !Empty(dDtEntrega)
		If dDtEntrega <> aAux[1] .Or. cCodCli <> aAux[2] .Or. cLojCli <> aAux[3]
			aAux[1] := dDtEntrega
			aAux[2] := cCodCli
			aAux[3] := cLojCli
			
			MsgRun("  Filtrando Kanban   ","Aguarde...",{|| ListaProdutos(cCodCli,cLojCli,cCodKanban,dDtEntrega) })
		Endif
	Else
		MsgAlert("Favor preencher o cliente, loja ou data de entrega corretamente !","FILTRO")
	Endif
Return

Static Function PesqKanban()
	Local nPos, nX
	Local lRet := .T.

	If Vazio()
		// Limpa os campos de leitura caso seja um conteúdo vazio
		lNovo    := .F.
		lLeQuant := .F.

		For nX:=1 To Len(aHoras)
			aHoras[nX] := 0
			aGetHor[nX]:Refresh()
		Next
	ElseIf lRet := ExistCpo("SB1")
		SA7->(dbSetOrder(1))
		If lRet := SA7->(dbSeek(XFILIAL("SA7")+cCodCli+cLojCli+cCodProd))
			nPos := AScan( aEntregas , {|x| x[1] == cCodProd })
			If lRet := (nPos > 0)
				lNovo    := .F.
				lLeQuant := .T.
				
				For nX:=1 To Len(aEntregas[nPos,6])
					aHoras[nX] := aEntregas[nPos,6][nX]
					aGetHor[nX]:Refresh()
				Next
				nPos++
				For nX:=1 To Len(aEntregas[nPos,6])
					aHoras[nX+12] := aEntregas[nPos,6][nX]
					aGetHor[nX+12]:Refresh()
				Next
				
				aGetHor[1]:SetFocus()
			ElseIf lRet := MsgYesNo("Não existe programação para esse produto. Confirma sua inclusão na programação ?","Sem programação")
				lNovo    := .T.
				lLeQuant := .T.
				aGetHor[1]:SetFocus()
			Endif
		Else
			Alert("Produto informado não está cadastrado na Amarração Cliente x Produto !")
		Endif
	Endif

Return lRet

Static Function ListaProdutos(cCliente,cLoja,cKanban,dEntrega)
	Local nPos, nHora, cSeek, cPos, cProduto

	Default cCliente := "AbCdEf"
	Default cLoja    := ""
	Default cKanban  := ""
	Default dEntrega := CtoD("")
	
	cSeek := XFILIAL("SZ2")+cCliente+cLoja

	aSize(aEntregas,0)
	
	SZ2->(dbSetOrder(1))     // Z2_FILIAL+Z2_CLIENTE+Z2_LOJA+Z2_PRODUTO+DTOS(Z2_DATENT)+Z2_HORENT+Z2_SETENT+Z2_KANBAN
	SZ2->(dbSeek(cSeek,.T.))
	While !SZ2->(Eof()) .And. cSeek == SZ2->Z2_FILIAL+SZ2->Z2_CLIENTE+SZ2->Z2_LOJA
		nPPrd    := 0
		cProduto := SZ2->Z2_PRODUTO
		While !SZ2->(Eof()) .And. cSeek == SZ2->Z2_FILIAL+SZ2->Z2_CLIENTE+SZ2->Z2_LOJA .And. cProduto == SZ2->Z2_PRODUTO
			
			If SZ2->Z2_DATENT == dEntrega
				If AScan( aEntregas , {|x| x[1] == SZ2->Z2_PRODUTO }) == 0
					AddItemEntrega(cProduto)
					nPPrd := Len(aEntregas) - 1
				Endif
				
				nHora := Min(Max(Val(SZ2->Z2_HORENT)/100,1),24)
				If nHora >= 12
					cPos := "2"
					nHora -= 12
				Else
					cPos := "1"
				Endif
				
				nPos := AScan( aEntregas , {|x| x[1]+x[5] == SZ2->Z2_PRODUTO+cPos })
				
				aEntregas[nPos,6][nHora+1] += SZ2->Z2_QUANT
				aEntregas[nPos,7][nHora+1] += SZ2->Z2_QTDENT
			Endif
			
			SZ2->(dbSkip())
		Enddo

		If nPPrd > 0
			CalcStatus(nPPrd)
		Endif
	Enddo

	If Empty(aEntregas)
		AddItemEntrega()
	Endif

	CalcCorItens()   // Calcula a cor dos itens

	If oLst <> Nil
		lLeQuant := .F.

		For nPos:=1 To Len(aHoras)
			aHoras[nPos] := 0
			aGetHor[nPos]:Refresh()
		Next

		cCodProd   := CriaVar("B1_COD",.F.)
		cDescricao := CriaVar("B1_DESC",.F.)
		
		oPrd:Refresh()
		oDes:Refresh()
		oLst:Refresh()
	Endif

Return

Static Function AddItemEntrega(cProduto)
	Local aCol := { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local aCor := AFill(Array(Len(aCol)),"")
	
	If cProduto == Nil
		AAdd( aEntregas , { CriaVar("Z2_PRODUTO",.F.), CriaVar("B1_DESC",.F.), 0, "", "1", aClone(aCol), aClone(aCol), aClone(aCor), 0})
	Else
		AAdd( aEntregas , { cProduto, cProduto, Estoque(cFilInd,cProduto), "", "1", aClone(aCol), aClone(aCol), aClone(aCor), 0})
		AAdd( aEntregas , { cProduto,  Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC"), Estoque(cFilDep,cProduto), "", "2", aClone(aCol), aClone(aCol), aClone(aCor), 0})
	Endif

Return

Static Function CalcCorItens()
	Local nX
	Local nCor := 1

	ASort( aEntregas ,,, {|x,y| x[1]+x[5] < y[1]+y[5] })    // Ordena por Produto + Sequencia

	For nX:=1 To Len(aEntregas) Step 2
		aEntregas[nX+0,9] := nCor
		If (nX+1) <= Len(aEntregas)
			aEntregas[nX+1,9] := nCor
		Endif
		nCor *= -1
	Next

Return

Static Function CalcStatus(nPos)
	Local nX, nY
	Local nSaldo := aEntregas[nPos,3] + aEntregas[nPos+1,3]   // Soma os estoques disponiveis
			
	// Atualiza o semáforo de cores conforme saldo em estoque e faturamento
	For nX:=nPos To nPos+1
		For nY:=1 To Len(aEntregas[nX][6])
			If aEntregas[nX][6,nY] > 0       // Se tem entrega
				If aEntregas[nX][7,nY] > 0   // Se tem faturamento
					If aEntregas[nX][7,nY] < aEntregas[nX][6,nY]   // Se tem faturamento parcial
						aEntregas[nX][8,nY] := oOrange
					Else
						aEntregas[nX][8,nY] := oAzul
					Endif
				ElseIf aEntregas[nX][6,nY] <= nSaldo
					aEntregas[nX][8,nY] := oVerde
				Else
					aEntregas[nX][8,nY] := oVermel
				Endif
				nSaldo -= (aEntregas[nX][6,nY] - aEntregas[nX][7,nY])
				nSaldo := Max(0,nSaldo)
			Endif
		Next
	Next
Return

Static Function Estoque(cFilPesq,cProduto)
	Local cFilAux := cFilAnt
	Local nRet    := 0
	
	cFilAnt := cFilPesq
	nRet    := CalcEst(cProduto, GetMV("MV_XLOCEXP",.F.,"02"), dDataBase+1)[1]
	cFilAnt := cFilAux
	
Return nRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ PosObjetos ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/04/2013 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Inicializa as dimensões da tela para posicionar os objetos    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function PosObjetos(aSize,aPosObj)
	Local aInfo
	Local aObjects := {}
	//Local aCor     := LeCoord()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize(.F.)
	AAdd( aObjects, { 100,  40, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100,  70, .T., .F. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )
	
Return

/*Static Function LeCoord()
	Local nHdl, nX, aLinha
	Local cFile := "D:\TOTVS\COORD.TXT"
	Local aRet  := {}
	
	If File(cFile)
		nHdl := FT_FUSE(cFile)
		FT_FGOTOP()
		While !FT_FEOF()
			aLinha := Separa(AllTrim(FT_FREADLN()),",",.F.)
			For nX:=1 To Len(aLinha)
				aLinha[nX] := Val(aLinha[nX])
			Next
			AAdd(aRet,aClone(aLinha))
			FT_FSKIP()
		EndDo
		FT_FUSE()
	Endif
	
Return aRet*/