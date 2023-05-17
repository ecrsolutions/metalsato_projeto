#include "Rptdef.CH"
#include "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"
/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTR02           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Imprime etiquetas - Ordem de Produção                          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 12/12/2019         ¦ Last Modified time ¦  12/12/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTR02()
    Private aCols  := {}
    Private aCols2 := {}
    Private cPathInServer   := "C:\temp\"
    Private aOP    := {}
    Private oPrinter 

    BeginSql ALias "TMPQRY"
        SELECT
            CONVERT(char,convert(date,C2_EMISSAO),103) AS 'EMISSAO'
            ,C2_PRODUTO AS 'PRODUTO'
            ,B1_DESC AS 'DESC'
            ,C2_QUANT AS 'QTD'
            ,C2_NUM+C2_ITEM+C2_SEQUEN AS 'OP'
            ,C2_ROTEIRO AS 'ROTEIRO'
			,G2_OPERAC AS 'OPERAC'
            ,right('0'+G2_OPERAC,2)+'/'+CONVERT(VARCHAR,(SELECT COUNT(*) FROM SG2010 WHERE D_E_L_E_T_ = '' AND G2_PRODUTO = C2_PRODUTO AND G2_CODIGO = C2_ROTEIRO))+' - '+RTRIM(G2_DESCRI) AS 'OPERACAO'
            ,ISNULL((SELECT TOP 1 G2_OPERAC FROM %table:SG2% A WHERE A.D_E_L_E_T_ = '' AND A.G2_PRODUTO = C2_PRODUTO AND A.G2_CODIGO = C2_ROTEIRO AND A.G2_OPERAC > SG2.G2_OPERAC ORDER BY A.G2_OPERAC ASC ),'CLIENTE') AS 'DESTCOD'
	        ,ISNULL((SELECT TOP 1 G2_DESCRI FROM %table:SG2% A WHERE A.D_E_L_E_T_ = '' AND A.G2_PRODUTO = C2_PRODUTO AND A.G2_CODIGO = C2_ROTEIRO AND A.G2_OPERAC > SG2.G2_OPERAC ORDER BY A.G2_OPERAC ASC ),'CLIENTE') AS 'DESTDES'
            ,ISNULL(RTRIM(A1_NOME)+' - '+A1_COD+'-'+A1_LOJA,'') AS 'CLIENTE'
	        ,ISNULL(RTRIM(A7_CODCLI),'') AS 'CODCLI'
            ,ISNULL(RTRIM(HB_NOME),'') AS 'ORIGEM'
        FROM %table:SC2% SC2
        LEFT JOIN %table:SB1% SB1
            ON C2_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ = ''
        LEFT JOIN %table:SA1% SA1
            ON C2_XCODCLI = A1_COD AND C2_XCODLOJ = A1_LOJA AND SA1.D_E_L_E_T_ = ''
        LEFT JOIN %table:SA7% SA7 
            ON A7_PRODUTO = C2_PRODUTO AND A7_CLIENTE = C2_XCODCLI AND A7_LOJA = C2_XCODLOJ AND SA7.D_E_L_E_T_  = '' 
        INNER JOIN %table:SG2% SG2
            ON SG2.G2_FILIAL = C2_FILIAL AND SG2.G2_CODIGO = C2_ROTEIRO AND SG2.G2_PRODUTO = C2_PRODUTO AND SG2.D_E_L_E_T_ = ''
        LEFT JOIN %table:SHB% SHB
	        ON SG2.G2_FILIAL = HB_FILIAL AND HB_COD = SG2.G2_CTRAB AND SHB.D_E_L_E_T_ = ''
        WHERE
            SC2.D_E_L_E_T_ = ''
            AND C2_NUM+C2_ITEM+C2_SEQUEN = %Exp:SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN%
        ORDER BY
            C2_NUM+C2_ITEM+C2_SEQUEN, G2_OPERAC
    EndSql
    
    While !EOF()
        
        aAdd(aCols,{;   
            stod(TMPQRY->EMISSAO),;
            TMPQRY->PRODUTO,;
            TMPQRY->DESC,;
            TMPQRY->QTD,;
            TMPQRY->ROTEIRO,;
            TMPQRY->OPERACAO,;
            0,;
            0,;
            "  ",;
            .F.})
        
        DbSkip()

    Enddo

    TMPQRY->(DbCloseArea())

    MostraTela()

    Pergunte ("MTA650    ",.F.)

