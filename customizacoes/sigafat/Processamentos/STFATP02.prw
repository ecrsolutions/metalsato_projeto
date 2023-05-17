#include "Protheus.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATP02   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Processa planilha para retorno simbólico da LG e Similares    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATP02()
	Local oDlg
	Local cOpc := ""
	Local aOpc := { "Usado", "Não Usado", "Retorno PA"}
	Local lRet := .F.
	Local nOpc := 0
	
	Private aPerg := {}
	
	AAdd( aPerg , { "Caminho" , "C",                 100, "G", "@!"   , "   ", "", "", Nil })
	AAdd( aPerg , { "Cliente" , "C",TamSX3("A1_COD" )[1], "G", "@!"   , "   ", "", "", Nil })
	AAdd( aPerg , { "Loja"    , "C",TamSX3("A1_LOJA")[1], "G", "@!"   , "   ", "", "", Nil })
	AAdd( aPerg , { "Campos"  , "C",                 255, "G", "@!"   , "   ", "", "", Nil })
	AAdd( aPerg , { "Operacao", "N",                   1, "C", "@!"   , "   ", "", "", aOpc})
	
	// Carrega perguntas para o perfil do usuário
	CriaPerg(.F.)
	
	cOpc := aOpc[mv_par05]
	
	While !lRet
		nOpc := 0
		lRet := .F.
		
		DEFINE MSDIALOG oDlg TITLE "Importação Produtos" From 0,0 To 15,50
		
		@ 05,07 SAY "Informe o local onde se encontra o arquivo para importação:" SIZE 200,80 PIXEL OF oDlg
		@ 15,05 MSGET mv_par01 PICTURE "@!" SIZE 150, 10 PIXEL OF oDlg
		
		@ 15,160 BUTTON "Abrir..." SIZE 30,12 PIXEL OF oDlg ACTION mv_par01 := FATP06DlgArq(mv_par01)
		
		@ 30,07 SAY "Cliente do Arquivo ?" SIZE 200,80 PIXEL OF oDlg
		@ 30,60 MSGET mv_par02 F3 "SA1" PICTURE "@!" VALID ExistCpo("SA1",mv_par02) SIZE 40,10 PIXEL OF oDlg
		
		@ 45,07 SAY "Loja               ?" SIZE 200,80 PIXEL OF oDlg
		@ 45,60 MSGET mv_par03 PICTURE "@!" VALID ExistCpo("SA1",mv_par02+mv_par03) SIZE 20,10 PIXEL OF oDlg
		
		@ 60,07 SAY "Quanto ao processo ?" SIZE 200,80 PIXEL OF oDlg
		@ 60,60 COMBOBOX cOpc ITEMS aOpc SIZE 40,10 ON CHANGE (mv_par05:=AScan(aOpc,cOpc)) PIXEL OF oDlg
		
		@ 85,050 BUTTON "Importar" SIZE 40,12 PIXEL OF oDlg ACTION If( Arquivo() , (nOpc:=1,oDlg:End()), )
		@ 85,110 BUTTON "Cancelar" SIZE 40,12 PIXEL OF oDlg ACTION (nOpc:=0,oDlg:End())
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		//-- Validacoes
		If nOpc == 1
			SA1->(dbSetOrder(1))
			If !(lRet := SA1->(dbSeek(XFILIAL("SA1")+mv_par02+mv_par03)))
				MsgInfo("Cliente informado não existe.","Atenção!!")
			EndIf
		Else
			lRet := .T.
		EndIf
		
		If lRet .And. nOpc == 1
			// Grava perguntas para o perfil do usuário
			CriaPerg(.T.)
			
			Processa({|| RunProc(mv_par01) },"Processando a leitura do arquivo.","Aguarde..")
		EndIf
	Enddo
	
Return

Static Function Arquivo()
	Local lRet := .T.
	
	If Empty(mv_par01)
		MsgInfo("Arquivo está sem informação.","Atenção!!")
		lRet := .F.
	ElseIf !File(mv_par01)
		MsgInfo("Arquivo não encontrado.","Atenção!!")
		lRet := .F.
	Endif
	
Return lRet

Static Function FATP06DlgArq(cArquivo)
	cType := "Extensão do arquivo" +" (*.csv) |*.csv|"
	cArquivo := cGetFile(cType, "Ok")
	If !Empty(cArquivo)
		cArquivo += Space(100-Len(cArquivo))
	Else
		cArquivo := Space(100)
	EndIf
Return cArquivo

