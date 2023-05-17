#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"                  
#Include 'Protheus.ch'                                       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ STFATP01  º Autor ³ Ronilton Barros   º Data ³  18/10/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Importação da Carteira de Pedido em TXT.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SATO METALURGICA                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function STFATP01()
	Local oDlg
	Local aCmpPed := {}
	Local nOpc    := 0
	
	Private cHashMD5 := ""
	Private aPerg    := {}
		
	AAdd( aPerg , { "Cliente"             , "C",   6, "G", "@!", "   ", "", "", Nil })
	AAdd( aPerg , { "Loja"                , "C",   2, "G", "@!", "   ", "", "", Nil })
	AAdd( aPerg , { "Path Arquivo Kanban" , "C", 150, "G", "@!", "   ", "", "", Nil })
	AAdd( aPerg , { "Separador"           , "C",   1, "G", "@!", "   ", "", "", Nil })
	AAdd( aPerg , { "Campos Kanban"       , "C", 255, "G", "@!", "   ", "", "", Nil })
	
	// Carrega perguntas para o perfil do usuário
	u_STCriaPerg(.F.)
	
	DEFINE MSDIALOG oDlg TITLE "Importação de Pedidos" From 0,0 To 26,50
	
	@ 007,007 SAY "Cliente" SIZE 40,10 PIXEL OF oDlg
	@ 007,035 MSGET mv_par01 PICTURE "@!" F3 "SA1" Valid ExistCpo("SA1") SIZE 40, 10 PIXEL OF oDlg
	@ 007,107 SAY "Loja "   SIZE 20,10 PIXEL OF oDlg
	@ 007,125 MSGET mv_par02 PICTURE "@!" SIZE 20, 10 PIXEL OF oDlg
	
	@ 025,007 SAY "Informe o local onde se encontra o arquivo de pedidos:" SIZE 200,80 PIXEL OF oDlg
	@ 035,005 MSGET mv_par03 PICTURE "@!" SIZE 150, 10 PIXEL OF oDlg
	@ 035,160 BUTTON "Abrir..." SIZE 30,12 PIXEL OF oDlg ACTION mv_par03 := FATP01DlgArq(mv_par03)
	
	@ 052,007 SAY "Separador de colunas" SIZE 60,80 PIXEL OF oDlg
	@ 052,070 MSGET mv_par04 PICTURE "@!" Valid mv_par04 $ ";,#|" SIZE 10, 10 PIXEL OF oDlg
	
	@ 170,050 BUTTON "Importar" SIZE 40,12 PIXEL OF oDlg ACTION If( Arquivo(mv_par03) , (nOpc:=1,oDlg:End()), )
	@ 170,110 BUTTON "Cancelar" SIZE 40,12 PIXEL OF oDlg ACTION (nOpc:=0,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpc == 1
		// Grava perguntas para o perfil do usuário
		u_STCriaPerg(.T.)
		
		If !Empty(mv_par03)
			AAdd( aCmpPed , { "PRODUTO"      , 0, .T., "Z1_PRODUTO" } )  // 1
			AAdd( aCmpPed , { "PED_CLIENTE"  , 0, .T., "Z1_PEDCLI"  } )  // 2
			AAdd( aCmpPed , { "DATA_ENTREGA" , 0, .T., "Z1_DATENT"  } )  // 3
			AAdd( aCmpPed , { "QUANTIDADE"   , 0, .T., "Z1_QUANT"   } )  // 4
			AAdd( aCmpPed , { "SETOR ENTREGA", 0, .F., "Z1_SETENT"  } )  // 5
			AAdd( aCmpPed , { "HORA ENTREGA" , 0, .F., "Z1_HORENT"  } )  // 6
			AAdd( aCmpPed , { "LINHA ENTREGA", 0, .F., "Z1_LINPED"  } )  // 7
			AAdd( aCmpPed , { "XPED_DA_NFE"  , 0, .F., "Z1_XPED"    } )  // 8
			AAdd( aCmpPed , { "LOCAL ENTREGA", 0, .F., "Z1_LOCENT"  } )  // 9
			
			ImportaArquivo(mv_par03,"mv_par05",aCmpPed,"Pedidos Sato")
		Endif
	Endif
	
Return

Static Function ImportaArquivo(cArquivo,cParam,aCampos,cLegenda)
	Local aPed := {}
	
	Private aCabArq  := {}
	Private aItemArq := {}
	
	Processa({|| aPed := RunProc(cArquivo,cParam,@aCampos,cLegenda) },"Lendo arquivo texto","Aguarde...")

	If !Empty(aPed)
		fLerArq(aPed,aCampos)
	Endif
	
Return

Static Function Arquivo(cFile)
	Local lRet := .F.
	
	If File(cFile)
		cHashMD5 := MD5FILE(cFile , 2, 0 )   // Calcula o identificador do arquivo
			
		If Empty(cHashMD5)
			Alert("Ocorreu um erro na leitura do arquivo "+cFile+" informado !")
		Else
			SZ1->(dbSetOrder(3))
			If lRet := !SZ1->(dbSeek(XFILIAL("SZ1")+cHashMD5))
			Else
				Alert("O arquivo "+cFile+" já foi importado !")
			Endif
		Endif
	Else
		MsgStop("Arquivo não encontrado.","Atenção!!")
	Endif
	
Return lRet

Static Function FATP01DlgArq(cArquivo)
	cType := "Extensão do arquivo" +" (*.csv) |*.csv|"
	cArquivo := cGetFile(cType, "Ok")
	If !Empty(cArquivo)
		cArquivo += Space(150-Len(cArquivo))
	Else
		cArquivo := Space(150)
	EndIf
Return cArquivo

Static Function fLerArq(aPedidos,aCampos)
	Local cCliente, cTipo, cPedido, cItem, dDtPlan, cHrPlan, cSetor, nQuant, cInform, cAstec, cInfXped, cInfLnPed, cQtdTemp, cDtTemp, nX, cLocalEnt
	Local lCab := .T.
	Local lOk  := .F.
	
	Private aItens
	
	SA1->(dbSetOrder(1))
	
	ProcRegua(Len(aPedidos))
	aCabArq     := {}
	aItemArq    := {}
	lMostraTela := .T.
	
	For nX:=1 To Len(aPedidos)
		
		IncProc()
		
		cCliente  := mv_par01+mv_par02                    // 1
		cTipo     := " "                                  // 2
		cPedido   := Conteudo(aPedidos[nX],aCampos[2,2])  // 3
		cItem     := Conteudo(aPedidos[nX],aCampos[1,2])  // 4
		cDtTemp   := Conteudo(aPedidos[nX],aCampos[3,2])  // 5
		cHrPlan   := Conteudo(aPedidos[nX],aCampos[6,2])  // 6
		cSetor    := Conteudo(aPedidos[nX],aCampos[5,2])  // 7
		cQtdTemp  := Conteudo(aPedidos[nX],aCampos[4,2])  // 8
		cInform   := cPedido                              // 9
		cAstec    := mv_par02                             // 10
		cInfXped  := Conteudo(aPedidos[nX],aCampos[8,2])  // 11
		cInfLnPed := Conteudo(aPedidos[nX],aCampos[7,2])  // 12
		cLocalEnt := Conteudo(aPedidos[nX],aCampos[9,2])  // 13
		
		nQuant    := Val(cQtdTemp)
		dDtPlan   := If( At("/",cDtTemp) == 0 , If( Empty(StoD(StrTran(cDtTemp,"-",""))), CtoD(Transform(cDtTemp,"@R 99/99/9999")), StoD(StrTran(cDtTemp,"-",""))), CtoD(cDtTemp))
		cHrPlan   := If( Empty(cHrPlan) , "0800", cHrPlan)
		
		// Somente importa datas de entrega igual ou superior a data atual
		If .T. .Or. dDtPlan >= dDataBase
			// Posiciona no cliente e identifica se o controle de kanban permite a importação da carteira
			If SA1->(dbSeek(XFILIAL("SA1")+cCliente))
				
				If lCab
					AAdd(aCabArq, {cCliente, cAstec})
					lCab := .F.
				EndIf
				
				//                 1        2      3        4        5       6       7        8       9         10         11                          12
				AAdd( aItemArq , { cPedido, cItem, dDtPlan, cHrPlan, cSetor, nQuant, cInform, cAstec, cInfXped, cInfLnPed, If(Empty(cPedido),"2","1"), cLocalEnt})
			Endif
		Endif
		
	Next
	lCab := .T.
	
	If lMostraTela .And. !Empty(aCabArq)   // Se encontrou registros válidos
		Processa({|| lOk := fTelaImp() },"Processando os Dados...")
	EndIf
	
Return lOk

Static Function Conteudo(aLinha,nColuna)
Return If( nColuna > 0 , aLinha[nColuna] , "")

Static Function fTelaImp()
	Local oDlg, nX, cCliente, cProduto, cDescri, cUM, nTitens, nY
	Local lRet      := .F.
	Local oFonte_16 := TFont():New("Calibri",,-16,.T.,.T.)
	Local oFonte_14 := TFont():New("Calibri",,-14,.T.,.T.)
	Local nTamPrd   := TamSX3("A7_CODCLI")[1]
	
	Private aCampos  := {}
	
	AAdd( aCampos , { "Z1_TIPPED" , {|| aItemArq[nX,11]                           }} )   //  1 - Tipo do Pedido
	AAdd( aCampos , { "A7_CODCLI" , {|| aItemArq[nX,02]                           }} )   //  2 - Produto Cliente
	AAdd( aCampos , { "A7_PRODUTO", {|| cProduto                                  }} )   //  3 - Produto MC
	AAdd( aCampos , { "A7_DESCCLI", {|| cDescri                                   }} )   //  4 - Descrição Produto
	AAdd( aCampos , { "C6_UM"     , {|| cUM                                       }} )   //  5 - Unidade Produto
	AAdd( aCampos , { "C6_QTDVEN" , {|| aItemArq[nX,6]                            }} )   //  6 - Quantidade
	AAdd( aCampos , { "C6_ENTREG" , {|| aItemArq[nX,3]                            }} )   //  7 - Data de Entrega
	AAdd( aCampos , { "C6_PEDCLI" , {|| aItemArq[nX,1]                            }} )   //  8 - Pedido Cliente
	AAdd( aCampos , { "Z1_SETENT" , {|| PADR(aItemArq[nX, 5],Len(SZ1->Z1_SETENT)) }} )   //  9 - Setor
	AAdd( aCampos , { "Z1_HORENT" , {|| PADR(aItemArq[nX, 4],Len(SZ1->Z1_HORENT)) }} )   // 10 - Hora
	AAdd( aCampos , { "Z1_XPED"   , {|| aItemArq[nX,9]                            }} )   // 11 - Linha
	AAdd( aCampos , { "Z1_LINPED" , {|| aItemArq[nX,10]                           }} )   // 12 - xPed
	AAdd( aCampos , { "Z1_KANBAN" , {|| PADR(aItemArq[nX, 7],Len(SZ1->Z1_KANBAN)) }} )   // 13 - Kanban
	AAdd( aCampos , { "C6_LOJA"   , {|| PADR(aItemArq[nX, 8],Len(SZ1->Z1_LOJA  )) }} )   // 14 - Astec
	AAdd( aCampos , { "Z1_LOCENT" , {|| PADR(aItemArq[nX,12],Len(SZ1->Z1_LOCENT)) }} )   // 15 - Local de Entrega
	
	Private aHeader := {}
	Private aCols   := {}
	Private cZ1KANB := "1"
	
	For nX:=1 To Len(aCampos)
		AAdd( aHeader , aCampos[nX,1] )
		
		aHeader[nX] := {GetSx3Cache(aCampos[nX,1], 'X3_TITULO'),;
						GetSx3Cache(aCampos[nX,1], 'X3_CAMPO'),;
						GetSx3Cache(aCampos[nX,1], 'X3_PICTURE'),;
						GetSx3Cache(aCampos[nX,1], 'X3_TAMANHO'),;
						GetSx3Cache(aCampos[nX,1], 'X3_DECIMAL'),;
						"",;
						GetSx3Cache(aCampos[nX,1], 'X3_USADO'),;
						GetSx3Cache(aCampos[nX,1], 'X3_TIPO'),;
						GetSx3Cache(aCampos[nX,1], 'X3_F3'),;
						GetSx3Cache(aCampos[nX,1], 'X3_CONTEXT'),;
						GetSx3Cache(aCampos[nX,1], 'X3_CBOX'),;
						GetSx3Cache(aCampos[nX,1], 'X3_RELACAO'),;
						GetSx3Cache(aCampos[nX,1], 'X3_WHEN'),;
						GetSx3Cache(aCampos[nX,1], 'X3_VISUAL'),;
						GetSx3Cache(aCampos[nX,1], 'X3_VLDUSER'),;
						GetSx3Cache(aCampos[nX,1], 'X3_PICTVAR'),;
						If(GetSx3Cache(aCampos[nX,1], 'X3_OBRIGAT') == "€", .T., .F.)}
	Next
	
	cCliente := aCabArq[1,1]+aCabArq[1,2]
	
	SA1->(DbSetorder(1))
	If SA1->(DbSeek(xFilial("SA1")+cCliente))
		cCliente := SA1->A1_COD + "-"+SA1->A1_LOJA+" "+SA1->A1_NOME
	EndIf
	
	ProcRegua(Len(aItemArq))
	
	nTitens := 0
	For nX:=1 To Len(aItemArq)
		
		IncProc()
		
		cProduto := ""
		cDescri  := ""
		cUM      := ""
		
		SA7->(dbSetOrder(3))
		If SA7->(dbSeek(XFILIAL("SA7")+SA1->A1_COD+SA1->A1_LOJA+aItemArq[nX,2])) .Or. SA7->(dbSeek(XFILIAL("SA7")+SA1->A1_COD+SA1->A1_LOJA+PADR("BE-"+aItemArq[nX,2],nTamPrd)))
			SB1->(DbSetorder(1))
			If SB1->(DbSeek(xFilial("SB1")+SA7->A7_PRODUTO)) 
				cProduto := SB1->B1_COD
				cDescri  := SB1->B1_DESC
				cUM      := SB1->B1_UM
			EndIf
		Endif
		
		AddLinhaaCols(@aCols,aHeader)
		
		For nY:=1 To Len(aCampos)
			aCols[nX,nY] := Eval(aCampos[nY,2])
		Next
		
		nTitens++
	Next

	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Importação do Arquivo do Kanban") FROM 09,00 TO 46,160

	@ 005,005 SAY "Validação do Arquivo" SIZE 100,15 OF oDlg PIXEL FONT oFonte_16 COLOR CLR_BLUE
	@ 018,002 TO 019,623 PIXEL OF oDlg
	@ 005,532 BUTTON OemToAnsi("Cancelar") SIZE 40,11 FONT oDlg:oFont ACTION (lRet:=.F.,oDlg:End()) PIXEL OF oDlg
	@ 005,582 BUTTON OemToAnsi("Importar") SIZE 40,11 FONT oDlg:oFont ACTION If(lRet:=fValidArq(),(aItens:=oGet:aCols,oDlg:End()),) PIXEL OF oDlg
	
	@ 030,005 SAY "Cliente:" SIZE 100,10 PIXEL OF oDlg 
	@ 030,045 SAY cCliente SIZE 200,10 OF oDlg PIXEL FONT oFonte_14
	
	@ 045,005 SAY "Total Pedido:" SIZE 70,10 PIXEL OF oDlg 
	@ 045,035 SAY PadR(Transform(nTitens,"@E 999,999,999"),15) SIZE 140,10  OF oDlg PIXEL FONT oFonte_14

	@ 055,002 TO 056,623 PIXEL OF oDlg

	oGet := MsNewGetDados():New(	85,005,225,623,;
											GD_UPDATE + GD_INSERT + GD_DELETE,;
											"LinOk",;
											"TudoOk",;
											NIL,;
											NIL,;
											NIL,;
											Len(aCols),;
											NIL,;
											NIL,;
											"AllWaysFalse",; 							//Validacao p/ delecao
											oDlg,;
											@aHeader,;
											@aCols)
	
	//a propriedade SetBlkBackColor serve para colorir o fundo do grid
	//criei a função GETDCLR no qual passo a ela a linha posicionada e uma determinada cor.
	oGet:oBrowse:SetBlkBackColor({|| GETDCLR(oGet:oBrowse:nAt) })
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If lRet
		Processa({|| lRet := ExcluiCarteira(SA1->A1_COD,SA1->A1_LOJA) },"Excluindo kanban...")
	Endif
	
	If lRet
		Processa({|| lRet := fGeraPV(aItens) },"Gravando kanban...")
	Endif
	
Return lRet

Static Function GETDCLR(nLinha)
	Local nRet := 16777215
	
	If Empty(aCols[nLinha,3])
		nRet := CLR_HRED //4227327
	Endif
	
Return nRet

Static Function fValidArq()  
	Local lRet := .T.  

	SA1->(dbSetOrder(1))
	If lRet := SA1->(dbSeek(XFILIAL("SA1")+aCabArq[1,1]+aCabArq[1,2])) 
		SE4->(dbSetOrder(1))
		If lRet := ( !Empty(SA1->A1_COND) .And. SE4->(dbSeek(XFILIAL("SE4")+SA1->A1_COND)) )
			cZ1KANB := If( MsgYesNo("<strong><font face='Arial' size=3 color=RED>Deseja atualizar esse arquivo no Kanban ?</font></strong>","Pedido no Kanban") , "1", "2")
		Else
			Aviso("Erro - Condição de Pagamento Inválida!","A Codição de Pagamento não foi localizada no Cadastro do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+Alltrim(SA1->A1_NOME)+".",{"OK"})
		EndIf
	Else
		Alert("Cliente informado não existe !")
	Endif

Return lRet

Static Function AddLinhaaCols(aCols,aHeader)
	Local nX
	Local nTam := Len(aCols)+1
	
	AAdd( aCols , Array(Len(aHeader)+1) )
	For nX:=1 To Len(aHeader)
		aCols[nTam,nX] := CriaVar(aHeader[nX,2])
	Next
	aCols[nTam,Len(aHeader)+1] := .F.
	
Return

Static Function ExcluiCarteira(cCodigo,cLoja)
	Local cQry
	
	// Iguala as quantidades dos itens faturados parcialmente
	cQry := "UPDATE " + RetSQLName("SZ1")
	cQry += " SET Z1_QUANT = Z1_QTDENT"
	cQry += " WHERE D_E_L_E_T_ = ' '"
	cQry += " AND Z1_CLIENTE = '"+cCodigo+"'"
	//cQry += " AND Z1_LOJA = '"+cLoja+"'"
	cQry += " AND Z1_DATENT >= '"+DtoS(dDataBase)+"'"
	cQry += " AND Z1_QTDENT > 0"
	cQry += " AND Z1_QTDENT < Z1_QUANT"
	
	If TCSQLExec(cQry) < 0
		Alert("TCSQLError() " + TCSQLError())
		Return .F.
	Endif
	
	// Exclui os itens ainda não faturados
	cQry := "UPDATE " + RetSQLName("SZ1")
	cQry += " SET D_E_L_E_T_ = '*'" //, R_E_C_D_E_L = R_E_C_N_O_"
	cQry += " WHERE D_E_L_E_T_ = ' '"
	cQry += " AND Z1_CLIENTE = '"+cCodigo+"'"
	//cQry += " AND Z1_LOJA = '"+cLoja+"'"
	cQry += " AND Z1_DATENT >= '"+DtoS(dDataBase)+"'"
	cQry += " AND Z1_QTDENT = 0"
	
	If TCSQLExec(cQry) < 0
		Alert("TCSQLError() " + TCSQLError())
		Return .F.
	Endif
	
Return .T.

Static Function fGeraPV(aItens)
	Local x, y, nPos, cChave, cPedSato
	Local nX       := 1
	Local lRetorno := .F.
	Local cLocExp  := Alltrim(GetMV("MV_XLOCEXP"))
	Local nPPrd    := PosCampo("A7_PRODUTO")
	Local nPTip    := PosCampo("Z1_TIPPED" )
	Local nPEnt    := PosCampo("C6_ENTREG" )
	Local nPHor    := PosCampo("Z1_HORENT" )
	Local nPSet    := PosCampo("Z1_SETENT" )
	Local nPKan    := PosCampo("Z1_KANBAN" )
	Local nPQtd    := PosCampo("C6_QTDVEN" )
	Local nPPCl    := PosCampo("C6_PEDCLI" )
	Local nPxPd    := PosCampo("Z1_XPED"   )
	Local nPLin    := PosCampo("Z1_LINPED" )
	Local nPLoj    := PosCampo("C6_LOJA"   )
	Local nPLoc    := PosCampo("Z1_LOCENT" )
	Local aPrev    := {}
	Local nSaveSX8 := GetSx8Len()    // Variavel que controla numeracao
  	
	lMsErroAuto := .F.
	
	ASort( aItens ,,, {|x,y| DtoS(x[nPEnt])+x[nPHor]+x[nPSet]+x[nPKan] < DtoS(y[nPEnt])+y[nPHor]+y[nPSet]+y[nPKan] } )
	
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(XFILIAL("SA1")+aCabArq[1,1]))
	
	ProcRegua(Len(aItens))
	
	BeginTran()
	
	While nX <= Len(aItens)
		
		IncProc()
		
		If Empty(aItens[nX,nPPrd]) .Or. Empty(aItens[nX,nPQtd])
			nX++
			Loop
		Endif

		//If aItens[nX,nPTip] == "1"
			// Posiciona no Cadastro de Produtos
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(XFILIAL("SB1")+aItens[nX,nPPrd]))
			
			SB2->(dbSetOrder(1))
			If !SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+cLocExp))
				CriaSB2(SB1->B1_COD,cLocExp)
			EndIf
			
			cChave := SZ1->(XFILIAL("SZ1"))+SA1->A1_COD+aItens[nX,nPLoj]+SB1->B1_COD+aItens[nX,nPPCl]

			SZ1->(dbSetOrder(5))  // Z1_FILIAL+Z1_CLIENTE+Z1_LOJA+Z1_PRODUTO+Z1_PEDCLI+DTOS(Z1_DATENT)+Z1_HORENT+Z1_SETENT
			If SZ1->(dbSeek(cChave))
				cPedSato := SZ1->Z1_NUM
			Else
				cPedSato := GetSXENum("SZ1","Z1_NUM")

				SZ1->(dbSetOrder(1))
				While SZ1->(dbSeek(XFILIAL("SZ1")+cPedSato))
					cPedSato := GetSXENum("SZ1","Z1_NUM")
				Enddo
			Endif

			// Verifica se o kanban já existe, caso exista atualiza os campos de informação e quantidade
			SZ1->(dbSetOrder(5))  // Z1_FILIAL+Z1_CLIENTE+Z1_LOJA+Z1_PRODUTO+Z1_PEDCLI+DTOS(Z1_DATENT)+Z1_HORENT+Z1_SETENT
			If SZ1->(dbSeek(cChave+DtoS(aItens[nX,nPEnt])+aItens[nX,nPHor]+aItens[nX,nPSet]))
				RecLock("SZ1",.F.)
			Else
				RecLock("SZ1",.T.)
				SZ1->Z1_FILIAL  := XFILIAL("SZ1")
				SZ1->Z1_CLIENTE := SA1->A1_COD
				SZ1->Z1_LOJA    := aItens[nX,nPLoj]
				SZ1->Z1_PRODUTO := SB1->B1_COD
				SZ1->Z1_DATENT  := aItens[nX,nPEnt]
				SZ1->Z1_HORENT  := aItens[nX,nPHor]
				SZ1->Z1_SETENT  := aItens[nX,nPSet]
				SZ1->Z1_KANBAN  := aItens[nX,nPKan]
				SZ1->Z1_NUM     := cPedSato
				SZ1->Z1_PEDCLI  := aItens[nX,nPPCl]
				SZ1->Z1_LOCENT  := aItens[nX,nPLoc]
			Endif
			SZ1->Z1_QUANT   := Max(aItens[nX,nPQtd],SZ1->Z1_QTDENT)
			SZ1->Z1_TIPPED  := aItens[nX,nPTip]
			SZ1->Z1_XPED    := aItens[nX,nPxPd]
			SZ1->Z1_LINPED  := aItens[nX,nPLin]
			SZ1->Z1_HASHMD5 := cHashMD5
			SZ1->Z1_ATUKANB := cZ1KANB
			MsUnLock()
		//EndIf

		If cZ1KANB == "1"    // Se atualiza Kanban
			u_STGravaKanban(.T.)
		Endif
		
		// Acumula os dados da previsão
		nPos := AScan( aPrev , {|x| x[1] == aItens[nX,nPPrd] .And. x[2] == aItens[nX,nPEnt] } )
		If nPos == 0
			AAdd( aPrev , { aItens[nX,nPPrd], aItens[nX,nPEnt], 0, aItens[nX,nPPCl]} )
			nPos := Len(aPrev)
		Endif
		aPrev[nPos,3] += aItens[nX,nPQtd]
		
		nX++
	Enddo	
	
	If !Empty(aPrev)
		lRetorno := .T.
	Endif

	If lRetorno
		Processa({|| GravaPrevisao(aPrev) },"Gravando da previsão de venda. Aguarde...")
		
		While ( GetSx8Len() > nSaveSX8 )
			ConfirmSX8()
		Enddo
		
		EndTran()
		
		MsgInfo("Kanban foi importado com sucesso !","Importação Kanban")
	Else
		While ( GetSx8Len() > nSaveSX8 )
			RollBackSx8()
		Enddo
		
		DisarmTransaction()
	Endif
	