Return

Static Function MostraTela()
    Local aTamanho    := MsAdvSize() 
	Local nJanLarg    := aTamanho[5]
	Local nJanAltu    := aTamanho[6]
    Local aCampos     := {}
    Local aCampos2    := {}
    Local aHead       := {}
    Local aHead2      := {}
    Local aAlter      := {"ETQDE","ETQPOR","TURNO"}
    Local aAlter2     := {}
    Private aButtons  := {}
    Private oDlg      := Nil
    Private oBrw      := Nil

    nAltIni := aTamanho[1]
    nAltFim := nJanAltu/2

    aAdd(aCampos, { "C2_EMISSAO","Emissão"               ,"EMISSAO"   })
    aAdd(aCampos, { "B1_COD"    , "Produto"              ,"PRODUTO"   })
    aAdd(aCampos, { "B1_DESC"   , "Descrição"            ,"DESCRICAO" })
    aAdd(aCampos, { "C2_QUANT"  , "Qtd. OP"              ,"QTDOP"     })
    aAdd(aCampos, { "C2_ROTEIRO", "Roteiro"              ,"ROTEIRO"   })
    aAdd(aCampos, { "G2_DESCRI" , "Operacação"           ,"OPERACAO"  })
    aAdd(aCampos, { "CB0_QTDE"  , "Qtd. por Etiqueta(s)" ,"ETQDE"     })
    aAdd(aCampos, { "CB0_QTDE"  , "Qtd. de Etiqueta(s)"  ,"ETQPOR"    })
    aAdd(aCampos, { "CB0_XTURNO", "Turno"                ,"TURNO"     })

    aAdd(aCampos2,{ "CB0_DTNASC" , "Emissão"             ,"EMISSAO"  })
    aAdd(aCampos2,{ "CB0_CODETI" , "Lote"                ,"LOTE"     })
    aAdd(aCampos2,{ "CB0_XROTEI" , "Roteiro"             ,"ROTEIRO"  })
    aAdd(aCampos2,{ "CB0_XOPERA" , "Operação"            ,"OPERACAO" })
    aAdd(aCampos2,{ "CB0_QTDE"   , "Qtd. por Etiqueta(s)","ETQDE2"   })
    aAdd(aCampos2,{ "CB0_XTURNO", "Turno"                ,"TURNO"     })

    aHead  := GetAheader(aCampos )
    aHead2 := GetAheader(aCampos2)

    aCols2 := GetEtiq()

    DEFINE MsDialog oDlg TITLE "Etiqueta OP" FROM 000,000 TO nJanAltu,nJanLarg PIXEL

        oGroup1 := TGroup():New(nAltIni+30,1,nAltFim*0.45,(nJanLarg/2),'Dados Ordem de Produção - '+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,oDlg,,,.T.) 
        oBrw :=    MsNewGetDados():New(nAltIni+45,2,nAltFim*0.44,(nJanLarg/2)-5,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter,0,99,"u_VldEtiq2",,"AllwaysTrue",oDlg,aHead,aCols)
        
        oGroup2 := TGroup():New(nAltFim*0.47,1,nAltFim*0.96,(nJanLarg/2),'Etiquetas Geradas - '+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,oDlg,,,.T.) 
        oBrw2  :=  MsNewGetDados():New(nAltFim*0.55,2,nAltFim*0.92,(nJanLarg/2)-5,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter2,0,99,"AllwaysTrue",,"AllwaysTrue",oDlg,aHead2,aCols2)
        
        oDlg:bInit := {||  EnchoiceBar(oDlg,{|| MsgRun("Imprimindo Etiqueta(s)... ","Aguarde...",{||Imprime()}),oDlg:End()},{|| oDlg:End()},,aButtons,,,.F.,.T.,.T.,.T.,.F.,)}

        Aadd(aButtons, {"Gerar Etiqueta(s)", {|| MsgRun("Gerando Etiqueta(s)... ","Aguarde...",{||GeraCB0()})}, "Gerar Etiq...", "Gerar Etiq" , {|| .T.}} )
		    
    ACTIVATE MSDIALOG oDlg CENTERED
