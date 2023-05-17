#INCLUDE "Protheus.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATA04   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cadastro de Retorno Simbólico                                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATA04()
	Local aCores      := {	{ "Z5_STATUS == 'A'","ENABLE"    },; // RETORNO SIMBÓLICO ABERTO
							{ "Z5_STATUS == 'P'","BR_AMARELO"},; // RETORNO SIMBÓLICO PARCIAL
							{ "Z5_STATUS == 'F'","DISABLE"   }}  // RETORNO SIMBÓLICO FINALIZADO
	
	Private cCadastro := "Retorno Simbólico"
	Private cAlias1   := "SZ5"
	Private cAlias2   := "SZ6"
	Private aRotina   := { 	{"Pesquisar" ,"AxPesqui"     ,0,1} ,;
							{"Visualizar","u_FAT04Inclui",0,2} ,;
							{"Incluir"   ,"u_FAT04Inclui",0,3} ,;
							{"Alterar"   ,"u_FAT04Inclui",0,4} ,;
							{"Excluir"   ,"u_FAT04Inclui",0,5} ,;
							{"Efetivar"  ,"u_FAT04Inclui",0,6} ,;
							{"Legenda"   ,"u_FAT04Legend",0,7} }
	
	dbSelectArea(cAlias1)
	dbSetOrder(1)
	
	mBrowse( 6,1,22,75,cAlias1,,,,,,aCores)
	Set Filter To
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦FAT04Inclui ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Inclui Retorno Simbólico                                      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAT04Inclui(cAlias, nRecNo, nOpc )
	Local nX, aPosObj, aSize, cArq, cMarca, lMarcado
	Local nOpcA     := 0
	Local oMainWnd  := Nil
	Local aAltera   := {}
	Local lTravou   := .F.
	Local aHeadCpo  := {}
	Local aCores    := {}
	Local aFldItens := FWSX3Util():GetAllFields(cAlias2)     // Retorna todos os campos ativos para a tabela
	
	Private aAlter  := {}
	Private aTela   := {}
	Private aGets   := {}
	Private aFields := {}
	Private bCampo  := { |nField| Field(nField) }
	Private Inclui  := (nOpc == 3)
	Private Altera  := (nOpc == 4)
	Private cFilSZ5 := (cAlias)->(XFILIAL(cAlias))
	Private aAcho   := { "Z6_FILIAL", "Z6_NUM", "Z6_OK"}
	
	Private oDlg    := Nil
	Private oGet    := Nil
	Private aHeader := {}
	Private aCols   := {}
	Private nPD     := 1
	Private oCli, cCliLoja
	
	// Se for Alteração, Exclusão ou Efetivação
	If nOpc == 4 .Or. nOpc == 5 .Or. nOpc == 6
		If nOpc == 5 .And. (cAlias1)->Z5_STATUS <> "A"   // Se for Exclusão e não estiver aberto
			MsgAlert("Não é permitido excluir um Retorno Simbólico parcial ou finalizado !")
			Return
		ElseIf nOpc == 6 .And. (cAlias1)->Z5_STATUS == "F"   // Se o Retorno Simbólico já estiver efetivado
			MsgAlert("Esse Retorno Simbólico já foi totalmente finalizado !")
			Return
		Endif
		lTravou := SoftLock(cAlias)
	Endif
	
	AEval( aFldItens , {|x| AAdd( aFields , { GetSx3Cache(x,"X3_ORDEM"), x}) } )
	ASort( aFields ,,, {|x,y| x[1] < y[1] } )    // Ordena pela ordem de exibição
	
	//+----------------
	//| Monta os aCols
	//+----------------
	MontaaCols(@aAltera,nOpc==3,nOpc,@cArq)
	
	//+----------------------------------
	//| Inicia as variaveis para Enchoice
	//+----------------------------------
	dbSelectArea(cAlias1)
	dbSetOrder(1)
	dbGoTo(nRecNo)
	For nX:= 1 To FCount()
		M->&(Eval(bCampo,nX)) := If( nOpc == 3 , CriaVar(FieldName(nX),.T.), FieldGet(nX))
	Next nX
	
	//+----------------------------------
	//| Inicia as posições dos objetos
	//+----------------------------------
	PosObjetos(@aSize,@aPosObj)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	
	EnChoice(cAlias, nRecNo, If(nOpc==4.Or.nOpc==6,2,nOpc),,,,,aPosObj[1],, 3,,,,oDlg)
	
	If nOpc == 6   // Se for Efetivar
		lMarcado := .T.
		
		dbSelectArea("TMP")
		dbGoTop()
		
		aEval( aHeader , {|x| AAdd(aHeadCpo,{ Trim(x[2]),, Trim(x[1]), Trim(x[3])}) } )   // Preenche o cabeçalho

		aCores := { {"TMP->Z6_STATUS == 'A'","ENABLE"}, {"TMP->Z6_STATUS == 'E'","BR_AMARELO"}, {"TMP->Z6_STATUS == 'F'","DISABLE"}}
		
		// Processa a marcação de todos os itens
		cMarca := GetMark()
		dbEval({|| Marcar(cMarca,lMarcado) },,{|| !TMP->(Eof()) })
		TMP->(dbGoTop())
		
		oMark := MsSelect():New( "TMP", "Z6_OK","",aHeadCpo,, @cMarca, { aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4] } ,,, oDlg,,aCores)
		
		oMark:oBrowse:Refresh()
		oMark:bAval               := {|| Marcar(cMarca), oMark:oBrowse:Refresh() }
		
		oMark:oBrowse:lHasMark    := .T.
		oMark:oBrowse:lCanAllMark := .F.
		oMark:oBrowse:bAllMark    := {|| lMarcado:=!lMarcado, nRecno:=TMP->(Recno()), dbEval({|| Marcar(cMarca,lMarcado) },,{|| !TMP->(Eof()) }), TMP->(dbGoTo(nRecno)), oMark:oBrowse:Refresh() }
		
		oMark:oBrowse:SetFocus()
	Else
		oGet := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"u_FAT04LinOk("+LTrim(Str(nOpc))+")",,"+Z6_ITEM",.T.,aAlter,,,1000,,,,"u_FAT04DelIt()",oDlg)
		oGet:oBrowse:bChange := {|| FAT04CpoAlt(oGet:oBrowse) }
		FAT04CpoAlt(oGet:oBrowse)
		
		If nOpc <> 3    // Se não for inclusão, coloca o foco nos itens
			oGet:oBrowse:SetFocus()
		Endif
	Endif
	
	@ aPosObj[3,1],aPosObj[3,2] SAY oCli VAR cCliLoja SIZE 300,10 PIXEL OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA := If( nOpc == 2 .Or. nOpc == 5 .Or. If( nOpc<>6 , .T., Obrigatorio(aGets,aTela)).And.;
                                                              u_FAT04TudOk(nOpc),1,0),;
                                                              If(nOpcA==1,oDlg:End(),) }, {||nOpcA:=0,oDlg:End()} )
 	
	If nOpc > 2
		If nOpcA == 1
			If nOpc == 6   // Se for Efetivar
				Processa({|| FAT04EFetiva(cMarca) },"Gerando documentos para o Retorno Simbólico...")
			Else
				Begin Transaction
					FAT04Grava(nOpc,nRecNo,aAltera)
				End Transaction
				
				If nOpc == 3  // Se for Inclusão
					ConfirmSX8()
				Endif
			Endif
		ElseIf nOpc == 3  // Se for Inclusão
			RollBackSX8()
		Endif
	Endif
	
	If lTravou
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Restaura a integridade dos dados                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MsUnLockAll()
	Endif
	
	If nOpc == 6   // Se for Efetivar
		// Exclui arquivo temporário
		TMP->(dbCloseArea())
		FErase(cArq+GetDBExtension())
	Endif