Static Function RunProc(mv_par01)
	Local nHdl, nTotReg, cTrecho, cLinha, aLinha, cProduto, nQuant, cNumDoc, cSerie, nPPrd, nPQtd, nPDoc, nPMat, nPos, cTpoErro, lFoundB1, x, y, aPesq, lFoundD1
	Local aImport  := {}
	Local nTamPrd  := TamSX3("A7_CODCLI")[1]
	Local nTamDoc  := TamSX3("F1_DOC")[1]
	Local nTamSer  := TamSX3("F1_SERIE")[1]
	Local aPosicao := { {0, ""} }
	Local nX       := 0
	Local aPedido  := {}
	Local aItem    := {}
	Local aErro    := {}
	Local aExcel   := {}
	Local aSaldo   := {}
	Local aTES     := { "MV_XTSBEN", "MV_XTSBENN", "MV_XTSRPA"}
	Local cTES     := GetMV(aTES[mv_par05])   // TES de Saída de Devolução
	
	Private aCampos  := { { "PRODUTO", 0}, { "QUANT", 0}, { "PRECO", 0}, { "NOTA", 0}, { "MATCHID", 0}}
	
	nHdl := FT_FUSE(mv_par01)
	FT_FGOTOP()
	
	nTotReg := FT_FLASTREC()
	cLinha  := FT_FREADLN()
	
	ProcRegua(nTotReg)
	IncProc()
	
	// Faz leitura do cabeçalho dos itens
	While !Empty(cLinha)
		nX++
		
		cTrecho := Upper(AllTrim(If(At(";",cLinha)>0,Substr(cLinha,1,At(";",cLinha)-1),cLinha)))
		cLinha  := If(At(";",cLinha)>0,Substr(cLinha,At(";",cLinha)+1),"")
		
		AAdd(aPosicao,{ nX, cTrecho})
	EndDo
	
	If Len(aPosicao) > 1
		FT_FUSE()  // Fecha o arquivo atual
		
		// Efetua vinculação dos campos obrigatórios com uma coluna do excel
		If Escolha(aPosicao)
			// Reabre novamente o arquivo texto
			nHdl := FT_FUSE(mv_par01)
			FT_FGOTOP()
			FT_FREADLN()
		Else
			Return
		Endif
	Endif
	
	// Inicia a leitura dos itens do arquivo texto
	FT_FSKIP()
	While !FT_FEOF()
		nY      := 0
		aLinha  := {}
		cLinha  := FT_FREADLN()
		
		While !Empty(cLinha)
			nY++
			
			cTrecho := Upper(AllTrim(If(At(";",cLinha)>0,Substr(cLinha,1,At(";",cLinha)-1),cLinha)))
			cLinha  := If(At(";",cLinha)>0,Substr(cLinha,At(";",cLinha)+1),"")
			
			For nX:=1 To Len(aPosicao)
				If aPosicao[nX,1] == nY   // Se achar o campo
					AAdd(aLinha,cTrecho)
					Exit
				Endif
			Next
			
		EndDo
		
		AAdd(aImport,aLinha)
		
		IncProc("Lendo Arquivo...")
		
		FT_FSKIP()
	Enddo
	FT_FUSE()
	
	nPPrd := aCampos[1,2]   // Posição do Codigo do Produto
	nPQtd := aCampos[2,2]   // Posição da Quantidade
	nPPrc := aCampos[3,2]   // Posição do Preço
	nPDoc := aCampos[4,2]   // Posição do Documento
	nPMat := aCampos[5,2]   // Posição do Match ID
	
	ProcRegua(Len(aImport))
	For x:=1 To Len(aImport)
		
		IncProc("Validando registros...")
		
		cProduto := PADR(AllTrim(aImport[x,nPPrd]),nTamPrd)
		nQuant   := Val(aImport[x,nPQtd])
		nPreco   := Val("0"+aImport[x,nPPrc])
		cMatchID := AllTrim(aImport[x,nPMat])
		
		// Caso a linha tenha conteúdo inválido
		If Empty(cProduto) .Or. Empty(nQuant) .Or. Empty(aImport[x,nPDoc])
			Loop
		Endif
		
		cNumDoc  := AllTrim(aImport[x,nPDoc])
		nPos     := At("-",cNumDoc)
		
		cSerie   := PADR(SubStr(cNumDoc,nPos+1,nTamSer),nTamSer)
		cNumDoc  := PADR(SubStr(cNumDoc,1,nPos-1),nTamDoc)
		cTpoErro := ""
		lFoundD1 := .F.
		aPesq    := {}
		
		// Monta as possibilidades de pesquisar a nota de entrada
		For y:=1 To 2
			AAdd( aPesq , PADR(cNumDoc,nTamDoc)+cSerie )
			AAdd( aPesq , PADR(StrZero(Val(cNumDoc),6),nTamDoc)+cSerie )
			AAdd( aPesq , StrZero(Val(cNumDoc),nTamDoc)+cSerie )
			
			cSerie := PADL(AllTrim(cSerie),nTamSer,"0")
		Next
		
		// Posiciona no cadastro de produto
		If lFoundB1 := PesqBN(cProduto)
			// Posiciona no documento de entrada
			SD1->(dbSetOrder(1))

			// Pesquisa as possibilidades de encontrar a nota de entrada no sistema
			For y:=1 To Len(aPesq)
				If lFoundD1 := SD1->(dbSeek(XFILIAL("SD1")+aPesq[y]+mv_par02+mv_par03))
					Exit
				Endif
			Next

			If lFoundD1   // Se encontrou a nota
				cNumDoc := SD1->D1_DOC
				cSerie  := SD1->D1_SERIE
				
				// Posiciona no item do documento de entrada
				If SD1->(dbSeek(XFILIAL("SD1")+cNumDoc+cSerie+mv_par02+mv_par03+SB1->B1_COD))
					// Posiciona no saldo em poder de terceiro
					SB6->(dbSetOrder(1))
					If SB6->(dbSeek(XFILIAL("SB6")+SD1->(D1_COD+D1_FORNECE+D1_LOJA+D1_IDENTB6)))
						
						nPos := AScan( aSaldo , {|x| x[1] == SB6->B6_IDENT })
						If nPos == 0
							AAdd( aSaldo , { SB6->B6_IDENT, SB6->B6_SALDO - SaldoPedido(SB6->B6_IDENT), SB6->B6_PRUNIT} )
							nPos := Len(aSaldo)
						Endif
						
						If aSaldo[nPos,2] >= nQuant
							aSaldo[nPos,2] -= nQuant
							
							If Round(nPreco,2) == Round(SB6->B6_PRUNIT,2)
								AAdd( aItem , { SB6->B6_PRODUTO, SB6->B6_IDENT, nQuant, SB6->B6_PRUNIT, Round(nQuant * SB6->B6_PRUNIT,2), "", "", cMatchID})
								
								// Adiciona os itens a serem exibidos em tela
								AAdd( aExcel , { "S", AllTrim(aImport[x,nPPrd]), Trim(SB1->B1_COD), Trim(SB1->B1_DESC), nQuant, nPreco, AllTrim(aImport[x,nPDoc]), "OK.", cMatchID})
							Else
								cTpoErro := "Produto com preco diferente."
							Endif
						Else
							cTpoErro := "Produto sem saldo suficiente."
						Endif
					Else
						cTpoErro := "Produto sem poder de terceiro."
					Endif
				Else
					cTpoErro := "Produto nao cadastrado no documento."
				Endif
			Else
				cTpoErro := "Documento nao cadastrado."
			Endif
		Else
			cTpoErro := "Produto nao cadastrado."
		Endif
		
		If !Empty(cTpoErro)  // Se não encontrou erro
			AAdd( aErro , { x, aImport[x,nPPrd], aImport[x,nPQtd], aImport[x,nPDoc], cTpoErro} )
			
			// Adiciona os itens a serem exibidos em tela
			AAdd( aExcel , { "N", AllTrim(aImport[x,nPPrd]), If(lFoundB1,Trim(SB1->B1_COD),""), If(lFoundB1,Trim(SB1->B1_DESC),""),;
			nQuant, nPreco, AllTrim(aImport[x,nPDoc]), "ERRO: "+cTpoErro, cMatchID})
		Endif
	Next
	
	If Planilha(aExcel)
		If Empty(aErro)
			If MsgYesNo("O arquivo foi lido com sucesso. Deseja gerar os pedidos de venda ?")
				AAdd( aPedido , { CriaVar("C6_PEDCLI"), mv_par02, mv_par03, aClone(aItem), cTES} )
				
				u_STMonitorProcesso({|a| u_GravaRetLG(a) },aPedido)
				
			Endif
		Else
			NaoCad(aErro)
		Endif
	Endif
	