Return

User Function VldEtiq2()
    Local lRet := .T.
    If ReadVar() == "M->ETQDE"
        If (&(ReadVar()) * oBrw:aCols[n,8]) > oBrw:aCols[n,4] .or. &(ReadVar()) < 0 
            alert("Quantidade inválida!")
            lret := .F.
        EndIf
    ElseIf ReadVar() == "M->ETQPOR"
        If (&(ReadVar()) * oBrw:aCols[n,7]) > oBrw:aCols[n,4] .or. &(ReadVar()) < 0 
            alert("Quantidade inválida!")
            lret := .F.
        EndIf
    EndIf
Return lRet

Static Function GeraCB0()
    Local cEtiq := GetMv("MV_CODCB0")	
    Local nI := 0
    Local nX := 0

    BEGIN TRANSACTION

    For nI := 1 to Len(oBrw:aCols)
        If !(oBrw:aCols[nI,len(oBrw:aCols[nI])]) .and. oBrw:aCols[nI,7] > 0 .and. oBrw:aCols[nI,8] > 0 
            For nX := 1 to oBrw:aCols[nI,8]
                DbSelectArea("CB0")    
                RecLock("CB0", .T.)	
                    CB0->CB0_FILIAL  := xFilial("CB0")	
                    CB0->CB0_CODETI  := cEtiq
                    CB0->CB0_DTNASC  := Date()
                    CB0->CB0_TIPO    := "01"
                    CB0->CB0_CODPRO  := oBrw:aCols[nI,2]
                    CB0->CB0_QTDE    := oBrw:aCols[nI,7]
                    CB0->CB0_LOCAL   := SC2->C2_LOCAL
                    CB0->CB0_DTVLD   := ctod("31/12/2049")
                    CB0->CB0_OP      := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
                    CB0->CB0_XROTEI  := oBrw:aCols[nI,5]
                    CB0->CB0_XOPERA  := left(oBrw:aCols[nI,6],2)
                    CB0->CB0_XTURNO  := oBrw:aCols[nI,9]
                MsUnLock() // Confirma e finaliza a operação
                   //{"10",{"CBG_CODPRO"    ,"CBG_QTDE"      ,"CBG_LOTE"                    ,"CBG_SLOTE"                   ,"CBG_ARM"    ,"CBG_END"                     ,"CBG_OP"                               ,"CBG_CC"                 ,"CBG_TM"                 ,"CBG_CODETI","CBG_OBS"}},;
                CBLog("10",{oBrw:aCols[nI,2],oBrw:aCols[nI,7],SPACE(TAMSX3("B8_LOTECTL")[1]),SPACE(TAMSX3("B8_NUMLOTE")[1]),SC2->C2_LOCAL,SPACE(TAMSX3("BE_LOCALIZ")[1]),SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,SPACE(TAMSX3("D3_CC")[1]),SPACE(TAMSX3("D3_TM")[1]),cEtiq       ,"Ordem de Produção"})
                cEtiq := soma1(cEtiq)
            Next nX
            oBrw:aCols[nI,7] := 0 
            oBrw:aCols[nI,8] := 0
            oBrw:aCols[nI,9] := "  "
        EndIf
    Next nI

    PutMv("MV_CODCB0",cEtiq)

    aCols2 := GetEtiq()
    
    oBrw2:SetArray(aCols2,.F.)
    oBrw2:ForceRefresh()
    oBrw:ForceRefresh()

    END TRANSACTION