Return

Static Function Marcar(cMarca,lMarcado)
	If TMP->Z6_STATUS <> "F"
		RecLock("TMP",.F.)
		TMP->Z6_OK := If( lMarcado == Nil , If( TMP->Z6_OK <> cMarca , cMarca, Space(Len(TMP->Z6_OK))), If( lMarcado , cMarca, Space(Len(TMP->Z6_OK))))
		MsUnLock()
	Endif
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04Valid ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar os campos                                             ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAT04Valid()
	Local nPPrd, nPDes
	Local cVar := ReadVar()
	Local lRet := .T.
	
	If cVar $ "M->Z5_CLIENTE,M->Z5_LOJA"
		If lRet := ExistCpo("SA1",M->Z5_CLIENTE+If(Empty(M->Z5_LOJA),"",M->Z5_LOJA))
			cCliLoja := SA1->A1_NOME
		Endif
	ElseIf cVar == "M->Z6_PEDIDO"
		If lRet := ExistCpo("SC6",M->Z6_PEDIDO)
			If lRet := (SC6->C6_CLI+SC6->C6_LOJA == M->Z5_CLIENTE+M->Z5_LOJA)
				If lRet := (GetMV("MV_YTESIND",.F.,"XXX") == SC6->C6_TES)
					If lRet := ((SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0)
						nPPrd := AScan( aHeader , {|x| Trim(x[2]) == "Z6_PRODUTO" } )
						nPDes := AScan( aHeader , {|x| Trim(x[2]) == "Z6_DESCRI"  } )
						
						aCols[n,nPPrd] := SC6->C6_PRODUTO
						aCols[n,nPDes] := PADR(Posicione("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_DESC"),TamSX3("Z6_DESCRI")[1])
					Else
						Alert("Esse pedido já foi totalmente faturado !")
					Endif
				Else
					Alert("O TES do Pedido de Venda não é válido para Industrialização: "+SC6->C6_TES+" !")
				Endif
			Else
				Alert("Esse pedido não pertence ao cliente informado no Retorno Simbólico !")
			Endif
		Endif
	ElseIf cVar == "M->Z6_PRODUTO"
		If lRet := ExistCpo("SB1")
			nPDes := AScan( aHeader , {|x| Trim(x[2]) == "Z6_DESCRI"  } )
			aCols[n,nPDes] := PADR(Posicione("SB1",1,XFILIAL("SB1")+M->Z6_PRODUTO,"B1_DESC"),TamSX3("Z6_DESCRI")[1])
		Endif
	ElseIf cVar == "M->Z6_QUANT"
		If lRet := Positivo()
			nPPrd := AScan( aHeader , {|x| Trim(x[2]) == "Z6_PRODUTO" } )
			CalcPedido(aCols[n,nPPrd],M->Z5_CLIENTE,M->Z5_LOJA,M->Z6_QUANT)
		Endif
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04LinOk ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar a linha do item                                       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAT04LinOk(nOpc,nPos)
	Local nX
	
	If nOpc == 3 .Or. nOpc == 4
		nPos := If( nPos == Nil , n, nPos)
		For nX:=1 To Len(aCols[nPos])-1
			If X3Obrigat( AllTrim(aHeader[nX,2]) ) .And. Empty(aCols[nPos,nX])
				Help(1," ","OBRIGAT")
				Return .F.
			Endif
		Next
	Endif
	
Return .T.

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04TudOk ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar todas as linhas dos itens                             ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAT04TudOk(nOpc)
	Local x
	Local nDel := Len(aCols[1])
	Local nCnt := 0
	Local lRet := .T.
	
	If nOpc == 6   // Se for Efetivação
		Return MsgYesNo("Confirma a efetivação do Retorno Simbólico "+(cAlias1)->Z5_NUM+" ?")
	Endif
	
	For x:=1 To Len(aCols)
		If !(lRet := u_FAT04LinOk(nOpc,x))
			Exit
		Endif
	Next
	
	If lRet
		// Conta o número de itens deletados
		aEval( aCols , {|x| nCnt += If( x[nDel] , 1, 0) } )
		
		If lRet := (nCnt <> Len(aCols))
		Else
			If nOpc == 3
				Aviso( "INVÁLIDO", "Favor adicionar pelo menos um item válido ao INCLUIR !", {"Ok"} )
			Else
				Aviso( "INVÁLIDO", "Não podem ser excluídos todos os itens. Utilize a opção EXCLUIR !", {"Ok"} )
			Endif
		Endif
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04Grava ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Grava os dados da lista de presentes                          ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ Parâmetro ¦ nOpc     -> Tipo da função (inclui,altera,exclui)             ¦¦¦
|¦¦           ¦ nRecNo   -> Numero do registro a ser gravado                  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FAT04Grava(nOpc,nRecNo,aAltera)
	Local nX, nY
	Local nPIte := AScan( aHeader , {|x| Trim(x[2]) == "Z6_ITEM" })
	Local nPDel := Len(aCols[1])
	
	SZ5->(dbSetOrder(1))
	
	For nX:=1 To Len(aCols)
		
		If SZ6->(dbSeek(cFilSZ5+M->Z5_NUM+aCols[nX,nPIte]))   // Pesquisa se o item está cadastrado
			RecLock("SZ6",.F.)
		ElseIf aCols[nX,nPDel]   // Se o item estiver deletado
			Loop
		Else
			RecLock("SZ6",.T.)
			SZ6->Z6_FILIAL := cFilSZ5
			SZ6->Z6_NUM    := M->Z5_NUM
		Endif
		
		If aCols[nX,nPDel] .Or. !(nOpc == 3 .Or. nOpc == 4)
			dbDelete()
		Else
			For nY := 1 To Len(aHeader)
				FieldPut( FieldPos(Trim(aHeader[nY,2])) , aCols[nX,nY] )
			Next
		Endif
		
		MsUnLock()
		
	Next
	
	//+-----------------
	//| Se for inclusão ou alteração
	//+-----------------
	If nOpc == 3 .Or. nOpc == 4
		RecLock(cAlias1,nOpc == 3)
		For nX := 1 To FCount()
			If "FILIAL" $ FieldName(nX)
				FieldPut(nX,XFILIAL(cAlias1))
			Else
				FieldPut(nX,M->&(Eval(bCampo,nX)))
			Endif
		Next nX
	Else
	   //+-----------------
		//| Se for exclusão
		//+-----------------
		RecLock(cAlias1,.F.)
		dbDelete()
	Endif
	MsUnLock()
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ MontaaCols ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria a variavel vetor aCols                                   ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MontaaCols(aAltera,lNovo,nOpc,cArq)
	Local nCols, nUsado, nX
	Local cSeek   := cFilSZ5+SZ5->Z5_NUM
	Local aStruct := {}
	
	//+--------------
	//| Monta o aHeader
	//+--------------
	CriaHeader(nOpc)
	
	If nOpc == 6    // Se for Efetivação
		// Cria tabela temporária para marcação dos itens
		aEval( aHeader , {|x| AAdd( aStruct , { x[2], x[8], x[4], x[5]} ) } )
		
		cArq := Criatrab(aStruct,.T.)
		dbUseArea(.T.,,cArq,"TMP")
	Endif
	
	//+--------------
	//| Monta o aCols com os dados referentes os ITENS
	//+--------------
	nCols  := 0
	nUsado := Len(aHeader)
	
	If !lNovo
		// Posiciona no Cadastro do Cliente
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(XFILIAL("SA1")+SZ5->Z5_CLIENTE+SZ5->Z5_LOJA))
		
		cCliLoja := SA1->A1_NOME
		
		// Preenche o aCols conforme dados já gravados
		dbSelectArea(cAlias2)
		dbSetOrder(1)
		dbSeek(cSeek,.T.)
		While !(cAlias2)->(Eof()) .And. cSeek == SZ6->Z6_FILIAL+SZ6->Z6_NUM
			
			aAdd(aCols,Array(nUsado+If(nOpc<>6,1,0)))
			nCols ++
			
			If nOpc == 6   // Se for Efetivar
				RecLock("TMP",.T.)
			Endif
			
			For nX := 1 To nUsado
				If ( aHeader[nX][10] != "V") .And. (cAlias2)->(FieldPos(aHeader[nX][2])) > 0
					If nOpc == 6   // Se for Efetivar
						TMP->(FieldPut( FieldPos(aHeader[nX][2]) ,  (cAlias2)->(FieldGet(FieldPos(aHeader[nX][2]))) ))
					Else
						aCols[nCols][nX] := (cAlias2)->(FieldGet(FieldPos(aHeader[nX][2])))
					Endif
				ElseIf Trim(aHeader[nX][2]) == "Z6_DESCRI"
					If nOpc == 6   // Se for Efetivar
						TMP->(FieldPut( FieldPos(aHeader[nX][2]) ,  PADR(Posicione("SB1",1,XFILIAL("SB1")+SZ6->Z6_PRODUTO,"B1_DESC"),TamSX3("Z6_DESCRI")[1]) ))
					Else
						aCols[nCols][nX] := PADR(Posicione("SB1",1,XFILIAL("SB1")+SZ6->Z6_PRODUTO,"B1_DESC"),TamSX3("Z6_DESCRI")[1])
					Endif
				Endif
			Next nX
			
			If nOpc == 6   // Se for Efetivar
				TMP->(MsUnLock())
			Else
				aCols[nCols][nUsado+1] := .F.
			Endif
			
			(cAlias2)->(dbSkip())
		Enddo
	Endif
	
	If Empty(aCols)  // Caso nao tenha itens
		//+--------------
		//| Monta o aCols com uma linha em branco
		//+--------------
		aColsBlank(@aCols)
	Endif
	