Return lRetorno

Static Function PosCampo(cCampo)
Return AScan( aCampos , {|x| x[1] == cCampo } )

Static Function fPrecoTab(cProduto,cCliente)
	Local nPreco := 0
	Local aArea  := GetArea()
	Local cQuery
	
	Default cCliente := "XyZxYzZz"
	
	SA1->(dbSetOrder(1))
	DA0->(dbSetOrder(1))
	DA1->(dbSetOrder(1))
	
	// Posiciona no Cliente e na tabela de preço definida para o mesmo
	If SA1->(dbSeek(XFILIAL("SA1")+cCliente)) .And. !Empty(SA1->A1_TABELA) .And. DA0->(dbSeek(XFILIAL("DA0")+SA1->A1_TABELA))
		// Caso a tabela esteja ativa
		If DA0->DA0_ATIVO == "1" .And. dDataBase >= DA0->DA0_DATDE .And. dDataBase <= If( Empty(DA0->DA0_DATATE) , dDataBase, DA0->DA0_DATATE)
			// Pesquisa os preços definidos para o produto + tabela cliente
			DA1->(dbSeek(XFILIAL("DA1")+SA1->A1_TABELA+cProduto,.T.))
			While !DA1->(Eof()) .And. XFILIAL("DA1")+SA1->A1_TABELA+cProduto == DA1->DA1_FILIAL+DA1->DA1_CODTAB+DA1->DA1_CODPRO
				// Caso a tabela definida para o produto esteja ativa
				If DA1->DA1_ATIVO == "1" .And. dDataBase >= If( Empty(DA1->DA1_DATVIG) , dDataBase, DA1->DA1_DATVIG)
					nPreco := DA1->DA1_PRCVEN    // Retorna o preço do produto + cliente e sai da pesquisa
					Exit
				Endif
				DA1->(dbSkip())
			Enddo
		Endif
	Endif
	
	// Caso não tenha encontrado um preço válido, processa o método antigo
	If nPreco == 0
		cQuery := " SELECT DA1_CODTAB,DA1_CODPRO,DA1_PRCVEN,DA1_ATIVO,DA1_DATVIG FROM "+RetSqlName("DA1")+" DA1"
		cQuery += " WHERE DA1_CODPRO = '"+cProduto+"' AND DA1_ATIVO = '1' AND DA1.D_E_L_E_T_ = ''"
		
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TBTEMP", .T., .T.)
		While !TBTEMP->(Eof())
			nPreco := TBTEMP->DA1_PRCVEN
			TBTEMP->(DbSkip())
		Enddo
		DbCloseArea()
	Endif
	RestArea(aArea)
	
