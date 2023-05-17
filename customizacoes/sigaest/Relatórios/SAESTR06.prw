#include "Rptdef.CH"
#INCLUDE "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"
#include "Fileio.ch"
#include 'totvs.ch'
#include 'inkey.ch'
#include 'rwmake.ch'
#include 'msserial.ch'


User Function SAESTR06()
	Local cTitulo        := ""
	Local nLin           := 0
	Local oTFont20       := TFont():New('Times New Roman',,20,,.T.)
	Local oTFont24       := TFont():New('Times New Roman',,24,,.T.)
	Local nMilissegundos := 5000 // Disparo será de 5 em 5 segundos
	Private oDlg, oSay
	Private oPesoBl, oOpManual,oManual, oCodProd,oTipo,oPN,oPesoTr,oQtdAmostra,oPanel
	Private oPesoMedio,oQtdEtq,oNrEtq,oLote,oPerador,oNota,oDescProd,oBtImprime
	Private nPesoBl,cCodPro,cTipo,cPN,nPesoTr,nQtdAmostra,nPesoMedio,nQtdEtq,nNrEtq
	Private cLote,cOperador,cNota,cDescProd,cArmazem,lManual,cPeso,cStat
	
	//PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' /*USER 'ADMIN' PASSWORD 'MSIGA!@#'*/ MODULO 'EST'
	
	nLin := 20
	nPesoBl := 0
	nPesoTr := 0
	nQtdAmostra := 0
	nPesoMedio := 0
	nQtdEtq := 1
	nNrEtq := 1
	cCodPro := Space(15)
	cDescProd := ""
	cTipo := "QA"
	cPN:= Space(50)
	cLote := Space(30)
	cOperador := Space(30)
	cNota:= Space(9)
	lManual := .F.
	lSair   := .F.

	cTitulo := "Etiqueta Yamaha"

	//While !lSair
		DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 TO 700,850 OF oMainWnd PIXEL

			@ nLin,10 CHECKBOX oManual VAR lManual PROMPT "Contagem Manual" SIZE 96, 15 PIXEL OF oDlg VALID fManual() FONT oTFont20
		
			oSay:= tSay():New(nLin,220,{||"Balança:"},oDlg,,oTFont20,,,,.T.,CLR_RED,CLR_WHITE,100,30)
			@ nLin-5,320 MSGET oPesoBl VAR nPesoBl PICTURE "@E 999,999,999.9999" Valid fQtdEtq() SIZE 96, 20 PIXEL OF oDlg FONT oTFont24 WHEN .T.
						
			oSay:= tSay():New(nLin+=20,10,{||"Código:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oCodProd VAR cCodPro PICTURE "@!" F3 "SB1" Valid fVerProd() SIZE 96, 15 PIXEL OF oDlg FONT oTFont20

			oDescProd:= tSay():New(nLin-15,220,{||cDescProd},oPanel,,oTFont20,,,,.T.,CLR_RED,CLR_WHITE,150,30)

			oSay:= tSay():New(nLin+=20,10,{||"Tipo de Inspeção:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oTipo VAR cTipo PICTURE "@!"  WHEN .F.  SIZE 20, 15 PIXEL OF oDlg FONT oTFont20

			oSay:= tSay():New(nLin+=20,10,{||"Cod. Produto Cliente:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oPN VAR cPN PICTURE "@!"  WHEN .F.  SIZE 96, 15 PIXEL OF oDlg FONT oTFont20

			oSay:= tSay():New(nLin+=20,10,{||"Peso Tara:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oPesoTr VAR nPesoTr PICTURE "@E 999,999,999.9999" WHEN .F. SIZE 60, 15 PIXEL OF oDlg FONT oTFont20 
			
			oBtTara := TButton():New( nLin, 200, "Obter Tara",oDlg,{||fTara()}, 40,20,,,.F.,.T.,.F.,,.F.,,,.F. )   
			
			oSay:= tSay():New(nLin+=20,10,{||"Quantidade de Amostra:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oQtdAmostra VAR nQtdAmostra PICTURE "@E 999,999,999"  Valid fCalcPM() SIZE 60, 15 PIXEL OF oDlg FONT oTFont20 WHEN !lManual

			oSay:= tSay():New(nLin+=20,10,{||"Peso Médio da Peça:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oPesoMedio VAR nPesoMedio PICTURE "@E 999,999,999.9999"  SIZE 60, 15 PIXEL OF oDlg FONT oTFont20 WHEN !lManual

			oSay:= tSay():New(nLin+=20,10,{||"Qtde da Etiqueta:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oQtdEtq VAR nQtdEtq PICTURE "@E 999,999,999"  SIZE 60, 15 PIXEL OF oDlg FONT oTFont20 WHEN lManual

			oSay:= tSay():New(nLin,220,{||"Num. de Etiquetas:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,320 MSGET oNrEtq VAR nNrEtq PICTURE "@E 9,999"  SIZE 60, 15 PIXEL OF oDlg FONT oTFont20 WHEN lManual

			oSay:= tSay():New(nLin+=20,10,{||"Lote/OP:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin,110 MSGET oLote VAR cLote PICTURE "@!"  WHEN .F.  SIZE 96, 15 PIXEL OF oDlg FONT oTFont20

			//oSay:= tSay():New(nLin+=20,10,{||"Operador:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			//@ nLin,110 MSGET oOperador VAR cOperador PICTURE "@!"    SIZE 96, 15 PIXEL OF oDlg FONT oTFont20

			//oSay:= tSay():New(nLin,250,{||"Nota:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			//@ nLin,300 MSGET oNota VAR cNota PICTURE "@!"  SIZE 96, 15 PIXEL OF oDlg FONT oTFont20

			oBtImprime := TButton():New( nLin+30, 100, "Imprimir",oDlg,{||MsgRun("Gerando CB0... ","Aguarde!",{||GeraCB0()})}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 

			oBtBalanca := TButton():New( nLin+50, 100, "Captura Balança",oDlg,{||MsgRun("Capturando Balança... ","Aguarde..!",{||fBalanca()})}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 

			oSay:= tSay():New(nLin+70,10,{||"Comunic. Balança:"},oDlg,,oTFont20,,,,.T.,CLR_BLACK,CLR_WHITE,100,30)
			@ nLin+70,110 MSGET oStat VAR cStat PICTURE "@!"  WHEN .F.  SIZE 96, 15 PIXEL OF oDlg FONT oTFont20
			@ nLin+90,110 MSGET oPESO VAR cPeso PICTURE "@!"  WHEN .T.  SIZE 300, 15 PIXEL OF oDlg FONT oTFont20

			oBtImprime := TButton():New( nLin+70, 340, "Sair",oDlg,{||MsgRun("Gerando CB0... ","Aguarde!",{||oDlg:End(),lSair:=.T.})}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 

			oTimer := TTimer():New(nMilissegundos, {|| fBalanca(),fQtdEtiq() }, oDlg )
			oTimer:Activate()
		
		ACTIVATE MSDIALOG oDlg CENTERED
	//End
Return

Static Function fManual()
	If lManual
		nQtdAmostra := 1
		nPesoMedio  := 1
		nPesoTr     := 0
		nQtdAmostra := 0
		nPesoMedio  := 0
		nQtdEtq     := 1
		nNrEtq      := 0
	Else
		nPesoMedio  := 0
		nQtdAmostra := 0
		nPesoTr     := 0
		nQtdAmostra := 0
		nPesoMedio  := 0
		nQtdEtq     := 1
		nNrEtq      := 0
	EndIf

	oQtdAmostra:Refresh()
	oPesoMedio:Refresh()
	oQtdEtq:Refresh()
	oNrEtq:Refresh()
		
Return .t.

Static Function fQtdEtq()
	Local lRet := .T.
Return lRet

Static Function fverprod()
	Local lRet := .T.

	SB1->(DbSelectArea("SB1"))
	SB1->(DbSetOrder(1))
	If !SB1->(dbSeek(xFilial("SB1")+alltrim(cCodPro)))
		lRet := .F.
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		While !SB1->(EOF())
			If right(alltrim(SB1->B1_COD),len(alltrim(cCodPro))) == alltrim(cCodPro)
				cCodPro := SB1->B1_COD
				lRet := .T.
				exit
			EndIf
			SB1->(DbSkip())
		Enddo
	EndIf

	If !lret
        cTitulo  := "ATENÇÃO!"
        cErro    := "Produto não encontrado."
        cSolucao := "Verifique o código informado."
        Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
		Return lRet
	EndIf


	cDescricao := SB1->B1_DESC

	If SB1->B1_XYAMAHA == '1'
		cTipo := "INSP"
	ElseIf SB1->B1_XYAMAHA == '2'
		cTipo := "QA"
	Else
		cTipo := "N/D"
	EndIf

	cPN := ""
	SA7->(DbSelectArea("SA7"))
	SA7->(DbSetOrder(1))
	SA7->(DbGoTop())
	While !SA7->(EOF())
		If rtrim(SA7->A7_PRODUTO) == rtrim(cCodPro) .and. !EMPTY(SA7->A7_CODCLI)
			cPN := SA7->A7_CODCLI
			exit
		EndIf
		SA7->(DbSkip())
	Enddo

	If empty(cPN)
		cPN := "NÃO DEFINIDO"
	EndIf

	GetLote()

	oDlg:Refresh() 
	oPN:Refresh() 
	oTipo:Refresh()
	oDescProd:Refresh()
	oLote:Refresh()

Return lRet

Static Function GetLote()

	BeginSql Alias "TMP"
		SELECT TOP 1 C2_NUM+C2_ITEM+C2_SEQUEN AS 'OP', C2_LOCAL AS 'LOC'
		FROM %TABLE:SC2%
		WHERE
			D_E_L_E_T_ = ''
			AND C2_FILIAL = %EXP:FwCodFil()%
			AND C2_PRODUTO = %EXP:cCodPro%
			AND C2_QUJE <> 0
		ORDER BY C2_NUM DESC 
	EndSql

	cLote    := TMP->OP
	cArmazem := TMP->LOC

	TMP->(DbCloseArea())
Return


Static Function GeraCB0()
    Local cEtiq := GetMv("MV_CODCB0")	
    Local nI := 0
	Local aEtiquetas := {}
	Local aArea := GetArea()

	CB0->(DbSelectArea("CB0"))
	CB0->(DbSetOrder(1))
	While CB0->(DbSeek(xFilial("CB0")+cEtiq))
		cEtiq := soma1(cEtiq)
	Enddo

    BEGIN TRANSACTION
		For nI := 1 to nNrEtq
			If nQtdEtq > 0 .and. nNrEtq > 0
				DbSelectArea("CB0")    
				RecLock("CB0", .T.)	
					CB0->CB0_FILIAL  := xFilial("CB0")			
					CB0->CB0_CODETI  := cEtiq
					CB0->CB0_DTNASC  := Date()
					CB0->CB0_TIPO    := "01"
					CB0->CB0_CODPRO  := cCodPro
					CB0->CB0_QTDE    := nQtdEtq
					CB0->CB0_LOCAL   := cArmazem
					CB0->CB0_DTVLD   := ctod("31/12/2049")
					CB0->CB0_OP      := cLote
					CB0->CB0_XPESO   := (nPesoTr)
				MsUnLock() // Confirma e finaliza a operação
					//{"10",{"CBG_CODPRO"    ,"CBG_QTDE"      ,"CBG_LOTE"                    ,"CBG_SLOTE"                   ,"CBG_ARM"    ,"CBG_END"                     ,"CBG_OP"   ,"CBG_CC"                 ,"CBG_TM"                 ,"CBG_CODETI","CBG_OBS"}},;
				CBLog("10",{cCodPro         ,nQtdEtq         ,SPACE(TAMSX3("B8_LOTECTL")[1]),SPACE(TAMSX3("B8_NUMLOTE")[1]),cArmazem     ,SPACE(TAMSX3("BE_LOCALIZ")[1]),cLote      ,SPACE(TAMSX3("D3_CC")[1]),SPACE(TAMSX3("D3_TM")[1]),cEtiq       ,"Etiqueta Yamaha"})
				aAdd(aEtiquetas,cEtiq)
				cEtiq := soma1(cEtiq)
			EndIf
		Next nI
		
		PutMv("MV_CODCB0",cEtiq)
    END TRANSACTION

	//imprime as etiquetas
	If nQtdEtq > 0 .and. nNrEtq > 0 
		u_SAESTR03(aEtiquetas)
	EndIf

	//
	RestArea(aArea)

Return

Static Function fTara()
	nPesoTr := nPesoBl

	oPesoTr:Refresh() 
Return

Static Function fCalcPM()
	Local lRet := .T.

	nPesoMedio := Round((nPesoBl - nPesoTr)/nQtdAmostra,4)

	oPesoMedio:Refresh() 

	fQtdEtiq(0)

Return lRet

Static Function fQtdEtiq(nIncr)
	If !lManual
		nQtdEtq := Round((nPesoBl - nPesoTr)/nPesoMedio,0)
		nNrEtq  := 1
	EndIf

	oPesoBl:Refresh()
	oQtdEtq:Refresh()
	oNrEtq:ReFresh()
Return

Static Function fBalanca()
    Local nHand   := 0
	Local cConfig := "COM1:9600,N,7,1"
	Local n       := 0
	Local nLoop   := 2000
	Local cT      := ""
	Private nHdll := 0

	While n < 300 .and. !lManual      
		If MsOpenPort(@nHand, cConfig) // Abrindo porta
			cStat := "Comunicação - OK."
			oStat:Refresh()

			While nLoop > 0
				
				cStat := "Buscando Peso..."
				oStat:Refresh()
			
				msRead(nHdll,@cT)

				cPeso := cValtoChar(cT)

				if !Empty(cPeso) .and. val(cPeso) > 0
					//cPeso := left(cValtoChar(val(cPeso)),4)
					//cPeso := cValtoChar(val(cPeso)/1000)
					cPeso := Left(cPeso,6)
					oPESO:Refresh()
					nPesoBl := val(cPeso)/1000
					exit
				endif

				nLoop--
			EndDo
			
			cStat := "Comunicação - OK."
			oStat:Refresh()
			exit

		Else
			cStat := "Comunicação - Falha."
			n++
		EndIf
	Enddo

	oStat:Refresh()
	oPesoBl:Refresh()

             
Return 