Return .T.

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ CriaHeader ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria a variavel vetor aHeader                                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CriaHeader(nOpc)
	Local nX
	
	If nOpc == 6    // Se for Efetivação
		aAdd(aHeader,{ "", "Z6_OK", "@!", 2, 0, "", "", "C", "", "", "", ""} )   // Adiciona o campo de marcação
	Endif
	
	For nX:=1 To Len(aFields)
		If AScan( aAcho , aFields[nX,2] ) == 0
			AdicionaCampo(aFields[nX,2],@aHeader)
			
			If GetSx3Cache(aFields[nX,2], 'X3_VISUAL') == "A"   // Se o campo for editável
				AAdd( aAlter , Trim(aFields[nX,2]) )
			Endif
		Endif
	Next
	
Return

Static Function AdicionaCampo(cCampo,aCabec)
	AAdd(aCabec, {GetSx3Cache(cCampo, 'X3_TITULO'),;
						GetSx3Cache(cCampo, 'X3_CAMPO'),;
						GetSx3Cache(cCampo, 'X3_PICTURE'),;
						GetSx3Cache(cCampo, 'X3_TAMANHO'),;
						GetSx3Cache(cCampo, 'X3_DECIMAL'),;
						GetSx3Cache(cCampo, 'X3_VALID'),;
						GetSx3Cache(cCampo, 'X3_USADO'),;
						GetSx3Cache(cCampo, 'X3_TIPO'),;
						GetSx3Cache(cCampo, 'X3_F3'),;
						GetSx3Cache(cCampo, 'X3_CONTEXT'),;
						GetSx3Cache(cCampo, 'X3_CBOX'),;
						GetSx3Cache(cCampo, 'X3_RELACAO'),;
						GetSx3Cache(cCampo, 'X3_WHEN'),;
						GetSx3Cache(cCampo, 'X3_VISUAL'),;
						GetSx3Cache(cCampo, 'X3_VLDUSER'),;
						GetSx3Cache(cCampo, 'X3_PICTVAR'),;
						If(GetSx3Cache(cCampo, 'X3_OBRIGAT') == "€", .T., .F.)} )
	
