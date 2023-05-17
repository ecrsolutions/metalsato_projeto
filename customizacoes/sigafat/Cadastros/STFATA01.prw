#INCLUDE "Protheus.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATA01   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 27/09/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cadastro de Kanban                                            ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function STFATA01()
	Local aCores      := {	{"Z1_QTDENT == 0","ENABLE" },;    // LISTA ABERTA
									{"Z1_QTDENT > 0 .And. Z1_QTDENT < Z1_QUANT","BR_AMARELO"},; // LISTA VIGENTE
									{"Z1_QTDENT >= Z1_QUANT","DISABLE"}}     // LISTA EXPIRADA
	Local aRotInc     := {}
	
	AAdd( aRotInc , { "Incluir" , "u_FATIncluir('SZ1',0,3)", 0 , 3} )
	AAdd( aRotInc , { "Importar", "u_STFATP01", 0 , 7} )
	
	Private cCadastro := "Cadastro de Pedido Sato"
	Private cAlias1   := "SZ1"
	Private cAlias2   := "SZ2"
	Private aRotina   := {	{"Pesquisar"   ,"AxPesqui"       ,0,1} ,;
									{"Visualizar"  ,"u_FATIncluir"   ,0,2} ,;
									{"Manutenção"  ,aRotInc          ,0,3} ,;
									{"Alterar"     ,"u_FATIncluir"   ,0,4} ,;
									{"Excluir"     ,"u_FATIncluir"   ,0,5} ,;
									{"Faturar"     ,"u_FATFaturar"   ,0,6} ,;
									{"Legenda"     ,"u_FATLegenda"   ,0,7} }
	
	dbSelectArea(cAlias1)
	dbSetOrder(1)
	
	mBrowse( 6,1,22,75,cAlias1,,,,,,aCores)
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FATIncluir ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 28/09/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Gera pedido de venda para o kanban                            ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FATIncluir(cAlias, nRecNo, nOpc )
	Local nX, aSize, aPosObj, aPosFol, oDlg, nPQEn
	Local nOpcA     := 0
	Local aFolder   := { "Pedido", "Saldo"}
	Local aCabec    := {}
	Local aSizes    := Nil
	Local nSaveSX8  := GetSx8Len()    // Variavel que controla numeracao
	Local nIndAtu   := (cAlias)->(IndexOrd())
	Local nRegAtu   := (cAlias)->(Recno())
	Local lKanban   := .F.
	
	Private oCli, cCliLoja, oLbx, oGet
	Private aTela   := {}
	Private aGets   := {}
	Private aAcho   := {}
	Private aFields := FWSX3Util():GetAllFields(cAlias)     // Retorna todos os campos ativos para a tabela
	Private aAltera := {}
	
	Private aHeader := {}
	Private aCols   := {}
	Private aCampos := { "Z1_DATENT", "Z1_QUANT", "Z1_SETENT", "Z1_HORENT", "Z1_QTDENT"}
	Private bCampo  := { |nField| Field(nField) }
	Private Inclui  := (nOpc == 3)
	Private Altera  := (nOpc == 4)
	Private aSaldo  := {}
	
	Private nPD     := 1
	
	dbSelectArea(cAlias)
	dbSetOrder(1)

	If nRecNo > 0
		dbGoTo(nRecNo)
	Endif

	For nX:= 1 To Len(aFields)
		//If AScan( aCampos , aFields[nX] ) == 0
			If nOpc == 3
				M->&( aFields[nX] ) := CriaVar(aFields[nX],.T.)
			Else
				M->&( aFields[nX] ) := (cAlias)->&( If( GetSx3Cache(aFields[nX], "X3_CONTEXT") <> "V" , aFields[nX], Trim(GetSx3Cache(aFields[nX], "X3_RELACAO")) ) )
			Endif
			
			AAdd( aAcho , aFields[nX] )
		//Endif
	Next nX
	
	If Inclui
		// Pesquisa se a chave já não foi gravada na base
		(cAlias)->(dbSetOrder(1))
		While (cAlias)->(dbSeek(XFILIAL(cAlias)+M->Z1_NUM))
			ConfirmSX8()
			nSaveSX8  := GetSx8Len()    // Variavel que controla numeracao
			M->Z1_NUM := GetSXENum(cAlias,"Z1_NUM")
		Enddo
		
		(cAlias)->(dbSetOrder(nIndAtu))
		(cAlias)->(dbGoTo(nRegAtu))
	Endif
	
	AAdd( aAcho , "NOUSER" )
	
	AAdd( aCabec , "Local" )
	AAdd( aCabec , "Saldo")
	
	//+----------------
	//| Monta os aCols
	//+----------------
	MontaaCols(nOpc,@aAltera)
	
	nPQEn := AScan( aHeader , {|x| Trim(x[2]) == "Z1_QTDENT" })
	If nOpc == 5 .And. (M->Z1_QTDENT > 0 .Or. AScan( aCols , {|x| !Empty(x[nPQEn]) } ) > 0)
		Alert("Não é permitida a exclusão de pedidos já faturados !")
		Return
	Endif
	
	cCliLoja := Posicione("SA1",1,XFILIAL("SA1")+M->Z1_CLIENTE+If(Empty(M->Z1_LOJA),"",M->Z1_LOJA),"A1_NOME")

	CarregaSaldos()   // Carrega os saldos em estoque para o produto do pedido
	
	//+----------------------------------
	//| Inicia as posições dos objetos
	//+----------------------------------
	PosObjetos(@aSize,@aPosObj,@aPosFol,.F.)
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],1110 OF oMainWnd PIXEL
	
	EnChoice(cAlias, nRecNo, nOpc,,,,aAcho,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],550},, 3,,,,oDlg,,.T.)
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aFolder,,oDlg,,,,.T.,,550-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)
	
	oGet := MSGetDados():New(aPosFol[1,1],aPosFol[1,2],aPosFol[1,3]-20,aPosFol[1,4],nOpc,/*"LinOk"*/,,/*"+Z1_ITEM"*/,.T.,/*aAlter*/,,,1000,,,,"u_FATADelIt()",oFolder:aDialogs[1])
	
	oLbx := TWBrowse():New(aPosFol[1,1],aPosFol[1,2],aPosFol[1,4]-aPosFol[1,2],aPosFol[1,3]-aPosFol[1,1]-20,/*Flds*/,aCabec,aSizes /*aColsSizes*/,oFolder:aDialogs[2],,,,/*Change*/,/*DblClick*/,,,,,,,,,.T.,,,,,)
	
	oLbx:SetArray( aSaldo )
	oLbx:bLine := {|| { aSaldo[oLbx:nAt,1], aSaldo[oLbx:nAt,2]}}
	
	@ aPosObj[3,1],aPosObj[3,2] SAY oCli VAR cCliLoja SIZE 300,10 PIXEL OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| If( nOpc==2.Or.nOpc==5.Or.Obrigatorio(aGets,aTela).And.FATATudOk(.F.,nOpc,@lKanban) , (nOpcA:=1, oDlg:End()),) }, {||nOpcA:=0,oDlg:End()},, )
	
	If nOpc > 2 .And. nOpcA == 1
		Begin Transaction
		FAT01Grava(nOpc,nRecNo,aAltera,lKanban)
		End Transaction
	Endif
	
	If nOpc == 3   // Se for Inclusão
		While ( GetSx8Len() > nSaveSX8 )
			If nOpcA == 1   // Se confirmou
				ConfirmSX8()
			Else
				RollBackSx8()
			Endif
		Enddo
	Endif

Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FATFaturar ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Gera pedido de venda para o kanban                            ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FATFaturar(cAlias, nRecNo, nOpc )
	Local nX, aSize, aPosObj, aPosFol, oDlg, oFolder, bLine
	Local aFolder   := { "Kanban", "Pedido"}
	Local aCabec    := {}
	Local aSizes    := Nil
	Local cLine     := ""
	Local nOpcA     := 0
	Local cAux      := cCadastro
	
	Private oCli, cCliLoja, oLbx
	Private aTela   := {}
	Private aGets   := {}
	Private aFields := FWSX3Util():GetAllFields(cAlias)     // Retorna todos os campos ativos para a tabela
	Private aAcho   := { "Z1_CLIENTE", "Z1_LOJA", "Z1_DATENT", "NOUSER" }
	
	Private aHeader := {}
	Private aCols   := {}
	Private aCampos := { "Z1_PRODUTO", "Z1_LOCAL", "Z1_QTDENT", "B1_DESC"}
	
	Private aHeaKan := {}
	Private aPedido := { "Z1_PRODUTO", "Z1_DATENT", "Z1_HORENT", "Z1_PEDCLI", "Z1_SETENT", "Z1_KANBAN", "Z1_QUANT", "C6_QTDLIB", "Z1_LOCAL", "Z1_NUM"}
	Private aMark   := {{}}
	Private nPD     := 1

	Private aEntregas := {}

	Inclui := .T.
	
	For nX:= 1 To Len(aAcho)-1
		If AScan( aFields , aAcho[nX] ) > 0
			If nOpc == 6
				M->&( aAcho[nX] ) := CriaVar(aAcho[nX],.F.)
			Else
				M->&( aAcho[nX] ) := (cAlias)->&( If( GetSx3Cache(aFields[nX], "X3_CONTEXT") <> "V" , aAcho[nX], Trim(GetSx3Cache(aFields[nX], "X3_RELACAO")) ) )
			Endif
		Endif
	Next nX

	AAdd( aFields , "B1_DESC" )    // Adiciona campo para exibição na tela de faturamento
	
	//+--------------
	//| Monta o aHeader
	//+--------------
	CriaHeader()

	For nX:=1 To Len(aPedido)
		AdicionaCampo(aPedido[nX],@aHeaKan)
	Next
	
	//+----------------
	//| Monta os aCols
	//+----------------
	aColsBlank(@aCols)
	
	// Preenche o cabeçalho
	For nX:=1 To Len(aHeaKan)
		AAdd( aCabec   , Trim(aHeaKan[nX,1]) )
		AAdd( aMark[1] , CriaVar(aHeaKan[nX,2]) )
		
		cLine += If( nX > 1 , ", ", "") + "aMark[oLbx:nAt,"+LTrim(Str(nX))+"]"
	Next
	
	cLine := "{|| {"+cLine+"}}"
	bLine := &(cLine)

	//+----------------------------------
	//| Inicia as posições dos objetos
	//+----------------------------------
	PosObjetos(@aSize,@aPosObj,@aPosFol,.T.)

	cCadastro := "Faturamento de Pedido Sato"
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	
	EnChoice(cAlias, nRecNo, 3,,,,aAcho,aPosObj[1],, 3,,,,oDlg)
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aFolder,,oDlg,,,,.T.,,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],)

	oGet := MSGetDados():New(aPosFol[1,1],aPosFol[1,2],aPosFol[1,3]-20,aPosFol[1,4],3,/*"LinOk"*/,,/*"+Z1_ITEM"*/,.T.,/*aAlter*/,,,1000,,,,"u_FATADelIt()",oFolder:aDialogs[1])
	
	oGet:oBrowse:bChange := {|| FAT01CpoAlt(oGet:oBrowse) }
	oGet:oBrowse:bSetGet := {|| FAT01CpoAlt(oGet:oBrowse) }
	
	FAT01CpoAlt(oGet:oBrowse)
	
	oLbx := TWBrowse():New(aPosFol[1,1],aPosFol[1,2],aPosFol[1,4]-aPosFol[1,2],aPosFol[1,3]-aPosFol[1,1]-20,/*Flds*/,aCabec,aSizes /*aColsSizes*/,oFolder:aDialogs[2],,,,/*Change*/,/*DblClick*/,,,,,,,,,.T.,,,,,)
	
	oLbx:SetArray( aMark )
	oLbx:bLine := bLine
	
	@ aPosObj[3,1],aPosObj[3,2] SAY oCli VAR cCliLoja SIZE 300,10 PIXEL OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| If( FATATudOk(.T.) , (nOpcA:=1, oDlg:End()),) }, {||nOpcA:=0,oDlg:End()},, )

	cCadastro := cAux
	
