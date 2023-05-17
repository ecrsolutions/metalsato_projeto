#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAETSR01           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Imprime Etiquetas Notas de Entrada                             ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 12/12/2019         ¦ Last Modified time ¦  12/12/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTR01()
    Local aTamanho    := MsAdvSize() 
	Local nJanLarg    := aTamanho[5]
	Local nJanAltu    := aTamanho[6]
    Local aHead       := {}
    Local aHead2      := {}
    Local aAlter      := {"ETQDE","ETQPOR"}
    Local aAlter2     := {}
    Local aButtons    := {}
    Local aCampos     := {}
    Local aCampos2    := {}
    Local aCols       := {}
    Local aCols2      := {}
    //Local aArea     := GetArea()
    Private aNota     := {SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_TIPO}
    Private oBrw      := Nil
    Private oDlg      := Nil

    nAltIni := aTamanho[1]
    nAltFim := nJanAltu/2

    SD1->(dbSelectArea("SD1"))
    SD1->(dbSetOrder(1))
    If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
        While SD1->D1_DOC == aNota[1] .and. SD1->D1_SERIE == aNota[2] .and. SD1->D1_FORNECE == aNota[3] .and. SD1->D1_LOJA == aNota[4] .and. !EOF()
            aAdd(aCols ,{   SD1->D1_ITEM,;
                            SD1->D1_COD,;
                            Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"),;
                            SD1->D1_UM,;
                            SD1->D1_QUANT,;
                            0,;
                            0,;
                            SD1->D1_LOCAL,;
                            .F.})
        
            SD1->(DbSkip())
        Enddo
    EndIf
    SD1->(DbCloseArea())

    aCols2 := GetEtiq()

    aAdd(aCampos, { "D1_ITEM"    , "Item"                 ,"D1_ITEM"    })
    aAdd(aCampos, { "D1_COD"     , "Código"               ,"D1_COD"     })
    aAdd(aCampos, { "B1_DESC"    , "Descrição"            ,"B1_DESC"    })
    aAdd(aCampos, { "D1_UM"      , "UM"                   ,"D1_UM"      })
    aAdd(aCampos, { "D1_QUANT"   , "Qtd. NF"              ,"D1_QUANT"   })
    aAdd(aCampos, { "CB0_QTDE"   , "Qtd. por Etiqueta(s)" ,"ETQDE"      })
    aAdd(aCampos, { "CB0_QTDE"   , "Qtd. de Etiqueta(s)"  ,"ETQPOR"     })
    aAdd(aCampos, { "D1_LOCAL"   , "Armazém"              ,"D1_LOCAL"   })

    aAdd(aCampos2, { "D1_ITEM"    , "Item"                 ,"D1_ITEM"    })
    aAdd(aCampos2, { "CB0_CODETI" , "Etiqueta"             ,"CB0_CODETI" })
    aAdd(aCampos2, { "D1_COD"     , "Código"               ,"D1_COD"     })
    aAdd(aCampos2, { "B1_DESC"    , "Descrição"            ,"B1_DESC"    })
    aAdd(aCampos2, { "D1_UM"      , "UM"                   ,"D1_UM"      })
    aAdd(aCampos2, { "CB0_QTDE"   , "Qtd. por Etiqueta(s)" ,"CB0_QTDE"   })
    aAdd(aCampos2, { "D1_LOCAL"   , "Armazém"              ,"D1_LOCAL"   })
    aAdd(aCampos2, { "CB0_DTNASC" , "Emissão"              ,"CB0_DTNASC" })

    aHead  := GetAheader(aCampos)
    aHead2 := GetAheader(aCampos2)
   
    DEFINE MsDialog oDlg TITLE "Totais" FROM 000,000 TO nJanAltu,nJanLarg PIXEL
        
        oGroup1 := TGroup():New(nAltIni+30,1,nAltFim*0.45,(nJanLarg/2),'Dados NF - '+SF1->F1_DOC+' - '+SF1->F1_SERIE,oDlg,,,.T.) 
        oBrw :=    MsNewGetDados():New(nAltIni+45,2,nAltFim*0.44,(nJanLarg/2)-5,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter,0,99,"u_VldEtiq",,"AllwaysTrue",oDlg,aHead,aCols)

        oGroup2 := TGroup():New(nAltFim*0.47,1,nAltFim*0.96,(nJanLarg/2),'Etiquetas Geradas - '+SF1->F1_DOC+' - '+SF1->F1_SERIE,oDlg,,,.T.) 
        oBrw2  :=  MsNewGetDados():New(nAltFim*0.55,2,nAltFim*0.92,(nJanLarg/2)-5,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter2,0,99,"AllwaysTrue",,"AllwaysTrue",oDlg,aHead2,aCols2)

        oDlg:bInit := {||  EnchoiceBar(oDlg,{|| MsgRun("Imprimindo Etiqueta(s)... ","Aguarde...",{||Imprimir()}),oDlg:End()},{|| oDlg:End()},,aButtons,,,.F.,.T.,.T.,.T.,.F.,)}

        Aadd(aButtons, {"Gerar Etiqueta(s)", {|| MsgRun("Gerando Etiqueta(s)... ","Aguarde...",{||GeraCB0()})}, "Gerar Etiq...", "Gerar Etiq" , {|| .T.}} )
		    
    ACTIVATE MSDIALOG oDlg CENTERED
    //RestArea(aArea)