Return nPreco

Static Function GravaPrevisao(aPrev)
	Local x, d, cProduto
	
	SC4->(dbSetOrder(1))
	
	ASort( aPrev ,,, {|x,y| x[1]+DtoS(x[2]) < y[1]+DtoS(y[2]) } )   // Ordena por PRODUTO + DATA ENTREGA
	
	ProcRegua(Len(aPrev))
	x := 1
	While x <= Len(aPrev)
		cProduto := aPrev[x,1]
		While x <= Len(aPrev) .And. cProduto == aPrev[x,1]
			
			IncProc()
			
			If SC4->(dbSeek(XFILIAL("SC4")+cProduto+DtoS(aPrev[x,2])))
				RecLock("SC4",.F.)
				SC4->C4_QUANT := aPrev[x,3]
				SC4->C4_VALOR := a410Arred( SC4->C4_QUANT * fPrecoTab(cProduto) , "C6_VALOR" , NIL )
				MsUnLock()
			Else
				RecLock("SC4",.T.)
				SC4->C4_FILIAL  := xFilial("SC4")
				SC4->C4_PRODUTO := cProduto
				SC4->C4_LOCAL   := Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_LOCPAD")
				SC4->C4_DOC     := SA1->A1_COD + SA1->A1_LOJA
				SC4->C4_QUANT   := aPrev[x,3]
				SC4->C4_VALOR   := a410Arred( SC4->C4_QUANT * fPrecoTab(cProduto) , "C6_VALOR" , NIL )
				SC4->C4_DATA    := aPrev[x,2]
				SC4->C4_OBS     := aPrev[x,4]
				MsUnLock()
			Endif

			x++
			
			// Apaga as datas não atualizadas
			If x <= Len(aPrev) .And. cProduto == aPrev[x,1]
				For d:=(aPrev[x-1,2]+1) To (aPrev[x,2]-1)
					If SC4->(dbSeek(XFILIAL("SC4")+cProduto+DtoS(d)))
						RecLock("SC4",.F.)
						dbDelete()
						MsUnLock()
					Endif
				Next
			Endif
		Enddo
		
	Enddo
	