Return (nOpcA == 1)

User Function STMonitorProcesso(bBlock,a,b,c,d,e)
	Local oDlg, oPanelT
	Local oOk   := LoadBitmap( GetResources(), "BR_VERDE" )
	Local oEr   := LoadBitmap( GetResources(), "BR_VERMELHO" )
	Local oAn   := LoadBitmap( GetResources(), "BR_AMARELO"  )
	Local nOpcA := 0

	Default bBlock := {|| Gravacao() }
	
	Private oMon    := Nil
	Private aStatus := {}
	
	AAdd( aStatus , { "1" , CriaVar("D2_PEDIDO",.F.),  CriaVar("D2_DOC",.F.),  CriaVar("D2_SERIE",.F.), Space(30)} )
	
	DEFINE MSDIALOG oDlg TITLE "Status de Faturamento" From 0,0 TO 30,84 OF oMainWnd
	
	@ 0,0 MSPANEL oPanelT PROMPT "" SIZE 10,198 OF oDlg CENTERED LOWERED //"Botoes"
	oPanelT:Align := CONTROL_ALIGN_BOTTOM
	
	oMon := TWBrowse():New(05,05,320,185,/*Flds*/,{"","Pedido","Nota","Serie","Status"}, /*aColsSizes*/,oPanelT,,,,/*Change*/,/*DblClick*/,,,,,,,,,.T.,,,,,)
	
	oMon:SetArray( aStatus )
	oMon:bLine := {|| {If( aStatus[oMon:nAt,1]=="1",oAn,If( aStatus[oMon:nAt,1]=="2",oOk,oEr)),;
							aStatus[oMon:nAt,2],;
							aStatus[oMon:nAt,3],;
							aStatus[oMon:nAt,4],;
							aStatus[oMon:nAt,5]} }
	
	DEFINE Timer oTimer Interval 1000 ACTION ( TmBrowse(oTimer,@nOpcA,bBlock,a,b,c,d,e), If( nOpcA == 1 , oDlg:End(), ) ) Of GetWndDefault()
	oTimer:Activate()
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA:=1, oDlg:End() }, {|| nOpcA:=1, oDlg:End() } )
	
Return nOpcA == 1

Static Function TmBrowse(oTimer,nOpcA,bBlock,a,b,c,d,e)
	
	ASize( aStatus , 0 )
	
	oTimer:Deactivate()
	nOpcA := If( Eval(bBlock,a,b,c,d,e) , 1, 0)
	
Return .T.

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ Gravacao   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Processa a geração do pedido de venda                         ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Gravacao()
	Local nX
	Local aSC6Ind  := {}
	Local aSC6Dep  := {}
	Local aPvlNfs  := {}
	Local cFilInd  := "01"           // Filial da Industria
	Local cFilDep  := "02"           // Filial do Deposito
	Local nSaveSX8 := GetSx8Len()    // Variavel que controla numeracao
	Local cNaturez := CriaVar("C5_NATUREZ",.F.)
	Local lTemDep  := ( AScan( aMark , {|x| x[9] == "2" } ) )    // Identifica se haverá saída do depósito
	Local lUnicaNF := .F.            // Define se as notas de industrialização e retorno simbólico devem ser faturadas em uma única nota
	
	Private cTPOper    := CriaVar("C6_OPER"   ,.F.)
	Private lInfNFS    := GetMV("MV_XINFNFS",.F.,.T.)    // Define se informa o número da nota
	Private __cNumNota := ""
	Private cSerie     := ""
	Private cNumero    := ""
	Private __cMensNF  := ""
	
	lMsErroAuto := .F.

	u_STInfNumeroNota(If(lTemDep,cFilDep,cFilInd))   // Exibe tela de digitação do número da nota
	
	BeginTran()
	
	For nX:=1 To Len(aMark)
		
		// Posiciona no Cadastro do Kanban
		SZ1->(dbSetOrder(2))    // Z1_FILIAL+Z1_CLIENTE+Z1_LOJA+Z1_PRODUTO+DTOS(Z1_DATENT)+Z1_HORENT+Z1_SETENT+Z1_KANBAN+Z1_NUM
		SZ1->(dbSeek(XFILIAL("SZ1")+M->Z1_CLIENTE+M->Z1_LOJA+aMark[nX,1]+DtoS(aMark[nX,2])+aMark[nX,3]+aMark[nX,5]+aMark[nX,6]+aMark[nX,10]))
		
		//RecLock("SZ1",.F.)
		//SZ1->Z1_QTDENT += aMark[nX,8]
		//MsUnLock()

		// Atualiza os saldos na tabela do kanban eletrônico
		//u_STGravaKanban(.F.)
		
		// Posiciona no Cadastro de Produtos
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(XFILIAL("SB1")+SZ1->Z1_PRODUTO))
		
		// Posiciona no Cadastro de Clientes x Produtos
		SA7->(dbSetOrder(1))
		SA7->(dbSeek(XFILIAL("SA7")+M->Z1_CLIENTE+M->Z1_LOJA+SB1->B1_COD))
		
		cNaturez := AdicionaItem(cFilInd,@aSC6Ind,"I",aMark[nX,8])
		
		If aMark[nX,9] == "2"    // Se saída for da Deposito
			AdicionaItem(cFilDep,@aSC6Dep,"D",aMark[nX,8])
		Endif
	Next
	
	If !Empty(aSC6Dep) .And. GeraPedido(cFilDep,aSC6Dep,"","D",cFilInd)
		GeraEntrada(cFilInd)
		
		ConcluiProcesso("D",nSaveSX8)
		
		u_STInfNumeroNota(cFilInd)   // Exibe tela de digitação do número da nota
		
		nSaveSX8  := GetSx8Len()    // Variavel que controla numeracao
		BeginTran()
	Endif
	
	If !lMsErroAuto
		GeraPedido(cFilInd,aSC6Ind,cNaturez,"I",cFilInd,@lUnicaNF)
	Endif

	ConcluiProcesso("I",nSaveSX8)

	__cMensNF := ""
	
	If !lMsErroAuto
		MsgInfo("Faturamento concluído com sucesso !")
		Sleep(5000)

		// Verifica se será gerado o retorno simbólico para a nota
		If !lUnicaNF .And. u_STFATE01(SF2->F2_DOC,SF2->F2_SERIE)
			If u_STLiberaPedido("Retorno Simbólico",@aPvlNfs)
				
				__cMensNF := "RETORNO CONF. NF " + SF2->F2_DOC+"/"+SF2->F2_SERIE
				
				u_STInfNumeroNota(cFilInd)   // Exibe tela de digitação do número da nota
				If u_STGeraSaida("R","Retorno Simbólico",aPvlNfs)
					u_STTransmissao("Retorno Simbólico")
				Endif
			Endif
		Endif
	Endif
	
Return !lMsErroAuto

Static Function ConcluiProcesso(cBase,nSaveSX8)
	Local cMens := If( cBase == "I" , "Venda", "Transferencia")
	
	If lMsErroAuto
		While ( GetSx8Len() > nSaveSX8 )
			RollBackSx8()
		Enddo
		
		MostraErro()
		
		DisarmTransaction()
	Else
		// Confirma SX8
		While ( GetSx8Len() > nSaveSX8 )
			ConfirmSX8()
		Enddo
		
		EndTran()
		
		u_STTransmissao(cMens)
	Endif

Return

User Function STInfNumeroNota(cFilAtu)
	Local cFilAux := cFilAnt
	
	If lInfNFS
		cFilAnt := cFilAtu
		cSerie  := ""
		cNumero := ""
		
		While !Sx5NumNota(@cSerie,SuperGetMV("MV_TPNRNFS"))
		Enddo
	 	
		 __cNumNota := cNumero
		 cFilAnt    := cFilAux
	Endif

Return

Static Function GeraPedido(cFilAtu,aItens,cNaturez,cBase,cFilCli,lUnicaNF)
	Local cNumPed, aMP, cItem, nPIte, nX
	Local aArray  := {}
	Local aPvlNfs := {}
	Local cMens   := If( cBase == "I" , "Venda", "Transferencia")
	
	cFilAnt := cFilAtu                     // Posiciona na filial
	cNumPed := GetSXENum("SC5","C5_NUM")   // Pega o próximo pedido de venda
	RollBAckSx8()

	If cBase == "I"
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(XFILIAL("SA1")+M->Z1_CLIENTE+M->Z1_LOJA))
		
		// Se gera a nota de retorno simbólico
		If lUnicaNF := (SA1->A1_XRETREM == "1" .And. SA1->A1_XINDBEN == "1")    // Define se fatura industrialização e retorno simbólico em uma única nota
			aMP := ItensRetorno(aItens)
			If !Empty(aMP) //.And. MsgYesNo("Deseja adicionar na nota fiscal os itens de Retorno Simbólico ?","Retorno Simbólico")
				// Adiciona os itens para retorno simbólico
				For nX:=1 To Len(aMP)
					AAdd( aItens , aClone(aMP[nX]) )
				Next
				
				// Recalcula os itens do pedido
				cItem := StrZero(0,TamSX3("C6_ITEM")[1])
				For nX:=1 To Len(aItens)
					nPIte := AScan( aItens[nX] , {|x| x[1] == "C6_ITEM" } )
					aItens[nX][nPIte][2] := cItem := Soma1(cItem)
				Next
			Endif
		Endif
	Else
		STVldCliFor("SA1",cFilCli)
	Endif
	
	u_STRefreshMonitor("1",{ "1" , cNumPed, "", "", "Gerando pedido de "+cMens+" na filial "+cFilAnt+"..."})
	
	AAdd( aArray , { "C5_FILIAL"  , xFilial("SC5")     , Nil} )
	AAdd( aArray , { "C5_NUM"     , cNumPed            , Nil} )
	AAdd( aArray , { "C5_TIPO"    , "N"                , Nil} )
	AAdd( aArray , { "C5_CLIENTE" , SA1->A1_COD        , Nil} )
	AAdd( aArray , { "C5_LOJACLI" , SA1->A1_LOJA       , Nil} )
	AAdd( aArray , { "C5_CLIENT"  , SA1->A1_COD        , Nil} )
	AAdd( aArray , { "C5_LOJAENT" , SA1->A1_LOJA       , Nil} )
	AAdd( aArray , { "C5_EMISSAO" , dDataBase          , Nil} )
	AAdd( aArray , { "C5_CONDPAG" , SA1->A1_COND       , Nil} )
	AAdd( aArray , { "C5_MOEDA"   , 1                  , Nil} )
	AAdd( aArray , { "C5_TIPOCLI" , SA1->A1_TIPO       , Nil} )
	If !Empty(cNaturez)
		AAdd( aArray , { "C5_NATUREZ" , cNaturez       , Nil} )
	Endif
	
	MSExecAuto({|x,y,Z| Mata410(x,y,Z)}, aArray, aItens, 3)
	
	If lMsErroAuto
		u_STRefreshMonitor("3","Erro na geração do pedido de " + cMens + " !")
	ElseIf u_STLiberaPedido(cMens,@aPvlNfs)
		u_STGeraSaida(cBase,cMens,aPvlNfs)
	Endif
	
