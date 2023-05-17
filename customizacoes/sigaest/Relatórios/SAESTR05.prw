#include "Rptdef.CH"
#include "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"
#include "Fileio.ch"

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTR05           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Gera etiquetas baseado no RIR gerado através do sistema Cronus ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 04/01/2020         ¦ Last Modified time ¦  04/01/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTR05()
    Private cEtiqIni := ""

    If Pergunte("SAESTR05  ",.T.)
        MsgRun("Gerando Etiqueta(s)..."    ,"Aguarde...",{||GeraCB0()})
        MsgRun("Imprimindo Etiqueta(s)..." ,"Aguarde...",{||Imprimir(cEtiqIni)})
    EndIf

Return

Static Function GeraCB0()
    Local cEtiq := GetMv("MV_CODCB0")	
    Local nI := 0

    cEtiqIni := cEtiq

    BEGIN TRANSACTION
        For nI := 1 to MV_PAR03
            If (MV_PAR04 > 0)
                DbSelectArea("CB0")    
                RecLock("CB0", .T.)	
                    CB0->CB0_FILIAL  := xFilial("CB0")	
                    CB0->CB0_CODETI  := cEtiq
                    CB0->CB0_DTNASC  := Date()
                    CB0->CB0_TIPO    := "05"
                    CB0->CB0_CODPRO  := MV_PAR01
                    CB0->CB0_QTDE    := MV_PAR04
                    CB0->CB0_LOCAL   := MV_PAR05
                    CB0->CB0_DTVLD   := ctod("31/12/2049")
                    CB0->CB0_FORNEC  := "CRONUS"
                    CB0->CB0_LOJAFO  := "XX"
                    CB0->CB0_NFENT   := MV_PAR02
                    CB0->CB0_SERIEE  := "XXX"
                    CB0->CB0_SERIES  := "XXX"
                    CB0->CB0_ITNFE   := "0001"
                    CB0->CB0_SDOCS   := "XXX"
                    CB0->CB0_SDOCE   := "XXX"
                MsUnLock() // Confirma e finaliza a operação
                //{"05",{"CBG_CODPRO"    ,"CBG_QTDE"      ,"CBG_LOTE"                    ,"CBG_NOTAE","CBG_SERIEE" ,"CBG_FORN"     ,"CBG_LOJFOR","CBG_ARM"       ,"CBG_CODETI","CBG_OBS"}},;
                CBLog("05",{MV_PAR01     ,MV_PAR03        ,SPACE(TAMSX3("B8_LOTECTL")[1]),MV_PAR02   ,"XXX"        ,"CRONUS"       ,"XX"        ,MV_PAR05        ,cEtiq       ,"Reeimpressão Cronus"})
                cEtiq := soma1(cEtiq)
            EndIf
        Next nI

        PutMv("MV_CODCB0",cEtiq)
    END TRANSACTION
    //RestArea(aArea)
Return