Return

Static Function GetEtiq()
    Local aRetorno := {}
    Local nItem    := 0
    //Local aArea     := GetArea()
        CB0->(DbSelectArea("CB0"))
        CB0->(DbSetOrder(6))
        CB0->(DbGoTop())
        If CB0->(dbSeek(xFilial("CB0")+aNota[1]+aNota[2]+aNota[3]+aNota[4]))
            While CB0->(!EOF()) .and. CB0->CB0_NFENT == aNota[1] .and. CB0->CB0_SERIEE == aNota[2] .and. CB0->CB0_FORNEC == aNota[3] .and. CB0->CB0_LOJAFO == aNota[4]
                aAdd(aRetorno,{;
                    StrZero(nItem++,4),;
                    CB0->CB0_CODETI,;
                    CB0->CB0_CODPRO,;
                    Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"),;
                    Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_UM"),;
                    CB0->CB0_QTDE,;
                    CB0->CB0_LOCAL,; 
                    CB0->CB0_DTNASC,;                   
                    .F.})
                CB0->(DbSkip())
            Enddo
        Else
            aAdd(aRetorno,{;
                "",;
                "",;
                "",;
                "",;
                "",;
                0 ,;
                "",;
                ctod(""),;
                .F.})
        EndIf
        DbCloseArea()
    //RestArea(aArea)
Return aRetorno

User Function VldEtiq()
    //Local aArea     := GetArea()
    Local lRet := .T.
    If ReadVar() == "M->ETQDE"
        If (&(ReadVar()) * acols[n,7]) > aCols[n,5] .or. &(ReadVar()) < 0 
            alert("Quantidade inválida!")
            lret := .F.
        EndIf
    ElseIf ReadVar() == "M->ETQPOR"
        If (&(ReadVar()) * acols[n,6]) > aCols[n,5] .or. &(ReadVar()) < 0 
            alert("Quantidade inválida!")
            lret := .F.
        EndIf
    EndIf
    //RestArea(aArea)
Return lRet