Return !lMsErroAuto

User Function STLiberaPedido(cMens,aPvlNfs)
	Local aBloqueio := {}
	
	u_STRefreshMonitor("1","Liberando pedido de " + cMens + "...")
	
	// Liberacao de pedido
	Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
	// Checa itens liberados
	Ma410LbNfs(1,@aPvlNfs,@aBloqueio)
	
	// Caso tenha itens liberados manda faturar
	If Empty(aBloqueio) .And. !Empty(aPvlNfs)
		u_STRefreshMonitor("2","Pedido de " + cMens + " gravado com sucesso !")
	Else
		u_STRefreshMonitor("3","Ocorreu problema na liberação do pedido de " + cMens)
		lMsErroAuto := .T.
		
		//ExibeBloqueio(aPvlNfs,aBloqueio)
	Endif
	
Return Empty(aBloqueio) .And. !Empty(aPvlNfs)

Static Function AdicionaItem(cFilAtu,aArray,cBase,nQuant)
	Local cEnder, cLocExp, nPreco, cTES, aEstoq, nPerc
	Local nItem := Len(aArray) + 1
	Local cItem := StrZero(nItem,TamSX3("C6_ITEM")[1])
	Local cFil  := cFilAnt
	Local cRet  := ""
	
	cFilAnt := cFilAtu
	
	cEnder  := GetMv("MV_XENDKAN",.F.,"FATURAR")
	cTES    := &( GetMV("MV_XESP008",.F.,"'501'") )  // TES padrão de saída
	cLocExp := Alltrim(GetMV("MV_XLOCEXP",.F.,"02"))
	nPerc   := GetMV("MV_XPERTRF",.F.,70) / 100
	cRet    := Posicione("SF4",1,XFILIAL("SF4")+cTES,"F4_XNATURE")
	nPreco  := u_STfPrecoTab(SB1->B1_COD,SA1->A1_COD+SA1->A1_LOJA)
	
	If cBase == "D"
		If nPreco <= 0 .Or. nPerc <= 0
			aEstoq := CalcEst(SB1->B1_COD, cLocExp, dDataBase+1)
			nPreco := Round( aEstoq[1] / aEstoq[2] , TamSX3("C6_PRCVEN")[2])
			nPreco := If( nPreco <= 0 , 1, nPreco)
		Else
			nPreco := Round( nPreco * nPerc , TamSX3("C6_PRCVEN")[2])
		Endif
	Endif
	
	nValor  := a410Arred( nQuant * nPreco , "C6_VALOR" , NIL )
	
	aAdd(aArray, {} )
	//AAdd( aArray[nItem] , { "C6_FILIAL"  , xFilial("SC6") , Nil} )
	AAdd( aArray[nItem] , { "C6_ITEM"    , cItem          , Nil} )
	AAdd( aArray[nItem] , { "C6_PRODUTO" , SB1->B1_COD    , Nil} )
	AAdd( aArray[nItem] , { "C6_DESCRI"  , SB1->B1_DESC   , Nil} )
	AAdd( aArray[nItem] , { "C6_LOCAL"   , cLocExp        , Nil} )
	If Localiza(SB1->B1_COD)
		AAdd( aArray[nItem] , { "C6_LOCALIZ" , cEnder     , Nil} )
	Endif
	AAdd( aArray[nItem] , { "C6_QTDVEN"  , nQuant         , Nil} )
	AAdd( aArray[nItem] , { "C6_ENTREG"  , SZ1->Z1_DATENT , Nil} )
	AAdd( aArray[nItem] , { "C6_UM"      , SB1->B1_UM     , Nil} )
	If !Empty(cTPOper)
		AAdd( aArray[nItem] , { "C6_OPER" , cTPOper       , Nil} )
	Endif
	AAdd( aArray[nItem] , { "C6_QTDLIB"  , nQuant         , Nil} )
	AAdd( aArray[nItem] , { "C6_CLI"     , SA1->A1_COD    , Nil} )
	AAdd( aArray[nItem] , { "C6_LOJA"    , SA1->A1_LOJA   , Nil} )
	AAdd( aArray[nItem] , { "C6_PRCVEN"  , nPreco         , Nil} )
	AAdd( aArray[nItem] , { "C6_VALOR"   , nValor         , Nil} )
	AAdd( aArray[nItem] , { "C6_PRUNIT"  , nPreco         , Nil} )
	AAdd( aArray[nItem] , { "C6_TES"     , cTES           , Nil} )
	
	If cBase == "I"
		AAdd( aArray[nItem] , { "C6_XTIPPED" , SZ1->Z1_TIPPED , Nil} )
		AAdd( aArray[nItem] , { "C6_XCODITE" , SA7->A7_CODCLI , Nil} )
		AAdd( aArray[nItem] , { "C6_PEDCLI"  , SZ1->Z1_PEDCLI , Nil} )
		AAdd( aArray[nItem] , { "C6_XSETENT" , SZ1->Z1_SETENT , Nil} )
		AAdd( aArray[nItem] , { "C6_XHORENT" , SZ1->Z1_HORENT , Nil} )

		If !Empty(SZ1->Z1_XPED)
			AAdd( aArray[nItem] , { "C6_PEDCLI", SZ1->Z1_XPED , Nil} )
		Endif

		AAdd( aArray[nItem] , { "C6_XLINPED" , SZ1->Z1_LINPED , Nil} )
		AAdd( aArray[nItem] , { "C6_XKANBAN" , SZ1->Z1_KANBAN , Nil} )
		AAdd( aArray[nItem] , { "C6_XPEDSAT" , SZ1->Z1_NUM    , Nil} )
	Endif
	
	cFilAnt := cFil
	
Return cRet