Return

User Function GravaRetLG(aPedido)
	Local aPvlNfs := {}
	Local lOk     := .T.
	
	Private cTPOper    := CriaVar("C6_OPER"   ,.F.)
	Private lInfNFS    := GetMV("MV_XINFNFS",.F.,.T.)    // Define se informa o número da nota
	Private __cNumNota := ""
	Private cSerie     := ""
	Private cNumero    := ""
	Private __cMensNF  := ""
	
	lMsErroAuto := .F.
	
	u_STInfNumeroNota(cFilAnt)   // Exibe tela de digitação do número da nota
	
	BeginTran()
	
	If lOk := u_STGeraPedido(aPedido,.T.)
		If lOk := u_STLiberaPedido("Retorno Simbólico",@aPvlNfs)
			
			__cMensNF := ""  //"RETORNO CONF. NF " + SF2->F2_DOC+"/"+SF2->F2_SERIE
			
			lOk := u_STGeraSaida("R","Retorno Simbólico",aPvlNfs)
		Endif
	Endif
	
	If lOk
		EndTran()
		
		u_STTransmissao("Retorno Simbólico")

		MsgInfo("Faturamento concluído com sucesso !")
	Else
		DisarmTransaction()
	Endif

Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ Escolha    ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de amarração dos campos obrigatórios da planilha       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Escolha(aPosicao)
	Local x
	Local nPos := 1
	Local aOpc := {}
	Local nOpc := 0
	Local lRet := .T.
	
	Private bOpc := {|a| ComboItem(a) }
	Private aCpo := {}
	Private aOpcoes := {}
	Private oDlgCol
	
	If !Empty(aCampos)
		aEval( aPosicao , {|x| AAdd( aOpcoes , x[2] ) } )
		
		// Monta vetor para seleção
		aEval( aCampos , {|x| AAdd( aCpo , { Nil, x[1], "", aClone(aOpcoes), AFill(Array(Len(aOpcoes)),.T.), "" } ) } )
		
		// Recupera os itens co-relacionados
		For x:=1 To Len(mv_par04)
			If SubStr(mv_par04,x,1) == ";"  // Quebra de item
				AAdd( aOpc , SubStr(mv_par04,nPos,x-nPos) )
				nPos := x + 1
			Endif
		Next
		
		// Efetua atribuição dos campos já co-relacionados
		For x:=1 To Len(aCpo)
			If x <= Len(aOpc)
				If Ascan( aCpo[x,4] , aOpc[x] ) > 0
					aCpo[x,3] := aOpc[x]
					Mudanca(x,.F.)
				Endif
			Endif
		Next
		
		DEFINE MSDIALOG oDlgCol TITLE "Atribuição de Colunas" FROM 00,00 TO 90+(20*Len(aCpo)),270 PIXEL
		
		@ 02,05 TO (Len(aCpo)*10)+13,140 PIXEL OF oDlgCol
		
		For x:=1 To Len(aCpo)
			Eval(bOpc,x)
		Next
		
		@ 23 + Len(aCpo)*10,060 BUTTON "&Ok" SIZE 25,15 PIXEL OF oDlgCol ACTION (nOpc:=Saida(), If( nOpc <> 0 , oDlgCol:End(), ))
		
		ACTIVATE MSDIALOG oDlgCol CENTERED
		
		If lRet := (nOpc == 1)  // Se não confirmou
			mv_par04 := ""
			For x:=1 To Len(aCampos)
				// Salva no parâmetro os campos relacionados
				mv_par04 += aCpo[x,3]+";"
				
				// Atribui a posição do campo no arquivo de origem (excel)
				aCampos[x,2] := AScan( aOpcoes , {|y| y == aCpo[x,3] } ) - 1
			Next
			
			// Grava perguntas para o perfil do usuário
			CriaPerg(.T.)
		Endif
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ ComboItem  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de criação do item de seleção                          ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ComboItem(x)
	@ (x*10)-5,010 SAY aCpo[x,2] SIZE 50,10 PIXEL OF oDlgCol
	@ (x*10)-5,050 COMBOBOX aCpo[x,1] VAR aCpo[x,3] ITEMS aCpo[x,4] SIZE 80,47 PIXEL OF oDlgCol ON CHANGE Mudanca(x,.T.)