Return Len(aCabec)

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ aColsBlank ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria array de itens em branco                                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function aColsBlank(aArray)
	Local nX
	Local nTam   := Len(aArray ) + 1
	Local nUsado := Len(aHeader)
	Local nPIte  := AScan( aHeader , {|x| Trim(x[2]) == "Z6_ITEM" } )
	Local nCol   := 0
	
	aAdd(aArray,Array(nUsado+1))
	aArray[nTam][nUsado+1] := .F.
	
	For nX:=1 To Len(aFields)
		If AScan( aAcho , aFields[nX,2] ) == 0
			nCol++
			aArray[nTam][nCol] := CriaVar(aFields[nX,2],.T.)
		Endif
	Next
	
	aArray[nTam][nPIte] := StrZero(nTam,TamSX3("Z6_ITEM")[1])
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04DelIt ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar delecao dos itens                                     ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAT04DelIt()
	Local nPSta := AScan( aHeader , {|x| Trim(x[2]) == "Z6_STATUS" } )
	Local lRet  := .T.
	
	If nPD == 2  // 2a. passagem
	Else
		lRet := (aCols[n,nPSta] <> "F")
	Endif
	nPD := If( nPD == 2 , 1, nPD + 1)
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦FAT04Efetiva¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/12/2014 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Processa a efetivação dos itens selecionados                  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FAT04EFetiva(cMarca)
	Local nX, nQtdNec, nSaldo, cTESInd, cTESRet, aBenef, lOk, aItem
	Local cAlias := Alias()
	Local aInd   := {}
	Local aRet   := {}
	Local aSaldo := {}
	
	cTESInd := GetMv("MV_YTESIND",.F.,"XXX")
	cTESRet := GetMv("MV_YTESRET",.F.,"XXX")
	
	If cTESInd == "XXX"
		Alert("O TES de industrialização não é válido !")
		Return
	Endif
	
	If cTESRet == "XXX"
		Alert("O TES de retorno de industrialização não é válido !")
		Return
	Endif
	
	Private aPvlNfs, aBloqueio
	Private cFilSG1 := XFILIAL("SG1")
	
	ProcRegua(TMP->(RecCount()))
	
	TMP->(dbGoTop())
	While !TMP->(Eof())
		
		IncProc("Selecionando itens a serem efetivados...")
		
		If TMP->Z6_OK <> cMarca   // Se foi selecionado
			TMP->(dbSkip())
			Loop
		Endif
		
		aItem  := {}
		aBenef := {}
		
		GetBN(TMP->Z6_PRODUTO,TMP->Z6_QUANT,@aBenef)
		
		lOk := !Empty(aBenef)
		
		For nX:=1 To Len(aBenef)
			nQtdNec := aBenef[nX,2]
			
			// Filtra as notas de origem em aberto para o produto
			cQry := "SELECT SB6.*, SD1.D1_ITEM"
			cQry += " FROM (
			cQry += " SELECT SB6.B6_DOC, SB6.B6_SERIE, SB6.B6_CLIFOR, SB6.B6_LOJA, SB6.B6_IDENT, SB6.B6_PRUNIT, SB6.B6_PRODUTO, SB6.B6_LOCAL,"
			cQry += " (SB6.B6_SALDO - (SELECT ISNULL(SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT),0)"
			cQry += " FROM "+RetSQLName("SC6")+" SC6"
			cQry += " WHERE SC6.D_E_L_E_T_ = ' '"
			cQry += " AND SC6.C6_FILIAL = '"+SC6->(XFILIAL("SC6"))+"'"
			cQry += " AND SC6.C6_IDENTB6 = SB6.B6_IDENT)) AS B6_SALDO"
			cQry += " FROM "+RetSQLName("SB6")+" SB6"
			cQry += " WHERE SB6.D_E_L_E_T_ = ' '"
			cQry += " AND SB6.B6_FILIAL = '"+XFILIAL("SB6")+"'"
			cQry += " AND SB6.B6_PRODUTO = '"+aBenef[nX,1]+"'"
			cQry += ") SB6"
			cQry += " INNER JOIN "+RetSQLName("SD1")+" SD1 ON SD1.D_E_L_E_T_ = ' '"
			cQry += " AND SD1.D1_FILIAL = '"+XFILIAL("SD1")+"'"
			cQry += " AND SD1.D1_DOC = SB6.B6_DOC"
			cQry += " AND SD1.D1_SERIE = SB6.B6_SERIE"
			cQry += " AND SD1.D1_FORNECE = SB6.B6_CLIFOR"
			cQry += " AND SD1.D1_LOJA = SB6.B6_LOJA"
			cQry += " AND SD1.D1_IDENTB6 = SB6.B6_IDENT"
			cQry += " WHERE SB6.B6_SALDO > 0"
			cQry += " ORDER BY SB6.B6_IDENT"
			
			dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "QRY", .T., .F. )	
			While !Eof() .And. nQtdNec > 0
				
				// Atualiza o controle desaldo
				nPos := AScan( aSaldo , {|x| x[1]+x[2] == B6_PRODUTO+B6_IDENT } )
				If nPos == 0
					AAdd( aSaldo , { B6_PRODUTO, B6_IDENT, B6_SALDO} )
					nPos := Len(aSaldo)
				Endif
				
				// Adiciona o item do pedido de venda de retorno de industrialização
				nSaldo := If( aSaldo[nPos,3] < nQtdNec , aSaldo[nPos,3], nQtdNec)
				AAdd( aItem , { B6_PRODUTO, B6_LOCAL, nSaldo, B6_PRUNIT, B6_DOC, B6_SERIE, D1_ITEM, B6_IDENT, TMP->Z6_ITEM})
				
				nQtdNec -= nSaldo         // Atualiza o saldo da necessidade (nQtdNec). A quantidade é abatida até zerar
				aSaldo[nPos,3] -= nSaldo  // Atualiza o saldo geral da matéria-prima. Será necessário pois pode ocorrer do mesmo item ser usado em outros PA's
				
				dbSkip()
			Enddo
			dbCloseArea()
			dbSelectArea(cAlias)
			
			If nQtdNec > 0   // Se a quantidade necessária não foi toda usada
				Alert("O componente "+Trim(aBenef[nX,1])+" não tem saldo suficiente para atender o produto "+Trim(TMP->Z6_PRODUTO)+" !")
				lOk := .F.
				Exit
			Endif
		Next
		
		If lOk
			// Adiciona o item do pedido de venda de industrialização
			AAdd( aInd , { TMP->Z6_PRODUTO, Posicione("SC6",1,XFILIAL("SC6")+TMP->Z6_PEDIDO+TMP->Z6_ITEMPV+TMP->Z6_PRODUTO,"C6_LOCAL"), TMP->Z6_QUANT, 0, TMP->Z6_PEDIDO, TMP->Z6_ITEMPV, "", "", TMP->Z6_ITEM} )
			AAdd( aRet , aClone(aItem) )    // Adiciona os itens de retorno para o item de industrialização
		Else
			Alert("Não foram encontrados itens do tipo BN para o produto "+Trim(TMP->Z6_PRODUTO)+"!")
			Return
		Endif
		
		TMP->(dbSkip())
	Enddo
	
	// Posiciona no Cadastro de Clientes
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(XFILIAL("SA1")+SZ5->Z5_CLIENTE+SZ5->Z5_LOJA))
	
	// Processa a geração das NF's em separado para cada item
	ProcRegua(Len(aInd))
	
	For nX:=1 To Len(aInd)
		
		IncProc("Item: "+Trim(aInd[nX,1])+" - Gerando documento de saída...")
		
		aPvlNfs   := {}   // Arrays com itens
		aBloqueio := {}   // Arrays com bloqueios
		
		If CriaLibPed(aInd[nX])
			If CriaPedido(aRet[nX],cTESRet)
				GeraNFiscal(aInd[nX])
			Endif
		Endif
	Next
	