User Function STGeraSaida(cBase,cMens,aPvlNfs)
	Local nX, cNota, nItemNf
	Local aNotas    := {}
	Local aPar      := Array(30)
	Local aNFGer    := {}
	
	If !lInfNFS
		cSerie     := GetMV("MV_XSERNFS",.F.,"001")
		__cNumNota := cNumero := ProximoNumero(cSerie)
	Endif

	nItemNf := a460NumIt(cSerie)
	
	u_STRefreshMonitor("1",{ "1" , "", cNumero, cSerie, "Gerando nota de "+cMens+" na filial "+cFilAnt+"..."} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os parâmentros da rotina de geração da nota fiscal   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MT460A",.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega parametros do programa                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX:=1 To Len(aPar)
		aPar[nX] := &("mv_par"+StrZero(nX,2))
	Next
	
	AAdd(aNotas,{})
	
	// Efetua as quebras de acordo com o número de itens
	For nX:=1 To Len(aPvlNfs)
		If Len(aNotas[Len(aNotas)])>=nItemNf
			aadd(aNotas,{})
		EndIf
		aadd(aNotas[Len(aNotas)],aClone(aPvlNfs[nX]))
	Next nX
	
	// Gera as notas de acordo com a quebra
	For nX := 1 To Len(aNotas)
		cNota := MaPvlNfs(aNotas[nX],cSerie,aPar[01]==1,aPar[02]==1,aPar[03]==1,aPar[04]==1,aPar[05]==1,aPar[07],aPar[08],aPar[15]==1,aPar[16]==2)
		
		AAdd( aNFGer , cNota )

		If cBase == "I"    // Se for Industria
			NotaNoKanban(cNota,cSerie)
		Endif
	Next nX
	
	If lMsErroAuto
		u_STRefreshMonitor("3","Ocorreu um erro na geração da nota de " + cMens)
	Else
		u_STRefreshMonitor("2","Nota Fiscal de " + cMens + " gerada com sucesso.")

		ProximoNumero(cSerie,cNota)
	Endif
	
Return !lMsErroAuto

Static Function NotaNoKanban(cDoc,cSerie)
	Local nX, nY

	SF2->(dbSetOrder(1))
	SF2->(dbSeek(XFILIAL("SF2")+cDoc+cSerie))
	
	For nX:=1 To Len(aEntregas)
		For nY:=1 To Len(aEntregas[nX,7])
			SZ3->(dbSetOrder(1))    // Z3_FILIAL+Z3_DOC+Z3_SERIE+Z3_NUM+Z3_PRODUTO+DTOS(Z3_DATENT)+Z3_HORENT+Z3_SETENT+Z3_LOCAL
			If SZ3->(dbSeek(XFILIAL("SZ3")+cDoc+cSerie+aEntregas[nX,7][nY,1]+aEntregas[nX,1]+DtoS(aEntregas[nX,2])+aEntregas[nX,3]+aEntregas[nX,4]+aEntregas[nX,7][nY,2]))
				RecLock("SZ3",.F.)
			Else
				RecLock("SZ3",.T.)
				SZ3->Z3_FILIAL  := XFILIAL("SZ3")
				SZ3->Z3_DOC     := cDoc
				SZ3->Z3_SERIE   := cSerie
				SZ3->Z3_NUM     := aEntregas[nX,7][nY,1]
				SZ3->Z3_PRODUTO := aEntregas[nX,1]
				SZ3->Z3_DATENT  := aEntregas[nX,2]
				SZ3->Z3_HORENT  := aEntregas[nX,3]
				SZ3->Z3_SETENT  := aEntregas[nX,4]
				SZ3->Z3_LOCAL   := aEntregas[nX,7][nY,2]
			Endif
			SZ3->Z3_QUANT += aEntregas[nX,7][nY,3]
			MsUnLock()
			
			// Soma a quantidade entregue no Pedido Sato
			SZ1->(dbSetOrder(1))
			If SZ1->(dbSeek(XFILIAL("SZ1")+SZ3->Z3_NUM+SZ3->Z3_PRODUTO))
				RecLock("SZ1",.F.)
				SZ1->Z1_QTDENT += aEntregas[nX,7][nY,3]
				MsUnLock()
			Endif
			
			// Subtrai a quantidade entregue no Kanban Eletrônico
			SZ2->(dbSetOrder(1))     //Z2_FILIAL+Z2_CLIENTE+Z2_LOJA+Z2_PRODUTO+DTOS(Z2_DATENT)+Z2_HORENT+Z2_SETENT
			If SZ2->(dbSeek(XFILIAL("SZ2")+SF2->F2_CLIENTE+SF2->F2_LOJA+SZ3->Z3_PRODUTO+DtoS(SZ3->Z3_DATENT)+SZ3->Z3_HORENT+SZ3->Z3_SETENT))
				RecLock("SZ2",.F.)
				SZ2->Z2_QTDENT += aEntregas[nX,7][nY,3]
				MsUnLock()
			Endif
		Next
	Next

Return

User Function STTransmissao(cLegenda)
	Local cMens, oSetupDanfe
	Local cStatus := "1"
	Local nTry    := 1
	Local nVezes  := 0
	Local nNTent  := Max(0,GetMV("MV_XNTENTA",.F.,3))    // Número de tentativas para enviar a NF-e

	If nNTent == 0    // Caso não queira transmitir a nota
		Return .T.
	Endif
	
	u_STRefreshMonitor("1",{ "1" , "", SF2->F2_DOC, SF2->F2_SERIE, "Transmitindo nota de "+cLegenda+"..."} )
	
	SF3->(dbSetOrder(4))

	While nTry < 4 .And. nVezes < 10 .And. cStatus == "1"
		If SF3->(dbSeek(XFILIAL("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
			If SF3->F3_CODRSEF == "100"
				cStatus := "2"
				cMens   := "Nota Fiscal Autorizada."
			ElseIf SF3->F3_CODRSEF $ "101,135"
				cStatus := "3"
				cMens   := "Nota Fiscal Cancelada."
			ElseIf SF3->F3_CODRSEF == "102"
				cStatus := "3"
				cMens   := "Nota Fiscal Inutilizada."
			ElseIf SF3->F3_CODRSEF == "110"
				cStatus := "3"
				cMens   := "Nota Fiscal Denegada."
			Else
				cMens   := If( Empty(SF3->F3_CODRSEF) , "Nota Fiscal ainda não foi transmitida.", Trim(SF3->F3_DESCRET))
			Endif
		Else
			cMens   := "Nota Fiscal não foi gravada no Livro Fiscal."
		Endif
		
		u_STRefreshMonitor(cStatus,cMens)

		If cStatus == "1"
			nVezes++
			
			If nVezes >= 10
				If nTry > (nNTent - 1)
					Alert("O processo de faturamento continuará porém não houve transmissão da nota fiscal " + SF2->F2_DOC+" / " + SF2->F2_SERIE + ".")
				Else
					MsgAlert("A transmissão e autorização da nota fiscal " + SF2->F2_DOC+" / " + SF2->F2_SERIE + " ainda não foi concluída. Se necessário processe a transmissão manualmente !")
					nVezes := 0
					nTry++
				Endif
			Else
				Sleep(5000)
			Endif
		Endif

	Enddo

	If cStatus == "2" .And. MsgYesNo("Deseja imprimir a DANFE da nota " + SF2->F2_DOC+" / "+SF2->F2_SERIE+" ?","Impressão DANFE")
		u_Predanfe(.F.,@oSetupDanfe)
	Endif

Return cStatus == "2"

Static Function GeraEntrada(cFilAtu)
	Local cTES, aLinha, cLocExp
	Local nTam    := TamSX3("D1_ITEM")[1]
	Local cDocNFS := SF2->F2_DOC
	Local cSerNFS := SF2->F2_SERIE
	Local cSeek   := SF2->F2_FILIAL+cDocNFS+cSerNFS
	Local aCabec  := {}
	Local aItens  := {}
	
	// Grava a mensagem informada no documento de saída do Depósito. Essa mensagem será utilizada na nota de industrialização
	__cMensNF := AllTrim(SF2->F2_XMSGNF)
	
	u_STRefreshMonitor("1",{ "1" , "", cDocNFS, cSerNFS, "Gerando nota de entrada na filial "+cFilAtu+"..."} )
	
	// Posiciona no fornecedor loja origem
	STVldCliFor("SA2",SF2->F2_FILIAL)
	
	SD2->(dbSetOrder(3))
	SD2->(dbSeek(cSeek,.T.))
	While !SD2->(Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == cSeek
		
		// Posiciona no cadastro de produtos
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
		
		// Adiciona os itens da nota de entrada
		aLinha := {}
		AAdd( aLinha , { "D1_ITEM"   , PADL(SD2->D2_ITEM,nTam,"0"), Nil})
		AAdd( aLinha , { "D1_COD"    , SD2->D2_COD     , Nil})
		AAdd( aLinha , { "D1_QUANT"  , SD2->D2_QUANT   , Nil})
		AAdd( aLinha , { "D1_VUNIT"  , SD2->D2_PRCVEN  , Nil})
		AAdd( aLinha , { "D1_TOTAL"  , SD2->D2_TOTAL   , Nil})
		AAdd( aLinha , { "D1_LOCAL"  , cLocExp         , Nil})
		AAdd( aLinha , { "D1_TES"    , cTES            , Nil})
		AAdd( aItens , aClone(aLinha) )
		
		SD2->(dbSkip())
	Enddo
	
	// Cabecalho da nota fiscal de entrada
	AAdd( aCabec , { "F1_TIPO"   , "N"             })
	AAdd( aCabec , { "F1_FORMUL" , "N"             })
	AAdd( aCabec , { "F1_DOC"    , cDocNFS         })
	AAdd( aCabec , { "F1_SERIE"  , cSerNFS         })
	AAdd( aCabec , { "F1_EMISSAO", SF2->F2_EMISSAO })
	AAdd( aCabec , { "F1_FORNECE", SA2->A2_COD     })
	AAdd( aCabec , { "F1_LOJA"   , SA2->A2_LOJA    })
	AAdd( aCabec , { "F1_ESPECIE", "SPED"          })
	AAdd( aCabec , { "F1_CHVNFE", SF2->F2_CHVNFE   })
	
	cFilAnt := cFilAtu
	cLocExp := Alltrim(GetMV("MV_XLOCEXP",.F.,"02"))
	cTES    := GetMV("MV_XESP009",.F.,"001")    // TES padrão de entrada

	aEval( aItens , {|x| x[6,2] := cLocExp, x[7,2] := cTES } )   // Atualiza com os conteúdos corretos
	
	// Atribui o módulo 4 (Estoque) para não ocorrer erro nas rotinas abaixo
	nModulo := 4
	
	// Inclui nota de entrada
	MATA103(aCabec,aItens,3) 
	
	If lMsErroAuto
		u_STRefreshMonitor("3","Ocorreu um erro na geração da nota de entrada")
	Else
		u_STRefreshMonitor("2","Nota Fiscal de entrada gerada com sucesso.")
	Endif
	
Return !lMsErroAuto

User Function STRefreshMonitor(cStatus,xMens)
	
	If ValType(xMens) == "A"
		AAdd( aStatus , aClone(xMens) )
		oMon:nAt := Len(aStatus)
		oMon:GoBottom()
	Else
		aStatus[oMon:nAt,5] := xMens
	Endif
	
	aStatus[oMon:nAt,1] := cStatus

	oMon:Refresh()
	MsgRun("","",{||.T.})
	
Return

Static Function ProximoNumero(cSerie,cNumNF)
	Local cFilSX5 := If( ExistBlock("CHGX5FIL") , u_CHGX5FIL(),If( Empty(SX5->(XFILIAL("SX5"))) , SX5->(XFILIAL("SX5")), cFilAnt))
	
	SX5->(dbSetOrder(1))
	If !SX5->(dbSeek(cFilSX5+"01"+cSerie))
		RecLock("SX5",.T.)
		SX5->X5_FILIAL := cFilSX5
		SX5->X5_TABELA := "01"
		SX5->X5_CHAVE  := cSerie
		MsUnLock()
	Endif
	
	If cNumNF == Nil    // Grava numeração
		// Pega o próximo número de nota fiscal
		If Empty(SX5->X5_DESCRI)
			cNumNF := StrZero(1,Len(SF2->F2_DOC))
		Else
			cNumNF := PADR(SX5->X5_DESCRI,Len(SF2->F2_DOC))
		Endif
		
		// Verifica se o número já não foi utilizado em uma nota de saída
		SF2->(dbSetOrder(1))
		While SF2->(dbSeek(XFILIAL("SF2")+cNumNF+cSerie))
			cNumNF := Soma1(cNumNF)
		Enddo
		
		// Verifica se o número já não foi utilizado em uma nota de entrada
		SF1->(dbSetOrder(1))
		While SF1->(dbSeek(XFILIAL("SF1")+cNumNF+cSerie)) .And. SF1->F1_TIPO == "D"
			cNumNF := Soma1(cNumNF)
		Enddo
		
		// Verifica se o número já não existe no Livro Fiscal
		SF3->(dbSetOrder(1))
		While SF3->(dbSeek(XFILIAL("SF3")+cNumNF+cSerie)) .And. Trim(SF3->F3_ESPECIE) == "SPED"
			cNumNF := Soma1(cNumNF)
		Enddo
	Else
		RecLock("SX5",.F.)
		SX5->X5_DESCRI  := Soma1(cNumNF)
		SX5->X5_DESCSPA := SX5->X5_DESCRI
		SX5->X5_DESCENG := SX5->X5_DESCRI
		MsUnLock()
	Endif
	
Return cNumNF

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ MontaaCols ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 27/09/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria a variavel vetor aCols                                   ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MontaaCols(nOpc,aAltera)
	Local nX
	Local nCols  := 0
	Local nUsado := CriaHeader()     // Monta o aHeader
	
	//+--------------
	//| Monta o aCols com os dados referentes os dados do Kanban
	//+--------------
	aAltera := {}

	If nOpc <> 3
		dbSelectArea(cAlias1)
		dbSetOrder(1)
		dbSeek(XFILIAL(cAlias1)+M->Z1_NUM,.T.)
		While !Eof() .And. XFILIAL(cAlias1)+M->Z1_NUM == SZ1->Z1_FILIAL+SZ1->Z1_NUM
			
			aAdd(aCols,Array(nUsado+1))
			nCols ++
			
			For nX := 1 To nUsado
				If ( aHeader[nX][10] != "V")
					aCols[nCols][nX] := FieldGet(FieldPos(aHeader[nX][2]))
				Else
					aCols[nCols][nX] := CriaVar(aHeader[nX][2],.T.)
				Endif
			Next nX
			aCols[nCols][nUsado+1] := .F.
			
			AAdd( aAltera , Recno() )
			
			dbSkip()
		Enddo
	Endif
	
	If Empty(aCols)  // Caso nao tenha itens no Kanban
		//+--------------
		//| Monta o aCols com uma linha em branco
		//+--------------
		aColsBlank(@aCols)
	Endif
	
Return .T.

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FATAValid  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de validação e filtro dos dados                        ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FATAValid()
	Local nPDes, nPPrd, nPQtd, nQuant, nPLoc
	Local nOpc := If( IsInCallStack("u_FATFaturar") , 2, 1)
	Local cVar := ReadVar()
	Local lRet := .T.
	
	If cVar $ "M->Z1_CLIENTE,M->Z1_LOJA"
		If lRet := ExistCpo("SA1",M->Z1_CLIENTE+If(Empty(M->Z1_LOJA),"",M->Z1_LOJA))
			cCliLoja := Posicione("SA1",1,XFILIAL("SA1")+M->Z1_CLIENTE+If(Empty(M->Z1_LOJA),"",M->Z1_LOJA),"A1_NOME")
			oCli:Refresh()

			M->Z1_PRODUTO := CriaVar("Z1_PRODUTO",.F.)
			M->Z1_DESCRI  := CriaVar("Z1_DESCRI" ,.F.)
		Endif
	ElseIf cVar == "M->Z1_DATENT"
		If !Empty(aSaldo)
			Alert("Não é permitida a alteração desse campo pois já existe entregas selecionadas para faturamento !")
			lRet := .F.
		Endif
	ElseIf cVar == "M->Z1_PRODUTO"
		If lRet := ExistCpo("SB1",M->Z1_PRODUTO)
			nPPrd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_PRODUTO" } )
			nPLoc := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_LOCAL"   } )
			
			If lRet := If( nOpc == 1 , JaExiste(M->Z1_PRODUTO,aCols,{nPPrd}), JaExiste(M->Z1_PRODUTO+aCols[n,nPLoc],aCols,{nPPrd,nPLoc}) )
				If Inclui .Or. Altera
					SA7->(dbSetOrder(1))
					If lRet := SA7->(dbSeek(XFILIAL("SA7")+M->Z1_CLIENTE+M->Z1_LOJA+M->Z1_PRODUTO))
						M->Z1_DESCRI := Posicione("SB1",1,XFILIAL("SB1")+M->Z1_PRODUTO,"B1_DESC")
					Else
						Alert("Produto informado não está cadastrado na Amarração Cliente x Produto !")
					Endif
				Else
					nPDes := ASCan( aHeader , {|x| Trim(x[2]) == "B1_DESC" } )
					aCols[n,nPDes] := Posicione("SB1",1,XFILIAL("SB1")+M->Z1_PRODUTO,"B1_DESC")
				Endif
			Endif
		Endif
	ElseIf cVar == "M->Z1_LOCAL"
		nPPrd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_PRODUTO" } )
		nPLoc := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_LOCAL"   } )
		
		lRet := JaExiste(aCols[n,nPPrd]+M->Z1_LOCAL,aCols,{nPPrd,nPLoc})
	ElseIf cVar == "M->Z1_QUANT"
		If lRet := (nOpc == 2 .Or. Len(aCols) < 2)
			If lRet := Positivo()
				If nOpc == 1   // Se estiver digitando o cabeçalho
					lRet  := (M->Z1_QUANT >= M->Z1_QTDENT)
				Else
					nPQtd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_QTDENT"  } )
					lRet  := (M->Z1_QUANT >= aCols[n,nPQtd])
				Endif
				
				If lRet
					If nOpc == 1   // Se estiver digitando o cabeçalho
						nPQtd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_QUANT"  } )
						aCols[1,nPQtd] := M->Z1_QUANT
						oGet:oBrowse:Refresh()
					Endif
				Else
					Alert("Quantidade não pode ser menor que a quantidade já faturada para esse pedido !")
				Endif
			Endif
		Else
			Aviso( "INVÁLIDO" , "Favor informar quantidade nos itens individualmente !")
		Endif
	ElseIf cVar == "M->Z1_QTDENT"
		nPPrd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_PRODUTO" } )
		nPQtd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_QTDENT"  } )
		nPLoc := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_LOCAL"   } )
		
		If lRet := !Empty(aCols[n,nPPrd])
			If lRet := NaoVazio() .And. Positivo()
				If lRet := (M->Z1_QTDENT <= CalcSaldoEntrega(aCols[n,nPPrd]))
					MsgRun("  Filtrando Kanban   ","Aguarde...",{|| nQuant := FiltraKanban(M->Z1_CLIENTE,M->Z1_LOJA,aCols[n,nPPrd],M->Z1_DATENT,M->Z1_QTDENT,aCols[n,nPLoc]) })
					
					If lRet := (nQuant > 0)
						aCols[n,nPQtd] := nQuant
					Endif
				Else
					Aviso( "INVÁLIDO", "Não existe saldo programado para atender a essa quantidade !", {"Ok"} )
				Endif
			Endif
		Else
			Aviso( "INVÁLIDO", "É necessário informar um produto antes de informar a quantidade !", {"Ok"} )
		Endif
	Endif
	
Return lRet

Static Function CarregaSaldos()
	Local cQry
	Local cAlias  := Alias()
	Local cFilAux := cFilAnt

	aSize(aSaldo,0)

	cQry := "SELECT SB2.B2_FILIAL, SB2.B2_LOCAL "
	cQry += " FROM " + RetSQLName("SB2") + " SB2"
	cQry += " WHERE SB2.D_E_L_E_T_ = ' '"
	cQry += " AND SB2.B2_COD = '" + M->Z1_PRODUTO + "'"
	cQry += " ORDER BY SB2.B2_FILIAL, SB2.B2_LOCAL"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "TMP", .T., .F. )
	While !Eof()
		cFilAnt := TMP->B2_FILIAL
		AAdd( aSaldo , { TMP->B2_LOCAL, CalcEst(M->Z1_PRODUTO, TMP->B2_LOCAL, dDataBase+1)[1]} )
		dbSkip()
	Enddo
	dbCloseArea()
	dbSelectArea(cAlias)

	cFilAnt := cFilAux

	If Empty(aSaldo)
		AAdd( aSaldo , { " ", 0})
	Endif
	
Return

Static Function CalcSaldoEntrega(cProduto)
	Local cChave := M->Z1_CLIENTE+M->Z1_LOJA+cProduto+DtoS(M->Z1_DATENT)
	Local nRet   := 0
	
	SZ2->(dbSetOrder(1))    // Z2_FILIAL+Z2_CLIENTE+Z2_LOJA+Z2_PRODUTO+DTOS(Z2_DATENT)+Z2_HORENT+Z2_SETENT 
	SZ2->(dbSeek(XFILIAL("SZ2")+cChave,.T.))
	While !SZ2->(Eof()) .And. XFILIAL("SZ2")+cChave == SZ2->Z2_FILIAL+SZ2->Z2_CLIENTE+SZ2->Z2_LOJA+SZ2->Z2_PRODUTO+DTOS(SZ2->Z2_DATENT)
		nRet += (SZ2->Z2_QUANT + SZ2->Z2_QTDPED) - SZ2->Z2_QTDENT
		SZ2->(dbSkip())
	Enddo
	
Return nRet

Static Function FiltraKanban(cCliente,cLoja,cProduto,dDataEnt,nQtdDig,cOrigem)
	Local cQry, nX, nPos, cArq
	Local aArea    := GetArea()
	Local cMarca   := GetMark()
	Local aHeadCpo := {}
	Local aSelect  := { "Z1_DATENT", "Z1_HORENT", "Z1_PEDCLI", "Z1_SETENT", "Z1_KANBAN", "Z1_QUANT", "Z1_QTDENT", "C6_QTDLIB", "B2_QATU", "Z1_LOCAL", "Z1_NUM"}
	Local cPicture := Trim(Posicione("SX3",2,"Z1_QUANT","X3_PICTURE"))
	Local aStruct  := {}
	
	Private nTotal := 0
	
	// Adiciona o campo de marcação
	AAdd( aHeadCpo , { "Z1_OK",, "", "@!"} )
	AAdd( aStruct ,  { "Z1_OK", "C", 2, 0} )
	
	SX3->(dbSetOrder(2))
	
	For nX:=1 To Len(aSelect)
		If SX3->(dbSeek(aSelect[nX]))
			AAdd( aHeadCpo , { Trim(GetSx3Cache(aSelect[nX], 'X3_CAMPO')),, Trim(GetSx3Cache(aSelect[nX], 'X3_TITULO')), If( GetSx3Cache(aSelect[nX], 'X3_TIPO') == "N" , cPicture, Trim(GetSx3Cache(aSelect[nX], 'X3_PICTURE')))} )
			AAdd( aStruct  , { Trim(GetSx3Cache(aSelect[nX], 'X3_CAMPO')), GetSx3Cache(aSelect[nX], 'X3_TIPO'), GetSx3Cache(aSelect[nX], 'X3_TAMANHO'), If( GetSx3Cache(aSelect[nX], 'X3_TIPO') == "N" , 2, 0)} )
		Endif
	Next
	
	// Cria tabela temporária para marcação dos itens
	cArq := Criatrab(aStruct,.T.)
	Use &(cArq) Alias TMP New Exclusive
	
	cQry := "SELECT SZ1.R_E_C_N_O_ AS Z1_RECNO"
	cQry += " FROM " + RetSQLName("SZ1") + " SZ1"
	cQry += " WHERE SZ1.D_E_L_E_T_ = ' '"
	cQry += " AND SZ1.Z1_FILIAL = '"+SZ1->(XFILIAL("SZ1"))+"'"
	cQry += " AND SZ1.Z1_QTDENT < SZ1.Z1_QUANT"
	cQry += " AND SZ1.Z1_CLIENTE = '"+cCliente+"'"
	cQry += " AND SZ1.Z1_LOJA = '"+cLoja+"'"
	cQry += " AND SZ1.Z1_TIPPED = '1'"
	
	If cProduto <> Nil .And. !Empty(cProduto)
		cQry += " AND SZ1.Z1_PRODUTO = '"+cProduto+"'"
	Endif
	//If dDataEnt <> Nil .And. !Empty(dDataEnt)
	//	cQry += " AND SZ1.Z1_DATENT = '"+DtoS(dDataEnt)+"'"
	//Endif
	
	cQry += " ORDER BY " + SZ1->(SQLOrder(IndexKey(1)))
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQry)), "TRB", .T., .F. )
	
	TCSetField("TRB","Z1_DATENT","D",8,0)
	
	dbGoTop()
	While !Eof()
		
		SZ1->(dbGoTo(TRB->Z1_RECNO))
		
		RecLock("TMP",.T.)
		For nX:=1 To TMP->(FCount())
			If (nPos := SZ1->(FieldPos( TMP->(FieldName(nX)) ))) > 0
				FieldPut( nX , SZ1->(FieldGet( nPos )) )
			Endif
		Next

		TMP->C6_QTDLIB := 0
		
		// Caso o item já tenha ocorrência de marcacação, soma todas as marcações
		For nX:=1 To Len(aMark)
			If aMark[nX,1]+DtoS(aMark[nX,2])+aMark[nX,3]+aMark[nX,5]+aMark[nX,6]+aMark[nX,10] == cProduto+DtoS(TMP->Z1_DATENT)+TMP->Z1_HORENT+TMP->Z1_SETENT+TMP->Z1_KANBAN+TMP->Z1_NUM
				TMP->C6_QTDLIB += aMark[nX,8]

				// Caso o item já tenha sido marcado, deixa o mesmo selecionado
				If aMark[nX,9] == cOrigem
					TMP->Z1_OK := cMarca
					nTotal += aMark[nX,8]
				Endif
			Endif
		Next
		
		TMP->B2_QATU  := TMP->Z1_QUANT - TMP->Z1_QTDENT - TMP->C6_QTDLIB
		TMP->Z1_LOCAL := cOrigem
		
		MsUnLock()
		
		dbSelectArea("TRB")
		dbSkip()
	Enddo
	dbCloseArea()
	RestArea(aArea)
	
	TMP->(dbGoTop())
	
	If !( TMP->(Bof()) .And. TMP->(Eof()) )
		Seleciona(aHeadCpo,cMarca,cProduto,nQtdDig,cOrigem)
	Else
		MsgAlert("Não existem registros para faturamento !")
	Endif
	
	TMP->(dbCloseArea())
	FErase(cArq+GetDBExtension())
	
Return nTotal

Static Function Seleciona(aHeadCpo,cMarca,cProduto,nQtdDig,cOrigem)
	Local oDlg, oPanelT, oFonte, oBold
	Local lMarcado := (nTotal > 0)
	Local aCores   := {	{"(TMP->Z1_QTDENT+TMP->C6_QTDLIB) == 0","ENABLE"},;
								{"(TMP->Z1_QTDENT+TMP->C6_QTDLIB) > 0 .AND. (TMP->Z1_QTDENT+TMP->C6_QTDLIB) < TMP->Z1_QUANT","BR_AMARELO"},;
								{"(TMP->Z1_QTDENT+TMP->C6_QTDLIB) >= TMP->Z1_QUANT","DISABLE"}}
	Local nOpcA    := 0
	Local aBackup  := aClone(aMark)
	Local aBkpEnt  := aClone(aEntregas)
	Local nLin     := 5
	
	Private oMark, oTot
	Private nSaldo := nQtdDig - nTotal
	
	oFonte := TFont():New("Arial",10,18,.T.,.F.)
	DEFINE FONT oBold   NAME "Arial" SIZE 0, -13 BOLD
	
	DEFINE MSDIALOG oDlg TITLE "Seleciona Kanban" From 0,0 TO 35,134 OF oMainWnd
	
	@ 0,0 MSPANEL oPanelT PROMPT "" SIZE 10,234 OF oDlg CENTERED LOWERED //"Botoes"
	oPanelT:Align := CONTROL_ALIGN_BOTTOM
	
	@ nLin,05 SAY Trim(cProduto) + " - " + Posicione("SB1",1,XFILIAL("SB1")+cProduto,"B1_DESC") SIZE 400,10 COLOR CLR_HRED FONT oFonte PIXEL OF oPanelT
	nLin += 15
	
	oMark := MsSelect():New( "TMP", "Z1_OK","",aHeadCpo,, @cMarca, { nLin, 05, 215, 525 } ,,, oPanelT,,aCores)
	
	oMark:oBrowse:Refresh()
	oMark:bAval               := {|| Marcar(cMarca,cProduto,cOrigem), oMark:oBrowse:Refresh(), lMarcado := (nTotal > 0), oTot:Refresh() }
	
	oMark:oBrowse:lHasMark    := .T.
	oMark:oBrowse:lCanAllMark := .F.
	oMark:oBrowse:bAllMark    := {|| lMarcado:=!lMarcado,;
												nRecno:=TMP->(Recno()),;
												TMP->(dbGoTop()),;
												dbEval({|| Marcar(cMarca,cProduto,cOrigem,lMarcado) },,{|| (!lMarcado .Or. nSaldo > 0) .And. !TMP->(Eof()) }),;
												TMP->(dbGoTo(nRecno)),;
												oTot:Refresh(),;
												oMark:oBrowse:Refresh() }
	
	oMark:oBrowse:SetFocus()
	
	@ 220,05 SAY "Quantidade selecionada" COLOR CLR_HRED FONT oBold PIXEL OF oPanelT
	@ 220,95 SAY oTot VAR nTotal Picture "@E 999,999,999.99" COLOR CLR_HRED FONT oBold PIXEL OF oPanelT
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
														{||If( nSaldo < 0 , Aviso( "INVÁLIDO", "Quantidade selecionada não pode ser maior que a quantidade informada !", {"Ok"} ),;
															If( nTotal < nQtdDig , Aviso( "INVÁLIDO", "Favor selecionar toda a quantidade informada !", {"Ok"} ), (nOpcA:=1, oDlg:End()))) },;
														{||nOpcA:=0,oDlg:End()},, )
	
	// Caso tenha cancelado a tela
	If nOpcA <> 1
		nTotal := 0
		
		// Volta as marcações anteriores
		aSize(aMark,0)
		aEval( aBackup , {|x| AAdd(aMark,aClone(x)) } )
		
		oLbx:Refresh()

		aEntregas := aClone(aBkpEnt)
	Endif
	