Return

Static Function Saida()
	Local x
	Local nRet := 1
	
	For x:=1 To Len(aCpo)
		// Verifica se algum campo não foi relacionado a uma coluna do Excel
		If Empty(aCpo[x,3])
			nRet := If( MsgYesNo("Não foram atribuídos todos os campos. Confirma saída?") , 2, 0)
			Exit
		Endif
	Next
	
Return nRet

Static Function Mudanca(nPos,lAtu)
	Local x, y
	Local cOpcAtu := aCpo[nPos,3]
	Local cOpcAnt := aCpo[nPos,6]
	
	For x:=1 To Len(aCpo)
		If x <> nPos
			// Processa a exibição ou não dos campos nos demais campos
			For y:=1 To Len(aCpo[x,5])
				// Desabilita a exibição
				If !Empty(cOpcAtu) .And. cOpcAtu == aOpcoes[y]
					aCpo[x,5][y] := .F.
				Endif
				// Habilita a exibição
				If !Empty(cOpcAnt) .And. cOpcAnt == aOpcoes[y]
					aCpo[x,5][y] := .T.
				Endif
			Next
			
			// Refaz os itens do COMBO conforme itens a serem exibidos
			aCpo[x,4] := {}
			For y:=1 To Len(aCpo[x,5])
				If aCpo[x,5][y]
					AAdd( aCpo[x,4] , aOpcoes[y] )
				Endif
			Next
			
			// Desenha os itens do COMBO na tela
			If lAtu   // Se atualiza
				Eval(bOpc,x)
			Endif
		Endif
	Next
	
	aCpo[nPos,3] := cOpcAtu
	aCpo[nPos,6] := cOpcAtu
	
