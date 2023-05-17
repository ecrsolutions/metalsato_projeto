#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATP03   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 23/01/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Controle de Canhotos                                          ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATP03()
	While LeSaida()
	Enddo
Return

Static Function LeSaida()
	Local oDlg, cVar
	Local oMainWnd := Nil
	Local oFont1   := TFont():New("Courier New", 8.5,15,.T.,.T.,,,15)
	Local oFont2   := TFont():New("Courier New", 7.5,15,.T.,.T.,,,15)
	Local nOpcA    := 0
	
	Private cCadastro := "Controle de Canhotos"
	Private aRotina   := {	{"Pesquisar" ,"AxPesqui",0,1} ,;
							{"Visualizar","AxVisual",0,2} }
	
	Private oLbx, oChave, oCli
	Private cChave := Space(Len(SF2->F2_DOC)+1)
	Private vItens := {}
	Private cSeek  := ""

	AAdd( vItens , { CriaVar("F2_DOC",.F.), CriaVar("F2_SERIE",.F.), CriaVar("F2_CHVNFE",.F.)} )

	SF2->(dbGoTop())
	SF2->(dbSkip())
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 TO 34,120 OF oMainWnd
	
	@ 0,0 MSPANEL oPanelT PROMPT "" SIZE 10,227 OF oDlg CENTERED LOWERED //"Botoes"
	oPanelT:Align := CONTROL_ALIGN_BOTTOM
	
	@ 005,005 SAY "Nota"                       SIZE 40,10 PIXEL OF oPanelT FONT oFont2 COLOR CLR_HBLUE
	@ 006,035 MSGET oChave   VAR cChave  Picture "@!" F3 VALID BuscaNota() SIZE 60,10 PIXEL OF oPanelT FONT oFont2 //WHEN lLePedido
	
	@ 025,005 LISTBOX oLbx VAR cVar FIELDS HEADER 	"Nota",;
													"Série",;
													"Chave" SIZE 468,180 OF oPanelT PIXEL FONT oFont1
	
	oLbx:SetArray( vItens )
	
	oLbx:bLine := {|| { vItens[oLbx:nAt,1],;
						vItens[oLbx:nAt,2],;
						vItens[oLbx:nAt,3] } }
	
	@ 212,005 SAY oCli VAR cSeek PIXEL OF oPanelT FONT oFont2 COLOR CLR_HBLUE
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nOpcA:=1, If(nOpcA==1,oDlg:End(),) },{||oDlg:End()})
	
	If nOpcA == 1
		If GravaTudo(vItens)
			MsgInfo("Gravação concluída com sucesso !","Canhotos")
		Endif
	Endif
	
Return nOpcA == 1

Static Function BuscaNota()
	Local lRet := .T.
	
	If Empty(cChave)
		Return lRet
	Endif
	
	SF2->(dbSetOrder(1))
	If lRet := SF2->(dbSeek(XFILIAL("SF2")+PADR(cChave,Len(SF2->F2_DOC))))
		If lRet := (AScan( vItens , {|x| x[1]+x[2] == SF2->F2_DOC+SF2->F2_SERIE }) == 0)
			If lRet := Empty(SF2->F2_XDATREC)
				
				If Len(vItens) == 1 .And. Empty(vItens[1,1])
					ASize(vItens,0)
				Endif
				
				AAdd( vItens , { SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CHVNFE} )
				
				oLbx:Refresh()
				
				cChave := Space(Len(cChave))
				oChave:SetFocus()
				oChave:Refresh()

				cSeek := "Cliente: " + Posicione("SA1",1,XFILIAL("SA1")+SF2->F2_DOC+SF2->F2_SERIE,"A1_NOME")
				oCli:Refresh()
			Else
				Alert("Nota Fiscal informada já foi recebida em "+DtoC(SF2->F2_XDATREC)+" !")
			Endif
		Else
			Alert("Essa nota já foi adicionada para recebimento !")
		Endif
	Else
		Alert("Nota Fiscal informada não existe no sistema !")
	Endif
	
Return lRet

Static Function GravaTudo(vItens)
	Local nX
	
	SF2->(dbSetOrder(1))

	For nX:=1 To Len(vItens)
		If SF2->(dbSeek(XFILIAL("SF2")+vItens[nX,1]+vItens[nX,2]))
			RecLock("SF2",.F.)
			SF2->F2_XDATREC := dDataBase
			SF2->F2_XHORREC := Time()
			SF2->F2_XUSRREC := __cUserID
			MsUnLock()
		Endif
	Next

Return !Empty(vItens)

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