Return

Static Function Marcar(cMarca,cProduto,cOrigem,lMarcado)
	Local nTam, nX, nEnt, nI
	Local cChave  := M->Z1_CLIENTE+M->Z1_LOJA+cProduto+DtoS(M->Z1_DATENT)
	Local nQtdLib := nSaldo
	
	If lMarcado <> Nil
		// Não processa registros com status igual a marcação
		If (lMarcado .And. TMP->Z1_OK == cMarca) .Or. (!lMarcado .And. TMP->Z1_OK <> cMarca)
			Return
		Endif
	Endif
	
	If TMP->Z1_OK <> cMarca .And. nSaldo == 0
		Aviso( "INVÁLIDO", "Quantidade ultrapassa o total informado no Kanban !", {"Ok"} )
		Return
	Endif
	
	// Identifica se existe programação para o dia que atenda o faturamento
	nEnt := AScan( aEntregas , {|x| x[1]+DtoS(x[2]) == cProduto+DtoS(M->Z1_DATENT) } )
	If nEnt == 0
		// Pesquisa se tem alguma entrega programada para o horário
		SZ2->(dbSetOrder(1))    // Z2_FILIAL+Z2_CLIENTE+Z2_LOJA+Z2_PRODUTO+DTOS(Z2_DATENT)+Z2_HORENT+Z2_SETENT 
		SZ2->(dbSeek(XFILIAL("SZ2")+cChave,.T.))
		While !SZ2->(Eof()) .And. XFILIAL("SZ2")+cChave == SZ2->Z2_FILIAL+SZ2->Z2_CLIENTE+SZ2->Z2_LOJA+SZ2->Z2_PRODUTO+DTOS(SZ2->Z2_DATENT)
			If SZ2->Z2_QTDENT < (SZ2->Z2_QUANT + SZ2->Z2_QTDPED)    // Adiciona somente os registros com saldo
				AAdd( aEntregas , { SZ2->Z2_PRODUTO, SZ2->Z2_DATENT, SZ2->Z2_HORENT, SZ2->Z2_SETENT, (SZ2->Z2_QUANT + SZ2->Z2_QTDPED) - SZ2->Z2_QTDENT, 0, {}} )
			Endif
			SZ2->(dbSkip())
		Enddo
	Endif
	
	If TMP->Z1_OK == cMarca   // Caso esteja desmarcando o item
		//nEnt := AScan( aEntregas , {|x| x[1]+DtoS(x[2]) == cProduto+DtoS(M->Z1_DATENT) .And. x[6] > 0 } )    // Pesquisa o 1o item com quantidade usada
	Else
		/*nEnt := AScan( aEntregas , {|x| x[1]+DtoS(x[2]) == cProduto+DtoS(M->Z1_DATENT) .And. (x[5]-x[6]) > 0 } )    // Pesquisa o 1o item com saldo
		
		If nEnt == 0 .Or. TMP->C6_QTDLIB > (aEntregas[nEnt,5]+Marcados(aEntregas[nEnt,7]))
			Aviso( "INVÁLIDO", "Não existe programação de Kanban para o dia/hora para o produto !", {"Ok"} )
			Return
		Endif*/
	Endif
	
	nTam := PesqRegistro(cProduto+DtoS(TMP->Z1_DATENT)+TMP->Z1_HORENT+TMP->Z1_SETENT+TMP->Z1_KANBAN+TMP->Z1_NUM,cOrigem)

	// Se está vindo marcado então o usuário está desmarcando
	If TMP->Z1_OK == cMarca
		nQtdLib := If( nTam > 0 , -aMark[nTam,8], 0)
	Else
		nQtdLib := Min(nSaldo,TMP->Z1_QUANT - TMP->Z1_QTDENT - TMP->C6_QTDLIB)
		
		If !SalvaEntregas(cProduto,nQtdLib,cOrigem)    // Salva as entregas para a marcação
			Return
		Endif
	Endif
	
	RecLock("TMP",.F.)
	TMP->Z1_OK     := If( lMarcado == Nil , If( TMP->Z1_OK <> cMarca , cMarca, Space(Len(TMP->Z1_OK))), If( lMarcado , cMarca, Space(Len(TMP->Z1_OK))))
	TMP->C6_QTDLIB += nQtdLib
	TMP->B2_QATU   := TMP->Z1_QUANT - TMP->Z1_QTDENT - TMP->C6_QTDLIB
	MsUnLock()
	
	If Empty(TMP->Z1_OK)   // Se desmarcou o item então apaga do array de itens marcados
		If nTam > 0
			aDel(aMark,nTam)
			aSize(aMark,Len(aMark)-1)
			
			CriaaMark()   // Caso o vetor esteja vazio, adiciona uma linha pelo menos
		Endif
		
		// Exclui o item da marcação
		For nI:=1 To Len(aEntregas)
			For nX:=1 To Len(aEntregas[nI,7])
				If aEntregas[nI,7][nX,1] == TMP->Z1_NUM  .And. aEntregas[nI,7][nX,2] == cOrigem //.And. aEntregas[nI,7][nX,3] == TMP->C6_QTDLIB
					aEntregas[nI,6] :=  Max(0,aEntregas[nI,6] - aEntregas[nI,7][nX,3])          // Recompõe a quantidade necessária
					
					aDel( aEntregas[nI,7] , nX )
					aSize( aEntregas[nI,7] , Len(aEntregas[nI,7]) - 1)
					Exit
				Endif
			Next
		Next
	Else
		If nTam == 0
			// Caso tenha mais de um item ou já exista um item preenchido, então adiciona uma linha.
			// Caso contrário aproveita a linha existente
			If Len(aMark) > 1 .Or. !Empty(aMark[1,1])
				AAdd( aMark , )
			Endif
			nTam := Len(aMark)
		Endif
		
		aMark[nTam] := {}
		AAdd( aMark[nTam] , cProduto )
		
		For nX:=2 To Len(aHeaKan)
			AAdd( aMark[nTam] , TMP->&( aHeaKan[nX,2] ) )
		Next

		aMark[nTam,8] := nQtdLib
	Endif
	
	oLbx:Refresh()
	
	nTotal += nQtdLib
	nSaldo -= nQtdLib
	
