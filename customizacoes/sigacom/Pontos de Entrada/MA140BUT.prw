#Include "Protheus.ch"
#Include "Rwmake.ch"

/*_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Programa  ¦ MA140BUT   ¦ Autor ¦ Ronilton O. Barros     ¦ Data ¦ 11/01/2021 ¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada para adicionar botoes do usuario na EnchoiceBar¦¦¦
¦¦+-----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MA140BUT()
	Local aBotao := {} 
	
	SetKey( 11 ,  {|| u_STCompNFE() } )
	AAdd( aBotao , {"BPMSRECI",{|| u_STCompNFE() },"Compl.Pre-NF","Compl.Pre-NF"})

Return aBotao
  
User Function STCompNFE()
	Local oDlg, cNomeFor, oDtEmb, oPvChg, oTran, oNomT, oCond, oDesc, oGet, nHdl, nX
	Local nOpcA  := 0
	Local nLin   := 0
	Local aCabec := {}
	Local aParc  := {}
	//Local nPTES  := AScan( aHeader , {|x| Trim(x[2]) == "D1_TES"   } )
	//Local nPTot  := AScan( aHeader , {|x| Trim(x[2]) == "D1_TOTAL" } )
	Local nTotal := a140Total[3]
	Local cFile  := "\PRE" + Trim(cNFiscal) + Trim(cSerie) + "_" + Trim(cA100For) + Trim(cLoja) + ".txt"
	
	//If AScan( aCols , {|x| x[nPTot] == 0 } ) > 0   // Caso tenha algum valor zerado não exibe a tela
	//	Return
	//Endif
	
	//If nPTES == 0 .Or. AScan( aCols , {|x| Empty(x[nPTES]) } ) > 0   // Caso tenha algum TES vazio não exibe a tela
	//	Return
	//Endif
	
	//If AScan( aCols , {|x| Posicione("SF4",1,XFILIAL("SF4")+x[nPTES],"F4_DUPLIC") == "S" } ) == 0   // Caso NÃO tenha TES que atualize o Financeiro
	//	Return
	//Endif
	
	// Totaliza os itens que atualizam financeiro
	//aEval( aCols , {|x| nTotal += x[nPTot] } )
	//aEval( aCols , {|x| nTotal += If( Posicione("SF4",1,XFILIAL("SF4")+x[nPTES],"F4_DUPLIC") == "S" , x[nPTot], 0) } )
	
	ConfigCampo({"E2_VENCTO","E2_VALOR"},@aCabec)
	
	Private dF1_XDTEMB := CriaVar("F1_XDTEMB" ,.F.)
	Private dF1_XDTENT := CriaVar("F1_XDTENT" ,.F.)
	Private cF1_TRANSP := CriaVar("F1_TRANSP" ,.F.)
	Private cA4_NOME   := CriaVar("A4_NOME"   ,.F.)
	Private cF1_COND   := CriaVar("F1_COND"   ,.F.)
	Private cE4_DESCRI := CriaVar("E4_DESCRI" ,.F.)
	Private nSaldo     := nTotal
	Private oSaldo     := Nil
	
	// Carrega os dados já gravados caso existam
	If Empty( aParc := u_STCargaProvisao() )
		If Empty( aParc := ProvisaoGravada() )
			AAdd( aParc , { Ctod(""), 0, .F.} )
		Else
			//atualiza o saldo
			nSaldo := 0
		Endif
	Else
		//atualiza o saldo
		aEval( aParc , {|x| nSaldo -= x[2] })
	Endif
	
	If cTipo $ "DB"
		cNomeFor := Posicione('SA1',1,xFilial('SA1') + cA100For + cLoja , "A1_NOME" )
	Else
		cNomeFor := Posicione('SA2',1,xFilial('SA2') + cA100For + cLoja , "A2_NOME" )
	Endif
	//aCor := LeCoord()
	@ 000,000 TO 365,412 DIALOG oDlg TITLE "Complemento da Nota Fiscal"
	
	@ nLin,010 SAY "Documento : " + cNFiscal + '/' + cSerie PIXEL OF oDlg
	nLin += 10
	@ nLin,010 SAY "Fornecedor : " + cA100For + '/' + cLoja + ' - ' + cNomeFor PIXEL OF oDlg
	nLin += 15
	@ nLin,010 SAY "Data Embarque" PIXEL OF oDlg
	@ nLin,055 MSGET oDtEmb VAR dF1_XDTEMB  Picture "@!" VALID NaoVazio(dF1_XDTEMB) SIZE 40,7 PIXEL OF oDlg WHEN Inclui .Or. Altera
	@ nLin,115 SAY "Prev. Chegada" PIXEL OF oDlg
	@ nLin,160 MSGET oPvChg VAR dF1_XDTENT  Picture "@!" VALID NaoVazio(dF1_XDTENT) SIZE 40,7 PIXEL OF oDlg WHEN Inclui .Or. Altera
	nLin += 15
	@ nLin,010 SAY "Transportadora" PIXEL OF oDlg
	@ nLin,055 MSGET oTran  VAR cF1_TRANSP  Picture "@!" F3 "SA4" VALID ExistCpo("SA4",cF1_TRANSP) SIZE 40,7 PIXEL OF oDlg WHEN Inclui .Or. Altera
	oTran:bLostFocus := {|| cA4_NOME := Posicione("SA4",1,XFILIAL("SA4")+cF1_TRANSP,"A4_NOME") }
	@ nLin,100 MSGET oNomT  VAR cA4_NOME    Picture "@!" SIZE 100,7 PIXEL OF oDlg WHEN .F.
	nLin += 15
	@ nLin,010 SAY "Cond. Pagamento" PIXEL OF oDlg
	@ nLin,055 MSGET oCond VAR cF1_COND   Picture "@!" F3 "SE4" VALID ExistCpo("SE4",cF1_COND)  SIZE 20,7 PIXEL OF oDlg WHEN Inclui .Or. Altera
	oCond:bLostFocus := {|| CalculaParc(cF1_COND,nTotal,@aParc), oGet:aCols := aParc, oGet:Refresh(), cE4_DESCRI := Posicione("SE4",1,XFILIAL("SE4")+cF1_COND,"E4_DESCRI") }
	@ nLin,090 MSGET oDesc VAR cE4_DESCRI Picture "@!" SIZE 60,7 PIXEL OF oDlg WHEN .F.
	nLin += 15
	oGet := MsNewGetDados():New( nLin, 10, nLin+80, 200, GD_UPDATE,"AllwaysTrue","AllwaysTrue","",{"E2_VENCTO","E2_VALOR"},,,"u_OkProv()",,,oDlg,aCabec,aParc,, )
	nLin += 90
	@ nLin,010 SAY "Saldo: " PIXEL OF oDlg
	@ nLin,055 MSGET oSaldo  VAR nSaldo  Picture "@E 999,999,999.99" SIZE 100,7 PIXEL OF oDlg WHEN .F.
	@ nLin,172 BMPBUTTON TYPE 01 ACTION If(ValidaTela(nTotal,oGet:aCols),(nOpcA := 1,aParc:=oGet:aCols,oDlg:End()),)
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If nOpcA == 1 .And. (Inclui .Or. Altera)
		If File(cFile)
			FErase(cFile)
		Endif
		
		nHdl := FCreate(cFile)
		
		FWrite(nHdl,"dF1_XDTEMB;CtoD('"+DtoC(dF1_XDTEMB)+"')" + Chr(13)+Chr(10))
		FWrite(nHdl,"dF1_XDTENT;CtoD('"+DtoC(dF1_XDTENT)+"')" + Chr(13)+Chr(10))
		FWrite(nHdl,"cF1_TRANSP;'"+cF1_TRANSP + "'"           + Chr(13)+Chr(10))
		FWrite(nHdl,"cA4_NOME;'"  +cA4_NOME + "'"             + Chr(13)+Chr(10))
		FWrite(nHdl,"cF1_COND;'"  +cF1_COND + "'"             + Chr(13)+Chr(10))
		FWrite(nHdl,"cE4_DESCRI;'"+cE4_DESCRI + "'"           + Chr(13)+Chr(10))
		
		For nX:=1 To Len(aParc)
			FWrite(nHdl,"cParc"+StrZero(nX,3)+";CtoD('"+DtoC(aParc[nX,1])+"');Val('"+LTrim(Str(aParc[nX,2],10,2)) + "')" + Chr(13)+Chr(10))
		Next
		
		FClose(nHdl)
	Endif
	
Return

User Function OkProv()
	Local lRet := .T.
	Local nI   := nil

	If ReadVar() == "M->E2_VALOR"
		
		nSaldo := a140Total[3]

		For nI := 1 to len(aCols)
			If !aCols[nI,len(aCols[nI])] .and. nI <> n
				nSaldo -= aCols[nI,2]
			EndIf
		Next nI
		
		nSaldo -= M->E2_VALOR
		oSaldo:Refresh()

		If nSaldo < 0
			Help(NIL, NIL, "Atenção", NIL, "Saldo das parcelas maior que o valor da nota.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Valide os valores informados."})
			Return .F.
		EndIf
	ElseIf ReadVar() == "M->E2_VENCTO"
		If M->E2_VENCTO < ddemissao
			Help(NIL, NIL, "Atenção", NIL, "Data de vencimento não pode ser menor que a emissão do documento.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Valide os valores informados."})
			Return .F.
		EndIf
	EndIf
	

return lRet

Static Function ValidaTela(nTotal,aParc)
	Local nPDel := Len(aParc[1])
	Local lRet  := .T.
	
	aEval( aParc , {|x| nTotal -= If(!x[nPDel],x[2],0) })
	
	If nTotal <> 0
		lRet := .F.
		Alert("Favor informar todo o valor do documento nas parcelas !")
	Endif

Return lRet

Static Function CalculaParc(cCond,nTotal,aParc)
	Local aPC := Condicao(nTotal,cCond,Nil,dDataBase)
	nSaldo := a140Total[3]
	aParc := {}
	If Empty(aPC)
		AAdd( aParc , { Ctod(""), 0, .F.})
	Else
		aEval( aPC , {|x| AAdd( aParc , { x[1], x[2], .F.} ) })
		aEval( aPC , {|x| nSaldo -= x[2]})
	Endif

Return

Static Function ConfigCampo(aCpos,aCabec)
	Local nX
	Local nTamCpo := Len(SX3->X3_CAMPO)
	
	SX3->(dbSetOrder(2)) //X3_CAMPO
	For nX := 1 to Len(aCpos)
		dbSelectArea("SX3")
		dbSetOrder(2)
		If SX3->(MsSeek( Padr(aCpos[nX],nTamCpo )))
			IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
				aAdd( aCabec ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
				,SX3->X3_PICTURE ,SX3->X3_TAMANHO ;
				,SX3->X3_DECIMAL ,Nil ;
				,SX3->X3_USADO ,SX3->X3_TIPO ;
				,Nil ,SX3->X3_CONTEXT ;
				,"" ,SX3->X3_RELACAO})
			EndIf
		EndIf
	Next
Return

User Function STCargaProvisao(cFile)
	Local aLinha, nHdl
	Local aRet := {}
	
	cFile := "\PRE" + Trim(cNFiscal) + Trim(cSerie) + "_" + Trim(cA100For) + Trim(cLoja) + ".txt"
	
	If File(cFile)
		nHdl := FT_FUSE(cFile)
		FT_FGOTOP()
		While !FT_FEOF()
			aLinha := Separa(AllTrim(FT_FREADLN()),";",.F.)
			
			If Len(aLinha) > 1
				If "cParc" $ aLinha[1]
					AAdd( aRet , { &(aLinha[2]) , &(aLinha[3]), .F.})
				Else
					&( aLinha[1] ) := &( aLinha[2] )
				Endif
			Endif
			
			FT_FSKIP()
		Enddo
		FT_FUSE()
	Endif

Return aRet

Static Function ProvisaoGravada()
	Local aRet := {}
	
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(XFILIAL("SE2")+cSerie+cNFiscal,.T.))
	While !SE2->(Eof()) .And. XFILIAL("SE2")+cSerie+cNFiscal == SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM
		If SE2->E2_TIPO = "PR" .And. SE2->E2_FORNECE+SE2->E2_LOJA == cA100For+cLoja
			AAdd( aRet , { SE2->E2_VENCTO , SE2->E2_VALOR, .F.})
		Endif
		SE2->(dbSkip())
	Enddo
	
	dF1_XDTEMB := SF1->F1_XDTEMB
	dF1_XDTENT := SF1->F1_XDTENT
	cF1_TRANSP := SF1->F1_TRANSP
	cA4_NOME   := Posicione("SA4",1,XFILIAL("SA4")+SF1->F1_TRANSP,"A4_NOME")
	cF1_COND   := SF1->F1_COND
	cE4_DESCRI := Posicione("SE4",1,XFILIAL("SE4")+SF1->F1_COND,"E4_DESCRI")
	
Return aRet

/*Static Function LeCoord()
	Local nHdl, nX, nTam
	Local cFile := "C:\TOTVS\COORD.TXT"
	Local aRet  := {}
	
	If File(cFile)
		nHdl := FT_FUSE(cFile)
		FT_FGOTOP()
		While !FT_FEOF()
			AAdd( aRet , Separa(AllTrim(FT_FREADLN()),",",.F.) )
			nTam := Len(aRet)
			For nX:=1 To Len(aRet[nTam])
				aRet[nTam,nX] := Val(aRet[nTam,nX])
			Next
			FT_FSKIP()
		Enddo
		FT_FUSE()
	Endif
	
Return aRet*/