Return

Static Function CriaLibPed(aItem)
	Local nRecSC9 := 0
	Local aRegSC6 := {}
	Local lRet    := .F.
	
	// Posiciona no pedido de venda
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(XFILIAL("SC5")+aItem[5]))
	// Posiciona na condição de pagamento
	SE4->(dbSetOrder(1))
	SE4->(dbSeek(XFILIAL("SE4")+SC5->C5_CONDPAG))
	
	// Posiciona no item do pedido de venda
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(XFILIAL("SC6")+aItem[5]+aItem[6]+aItem[1]))
	// Posiciona no cadastro do produto
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(XFILIAL("SB1")+SC6->C6_PRODUTO))
	// Posiciona no saldo em estoque do produto
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(XFILIAL("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL))
	// Posiciona no TES
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(XFILIAL("SF4")+SC6->C6_TES))
	
	// Posiciona itens liberados
	SC9->(dbSetOrder(1))
	SC9->(dbSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM,.T.))
	While !SC9->(Eof()) .And. SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM == SC9->C9_FILIAL+SC0->C9_PEDIDO+SC9->C9_ITEM
		
		If Empty(SC9->C9_NFISCAL) .And. Abs(aItem[3] - SC9->C9_QTDLIB) == 0   // Se ainda não foi faturado e a quantidade é igual a do Retorno Simbólico
			If Trim(SC9->C9_BLEST) == "02" .Or. Trim(SC9->C9_BLCRED) == "02"
				a460Estorna()
			Else
				nRecSC9 := SC9->(Recno())
				lRet := AddLiberacao()
			Endif
			Exit
		Endif
		
		SC9->(dbSkip())
	Enddo
	
	If nRecSC9 == 0   // Se não existe item liberado
		If lRet := LiberaItem(@aRegSC6,aItem[3])
			lRet := AddLiberacao()
		Endif
	Endif
	
	If !lRet
		Alert("Pedido de venda de industrialização não foi liberado !")
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ LiberaItem ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2015 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Processa a liberação do item do pedido de venda               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function LiberaItem(aRegSC6,nQtdLib)
	Local nQtdAux
	Local lLibOk  := .F.
	Local nFolga  := GetMV("MV_FOLGAPV")
	Local lCredit := .T.
	Local lEstoq  := .T.
	Local lAvEst  := (GetMv("MV_ESTNEG") <> "S")
	Local lLiber  := .T.
	Local lTransf := .F.
	//Local aLocal  := {}
	//Local aEmpenho:= {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o item esta bloqueado e dentro do prazo de entrega          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !AllTrim(SC6->C6_BLQ) $ "SR" .And. SC6->C6_ENTREG <= (dDataBase + nFolga) .And. Empty(SC6->C6_BLOQUEI) .And. nQtdLib > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona no cliente do Pedido de Venda                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(XFILIAL("SA1")+SC6->C6_CLI+SC6->C6_LOJA))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o Pedido de Venda                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SC5->(dbSetOrder(1))
		SC5->(dbSeek(SC6->C6_FILIAL+SC6->C6_NUM))
		
		If RecLock("SC5",.F.)
			nQtdAux := nQtdLib
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Recalcula a Quantidade Liberada                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SC6") //Forca a atualizacao do Buffer no Top
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o tipo de Liberacao                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( SC5->C5_TIPLIB == "1" )
				// Verifica o saldo atual para complementar a quantidade liberada
				SB2->(dbSetOrder(1))
				SB2->(dbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL))
				nSaldo := SaldoSb2(,GetNewPar("MV_QEMPV",.F.),,.F.,.F.)
				lEstoq := A440VerSB2(@nQtdLib,lLiber,lTransf) //,@aLocal,@aEmpenho)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Libera por Item de Pedido                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//u_PAQtdLib(nQtdLib+Abs(nSaldo))  // Força a liberação da quantidade do Kanban + saldo atual
				Begin Transaction
				nQtdLib := MaLibDoFat(SC6->(RecNo()),@nQtdLib,@lCredit,@lEstoq,.F.,lAvEst,lLiber,lTransf)
				End Transaction
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Libera por Pedido                                                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Begin Transaction
				RecLock("SC6")
				SC6->C6_QTDLIB := nQtdLib
				MsUnLock()
				aadd(aRegSC6,SC6->(RecNo()))
				End Transaction
			EndIf
			
			lLibOk := (nQtdAux == nQtdLib)
			
			SC6->(MsUnLock())
		EndIf
	EndIf
	