Return

Static Function SalvaEntregas(cProduto,nQtdLib,cOrigem)
	Local nQtdFat := 0
	Local nQtdAux := nQtdLib
	Local nEnt    := 0
		
	While nQtdAux > 0 .And. (nEnt := AScan( aEntregas , {|x| x[1]+DtoS(x[2]) == cProduto+DtoS(M->Z1_DATENT) .And. (x[5]-x[6]) > 0 } )) > 0    // Pesquisa o 1o item com saldo
		
		If TMP->C6_QTDLIB > (aEntregas[nEnt,5]+Marcados(aEntregas[nEnt,7]))
			Exit
		Endif
		
		nQtdFat := Min(nQtdAux , aEntregas[nEnt,5] - aEntregas[nEnt,6])
		
		AAdd( aEntregas[nEnt,7] , { TMP->Z1_NUM, cOrigem, nQtdFat} )    // Adiciona os Kanbans faturados com o horário
		aEntregas[nEnt,6] += nQtdFat
		
		nQtdAux -= nQtdFat
	Enddo

	If nQtdAux > 0
		Aviso( "INVÁLIDO", "Não existe programação de Kanban para o dia/hora para o produto !", {"Ok"} )
		Return .F.
	Endif
	
Return .T.

Static Function PesqRegistro(cSeek,cOrigem)
Return ASCan( aMark , {|x| x[1]+DtoS(x[2])+x[3]+x[5]+x[6]+x[10] == cSeek .And. (cOrigem == Nil .Or. x[9] == cOrigem) } )