Return .T.

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ Planilha   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Exibe browse contendo os itens da planilha em excel           ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Planilha(aVetor)
	Local oDlg, oLbx, oTot, oPanelT, oVlr
	Local nOpcA := 0
	Local oOk   := LoadBitMap(GetResources(),"BR_VERDE")
	Local oNo   := LoadBitMap(GetResources(),"BR_VERMELHO")
	Local oFnt1 := TFont():New("Courier New",,-14,.T.,.T.)
	Local nTot  := 0
	
	If Empty(aVetor)
		Alert("Não foi possível importar os itens do arquivo !")
		Return .F.
	Endif
	
	aEval( aVetor , {|x| nTot += x[5]*x[6] } )

	DEFINE MSDIALOG oDlg TITLE "Itens do arquivo: "+Trim(mv_par01) From 8,0 To 39,129 OF oMainWnd
	
	@ 0,0 MSPANEL oPanelT PROMPT "" SIZE 10,202 OF oDlg CENTERED LOWERED //"Botoes"
	oPanelT:Align := CONTROL_ALIGN_BOTTOM
	
	@ 05,005 LISTBOX oLbx VAR cVar FIELDS HEADER;
														" ",;
														"Part Number",;
														"Produto",;
														"Descrição",;
														"Quantidade",;
														"Preço",;
														"Documento",;
														"Match ID",;
														"Observação",;
														SIZE 500,180 OF oPanelT PIXEL
	
	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {	If(aVetor[oLbx:nAt,1]=="S",oOk,oNo),;
						aVetor[oLbx:nAt,2],;
						aVetor[oLbx:nAt,3],;
						aVetor[oLbx:nAt,4],;
						aVetor[oLbx:nAt,5],;
						aVetor[oLbx:nAt,6],;
						aVetor[oLbx:nAt,7],;
						aVetor[oLbx:nAt,9],;
						aVetor[oLbx:nAt,8]}}
	
	@ 190,005 SAY "Total de itens lidos" SIZE 80,8 OF oPanelT PIXEL FONT oFnt1 COLOR CLR_BLUE
	@ 190,080 SAY oTot VAR Transform(Len(aVetor),"@E 999,999") PIXEL OF oPanelT FONT oFnt1 SIZE 85,10 COLOR CLR_HRED
	
	@ 190,155 SAY "Valor Total" SIZE 80,8 OF oPanelT PIXEL FONT oFnt1 COLOR CLR_BLUE
	@ 190,195 SAY oVlr VAR Transform(nTot,"@E 999,999,999.99") PIXEL OF oPanelT FONT oFnt1 SIZE 85,10 COLOR CLR_HRED
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| IIf(BuscaErro(aVetor),(nOpcA:=1,oDlg:End()), ) },{||oDlg:End()}) CENTERED
	
Return nOpcA == 1

Static Function BuscaErro(aVetor)
	Local nObs := Len(aVetor[1])
	Local lRet := (AScan( aVetor , {|x| "ERRO: " $ x[nObs] }) == 0)
	If !lRet
		Alert("Não é possível importar pois existe(m) item(ns) com erro no arquivo !")
	Endif
Return lRet


/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ NaoCad     ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Imprime as divergencias encontrdas na planilha en excel.      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function NaoCad(vErro)
Local cDesc1     := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2     := "de acordo com os parametros informados pelo usuario."
Local cDesc3     := "Divergencia arquivo Excel"
Local Titulo     := "Divergencia arquivo Excel"
Local nLin       := 80
Local Cabec1     := ""
Local Cabec2     := ""
Local aOrd       := {}