Return

Static Function RunProc(cArquivo,cParam,aCampos,cPlanilha)
	Local nHdl, nTotReg, cTrecho, cLinha, aLinha, nY, nC, cValor
	Local aImport  := {}
	Local aPosicao := { {0, ""} }
	Local nX       := 0
	Local aLay     := LayOut(mv_par01)
	Local cQuebra  := aLay[2]
	
	nHdl := FT_FUSE(cArquivo)
	FT_FGOTOP()
	
	nTotReg := FT_FLASTREC()
	cLinha  := FT_FREADLN()
	
	If !(cQuebra $ cLinha)  // Se o caractere de quebra não for o ponto-e-virgula
		cQuebra := ","  // Substitui por virgula
	Endif
	
	ProcRegua(nTotReg)
	IncProc()
	
	If aLay[3] == "1"    // Se o arquivo padrão do cliente possui cabeçalho
		// Faz leitura do cabeçalho dos itens
		While !Empty(cLinha)
			nX++
			
			cTrecho := Upper(AllTrim(If(At(cQuebra,cLinha)>0,Substr(cLinha,1,At(cQuebra,cLinha)-1),cLinha)))
			cLinha  := If(At(cQuebra,cLinha)>0,Substr(cLinha,At(cQuebra,cLinha)+1),"")
			
			AAdd(aPosicao,{ nX, cTrecho})
		EndDo
		
		If Len(aPosicao) > 1
			FT_FUSE()  // Fecha o arquivo atual
			
			// Efetua vinculação dos campos obrigatórios com uma coluna do excel
			If Escolha(cPlanilha,@aCampos,aPosicao,cParam,cQuebra)
				// Reabre novamente o arquivo texto
				nHdl := FT_FUSE(cArquivo)
				FT_FGOTOP()
				FT_FREADLN()
			Else
				Return {}
			Endif
		Endif

		FT_FSKIP()
	Else
		For nX:=1 To Len(aLay[4])
			If ValType(aLay[4][nX,3]) == "A"   // Caso seja um conjunto de coordenadas
				AAdd( aPosicao , { nX, aLay[4][nX,1], aClone(aLay[4][nX,3])} )   // Adiciona as coordenadas
			Else
				AAdd( aPosicao , { nX, aLay[4][nX,1], aLay[4][nX,3], aLay[4][nX,4]} )
			Endif
		Next
		
		aEval( aCampos , {|x| cTrecho := x[4], x[2] := AScan( aLay[4] , {|y| y[2] == cTrecho } ) } )    // Pesquisa as posições das colunas
	Endif
	
	If aLay[3] == "2"    // Se o arquivo padrão deve saltar o cabeçalho
		FT_FSKIP()
	Endif
	
	// Inicia a leitura dos itens do arquivo texto
	While !FT_FEOF()
		nY      := 0
		aLinha  := {}
		cLinha  := FT_FREADLN()
		
		If aLay[3] <> "2"
			While !Empty(cLinha)
				nY++
				
				cTrecho := Upper(AllTrim(If(At(cQuebra,cLinha)>0,Substr(cLinha,1,At(cQuebra,cLinha)-1),cLinha)))
				cLinha  := If(At(cQuebra,cLinha)>0,Substr(cLinha,At(cQuebra,cLinha)+1),"")
				
				For nX:=1 To Len(aPosicao)
					If aPosicao[nX,1] == nY   // Se achar o campo
						AAdd(aLinha,cTrecho)
						Exit
					Endif
				Next
				
			EndDo
		Else
			For nX:=2 To Len(aPosicao)
				If ValType(aPosicao[nX,3]) == "A"
					cValor := ""
					For nC:=1 To Len(aPosicao[nX,3])
						cValor += AllTrim(SubStr(cLinha,aPosicao[nX,3][nC,1],aPosicao[nX,3][nC,2]-aPosicao[nX,3][nC,1]+1))
					Next
				Else
					cValor := AllTrim(SubStr(cLinha,aPosicao[nX,3],aPosicao[nX,4]-aPosicao[nX,3]+1))
				Endif
				AAdd(aLinha,cValor)
			Next
		Endif
		
		AAdd(aImport,aLinha)
		
		IncProc("Lendo Arquivo...")
		
		FT_FSKIP()
	Enddo
	FT_FUSE()