Static Function Marcados(aMarks)
	Local nRet := 0
	aEval( aMarks , {|x| nRet += x[3] })
Return nRet

Static Function CriaaMark()
	// Caso o vetor esteja vazio, adiciona uma linha pelo menos
	If Empty(aMark)
		AAdd( aMark , {} )
		aEval( aHeaKan , {|x| AAdd( aMark[1] , CriaVar(x[2]) ) } )
	Endif
Return

//Static Function ExibeBloqueio(aPvlNfs,aBloqueio)
//	Local oDlg, oBlq, oPanelT
//	Local oOk    := LoadBitmap( GetResources(), "BR_VERDE" )
//	Local oEst   := LoadBitmap( GetResources(), "BR_PRETO" )
//	Local oCrd   := LoadBitmap( GetResources(), "BR_AZUL"  )
//	Local oOut   := LoadBitmap( GetResources(), "BR_VERMELHO"  )
//	Local aItens := {}
//	Local nOpcA  := 0
//	
//	aEval( aPvlNfs   , {|x| AAdd( aItens , { "  ", x[2], x[6], Posicione("SB1",1,XFILIAL("SB1")+x[6],"B1_DESC"), x[15], TransForm(x[4],X3Picture("C9_QTDLIB"))} ) } )
//	aEval( aBloqueio , {|x| AAdd( aItens , { If(!Empty(x[6]) , x[6], If(!Empty(x[7]) , x[7], x[8])),;
//															x[2], x[4], Posicione("SB1",1,XFILIAL("SB1")+x[4],"B1_DESC"),;
//															Posicione("SC9",1,XFILIAL("SC9")+x[1]+x[2],"C9_LOCAL"), x[5]} ) } )
//	
//	ASort( aItens ,,, {|x,y| x[2] < y[2] } )
//	
//	DEFINE MSDIALOG oDlg TITLE "Status de Liberações" From 0,0 TO 30,84 OF oMainWnd
//	
//	@ 0,0 MSPANEL oPanelT PROMPT "" SIZE 10,198 OF oDlg CENTERED LOWERED //"Botoes"
//	oPanelT:Align := CONTROL_ALIGN_BOTTOM
//	
//	oBlq := TWBrowse():New(05,05,320,185,/*Flds*/,{"","Item","Produto","Descrição","Almoxarifado","Quantidade"}, /*aColsSizes*/,oPanelT,,,,/*Change*/,/*DblClick*/,,,,,,,,,.T.,,,,,)
//	
//	oBlq:SetArray( aItens )
//	oBlq:bLine := {|| {If( aItens[oBlq:nAt,1]=="  ",oOk,If( aItens[oBlq:nAt,1]=="02",oEst,If( aItens[oBlq:nAt,1]=="05",oCrd,oOut))),;
//							aItens[oBlq:nAt,2],;
//							aItens[oBlq:nAt,3],;
//							aItens[oBlq:nAt,4],;
//							aItens[oBlq:nAt,5],;
//							aItens[oBlq:nAt,6]} }
//	
//	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nOpcA:=1, oDlg:End() }, {|| oDlg:End() } )
//	
//Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FATALinOk  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/11/2018 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar a linha do item                                       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FATALinOk(nPos)
	Local nX
	Local nPEnt := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_DATENT" } )
	
	nPos := If( nPos == Nil , n, nPos)
	
	If !aCols[nPos,Len(aCols[nPos])] .And. nPEnt > 0 .And. !Empty(aCols[nPos,nPEnt])   // Caso tenha sido definido um item
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
¦¦¦ Função    ¦ FATATudOk  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/11/2018 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar todas as linhas dos itens                             ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FATATudOk(lFaturar,nOpc,lKanban)
	Local nX
	Local nDel := Len(aCols[1])
	Local nHor := AScan( aHeader , {|x| Trim(x[2]) == "Z1_HORENT" } )
	Local nCnt := 0
	Local lRet := .T.

	If lFaturar .And. Len(aCols) == 1 .And. Empty(aCols[1,1])
		Return u_STMonitorProcesso()
	Endif
	
	For nX:=1 To Len(aCols)
		If !(lRet := FATALinOk(nX))
			Exit
		Endif
	Next
	
	If lRet
		If lFaturar
			// Conta o número de itens deletados
			aEval( aCols , {|x| nCnt += If( x[nDel] , 1, 0) } )
			
			If lRet := (nCnt <> Len(aCols))
				lRet := u_STMonitorProcesso()
			Else
				Aviso( "INVÁLIDO", "Favor adicionar pelo menos um item válido ao faturar !", {"Ok"} )
			Endif
		ElseIf !Empty(M->Z1_HORENT) .Or. AScan( aCols , {|x| !x[nDel] .And. !Empty(x[nHor])} ) > 0
			If M->Z1_ATUKANB == "1"
				lKanban := (nOpc > 4 .Or. MsgYesNo("<strong><font face='Arial' size=3 color=RED>Deseja atualizar esse pedido no Kanban ?</font></strong>","Pedido no Kanban") )
			Endif
		Endif
	Endif
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FATADelIt  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Validar delecao dos itens                                     ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FATADelIt()
	Local nPQtd, nPPrd, nPLoc
	Local nDel := Len(aCols[1])
	Local lRet := .T.
	
	If lRet .And. nPD == 1
		If aCols[n,nDel] // Na recuperacao da linha - 1a. passagem
			nPPrd := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_PRODUTO" } )
			nPLoc := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_LOCAL"   } )

			lRet := JaExiste(aCols[n,nPPrd]+aCols[n,nPLoc],aCols,{nPPrd,nPLoc})
		ElseIf Inclui .Or. Altera
			nPQtd := AScan( aHeader , {|x| Trim(x[2]) == "Z1_QTDENT" } )
			If aCols[n,nPQtd] > 0
				If lRet := MsgYesNo("Todos os itens selecionados serão excluídos, confirma exclusão do item ?","EXCLUSÃO")
					ApagaTudo()
					aCols[n,nPQtd] := 0
					oLbx:Refresh()
				Endif
			Endif
		Endif
	Endif
	
	nPD := If( nPD > 1 , 1, 2)
	
Return lRet

Static Function ApagaTudo()
	Local nPos
	Local nPPrd := AScan( aHeader , {|x| Trim(x[2]) == "Z1_PRODUTO" } )
	
	While (nPos := ASCan( aMark , {|x| x[1]+DtoS(x[2]) == aCols[n,nPPrd]+DtoS(M->Z1_DATENT) } )) > 0
		aDel(aMark,nPos)
		aSize(aMark,Len(aMark)-1)
	Enddo
	
	CriaaMark()
	
Return 

Static Function JaExiste(cBusca,aCols,aChaves)
	Local nX, cChave
	Local nDel := Len(aCols[1])
	Local lRet := .T.

	Default aChaves := {1}
	
	For nX:=1 To Len(aCols)
		If nX <> n .And. !aCols[nX,nDel]
			// Monta a chave de pesquisa
			cChave := ""
			aEval( aChaves , {|x| cChave += aCols[nX,x] })

			If cBusca == cChave
				lRet := ExistChav("SX5","00")
				Exit
			Endif
		Endif
	Next
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ CriaHeader ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 28/09/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria a variavel vetor aHeader                                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CriaHeader()
	Local nX, nPos
	
	For nX:=1 To Len(aCampos)
		If AScan( aFields , aCampos[nX] ) > 0
			nPos := AdicionaCampo(aCampos[nX],@aHeader)
			aHeader[nPos,6] := "u_FATAValid()"
		Endif
	Next

Return Len(aHeader)

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ aColsBlank ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 28/09/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria array de itens em branco                                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function aColsBlank(aArray)
	Local nX
	Local nTam   := Len(aArray ) + 1
	Local nUsado := Len(aHeader)
	
	aAdd(aArray,Array(nUsado+1))
	aArray[nTam][nUsado+1] := .F.
	
	For nX:=1 To Len(aCampos)
		If AScan( aFields , aCampos[nX] ) > 0
			aArray[nTam][nX] := CriaVar(aCampos[nX],.T.)
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
¦¦¦ Função    ¦ FAT01CpoAlt¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 01/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Habilita a leitura dos campos conforme condição               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FAT01CpoAlt(oGet)
	Local nPQtd := AScan( aHeader , {|x| Trim(x[2]) == "Z1_QTDENT" } )
	Local aVar  := {}
	
	oGet:aAlter := {}
	oGet:oMother:aAlter := {}
	
	If aCols[oGet:nAt,nPQtd] > 0    // Se já foi informada a quantidade, não permite alterar o produto
		aVar := { "Z1_QTDENT" }
	Else
		aVar := { "Z1_PRODUTO", "Z1_QTDENT", "Z1_LOCAL"}
	Endif
	
	oGet:aAlter := aVar
	oGet:oMother:aAlter := aVar
	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FAT01Grava ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 27/09/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Grava os dados do Kanban                                      ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦ Parâmetro ¦ nOpc     -> Tipo da função (inclui,altera,exclui)             ¦¦¦
|¦¦           ¦ nRecNo   -> Numero do registro a ser gravado                  ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function FAT01Grava(nOpc,nRecNo,aAltera,lKanban)
	Local nX
	Local nPDel := Len(aCols[1])
	
	For nX:=1 To Len(aCols)
		
		If nX <= Len(aAltera)
			(cAlias1)->(dbGoTo(aAltera[nX]))   // Posiciona no registro
		Endif
		
		GravaItem(nX,nX>Len(aAltera),nOpc == 5 .Or. aCols[nX,nPDel],lKanban)
	Next
	
Return