Private Limite   := 132
Private Tamanho  := "M"
Private NomeProg := "PAFATP06" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo    := 15
Private aReturn  := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey := 0
Private m_pag    := 01
Private wnrel    := "PAFATP06" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,"",@Titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cabec1 := "Linha  Produto                         Quantidade  Documento        Observacao"
//         9999   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  xxxxxxxxxx  xxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//         000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111111111111111111
//         000000000011111111112222222222333333333344444444445555555555666666666677777777778888888888999999999900000000001111111111222222222233
//         012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,vErro) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,vErro)
Local x

SetRegua(Len(vErro))

For x:=1 To Len(vErro)
	
	IncRegua()
	
	If nLin > 60
		nLin := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18) + 1 //Impressao do cabecalho
	EndIf
	@ nLin,000      PSAY vErro[x,1] Picture "@E 9999"
	@ nLin,PCol()+3 PSAY PADR(vErro[x,2],30)
	@ nLin,PCol()+2 PSAY PADR(vErro[x,3],10)
	@ nLin,PCol()+2 PSAY PADR(vErro[x,4],15)
	@ nLin,PCol()+2 PSAY PADR(vErro[x,5],40)
	nLin++
	
Next
nLin++
@ nLin,001 PSAY "Total de registros ==>> "+Str(Len(vErro),5)

Roda(0,Space(10),Tamanho)
If aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel) //Chamada do Spool de Impressao
Endif
MS_FLUSH() //Libera fila de relatorios em spool
Return

Static Function CriaPerg(lGrv)
	Local aLinha, x, nTam
	Local nPos   := 0
	Local aUser  := {}
	Local cLinha := ""
	Local cPerg  := GetSrvProfString("StartPath","") + Trim(FunName()) + ".SX1"
	
	If !File(cPerg)
		fHandle := FCREATE(cPerg)
		FCLOSE(fHandle)
	Endif
	
	fHandle := FT_FUSE(cPerg)
	FT_FGOTOP()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		aLinha := {}
		nTam   := 0
		
		// Adiciona o usuário
		AAdd( aLinha , SubStr(cLinha,1,30) )
		nTam += 30
		
		For x:=1 To Len(aPerg)
			AAdd( aLinha , SubStr(cLinha,nTam+1,aPerg[x,3]) )
			nTam += aPerg[x,3]
		Next
		
		AAdd( aUser , aClone(aLinha) )
		
		// Pesquisa o usuário no arquivo de perguntas
		If cUserName == PADR(cLinha,Len(cUserName))
			nPos := Len(aUser)
		Endif
		
		FT_FSKIP()
	Enddo
	FT_FUSE()
	
	If nPos == 0
		AAdd( aUser , Nil )
		nPos := Len(aUser)
	Endif
	aLinha := {}
	AAdd( aLinha , PADR(cUserName,30) )
	
	If lGrv
		FErase(cPerg)
		fHandle := FCREATE(cPerg)
		
		For x:=1 To Len(aPerg)
			
			If aPerg[x,4] == "C"
				aPerg[x,7] := AScan( aPerg[x,9] , aPerg[x,7] )
			Endif
			
			//&("mv_par"+StrZero(x,2)) := aPerg[x,7]
			aPerg[x,7] := &("mv_par"+StrZero(x,2))
			
			aPerg[x,7] := If( aPerg[x,2] == "N" , Str(aPerg[x,7],aPerg[x,3]), If( aPerg[x,2] == "D" , PADR(Dtoc(aPerg[x,7]),10), PADR(aPerg[x,7],aPerg[x,3])))
			
			AAdd( aLinha , aPerg[x,7] )
		Next
		
		aUser[nPos] := aClone(aLinha)
		
		For x:=1 To Len(aUser)
			cLinha := ""
			aEval( aUser[x] , {|y| cLinha += y } )
			FWRITE( fHandle , cLinha+Chr(13)+Chr(10) )
		Next
		
		FCLOSE(fHandle)
	ElseIf nPos > 0
		
		// Caso não existe referência de perguntas para o usuário
		If aUser[nPos] == Nil
			aEval( aPerg , {|x| x[7] := If( x[4] == "C" , "1", If( x[2] == "N" , "0", Space(x[3]))),;
			AAdd( aLinha , x[7] ) })
			aUser[nPos] := aClone(aLinha)
		Endif
		
		For x:=1 To Len(aPerg)
			aPerg[x,7] := If( aPerg[x,2] == "N" , Val(aUser[nPos,x+1]), If( aPerg[x,2] == "D" , Ctod(aUser[nPos,x+1]), aUser[nPos,x+1]))
			
			&("mv_par"+StrZero(x,2)) := aPerg[x,7]
			
			If aPerg[x,4] == "C"
				aPerg[x,7] := aPerg[x,9][If( aPerg[x,7] > 0 .And. aPerg[x,7] <= Len(aPerg[x,9]) , aPerg[x,7], 1)]
				&("mv_par"+StrZero(x,2)) := Ascan(aPerg[x,9],aPerg[x,7])
			Endif
		Next
	Endif
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ SaldoPedido¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Calcula o saldo em pedido para o item do poder de terceiros   ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function SaldoPedido(cIdentB6)
	Local cAli := Alias()
	Local cQry := ""
	Local nRet := 0
	
	cQry += "SELECT ISNULL(SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT),0) AS C6_QTDVEN"
	cQry += " FROM "+RetSQLName("SC6")+" SC6"
	cQry += " WHERE SC6.D_E_L_E_T_ = ' '"
	cQry += " AND SC6.C6_FILIAL = '"+SC6->(XFILIAL("SC6"))+"'"
	cQry += " AND SC6.C6_IDENTB6 = '"+cIdentB6+"'"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "QRY", .T., .F. )
	nRet := C6_QTDVEN
	dbCloseArea()
	dbSelectArea(cAli)
	
