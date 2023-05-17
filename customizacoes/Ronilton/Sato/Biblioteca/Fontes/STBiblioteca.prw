/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PutSx1    ³ Autor ³Wagner                 ³ Data ³ 14/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma pergunta usando rotina padrao                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function STPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa  := .f.
Local lIngl := .f. 

If .T. //GetVersao(.F.) < "12"

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	
	cPyme    := Iif( cPyme 		== Nil, " ", cPyme		)
	cF3      := Iif( cF3 		== NIl, " ", cF3		)
	cGrpSxg  := Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
	cCnt01   := Iif( cCnt01		== Nil, "" , cCnt01 	)
	cHelp	 := Iif( cHelp		== Nil, "" , cHelp		)
	
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	
	If !( DbSeek( cGrupo + cOrdem ))
	
	    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
	
		Reclock( "SX1" , .T. )
	
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
	
		Replace X1_VAR01   With cVar01
	
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
	
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
	
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"			// Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
	
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
	
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
	
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
	
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
	
		Replace X1_HELP  With cHelp
	
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	
		MsUnlock()
	Else
	
	   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
	   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
	   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
	
	   If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort 
	         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	
	RestArea( aArea )
Endif	
Return

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ STDispara  ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Efetua execução dos gatilhos do campo                         ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STDispara(cCampo,xValor,nPos)
	Local bValida
	Local cAlias  := Alias()
	Local cValida := ""
	Local cAux    := __ReadVar
	Local nAuxN   := If( Type("n") == "N" , n, 1)
	Local aArea   := SB1->(GetArea())
	Local lRet    := .T.
	
	cCampo := PADR(cCampo,Len(SX3->X3_CAMPO))   // Ajusta o tamanho da variávei para localizar corretamente o campo
	
	SX3->(dbSetOrder(2))  // Dispara SX7
	SX3->(dbSeek(cCampo))
	
	// Monta as validações do campo
	If !Empty(SX3->X3_VALID)
		cValida += Trim(SX3->X3_VALID)
	Endif
	If !Empty(SX3->X3_VLDUSER)
		cValida += If( Empty(cValida) , "", ".And.")+Trim(SX3->X3_VLDUSER)
	Endif
	
	nPos := If( nPos == Nil , Len(aCols), nPos)
	
	bValida := &("{|| "+If(Empty(cValida),".T.",cValida)+" }")
	
	__ReadVar := "M->" + Trim(cCampo)
	
	M->&(cCampo) := xValor
	
	n := nPos
	
	If lRet := Eval(bValida)
		If ExistTrigger(cCampo)
			(cAlias)->(RunTrigger(2,nPos,,,cCampo))
		Endif
	EndIf
	
	n := nAuxN
	__ReadVar := cAux
	RestArea(aArea)
	
Return lRet

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ STCriaPerg ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 18/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Cria perguntas no perfil do usuário                           ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STCriaPerg(lGrv)
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
			aEval( aPerg , {|x| x[7] := If( x[4] == "C" , "1", If( x[2] == "N" , "0", Space(x[3]))), AAdd( aLinha , x[7] ) })
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