Static Function GravaItem(nX,lNovo,lDel,lKanban)
	Local nY, cChave, cHora
	Local nPEnt := ASCan( aHeader , {|x| Trim(x[2]) == "Z1_DATENT" } )
	
	If !(lNovo .And. lDel)   // Se não for um novo registro deletado
		// Grava os dados dos itens da tela
		RecLock(cAlias1,lNovo)
		If lDel
			cHora  := If( Empty((cAlias1)->Z1_HORENT), PADR("0800",Len((cAlias1)->Z1_HORENT)), (cAlias1)->Z1_HORENT)
			cChave := (cAlias1)->Z1_CLIENTE+(cAlias1)->Z1_LOJA+(cAlias1)->Z1_PRODUTO+DTOS((cAlias1)->Z1_DATENT)+cHora+(cAlias1)->Z1_SETENT
			dbDelete()
		Else
			// Grava o cabeçalho
			For nY := 1 To Len(aAcho)
				If FieldPos(aAcho[nY]) > 0
					FieldPut(FieldPos(aAcho[nY]),M->&(aAcho[nY]))
				Endif
			Next
			// Grava os itens
			If !Empty(aCols[nX,nPEnt])   // Caso tenha sido definido um item
				For nY := 1 To Len(aHeader)
					FieldPut(FieldPos(Trim(aHeader[nY,2])),aCols[nX,nY])
				Next nY
			Endif
			(cAlias1)->Z1_FILIAL  := XFILIAL(cAlias1)
			(cAlias1)->Z1_ATUKANB := If( lKanban , "1", "2")
		Endif
		MsUnLock()
		
		If lKanban
			u_STGravaKanban(.T.,lDel,cChave)
		Endif
	Endif
	
Return

User Function STGravaKanban(lAdiciona,lDel,cKey)
	Local nX, cNome, nPos
	Local cAlias1 := "SZ1"
	Local cAlias2 := "SZ2"
	Local cHora   := If( Empty((cAlias1)->Z1_HORENT), PADR("0800",Len((cAlias1)->Z1_HORENT)), (cAlias1)->Z1_HORENT)
	Local cChave  := If( lDel == Nil .Or. !lDel , (cAlias1)->Z1_CLIENTE+(cAlias1)->Z1_LOJA+(cAlias1)->Z1_PRODUTO+DTOS((cAlias1)->Z1_DATENT)+cHora+(cAlias1)->Z1_SETENT, cKey)
	Local aSoma   := If( lDel == Nil .Or. !lDel , SomaKanban(lAdiciona), {0,0})
	
	Default lDel      := .F.
	Default lAdiciona := .F.
	
	(cAlias2)->(dbSetOrder(1))
	If (cAlias2)->(dbSeek(XFILIAL(cAlias2)+cChave))
		RecLock(cAlias2,.F.)
		
		If lDel    // Se for exclusão
			dbDelete()
		Else
			(cAlias2)->Z2_QTDPED := aSoma[1]
			//(cAlias2)->Z2_QTDENT := aSoma[2]
			
			If (SZ2->Z2_QUANT + SZ2->Z2_QTDPED) <= 0 .And. (cAlias2)->Z2_QTDENT <= 0    // Exclui registro caso não tenha quantidades válidas
				dbDelete()
			Endif
		Endif
		MsUnLock()
	ElseIf lAdiciona .And. !lDel .And. aSoma[1] > 0    // Se não for exclusão e tiver quantidade válida
		RecLock(cAlias2,.T.)
		For nX:=1 To (cAlias2)->(FCount())
			cNome := StrTran((cAlias2)->(FieldName(nX)),"Z2_","Z1_")
			If (nPos := (cAlias1)->(FieldPos(cNome))) > 0
				FieldPut( nX , (cAlias1)->(FieldGet(nPos)) )
			Endif
		Next
		(cAlias2)->Z2_FILIAL := XFILIAL(cAlias2)
		(cAlias2)->Z2_HORENT := If( Empty((cAlias2)->Z2_HORENT) , "0800", (cAlias2)->Z2_HORENT)
		(cAlias2)->Z2_QTDPED := aSoma[1]
		(cAlias2)->Z2_QUANT  := 0
		MsUnLock()
	Endif

Return

Static Function SomaKanban(lAdiciona)
	Local cKey := SZ1->Z1_FILIAL+SZ1->Z1_CLIENTE+SZ1->Z1_LOJA+SZ1->Z1_PRODUTO+DTOS(SZ1->Z1_DATENT)+SZ1->Z1_HORENT+SZ1->Z1_SETENT
	Local nInd := SZ1->(IndexOrd())
	Local nReg := SZ1->(Recno())
	Local nQtd := 0
	Local nEnt := 0
	
	SZ1->(dbSetOrder(2))
	SZ1->(dbGoTop())
	SZ1->(dbSeek(cKey,.T.))
	While !SZ1->(Eof()) .And. SZ1->Z1_FILIAL+SZ1->Z1_CLIENTE+SZ1->Z1_LOJA+SZ1->Z1_PRODUTO+DTOS(SZ1->Z1_DATENT)+SZ1->Z1_HORENT+SZ1->Z1_SETENT == cKey
		nQtd += If( SZ1->Z1_ATUKANB == "1" .Or. !lAdiciona , SZ1->Z1_QUANT, 0)
		nEnt += SZ1->Z1_QTDENT
		SZ1->(dbSkip())
	Enddo
	SZ1->(dbSetOrder(nInd))
	SZ1->(dbGoTo(nReg))

Return { nQtd, nEnt}

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ STVldCliFor¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 22/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Valida o cliente e fornecedor da transferência                ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function STVldCliFor(cAlias,cCodFil)
	Local nPos, cSeek, cInscr
	Local aAreaSM0 := SM0->(GetArea())
	Local cCmpFil  := SubStr(cAlias,2,2) + "_FILIAL"
	Local cCmpCGC  := SubStr(cAlias,2,2) + "_CGC"
	Local cCmpIns  := SubStr(cAlias,2,2) + "_INSCR"
	Local cCmpCod  := SubStr(cAlias,2,2) + "_COD"
	Local lRet     := .F.
	
	If Type("aFiliais") == "U"  // Caso não tenha carregado as filiais
		aFiliais := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega filiais da empresa corrente                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SM0")
		dbSeek(cEmpAnt)
		While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
			// Adiciona filial
			If Type("aParam310") == "U" .Or. SM0->M0_CODFIL >= aParam310[03] .And. SM0->M0_CODFIL <= aParam310[04]
				Aadd( aFiliais , { AllTrim(SM0->M0_CODFIL), SM0->M0_CODIGO, SM0->M0_CGC, SM0->M0_INSC, SM0->M0_FILIAL})
			EndIf
			dbSkip()
		Enddo
		RestArea(aAreaSM0)
	Endif
	
	nPos := AScan( aFiliais , {|x| x[1] == cCodFil } )
	
	If lRet := ( nPos > 0 )
		(cAlias)->(dbSetOrder(3))
		
		cSeek := xFilial(cAlias) + Padr( aFiliais[nPos,3],TAMSX3("A1_CGC")[01] )
		
		If lRet := (cAlias)->(dbSeek( cSeek ))
			cInscr := Padr( aFiliais[nPos,4],TAMSX3("A1_INSCR")[01] )
			While !(cAlias)->(Eof()) .And. cSeek == (cAlias)->( &(cCmpFil) + &(cCmpCGC) )
				If lRet := ( AllTrim(cInscr) == AllTrim((cAlias)->&(cCmpIns)) .And. Alltrim(SuperGetMv("MV_XCLIDEP",.F.,"")) != (cAlias)->&(cCmpCod) )
					Exit
				EndIf
				(cAlias)->(dbSkip())
			EndDo
		Endif
	Endif
	
	If !lRet
		If cAlias == "SA1"
			// Nao existem dados da filial destino cadastrados como cliente na filial origem. A transferencia nao sera realizada
			Help(" ",1,"A310DATFL1")
		Else
			// Nao existem dados da filial origem cadastrados como fornecedor na filial destino. A transferencia nao sera realizada
			Help(" ",1,"A310DATFL2")
		Endif
	EndIf
	
Return lRet

Static Function ItensRetorno(aItens)
	Local nX, cPedido, nPPrd, nPQtd, nPPed, nPLin
	Local aPA := {}
	Local aMP := {}
	
	SF4->(dbSetOrder(1))
	
	For nX:=1 To Len(aItens)
		nPTES := AScan( aItens[nX] , {|x| x[1] == "C6_TES"     } )
		
		SF4->(dbSeek(XFILIAL("SF4")+aItens[nX][nPTES,2]))
		
		If SF4->F4_XRETREM == "1" .And. SF4->F4_PODER3 == "N"
			nPPrd := AScan( aItens[nX] , {|x| x[1] == "C6_PRODUTO" } )
			nPQtd := AScan( aItens[nX] , {|x| x[1] == "C6_QTDVEN"  } )
			nPPed := AScan( aItens[nX] , {|x| x[1] == "C6_PEDCLI"  } )
			nPLin := AScan( aItens[nX] , {|x| x[1] == "C6_XLINPED" } )
			
			cPedido := aItens[nX][nPPed][2]
			AAdd( aPA , { aItens[nX][nPPrd][2], aItens[nX][nPQtd][2], cPedido, aItens[nX][nPLin][2]})
		Endif
	Next
	
	If !Empty(aPA)
		u_STFATE01(,,aPA,cPedido,@aMP)
	Endif

Return aMP

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ FATLegenda ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 31/10/2018 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Legenda do Kanban                                             ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FATLegenda( cAlias, nRecNo, nOpc )
	BRWLEGENDA(cCadastro,"Legenda - Cadastro de Kanban",;
								{{"ENABLE"    ,"Aberta"  },;
								{"BR_AMARELO","Parcial" },;
								{"DISABLE"   ,"Fechada"}})
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ PosObjetos ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 31/10/2018 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Inicializa as dimensões da tela para posicionar os objetos    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function PosObjetos(aSize,aPosObj,aPosFol,lFatura)
	Local aInfo1, aInfo2
	Local aObjects := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	
	// Divide a tela para os objetos ENCHOICE e FOLDER
	AAdd( aObjects, { 100, 100, .t., .t. } )    // ENCHOICE
	AAdd( aObjects, { 100,  90, .t., .t. } )    // FOLDER
	AAdd( aObjects, { 100,  10, .t., .f. } )    // RODAPÉ
	
	// Calcula as coordenadas no MSDIALOG para os objetos (ENCHOICE e FOLDER)
	aInfo1  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo1, aObjects )
	
	// Calcula as coordenadas para o objeto FOLDER
	aInfo2 := { 0, aPosObj[2,2], If(lFatura,aPosObj[2,4],550)-aPosObj[2,2]-aInfo1[1], aPosObj[2,3]-aPosObj[2,1], 3, 3 }
	
	aObjects := {}
	AAdd( aObjects , { 100, 100, .t., .t.} )
	
	aPosFol := MsObjSize( aInfo2, aObjects, .T. )
	
Return

/*Static Function LeCoord()
	Local nHdl, nX
	Local cFile := "D:\TOTVS\COORD.TXT"
	Local aRet  := {}
	
	If File(cFile)
		nHdl := FT_FUSE(cFile)
		FT_FGOTOP()
		aRet := Separa(AllTrim(FT_FREADLN()),",",.F.)
		For nX:=1 To Len(aRet)
			aRet[nX] := Val(aRet[nX])
		Next
		FT_FUSE()
	Endif
	
Return aRet*/