Return lLibOk

Static Function AddLiberacao()
	Local lRet := (Empty(SC9->C9_BLCRED+SC9->C9_BLEST) .And. (Empty(SC9->C9_BLWMS) .Or. SC9->C9_BLWMS == "05" .Or. SC9->C9_BLWMS == "07"))
	
	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta array para geracao da NF                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aPvlNfs,{ SC9->C9_PEDIDO,;
							SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							SC9->C9_QTDLIB,;
							SC9->C9_PRCVEN,;
							SC9->C9_PRODUTO,;
							SF4->F4_ISS=="S",;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo()),;
							SC9->C9_LOCAL,;
							0,;
							SC9->C9_QTDLIB2})
	ElseIf SC9->C9_BLCRED <> "10" .And. SC9->C9_BLEST <> "10"
		AAdd(aBloqueio,{	SC9->C9_PEDIDO,;
								SC9->C9_ITEM,;
								SC9->C9_SEQUEN,;
								SC9->C9_PRODUTO,;
								TransForm(SC9->C9_QTDLIB,X3Picture("C9_QTDLIB")),;
								SC9->C9_BLCRED,;
								SC9->C9_BLEST,;
								SC9->C9_BLWMS})
	Endif
	
Return lRet

Static Function CriaPedido(aItem,cTES)
	Local nX, nValor, nSaveSX8, cNumPed
	Local aArrSC5 := {}
	Local aArrSC6 := {}
	Local aPV     := {}
	Local aBlq    := {}
	Local cItem   := StrZero(0,TamSX3("C6_ITEM")[1])
	Local lTrunca := ( SA1->A1_COD $ GetMV("MV_XCLITRU",.F.,"000001") )    // Define se trunca os valores para os clientes do parâmetro
	Local nDecQtd := If( SA1->(FieldPos("A1_XDECQTD")) > 0 , SA1->A1_XDECQTD, 0)
	Local nDecPrc := If( SA1->(FieldPos("A1_XDECPRC")) > 0 , SA1->A1_XDECPRC, 0)
		
	// Variavel que controla numeracao
	nSaveSX8 := GetSx8Len()
	
	cNumPed := GetSXENum("SC5","C5_NUM")   // Pega o próximo pedido de venda
	RollBAckSx8()
	
	// Posiciona no TES do pedido
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(XFILIAL("SF4")+cTES))
	
	For nX:=1 To Len(aItem)

		If lTrunca   // Caso para o cliente deva truncar os valores
			If nDecQtd > 0   // Trunca a quantidade
				aItem[nX,3] := NoRound( aItem[nX,3] , nDecQtd)
			Endif
			If nDecPrc > 0   // Trunca o preço unitário
				aItem[nX,4] := NoRound( aItem[nX,4] , nDecPrc)
			Endif
		Endif
		
		// Posiciona no Cadastro de Produtos
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(XFILIAL("SB1")+aItem[nX,1]))
		
		AAdd( aArrSC6 , {} )
		aAdd(aArrSC6[nX], { "C6_FILIAL"  , XFILIAL("SC6")      , Nil} )
		aAdd(aArrSC6[nX], { "C6_ITEM"    , cItem:=Soma1(cItem) , Nil} )
		aAdd(aArrSC6[nX], { "C6_PRODUTO" , SB1->B1_COD         , Nil} )
		aAdd(aArrSC6[nX], { "C6_DESCRI"  , SB1->B1_DESC        , Nil} )
		aAdd(aArrSC6[nX], { "C6_QTDVEN"  , aItem[nX,3]         , Nil} )
		aAdd(aArrSC6[nX], { "C6_ENTREG"  , dDataBase           , Nil} )
		aAdd(aArrSC6[nX], { "C6_UM"      , SB1->B1_UM          , Nil} )
		aAdd(aArrSC6[nX], { "C6_SEGUM"   , SB1->B1_SEGUM       , Nil} )
		aAdd(aArrSC6[nX], { "C6_TES"     , cTES                , Nil} )
		aAdd(aArrSC6[nX], { "C6_CF"      , SF4->F4_CF          , Nil} )
		aAdd(aArrSC6[nX], { "C6_QTDLIB"  , aItem[nX,3]         , Nil} )
		aAdd(aArrSC6[nX], { "C6_XSTATUS" , "S"                 , Nil} )
		aAdd(aArrSC6[nX], { "C6_LOCAL"   , SB1->B1_LOCPAD      , Nil} )
		aAdd(aArrSC6[nX], { "C6_CLI"     , SA1->A1_COD         , Nil} )
		aAdd(aArrSC6[nX], { "C6_LOJA"    , SA1->A1_LOJA        , Nil} )
		aAdd(aArrSC6[nX], { "C6_OP"      , "02"                , Nil} )
		aAdd(aArrSC6[nX], { "C6_TPOP"    , "F"                 , Nil} )
		
		If aItem[nX,4] > 0   // Se tem preço válido
			nValor := a410Arred( aItem[nX,3] * aItem[nX,4] , "C6_VALOR" , NIL )
			
			aAdd(aArrSC6[nX], { "C6_PRUNIT"  , aItem[nX,4]         , Nil} )
			aAdd(aArrSC6[nX], { "C6_PRCVEN"  , aItem[nX,4]         , Nil} )
			aAdd(aArrSC6[nX], { "C6_VALOR"   , nValor              , Nil} )
		Endif
		
		aAdd(aArrSC6[nX], { "C6_NFORI"   , aItem[nX,5]         , Nil} )
		aAdd(aArrSC6[nX], { "C6_SERIORI" , aItem[nX,6]         , Nil} )
		aAdd(aArrSC6[nX], { "C6_ITEMORI" , aItem[nX,7]         , Nil} )
		aAdd(aArrSC6[nX], { "C6_IDENTB6" , aItem[nX,8]         , Nil} )
		
	Next	
	
	aArrSC5 := {{ "C5_FILIAL"  , xFilial("SC5")  , Nil}, ;
					{ "C5_NUM"     , cNumPed         , Nil}, ;
					{ "C5_TIPO"    , "N"             , Nil}, ;
					{ "C5_CLIENTE" , SA1->A1_COD     , Nil}, ;
					{ "C5_LOJACLI" , SA1->A1_LOJA    , Nil}, ;
					{ "C5_CLIENT"  , SA1->A1_COD     , Nil}, ;
					{ "C5_LOJAENT" , SA1->A1_LOJA    , Nil}, ;
					{ "C5_EMISSAO" , dDataBase       , Nil}, ;
					{ "C5_CONDPAG" , SA1->A1_COND    , Nil}, ;
					{ "C5_TABELA"  , SA1->A1_TABELA  , Nil}, ;
					{ "C5_MOEDA"   , 1               , Nil}, ;
					{ "C5_TIPOCLI" , SA1->A1_TIPO    , Nil}, ;
					{ "C5_TIPLIB"  , "2"             , Nil}, ;
					{ "C5_LIBEROK" , "S"             , Nil}}
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y,Z| Mata410(x,y,Z)}, aArrSC5, aArrSC6, 3)
	
	If lMsErroAuto
		MostraErro()
	Else
		// Confirma SX8
		While ( GetSx8Len() > nSaveSX8 )
			ConfirmSX8()
		Enddo
		
		// Liberacao de pedido
		Ma410LbNfs(2,@aPv,@aBlq)
		// Checa itens liberados
		Ma410LbNfs(1,@aPv,@aBlq)

		aEval( aBlq , {|x| AAdd( aBloqueio , aClone(x) ) } )
		aEval( aPv  , {|x| AAdd( aPvlNfs   , aClone(x) ) } )
	Endif
	