Return aImport

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ Escolha    ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de amarração dos campos obrigatórios da planilha       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Escolha(cPlanilha,aCampos,aPosicao,cParam,cQuebra)
	Local x
	Local nPos    := 1
	Local aOpc    := {}
	Local nOpc    := 0
	Local cCampos := &(cParam)
	Local lRet    := .T.
	
	Private bOpc := {|a| ComboItem(a) }
	Private aCpo := {}
	Private aOpcoes := {}
	Private oDlgCol
	
	If !Empty(aCampos)
		aEval( aPosicao , {|x| AAdd( aOpcoes , x[2] ) } )
		
		// Monta vetor para seleção
		aEval( aCampos , {|x| AAdd( aCpo , { Nil, x[1], "", aClone(aOpcoes), AFill(Array(Len(aOpcoes)),.T.), "",;
									 If(x[3],CLR_HBLUE,CLR_BLACK)} ) } )
		
		// Recupera os itens co-relacionados
		For x:=1 To Len(cCampos)
			If SubStr(cCampos,x,1) == cQuebra  // Quebra de item
				AAdd( aOpc , SubStr(cCampos,nPos,x-nPos) )
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
		
		DEFINE MSDIALOG oDlgCol TITLE "Atribuição de Colunas: "+cPlanilha FROM 00,00 TO 90+(20*Len(aCpo)),280 PIXEL
		
		@ 02,05 TO (Len(aCpo)*10)+13,140 PIXEL OF oDlgCol
		
		For x:=1 To Len(aCpo)
			Eval(bOpc,x)
		Next
		
		@ 23 + Len(aCpo)*10,065 BUTTON "&Ok" SIZE 25,15 PIXEL OF oDlgCol ACTION (nOpc:=Saida(), If( nOpc <> 0 , oDlgCol:End(), ))
		
		ACTIVATE MSDIALOG oDlgCol CENTERED
		
		If lRet := (nOpc == 1)  // Se não confirmou
			cCampos := ""
			For x:=1 To Len(aCampos)
				// Salva no parâmetro os campos relacionados
				cCampos += aCpo[x,3]+";"
				
				// Atribui a posição do campo no arquivo de origem (excel)
				aCampos[x,2] := AScan( aOpcoes , {|y| y == aCpo[x,3] } ) - 1
			Next
			&(cParam) := cCampos   // Atribui os campos ao parâmetro
			
			// Grava perguntas para o perfil do usuário
			u_STCriaPerg(.T.)
		Endif
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ ComboItem  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de criação do item de seleção                          ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ComboItem(x)
	@ (x*10)-3,010 SAY aCpo[x,2] SIZE 50,10 PIXEL OF oDlgCol COLOR aCpo[x,7]
	@ (x*10)-5,050 COMBOBOX aCpo[x,1] VAR aCpo[x,3] ITEMS aCpo[x,4] SIZE 80,10 PIXEL OF oDlgCol ON CHANGE Mudanca(x,.T.)