Static Function GeraCB0()
    //Local aArea     := GetArea()
    Local cEtiq := GetMv("MV_CODCB0")	
    Local nI := 0
    Local nX := 0

    BEGIN TRANSACTION
    
    For nI := 1 to Len(oBrw:aCols)
        If !(oBrw:aCols[nI,len(oBrw:aCols[nI])]) .and. oBrw:aCols[nI,5] > 0 .and. oBrw:aCols[nI,6] > 0 
            For nX := 1 to oBrw:aCols[nI,7]
                CB0->(DbSelectArea("CB0"))   
                CB0->(DbSetOrder(1))
                RecLock("CB0", .T.)	
                    CB0->CB0_FILIAL  := xFilial("CB0")	
                    CB0->CB0_CODETI  := cEtiq
                    CB0->CB0_DTNASC  := Date()
                    CB0->CB0_TIPO    := "01"
                    CB0->CB0_CODPRO  := oBrw:aCols[nI,2]
                    CB0->CB0_QTDE    := oBrw:aCols[nI,6]
                    CB0->CB0_LOCAL   := oBrw:aCols[nI,8]
                    CB0->CB0_DTVLD   := ctod("31/12/2049")
                    CB0->CB0_FORNEC  := aNota[3]
                    CB0->CB0_LOJAFO  := aNota[4]
                    CB0->CB0_NFENT   := aNota[1] 
                    CB0->CB0_SERIEE  := aNota[2]
                    CB0->CB0_SERIES  := aNota[2]
                    CB0->CB0_ITNFE   := oBrw:aCols[nI,1]
                    CB0->CB0_SDOCS   := aNota[2]
                    CB0->CB0_SDOCE   := aNota[2]
                MsUnLock() // Confirma e finaliza a operação
                   //{"05",{"CBG_CODPRO"    ,"CBG_QTDE"      ,"CBG_LOTE"                    ,"CBG_NOTAE","CBG_SERIEE" ,"CBG_FORN"     ,"CBG_LOJFOR","CBG_ARM"       ,"CBG_CODETI","CBG_OBS"}},;
                CBLog("05",{oBrw:aCols[nI,2],oBrw:aCols[nI,6],SPACE(TAMSX3("B8_LOTECTL")[1]),SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,oBrw:aCols[nI,8],cEtiq       ,"Entrada NF"})
                cEtiq := soma1(cEtiq)
            Next nX
            
        EndIf
    Next nI

    PutMv("MV_CODCB0",cEtiq)

    aCols2 := {}
    aCols2 := GetEtiq()
    
    oBrw2:SetArray(aCols2,.F.)
    oBrw2:ForceRefresh()
    oBrw:ForceRefresh()

    END TRANSACTION
    //RestArea(aArea)
Return