Return

Static Function GetEtiq()
    Local aRetorno := {}

    DbSelectArea("CB0")
    DbSetOrder(7)
    If DbSeek(xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
        While !EOF() .and. rtrim(CB0->CB0_OP) == rtrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
            aAdd(aRetorno,{;
                CB0->CB0_DTNASC,;
                CB0->CB0_CODETI,;
                CB0->CB0_XROTEI,;
                CB0->CB0_XOPERA,;
                CB0->CB0_QTDE,;
                CB0->CB0_XTURNO,;
            })
            DbSkip()
        Enddo
    Else
            aAdd(aRetorno,{;
                ctod(""),;
                "",;
                "",;
                "",;
                "",;
                0,;
            })
    EndIf
    DbCloseArea()

Return aRetorno

Static Function GetAheader(aCampos)
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
	
Return aHead

Static Function Imprime(cDescri,cEan)
    Local cFileName       := "OP_"+Dtos(MSDate())+StrTran(Time(),":","")
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local lTReport        := .F.
    Local lServer         := .F.
    Local lPDFAsPNG       := .T.
    Local lRaw            := .F.
    Local lViewPDF        := .T.
    Local nQtdCopy        := 1   
    Local oTfont          := Nil
    Local nTamMsg         := 0
    Local nPosMsg         := 1
    Local nQtd            := 0
    Local nLinBox         := 0
    Private nMaxLine      := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private nHeight       := 75
    Private nWidght       := 90    
            
    oPrinter := FWMSPrinter():New(cFileName,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,,/*alltrim(cPrinter)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)

    oTFont     := TFont():New('Calibri',,-14,.T.)
    oTFont12   := TFont():New('Calibri',,-14,.T.)
    oTFont3    := TFont():New('Calibri',,-14,.T.)
    oTFont10   := TFont():New('Calibri',,-8,.F.)
    oTFont14   := TFont():New('Calibri',,-14,.T.)
    oTFont16   := TFont():New('Calibri',,-16,.T.)
    oTFont18   := TFont():New('Calibri',,-18,.T.)
    oTFont20   := TFont():New('Calibri',,-20,.T.)
    oTFont26   := TFont():New('Calibri',,-26,.T.)
                
    oTFont:Bold  := .T.
    oTFont12:Bold := .T.
    oTFont20:Bold := .T.
    oTFont3:Bold := .T.

    If !Pergunte(PADR("SAESTR02",Len(SX1->X1_GRUPO)),.T.)
        Return
    EndIf

    DbSelectArea("CB0")
    DbSetOrder(7)
    If DbSeek(xFilial("CB0")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN) 
        While !EOF() .and. rtrim(CB0->CB0_OP) == rtrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)        
            If CB0->CB0_CODETI >= MV_PAR01 .and. CB0->CB0_CODETI <= MV_PAR02
                nQtd++
                
                If Mod(nQtd,2) <> 0
                    oPrinter:StartPage()
                    nLinha := 20
                EndIf
            
                //insere box ao redor da página
                    nHeight := oPrinter:NPAGEHEIGHT
                    nWidght := oPrinter:NPAGEWIDTH

                    nHeight := nHeight-(nHeight*0.05)
                    nWidght := nWidght-(nWidght*0.015)

                    //oPrinter:Box(nHeight/2.3,nWidght,nLinha+20,20)

                    

                //seção1
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)
                    nLinBox1 := nLinha
                    
                    nEspacoLin := 30     
                    nLinha += nEspacoLin*2
                    oPrinter:SayBitmap( nLinha, 100, "\system\lgrl01.bmp" , 220, 140)
                    oPrinter:Say( nLinha, 450, "ETIQUETA DE PRODUÇÃO",oTFont20)
                        
                    nLinha += nEspacoLin*2
                    oPrinter:Say( nLinha, 450, dtoc(CB0->CB0_DTNASC),oTFont26)
                    oPrinter:Say( nLinha, 1800, "Lote",oTFont26)
                        
                    nLinha += nEspacoLin*2
                    oPrinter:Say( nLinha, 450 , "Cód. Sato: "+CB0->CB0_CODPRO,oTFont26)
                    oPrinter:Say( nLinha, 1800, CB0->CB0_CODETI,oTFont26)
                        

                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght) 
                    
                    
                //seção 02
                    nEspacoLin := 60
                    nLinha += nEspacoLin

                    
                    oPrinter:Say( nLinha, 100 , "Descri.:    ",oTFont26)
                    cTexto := Rtrim(Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_DESC"))
                    nTamMsg := len(ltrim(rtrim(cTexto)))
                    nPosMsg := 1
                    nMaxMsg := 37
                    If nTamMsg > nMaxMsg
                        While nTamMsg > nMaxMsg
                            oPrinter:Say( nLinha, 600, SubStr(cTexto,nPosMsg,nMaxMsg),oTFont26)
                            nPosMsg += nMaxMsg
                            nTamMsg -= nMaxMsg
                            nLinha += nEspacoLin
                        Enddo 
                    EndIf
                    oPrinter:Say( nLinha, 600, ltrim(SubStr(cTexto,nPosMsg,nMaxMsg)),oTFont26)

                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)
                    

                    nLinAnt := nLinha 
                    
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100 , "Cod. Cli.: ",oTFont26)

                    oPrinter:Say( nLinha, 1100 , "Cliente: ",oTFont26)
                    oPrinter:Say( nLinha, 1500 , left(Posicione("SA1",1,xFilial("SA1")+SC2->C2_XCODCLI+SC2->C2_XCODLOJ,"A1_NOME"),17),oTFont26)

                    
                    cTexto := Rtrim(Posicione("SA7",1,xFilial("SA7")+SC2->C2_XCODCLI+SC2->C2_XCODLOJ+SC2->C2_PRODUTO,"A7_CODCLI"))
                    nTamMsg := len(ltrim(rtrim(cTexto)))
                    nPosMsg := 1
                    nMaxMsg := 15
                    If nTamMsg > nMaxMsg
                        While nTamMsg > nMaxMsg
                            oPrinter:Say( nLinha, 550, SubStr(cTexto,nPosMsg,nMaxMsg),oTFont20)
                            nPosMsg += nMaxMsg
                            nTamMsg -= nMaxMsg
                            nLinha += nEspacoLin
                        Enddo 
                    EndIf
                    oPrinter:Say( nLinha, 550, ltrim(SubStr(cTexto,nPosMsg,nMaxMsg)),oTFont20)

                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)           

                    nLinha += nEspacoLin
                    SG2->(DbSelectArea("SG2"))
                    SG2->(DbSetOrder(1))
                    If SG2->(DbSeek(xFilial("SG2")+CB0->CB0_CODPRO+CB0->CB0_XROTEI+CB0->CB0_XOPERA))
                        cOperaca := CB0->CB0_XOPERA+"/"+cvaltochar(len(oBrw:Acols))+" - "+SG2->G2_DESCRI
                        cOrigem  := rtrim(left(Posicione("SHB",1,xFilial("SHB")+SG2->G2_CTRAB,"HB_NOME"),12))
                        SG2->(DbSkip())
                        If !(SG2->(EOF())) .and. SG2->G2_PRODUTO == CB0->CB0_CODPRO
                            cDestino := rtrim(left(Posicione("SHB",1,xFilial("SHB")+SG2->G2_CTRAB,"HB_NOME"),12))
                        Else
                            //se o produto for PI a proxima operação é a primeira posição do PA correspondente
                            If Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_TIPO") <> "PA"
                                cProdPai := Posicione("SG1",2,xFilial("SG1")+CB0->CB0_CODPRO, "G1_COD"  )
                                cTrabPai := Posicione("SG2",1,xFilial("SG2")+cProdPai       , "G2_CTRAB")
                                cDestino := left(Posicione("SHB",1,xFilial("SHB")+cTrabPai  , "HB_NOME" ),12)
                            Else
                                cDestino := "Cliente"
                            EndIf

                        EndIf
                    Else
                        cOperaca := ""
                        cDestino := ""
                        cOrigem  := ""
                    EndIf
                    SG2->(DbCloseArea())

                    oPrinter:Say( nLinha, 100, "Origem: ",oTFont26)
                    oPrinter:Say( nLinha, 450, cOrigem,oTFont26)
                    
                    oPrinter:Say( nLinha, 1100 , "Destino: ",oTFont26)
                    oPrinter:Say( nLinha, 1500, cDestino,oTFont26)

                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)
                    If MV_PAR03 == 1
                        oPrinter:Line(nLinha, 20, nLinBox1, nWidght,,"-8")  //linha diagonal
                    EndIf 

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "Qtd: ",oTFont26)
                    oPrinter:Say( nLinha, 300, cvaltochar(CB0->CB0_QTDE)+' '+Rtrim(Posicione("SB1",1,xFilial("SB1")+CB0->CB0_CODPRO,"B1_UM")),oTFont26)
                    
                    oPrinter:Say( nLinha, 1100 , "Turno:",oTFont26)
                    oPrinter:Say( nLinha, 1500, CB0->CB0_XTURNO,oTFont26)

                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)
                    If MV_PAR03 == 1
                        oPrinter:Line(nLinha, 20, nLinBox1+nEspacoLin*2.0, nWidght,,"-8") 
                    EndIf 

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "OP: ",oTFont26)
                    oPrinter:Say( nLinha, 300, CB0->CB0_OP,oTFont26)
                    
                    oPrinter:Say( nLinha, 1100 ,"Operação:",oTFont26)
                    cTexto := cOperaca
                    nTamMsg := len(ltrim(rtrim(cTexto)))
                    nPosMsg := 1
                    nMaxMsg := 15
                    If nTamMsg > nMaxMsg
                        While nTamMsg > nMaxMsg
                            oPrinter:Say( nLinha, 1500, SubStr(cTexto,nPosMsg,nMaxMsg),oTFont26)
                            nPosMsg += nMaxMsg
                            nTamMsg -= nMaxMsg
                            nLinha += nEspacoLin
                        Enddo 
                    EndIf
                    oPrinter:Say( nLinha, 1500, ltrim(SubStr(cTexto,nPosMsg,nMaxMsg)),oTFont26)

                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)
                    oPrinter:Line(nLinAnt, 1050 , nLinha, 1050) //cria linha vertical
                
                //seção 03
                    nLinha += nEspacoLin

                    cCodBar := CB0->CB0_CODETI  
                    
                    oPrinter:Say( nLinha+=205, 0900, "____________",oTFont26)
                    oPrinter:Say( nLinha+=000, 1550, "_____________",oTFont26)
                    oPrinter:Say( nLinha+=100, 0900, "  Operador    ",oTFont26)
                    oPrinter:Say( nLinha+=000, 1550, " Aprovado por",oTFont26)

                    oPrinter:Code128C( nLinha, 100, cCodBar, 70 )

                    nLinha += nEspacoLin
                    oPrinter:Line(nLinBox, 20, nLinha, 20) //cria linha vertical
                    oPrinter:Line(nLinBox, nWidght, nLinha, nWidght) //cria linha vertical
                    oPrinter:Line(nLinha, 20 , nLinha, nWidght)

                    nLinha += 205

                If Mod(nQtd,2) == 0
                    oPrinter:EndPage() 
                EndIf  
                
            EndIf
            DbSkip()
        Enddo

        
        If Mod(nQtd,2) <> 0
            oPrinter:EndPage() 
        EndIf  

    EndIf 

    oPrinter:cPathPDF:= cPathInServer 

    oPrinter:Preview()   
Return