Return

Static Function Saida()
	Local x
	Local nRet := 1
	
	For x:=1 To Len(aCpo)
		// Verifica se algum campo não foi relacionado a uma coluna do Excel
		If Empty(aCpo[x,3]) .And. aCpo[x,7] <> CLR_BLACK
			nRet := If( MsgYesNo("Não foram atribuídos todos os campos obrigatórios. Confirma saída?") , 2, 0)
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

Static Function LayOut(cCliente)
	Local aLayout := {}
	Local aStruct := {}
	
	If cCliente == "000001"        // Yamaha
		AAdd( aStruct , { "PRODUTO"    , "Z1_PRODUTO", 0, 0} )
		AAdd( aStruct , { "DESCRICAO"  , ""          , 0, 0} )
		AAdd( aStruct , { "PEDIDO"     , "Z1_PEDCLI" , 0, 0} )
		AAdd( aStruct , { "DATA"       , "Z1_DATENT" , 0, 0} )
		AAdd( aStruct , { "QTDE"       , "Z1_QUANT"  , 0, 0} )
		
		aLayout := { cCliente, ";", "1",aClone(aStruct)}
	ElseIf cCliente $ "000011,000012"    // Moto Honda
		AAdd( aStruct , { "COD.CLIENTE", "Z1_PRODUTO",   2,  26} )
		AAdd( aStruct , { "DESCRICAO"  , ""          ,  27,  81} )
		AAdd( aStruct , { "DATA"       , "Z1_DATENT" , 142, 149} )
		AAdd( aStruct , { "PEDIDO"     , "Z1_PEDCLI" , 134, 141} )
		AAdd( aStruct , { "QTDE"       , "Z1_QUANT"  , 164, 170} )
		AAdd( aStruct , { "SETOR"      , "Z1_SETENT" , 102, 131} )
		AAdd( aStruct , { "HORA"       , "Z1_HORENT" , 160, 163} ) 
		AAdd( aStruct , { "LINHA"      , "Z1_LINPED" , 171, 177} ) 
		AAdd( aStruct , { "XPED"       , "Z1_XPED"   , {{90,101},{132,133},{134,141}}} )
		AAdd( aStruct , { "LOCENT"     , "Z1_LOCENT" , 568, 580} )
		
		aLayout := { cCliente, "", "2", aClone(aStruct)}
	ElseIf cCliente == "000005"    // Climazon
		AAdd( aStruct , { "CENTRO"     , ""          , 0, 0} )
		AAdd( aStruct , { "SETOR"      , ""          , 0, 0} )
		AAdd( aStruct , { "COD.CLIENTE", "Z1_PRODUTO", 0, 0} )
		AAdd( aStruct , { "DESCRICAO"  , ""          , 0, 0} )
		AAdd( aStruct , { "DATA"       , "Z1_DATENT" , 0, 0} )
		AAdd( aStruct , { "PEDIDO"     , "Z1_PEDCLI" , 0, 0} )
		AAdd( aStruct , { "QTDE"       , "Z1_QUANT"  , 0, 0} )
		AAdd( aStruct , { "SALDO"      , ""          , 0, 0} )
		AAdd( aStruct , { "ULT.NF"     , ""          , 0, 0} ) 
		AAdd( aStruct , { "LINHA"      , "Z1_LINPED" , 0, 0} ) 
		
		aLayout := { cCliente, "#", "3", aClone(aStruct)}
	Endif
	
Return aLayOut