Static Function Imprimir(cEtiqIni)
    Local cFileName       := "Etiqueta - "+Dtos(MSDate())+StrTran(Time(),":","")
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
    Local nHeight         := 70.5 //7,5 cm
    Local nWidght         := 100 //10cm
    Local nX              := Nil
    Private aTMP          := {}
    Private nMaxLine      := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter     

        oPrinter := FWMSPrinter():New(cFileName,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,,/*alltrim(cPrinter)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
        
        oPrinter:SetPortrait()

        oTFont10   := TFont():New('Arial Black',,-10,.T.)
        oTFont12   := TFont():New('Arial Black',,-12,.T.)
        oTFont14   := TFont():New('Arial Black',,-14,.T.)
        oTFont16   := TFont():New('Arial Black',,-16,.T.)

        oTFont10:Bold := .T.
        oTFont12:Bold := .T.
        oTFont14:Bold := .T.
        oTFont16:Bold := .T.

        oPrinter:SetPaperSize(0,nHeight,nWidght) 

        aAdd(aSize,oPrinter:PaperSize()) //Retorna o tamanho do papel.
        aAdd(aSize,oPrinter:nHorzSize()) //Retorno largura da página.
        aAdd(aSize,oPrinter:nVertSize()) //Retorno altura da página.
        aAdd(aSize,oPrinter:nHorzRes())  //Retorna a resolução horizontal da impressora configurada.
        aAdd(aSize,oPrinter:nVertRes())  //Retorna a resolução vertical da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelX())//Retorna a resolução vertical, em pixels, da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelY())//Retorna a resolução horizontal, em pixels, da impressora configurada.

        If !Pergunte(PADR("SAESTR01",Len(SX1->X1_GRUPO)),.T.)
            Return
        EndIf
        
        CB0->(DbSelectArea("CB0"))
        CB0->(DbSetOrder(6))
        CB0->(DbGoTop())
        If CB0->(dbSeek(xFilial("CB0")+aNota[1]+aNota[2]+aNota[3]+aNota[4]))
            While CB0->CB0_NFENT == aNota[1] .and. CB0->CB0_SERIEE == aNota[2] .and. CB0->CB0_FORNEC == aNota[3] .and. CB0->CB0_LOJAFO == aNota[4]
                If CB0->CB0_CODETI >= MV_PAR01 .and. CB0->CB0_CODETI <= MV_PAR02
                            oPrinter:StartPage()
                                nLinha  := 5
                                nEspLin := 7 
                                nLargura := nWidght*5.5
                                
                                oPrinter:Line(nLinha, 10 , nLinha, nLargura,0,"-7")
                                nLinAnt  := nLinha
                                nLinAnt2 := nLinha
                                nLinInic := nLinha
                                
                                nLinha += nEspLin    
                                //oPrinter:Say(nLinha,20,"LPN" ,oTFont14)
                                
                                nLinha += nEspLin*1.5
                                //cLPN :="5329"
                                //cLPN += left(replace(dtoc(ddatabase),"/",""),4)+right(dtoc(ddatabase),2)
                                //cLPN += right(rtrim(TiraZeros(CB0->CB0_CODETI)),5)
                                //oPrinter:Say(nLinha,25 ,cLPN ,oTFont14)

                                //cCodPro := CB0->CB0_CODPRO
                                //If Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_XYAMAHA") == '1'
                                //    cTipo := "INSP"
                                //ElseIf Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_XYAMAHA") == '2'
                                //    cTipo := "QA"
                                //Else
                                //    cTipo := "NÃO DEFINIDO"
                                //EndIf
                                //oPrinter:Say(nLinha,380,cTipo  ,oTFont14)

                                        
                                //nEspLin := 10
                                //nLinha += nEspLin*0.5
                                //oPrinter:Line(nLinha    , 10  , nLinha, nLargura,0,"-7")
                                //oPrinter:Line(nLinAnt2  , 360 , nLinha, 360     ,0,"-7")  //cria linha vertical
                                //oPrinter:Line(nLinAnt2  , 450 , nLinha, 450     ,0,"-7")  //cria linha vertical


                                //nLinha += nEspLin*1.5
                                //cCodBar := Replace(cLPN,"-","")
                                //oPrinter:Code128(nLinha-12.5,160, REPLACE(cCodBar,".",""), 1, 20 , .F.,,100 )
                                //nLinha += nEspLin*1.4
                                //oPrinter:Say(nLinha,170,""+cCodBar+""  ,oTFont10)

                                //nLinha += nEspLin*.080
                                //oPrinter:Line(nLinha, 10 , nLinha, nLargura,0,"-7")
                                //nLinAnt2 := nLinha

                                nEspLin := 7  
                                nLinha  += nEspLin*9.2    
                                oPrinter:Say(nLinha,15  ,"Código"    ,oTFont14)
                                //oPrinter:Say(nLinha,330 ,"Supplier"  ,oTFont14)
                                //oPrinter:Say(nLinha,480 ,"User"      ,oTFont14)
                                
                                nLinha += nEspLin*1.5
                                //SA7->(DbSelectArea("SA7"))
                                //SA7->(DbSetOrder(1))
                                //SA7->(DbGoTop())

                                //cCOdCli := ""
                                //While !SA7->(EOF())
                                //    If rtrim(SA7->A7_PRODUTO) == rtrim(cCodPro) .and. !EMPTY(SA7->A7_CODCLI)
                                //        cCodCli := rtrim(Replace(SA7->A7_CODCLI,"BE-",""))
                                //        exit
                                //    EndIf
                                //    SA7->(DbSkip())
                                //Enddo    

                                
                                oPrinter:Say(nLinha,25  ,CB0->CB0_CODPRO   ,oTFont14)
                                //oPrinter:Say(nLinha,330 ,"5329"            ,oTFont14)
                                //oPrinter:Say(nLinha,480 ,"9219"            ,oTFont14)

                                nEspLin := 10
                                nLinha += nEspLin

                                //oPrinter:Line(nLinha    , 10          , nLinha, nLargura,0,"-7")
                                //oPrinter:Line(nLinAnt2  , 320         , nLinha, 320     ,0,"-7")  //cria linha vertical
                                //oPrinter:Line(nLinAnt2  , 470         , nLinha, 470     ,0,"-7")  //cria linha vertical
                                nLinAnt2 := nLinha

                                //nLinha += nEspLin*1.5
                                //cCodBar := rtrim(replace(cCodCli,"-",""))+"-5329-"+"9219" 
                                //oPrinter:Code128(nLinha-10.5,80, REPLACE(cCodBar,".",""), 1, 20 , .F.,,200  )
                                
                                //nLinha += nEspLin*1.6
                                //oPrinter:Say(nLinha,140,""+cCodBar+""  ,oTFont10)
                                cTexto := rtrim(Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"))
                                oPrinter:Say( nLinha, 25, SubStr(cTexto,1,40),oTFont12)

                                nLinha += nEspLin*0.60
                                oPrinter:Line(nLinha    , 10        , nLinha, nLargura,0,"-7")

                                nLinAnt  := nLinha
                                nLinAnt2 := nLinha

                                nLinha += nEspLin*0.8    
                                nEspLin := 7 
                                oPrinter:Say(nLinha,15 ,"Fornecedor"  ,oTFont14)
                                oPrinter:Say(nLinha,330,"Nota Fiscal" ,oTFont14)
                                
                                
                                nLinha += nEspLin*1.2
                                //cDescricao := Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
                                //cDescricao := Left(cDescricao,20)      

                                If aNota[5] == "B"
                                    cTexto := Posicione("SA1",1,xFilial("SA1")+CB0->CB0_FORNEC+CB0->CB0_LOJAFO,"A1_NOME")  
                                Else
                                    cTexto := Posicione("SA2",1,xFilial("SA2")+CB0->CB0_FORNEC+CB0->CB0_LOJAFO,"A2_NOME")
                                EndIf
                                //nLinha += 20
                                oPrinter:Say(nLinha,25 , Left(CB0->CB0_FORNEC+"-"+CB0->CB0_LOJAFO+cTexto,25) ,oTFont14)
                                oPrinter:Say(nLinha,330, CB0->CB0_NFENT+"-"+CB0->CB0_SERIEE                  ,oTFont14)

                                nLinha += nEspLin*0.4
                                oPrinter:Line(nLinAnt2   , 320      , nLinha, 320     ,0,"-7")  //cria linha vertical
                                oPrinter:Line(nLinha    ,  010      , nLinha, nLargura,0,"-7")

                                nLinAnt3 := nLinha
                                nLinha += nEspLin*1.2    
                                oPrinter:Say(nLinha,15 ,"Qtd.:"                  ,oTFont14)
                                oPrinter:Say(nLinha,150,"U.M."             ,oTFont14)
                                oPrinter:Say(nLinha,200,"Data Ent."             ,oTFont14)
                                oPrinter:Say(nLinha,330,"R.I.R" ,oTFont14)
                                
                                nLinha += nEspLin*0.75
                                //oPrinter:Say(nLinha,330 ,"Código: "+RTRIM(CB0->CB0_CODPRO)    ,oTFont12)
                                
                                nLinha += nEspLin*0.75
                                oPrinter:Say(nLinha,15 ,cValtoChar(CB0->CB0_QTDE) ,oTFont14)
                                
                                cTexto := rtrim(Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_UM"))
                                oPrinter:Say( nLinha, 150, cTexto ,oTFont14)
                                oPrinter:Say( nLinha, 200, dtoc(CB0->CB0_DTNASC) ,oTFont14)
                                
                                //nLinha += nEspLin*0.20
                                oPrinter:Say(nLinha,330 ,CB0->CB0_CODETI        ,oTFont14)

                                nEspLin  := 10
                                nLinha   += nEspLin*0.3 
                                oPrinter:Line(nLinha     , 10       , nLinha , nLargura,0,"-7")
                                oPrinter:Line(nLinAnt3   , 140      , nLinha, 140      ,0,"-7")  //cria linha vertical
                                oPrinter:Line(nLinAnt3   , 195      , nLinha, 190      ,0,"-7")  //cria linha vertical
                                oPrinter:Line(nLinAnt3   , 320      , nLinha, 320      ,0,"-7")  //cria linha vertical
                                nLinAnt3 := nLinha
                                                
                                nLinha += nEspLin*0.5

                                cCodBar1 := cValtoChar(CB0->CB0_QTDE)
                                cTmpBar  := ""
                                For nX := 1 to 4-len(cCodBar1)
                                    cTmpBar += "0"
                                Next nX
                                cCodBar := cTmpBar + cCodBar1
                                //oPrinter:Code128(nLinha,50, cCodBar1, 1, 20 , .F.,,40 )
    
                                cCodBar2 := CB0->CB0_CODETI 
                                oPrinter:Code128(nLinha,170, cCodBar2, 1, 17 , .F.,,80 )   

                                nLinha += nEspLin*2.5
                                oPrinter:Say(nLinha,360 ,"FSATO 8.5.2.103 REV 03",oTFont12) 

                                nLinha += nEspLin*0.1
                                oPrinter:Line(nLinha     , 10       , nLinha , nLargura ,0 ,"-7")
                                oPrinter:Line(nLinInic   , 10       , nLinha , 10       ,0 ,"-7")  //cria linha vertical
                                //oPrinter:Line(nLinAnt3   , 320      , nLinha, 320      ,0,"-7")  //cria linha vertical
                                oPrinter:Line(nLinInic   , nLargura , nLinha , nLargura ,0 ,"-7")  //cria linha vertical

                            oPrinter:EndPage()
                EndIf
                CB0->(DbSkip())
            Enddo
        EndIf     

        oPrinter:cPathPDF:= cPathInServer 
    
        oPrinter:Preview()  

        //RestArea(aArea)   
Return

Static Function GetAheader(aCampos)
    //Local aArea     := GetArea()
    Local aHead := {}
    Local nI := 0

    //monta array padrao aHeader
        dbSelectArea("SX3")
        SX3->(dbSetOrder(2))
        For nI := 1 to Len(aCampos)
    	    If dbSeek(aCampos[nI][1],.T.) 
                AADD(aHead,{IIF(!Empty(aCampos[nI][2]),rtrim(aCampos[nI][2]),rtrim(X3Titulo())),;
                            aCampos[nI][3] ,;//SX3->X3_CAMPO,;                                                                                                                                                                                              
                            SX3->X3_PICTURE,;
                            SX3->X3_TAMANHO,;
                            SX3->X3_DECIMAL,;
                            SX3->X3_VALID,;
                            SX3->X3_USADO,;//reservado
                            SX3->X3_TIPO,;
                            SX3->X3_F3,;//reservado
                            SX3->X3_CONTEXT,;
                            SX3->X3_CBOX,;
                            SX3->X3_RELACAO,;
                            SX3->X3_WHEN})//reservado
		    Endif
	    Next
	//RestArea(aArea)
Return aHead