Static Function Imprimir(cEtiqIni)
    Local cFileName       := "SAESTR05_"+Dtos(MSDate())+'_'+StrTran(Time(),":","")
    Local cPathInServer   := "C:\temp\"
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local lTReport        := .F.
    Local lServer         := .F.
    Local lPDFAsPNG       := .T.
    Local lRaw            := .F.
    Local lViewPDF        := .T.
    Local nQtdCopy        := 1   
    Local aSize           := {}  
    Private aTMP          := {}
    Private nHeight       := 110
    Private nWidght       := 150
    Private nMaxLine      := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter     

        oPrinter := FWMSPrinter():New(cFileName,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,,/*alltrim(cPrinter)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
        
        oPrinter:SetPortrait()

        oTFont22   := TFont():New('ARIAL',,-22,.T.)
        oTFont24   := TFont():New('ARIAL',,-24,.T.)
        oTFont26   := TFont():New('ARIAL',,-26,.T.)

        oPrinter:SetPaperSize(0,nHeight,nWidght) 

        aAdd(aSize,oPrinter:PaperSize()) //Retorna o tamanho do papel.
        aAdd(aSize,oPrinter:nHorzSize()) //Retorno largura da página.
        aAdd(aSize,oPrinter:nVertSize()) //Retorno altura da página.
        aAdd(aSize,oPrinter:nHorzRes())  //Retorna a resolução horizontal da impressora configurada.
        aAdd(aSize,oPrinter:nVertRes())  //Retorna a resolução vertical da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelX())//Retorna a resolução vertical, em pixels, da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelY())//Retorna a resolução horizontal, em pixels, da impressora configurada.
       
        DbSelectArea("CB0")
        DbSetOrder(1)
        If dbSeek(xFilial("CB0")+cEtiqIni)
            While rtrim(CB0->CB0_NFENT) == rtrim(MV_PAR02)
                oPrinter:StartPage()

                    nLinha := 90
                    nLinAnt := nLinha
                    cTexto := rtrim(Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"))
                    oPrinter:Say( nLinha, 550, SubStr(cTexto,1,26),oTFont22)
                    
                    nLinha += 20
                    oPrinter:Say( nLinha, 550, ltrim(SubStr(cTexto,29,52)),oTFont22)

                    nLinha += 30
                    oPrinter:Say( nLinha, 380, "X",oTFont26)
                    
                    cTexto := Posicione("SA2",1,xFilial("SA2")+CB0->CB0_FORNEC+CB0->CB0_LOJAFO,"A2_NOME")
                    nLinha += 20
                    oPrinter:Say( nLinha, 500, Left(CB0->CB0_FORNEC+"-"+CB0->CB0_LOJAFO+cTexto,28) ,oTFont22)
                    
                    nLinha += 60
                    oPrinter:Say( nLinha, 60, iif(month(CB0->CB0_DTNASC)=1,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 220, iif(month(CB0->CB0_DTNASC)=7,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 600, CB0->CB0_CODPRO ,oTFont24)
                    
                    nLinha += 45
                    oPrinter:Say( nLinha, 60, iif(month(CB0->CB0_DTNASC)=2,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 220, iif(month(CB0->CB0_DTNASC)=8,"X","") ,oTFont26)

                    nLinha += 20
                    oPrinter:Say( nLinha, 600, dtoc(CB0->CB0_DTNASC) ,oTFont24)
                    oPrinter:Say( nLinha, 340, Right(dtoc(CB0->CB0_DTNASC),2) ,oTFont26)

                    nLinha += 25
                    oPrinter:Say( nLinha, 60, iif(month(CB0->CB0_DTNASC)=3,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 220, iif(month(CB0->CB0_DTNASC)=9,"X","") ,oTFont26)
                    
                    nLinha += 45
                    oPrinter:Say( nLinha, 60, iif(month(CB0->CB0_DTNASC)=4,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 220, iif(month(CB0->CB0_DTNASC)=10,"X","") ,oTFont26)

                    nLinha += 10
                    cTexto := cValtoChar(CB0->CB0_QTDE)+" - "
                    cTexto += rtrim(Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_UM"))
                    oPrinter:Say( nLinha, 600, cTexto ,oTFont24)
                    oPrinter:Say( nLinha, 950, "X" ,oTFont26)

                    nLinha += 35
                    oPrinter:Say( nLinha, 60, iif(month(CB0->CB0_DTNASC)=5,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 220, iif(month(CB0->CB0_DTNASC)=11,"X","") ,oTFont26)
                    
                    nLinha += 35
                    oPrinter:Say( nLinha, 650, CB0->CB0_CODETI,oTFont22)

                    nLinha += 10
                    oPrinter:Say( nLinha, 60, iif(month(CB0->CB0_DTNASC)=6,"X","") ,oTFont26)
                    oPrinter:Say( nLinha, 220, iif(month(CB0->CB0_DTNASC)=12,"X","") ,oTFont26)
                    
                    oPrinter:Code128C( nLinha, 1000, CB0->CB0_CODETI, 30 )

                oPrinter:EndPage()
                DbSkip()
            Enddo
        EndIf     

        oPrinter:cPathPDF:= cPathInServer 
    
        oPrinter:Preview()  

        //RestArea(aArea)   
Return