Return !lMsErroAuto
		
Static Function GeraNFiscal(aItem)
	Local nX, nItemNf, cNotaFeita, nQtdA, nQtdF
	Local aNotas := {}
	Local aNotaFeita := {}
	
	// Obtem serie para as notas desta filial
	cSerie  := ""
	cNumero := ""
	
	While Empty(cSerie)
		Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"),cFilAnt)
		
		If Empty(cSerie)
			Alert("Ocorreu um erro na definição da série da nota (série vazia), favor redefinir a numeração !")
		Endif
	Enddo
	
	Pergunte("MT460A",.F.)
	
	aParam460 := Array(30)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa geracao de documentos de saida                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega parametros do programa                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aParam460)
		aParam460[nx] := &("mv_par"+StrZero(nx,2))
	Next nx
	
	// Caso tenha itens liberados manda faturar
	If Empty(aBloqueio) .And. !Empty(aPvlNfs)
		nItemNf := a460NumIt(cSerie)
		aadd(aNotas,{})
		
		// Efetua as quebras de acordo com o numero de itens
		For nX := 1 To Len(aPvlNfs)
			If Len(aNotas[Len(aNotas)])>=nItemNf
				aadd(aNotas,{})
			EndIf
			aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
		Next nX
		
		If !Empty(aNotas)
			// Gera as notas de acordo com a quebra
			For nX:=1 To Len(aNotas)
				cNotaFeita:=MaPvlNfs(aNotas[nX],cSerie,aParam460[01]==1,aParam460[02]==1,aParam460[03]==1,aParam460[04]==1,aParam460[05]==1,aParam460[07],aParam460[08],aParam460[15]==1,aParam460[16]==2)
				AADD(aNotaFeita,cNotaFeita)
			Next nX
			
			If !Empty(aNotaFeita)
				// Atualiza os status dos itens
				If SZ6->(dbSeek(cFilSZ5+M->Z5_NUM+aItem[9]))
					RecLock("SZ6",.F.)
					SZ6->Z6_STATUS := "F"    // Atualiza como finalizado
					MsUnLock()
				Endif
				
				nQtdA := 0
				nQtdF := 0
				
				// Verifica o status dos itens
				SZ6->(dbSetOrder(1))
				SZ6->(dbSeek(cFilSZ5+M->Z5_NUM,.T.))
				While !SZ6->(Eof()) .And. cFilSZ5+M->Z5_NUM == SZ6->Z6_FILIAL+SZ6->Z6_NUM
					If SZ6->Z6_STATUS == "F"
						nQtdF++
					Else
						nQtdA++
					Endif
					SZ6->(dbSkip())
				Enddo
				
				RecLock("SZ5",.F.)
				SZ5->Z5_STATUS := If( nQtdF == 0 , "A", If( nQtdA == 0 , "F", "P"))
				MsUnLock()
				
				MsgInfo("Nota Fiscal "+Trim(aNotaFeita[1])+" / Serie "+cSerie+" gerada com sucesso!")
			Endif
		Else
			Alert("Nota fiscal de industrialização não foi gerada !")
		Endif
	Else
		Alert("Pedido de venda de retorno não foi liberado !")
	Endif
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ GetBN      ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/12/2014 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de busca dos itens de beneficiamento da estrutura      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function GetBN(cProduto,nQuant,vBN)
	Local nPos
	Local nReg := SG1->(Recno())
	Local lRet := .F.
	
	If ValType(vBN) <> "A"
		vBN := {}
	Endif
	
	SG1->(dbSetOrder(1))
	If lRet := SG1->(dbSeek(cFilSG1+cProduto,.T.))
		While !SG1->(Eof()) .And. SG1->G1_FILIAL+SG1->G1_COD == cFilSG1+cProduto
			
			If dDataBase >= SG1->G1_INI .And. dDataBase <= SG1->G1_FIM
				// Se for Material de Beneficiamento
				If Posicione("SB1",1,XFILIAL("SB1")+SG1->G1_COMP,"B1_TIPO") $ "BN,MT"
					nPos := AScan( vBN , {|x| x[1] == SG1->G1_COMP })
					If nPos == 0
						AAdd( vBN , { SG1->G1_COMP, 0})
						nPos := Len(vBN)
					Endif
					vBN[nPos,2] += (If( SG1->(FieldPos("G1_XQTDRET")) > 0 .And. SG1->G1_XQTDRET > 0 , SG1->G1_XQTDRET, SG1->G1_QUANT)  * nQuant) * ((100 + SG1->G1_PERDA) /100)
				Endif
				
				GetBN(SG1->G1_COMP,(If( SG1->(FieldPos("G1_XQTDRET")) > 0 .And. SG1->G1_XQTDRET > 0 , SG1->G1_XQTDRET, SG1->G1_QUANT)  * nQuant) * ((100 + SG1->G1_PERDA) /100), @vBN)
			Endif
			
			SG1->(dbSkip())
		Enddo
	Endif
	SG1->(dbGoTo(nReg))
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ CalcPedido ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 09/01/2015 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de busca dos itens de beneficiamento da estrutura      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CalcPedido(cProduto,cCodCli,cLjCli,nQuant)
	Local cSeek
	Local cAlias := Alias()
	Local nPPed  := Ascan(aHeader,{|x| Trim(x[2]) == "Z6_PEDIDO"  })
	Local nPItP  := Ascan(aHeader,{|x| Trim(x[2]) == "Z6_ITEMPV"  })
	Local lRet   := .F.
	
	If GetMv("MV_XUSAKAN",.F.,.T.)   // Define se usa o Kanban no cálculo do pedido
		cSeek := XFILIAL("SZ1")+cCodCli+cLjCli+cProduto
		
		SZ1->(dbSetOrder(3))
		SZ1->(dbSeek(cSeek,.T.))
		While !SZ1->(Eof()) .And. cSeek == SZ1->Z1_FILIAL+SZ1->Z1_CLIENTE+SZ1->Z1_LOJA+SZ1->Z1_COD
			If lRet := (Empty(SZ1->Z1_DOC) .And. SZ1->Z1_STATUS == "E" .And. Abs(SZ1->Z1_QTDNEC - nQuant) == 0)   // Se ainda não foi faturado
				// Pesquisa o item do pedido de venda
				SC6->(dbSetOrder(1))
				If SC6->(dbSeek(XFILIAL("SC6")+SZ1->Z1_PEDIDO+SZ1->Z1_ITEMPV+SZ1->Z1_COD))
					If (SC6->C6_QTDVEN - SC6->C6_QTDENT) > 0   // Se tem saldo a faturar
						aCols[n,nPPed] := SZ1->Z1_PEDIDO
						aCols[n,nPItP] := SZ1->Z1_ITEMPV
						Return lRet
					Endif
				Endif
			Endif
			SZ1->(dbSkip())
		Enddo
	Endif
	
	BeginSql Alias "TMPPED"
		SELECT C6_NUM, C6_ITEM, (C6_QTDVEN - C6_QTDENT) AS C6_QTSALDO
		FROM %Table:SC6% SC6
		WHERE SC6.%notdel%
		AND C6_FILIAL = %xFilial:SC9%
		AND C6_PRODUTO = %Exp:cProduto%
		AND C6_CLI = %Exp:cCodCli%
		AND C6_LOJA = %Exp:cLjCli%
		AND C6_QTDVEN > C6_QTDENT
		ORDER BY C6_ENTREG, C6_NUM
	EndSql
	
	If !TMPPED->(Eof())
		While !TMPPED->(Eof())
			If lRet := (nQuant <= TMPPED->C6_QTSALDO)
				aCols[n,nPPed] := TMPPED->C6_NUM
				aCols[n,nPItP] := TMPPED->C6_ITEM
				Exit
			EndIf
			TMPPED->(dbSkip())
		Enddo
		If !lRet
			MsgStop("Quantidade liberada é insuficiente para o Retorno Simbólico !")
		EndIf
	Else
		MsgStop("Produto não possui Pedido liberado !")
	EndIf
	
	TMPPED->(DbCloseArea())
	DbSelectArea(cAlias)
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04CpoAlt¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 09/01/2015 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Habilita a leitura dos campos conforme condição               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FAT04CpoAlt(oGet)
	Local nPSta := AScan( aHeader , {|x| Trim(x[2]) == "Z6_STATUS" } )
	Local aVar  := aClone(aAlter)
	
	If aCols[oGet:nAt,nPSta] == "F"   // Se estiver finalizado
		aVar := {}
	Endif
	
	oGet:aAlter := aVar
	oGet:oMother:aAlter := aVar
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ PosObjetos ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Inicializa as dimensões da tela para posicionar os objetos    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function PosObjetos(aSize,aPosObj)
	Local aInfo
	Local aObjects := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 060, .t., .f. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 010, .t., .f. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT04Legend¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 06/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Legenda do Retorno Simbólico                                  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FAT04Legend( cAlias, nRecNo, nOpc )
   BRWLEGENDA(cCadastro,"Legenda - Retorno Simbólico",;
   							{	{ "ENABLE"    , "Aberto"    },;
   								{ "BR_AMARELO", "Parcial"   },;
   								{ "DISABLE"   , "Finalizado"}})
Return