Return nRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ PesqBN     ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Efetua pesquisa de um produto beneficiamento                  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function PesqBN(cProd)
	Local lRet := .T.
	
	SA7->(dbSetOrder(3))
	If lRet := SA7->(dbSeek(XFILIAL("SA7")+SA1->A1_COD+SA1->A1_LOJA+cProd))
		SB1->(dbSetOrder(1))
		If lRet := SB1->(dbSeek(XFILIAL("SB1")+SA7->A7_PRODUTO))
			// Se for tipo de beneficiamento ou Produto Acabado, dependendo do parâmetro
			lRet := (SB1->B1_TIPO $ If( mv_par05 < 3 , "BN,MT", "PA"))
		Endif
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦STGeraPedido¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 19/11/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina para criar os pedidos de venda de beneficiamento       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STGeraPedido(vPedido,lMonitor,lGeraPed,aItens)
	Local x, y, nValor, cMatchID, aItem
	Local cItem    := StrZero(0,Len(SC6->C6_ITEM))
	Local aArrSC5  := {}
	Local aArrSC6  := {}
	Local nSaveSX8 := 0
	Local cFilSC6  := SC6->(XFILIAL("SC6"))
	Local cNumPed  := ""
	Local lRetorno := .F.
	
	Default lMonitor := .F.
	Default lGeraPed := .T.
	
	For x:=1 To Len(vPedido)
		If lGeraPed
			// Variavel que controla numeracao
			nSaveSX8 := GetSx8Len()
			
			cNumPed := GetSXENum("SC5","C5_NUM")   // Pega o próximo pedido de venda
			RollBAckSx8()
		Endif
		
		If lMonitor
			u_STRefreshMonitor("1",{ "1" , cNumPed, "", "", "Gerando pedido de Retorno Simbólico na filial "+cFilAnt+"..."})
		Endif
		
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(XFILIAL("SA1")+vPedido[x,2]+vPedido[x,3]))
		
		For y:=1 To Len(vPedido[x,4])
			
			cMatchID := If( Len(vPedido[x,4][y]) > 7 , vPedido[x,4][y,8], "")
			
			// Posiciona no Cadastro de Produtos
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(XFILIAL("SB1")+vPedido[x,4][y,1]))
			
			// Posiciona no Item da N.F. de Entrada
			SD1->(dbSetOrder(4))
			SD1->(dbSeek(XFILIAL("SD1")+vPedido[x,4][y,2]))
			
			// Posiciona no TES de  Retorno
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(XFILIAL("SF4")+vPedido[x,5]))
						
			cItem := Soma1(cItem,Len(SC6->C6_ITEM))
			
			nValor := a410Arred( vPedido[x,4][y,3] * vPedido[x,4][y,4] , "C6_VALOR" , NIL )
			
			aItem  := {}
			If lGeraPed
				AAdd(aItem, { "C6_FILIAL"  , cFilSC6             , Nil} )
				AAdd(aItem, { "C6_NUM"     , cNumPed             , Nil} )
			Endif
			AAdd(aItem, { "C6_ITEM"    , cItem               , Nil} )
			AAdd(aItem, { "C6_PRODUTO" , SB1->B1_COD         , Nil} )
			AAdd(aItem, { "C6_DESCRI"  , SB1->B1_DESC        , Nil} )
			AAdd(aItem, { "C6_QTDVEN"  , vPedido[x,4][y,3]   , Nil} )
			AAdd(aItem, { "C6_ENTREG"  , dDataBase           , Nil} )
			AAdd(aItem, { "C6_UM"      , SB1->B1_UM          , Nil} )
			//AAdd(aItem, { "C6_SEGUM"   , SB1->B1_SEGUM       , Nil} )
			AAdd(aItem, { "C6_TES"     , vPedido[x,5]        , Nil} )
			AAdd(aItem, { "C6_CF"      , SF4->F4_CF          , Nil} )
			//AAdd(aItem, { "C6_XSTATUS" , "S"                 , Nil} )
			AAdd(aItem, { "C6_QTDLIB"  , vPedido[x,4][y,3]   , Nil} )
			AAdd(aItem, { "C6_LOCAL"   , SB1->B1_LOCPAD      , Nil} )
			AAdd(aItem, { "C6_CLI"     , SA1->A1_COD         , Nil} )
			AAdd(aItem, { "C6_LOJA"    , SA1->A1_LOJA        , Nil} )
			AAdd(aItem, { "C6_OP"      , "02"                , Nil} )
			AAdd(aItem, { "C6_TPOP"    , "F"                 , Nil} )
			AAdd(aItem, { "C6_PRUNIT"  , vPedido[x,4][y,4]   , Nil} )
			AAdd(aItem, { "C6_PRCVEN"  , vPedido[x,4][y,4]   , Nil} )
			AAdd(aItem, { "C6_VALOR"   , nValor              , Nil} )
			AAdd(aItem, { "C6_NFORI"   , SD1->D1_DOC         , Nil} )
			AAdd(aItem, { "C6_SERIORI" , SD1->D1_SERIE       , Nil} )
			AAdd(aItem, { "C6_ITEMORI" , SD1->D1_ITEM        , Nil} )
			AAdd(aItem, { "C6_IDENTB6" , vPedido[x,4][y,2]   , Nil} )
			AAdd(aItem, { "C6_PEDCLI"  , vPedido[x,4][y,6]   , Nil} )
			AAdd(aItem, { "C6_XLINPED" , vPedido[x,4][y,7]   , Nil} )
			AAdd(aItem, { "C6_XMATCH"  , cMatchID            , Nil} )
			
			AAdd(aArrSC6, aClone(aItem) )
		Next
		
		aArrSC5 := {}
		AAdd( aArrSC5 , { "C5_FILIAL"  , xFilial("SC5")  , Nil} )
		AAdd( aArrSC5 , { "C5_NUM"     , cNumPed         , Nil} )
		AAdd( aArrSC5 , { "C5_TIPO"    , "N"             , Nil} )
		AAdd( aArrSC5 , { "C5_CLIENTE" , SA1->A1_COD     , Nil} )
		AAdd( aArrSC5 , { "C5_LOJACLI" , SA1->A1_LOJA    , Nil} )
		AAdd( aArrSC5 , { "C5_CLIENT"  , SA1->A1_COD     , Nil} )
		AAdd( aArrSC5 , { "C5_LOJAENT" , SA1->A1_LOJA    , Nil} )
		AAdd( aArrSC5 , { "C5_EMISSAO" , dDataBase       , Nil} )
		AAdd( aArrSC5 , { "C5_CONDPAG" , SA1->A1_COND    , Nil} )
		AAdd( aArrSC5 , { "C5_TABELA"  , SA1->A1_TABELA  , Nil} )
		AAdd( aArrSC5 , { "C5_MOEDA"   , 1               , Nil} )
		AAdd( aArrSC5 , { "C5_TIPOCLI" , SA1->A1_TIPO    , Nil} )
		AAdd( aArrSC5 , { "C5_TIPLIB"  , "2"             , Nil} )
		AAdd( aArrSC5 , { "C5_LIBEROK" , "S"             , Nil} )
		AAdd( aArrSC5 , { "C5_XPEDORI" , vPedido[x,1]    , Nil} )
		
		If lGeraPed
			lMsErroAuto := .F.
			
			MSExecAuto({|x,y,Z| Mata410(x,y,Z)}, aArrSC5, aArrSC6, 3)
			
			If lRetorno := !lMsErroAuto
				If (__lSX8)
					// Confirma SX8
					While ( GetSx8Len() > nSaveSX8 )
						ConfirmSX8()
					Enddo
				EndIf
			Else
				MostraErro()
				
				If (__lSX8)
					RollBackSx8()
				EndIf
				
				DisarmTransaction()
				
				If lMonitor
					u_STRefreshMonitor("3","Erro na geração do pedido de Retorno Simbólico !")
				Endif
			Endif
		Else
			aItens := aClone(aArrSC6)
		Endif
	Next
	
Return lRetorno
