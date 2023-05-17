#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"
/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTR04           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Relatorio Ordem de Produção                                    ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 26/12/2019         ¦ Last Modified time ¦  26/12/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTR04()
    Local aDados      := {}
    Local aArea       := GetArea()
    Private cMaquina  := ""
    Private cOPerIni  := ""
    Private cOPerFim  := ""

    If Pergunte ("SAESTR04  ",.T.)
        
        cMaquina  := MV_PAR01

        If Empty(MV_PAR02)
            cOPerIni := ""
            cOPerFim := "ZZZ"
        Else
            cOPerIni := MV_PAR02
            cOPerFim := MV_PAR02
        EndIf

        MsgRun("Verificando Dados..."    ,"Aguarde...",{|| aDados := GetOP()})
        
        If len(aDados) > 0
            MsgRun("Imprimindo..."           ,"Aguarde...",{|| GetReport(aDados)})
        EndIf

    EndIf

    Pergunte ("MTA650    ",.F.)
    RestArea(aArea)
Return

Static Function GetReport(aDados)
    Local cFileName       := "SAESTR04"+Dtos(MSDate())+StrTran(Time(),":","")
    //Local cPathInServer   := "C:\temp\"
    Local cPathInServer   := GetTempPath()
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local lTReport        := .F.
    Local lServer         := .T.
    Local lPDFAsPNG       := .T.
    Local lRaw            := .F.
    Local lViewPDF        := .T.
    Local nQtdCopy        := 1   
    Local aSize           := {}
    Local nFrom           := 0
    Local nPagina         := 0
    Local nI              := 0
    Private nHeight       := 75
    Private nWidght       := 90
    Private n8000Line     := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter     

    oPrinter := FWMSPrinter():New(cFileName,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,,/*alltrim(cPrinter)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
    
    oPrinter:SetPortrait()

    oTFont10   := TFont():New('ARIAL',,-10,.F.)
    oTFont16   := TFont():New('ARIAL',,-16,.T.)
    oTFont16_2 := TFont():New('ARIAL',,-16,.T.)
    oTfont14_2   := TFont():New('ARIAL',,-14,.T.)
    oTfont14   := TFont():New('ARIAL',,-12,.T.)
    oTfont14 := TFont():New('ARIAL',,-12,.T.)

    oTFont16:Bold := .T.
    oTfont14:Bold := .T.

    aAdd(aSize,oPrinter:PaperSize()) //Retorna o tamanho do papel.
    aAdd(aSize,oPrinter:nHorzSize()) //Retorno largura da página.
    aAdd(aSize,oPrinter:nVertSize()) //Retorno altura da página.
    aAdd(aSize,oPrinter:nHorzRes())  //Retorna a resolução horizontal da impressora configurada.
    aAdd(aSize,oPrinter:nVertRes())  //Retorna a resolução vertical da impressora configurada.
    aAdd(aSize,oPrinter:nLogPixelX())//Retorna a resolução vertical, em pixels, da impressora configurada.
    aAdd(aSize,oPrinter:nLogPixelY())//Retorna a resolução horizontal, em pixels, da impressora configurada.

    cOperacao := ""
    While nFrom <= len(aDados)
        nFrom ++

        If nFrom > len(aDados)
            loop
        EndIf

        If cOperacao == aDados[nFrom,19]
            loop
        EndIf

        cOperacao := aDados[nFrom,19]
    
        oPrinter:StartPage()

            //armazena número da página
            nPagina+= 1

            //insere box ao redor da página
                nHeight := oPrinter:NPAGEHEIGHT
                nWidght := oPrinter:NPAGEWIDTH

                nHeight := nHeight-(nHeight*0.05)
                nWidght := nWidght-(nWidght*0.015)

                oPrinter:Box(nHeight,nWidght,20,20)

            //dados empresa
                nLinha  := 70
                nColuna := 70
                nEspacoLin := 25

                DbSelectArea("SM0")
                DbSetOrder(1)
                While !EOF() .and. SM0->M0_CODFIL <> FwCodFil()
                    DbSkip()
                Enddo 
        
                cTexto := ALLTRIM(SM0->M0_NOMECOM)+' - '+rtrim(SM0->M0_FILIAL)
                oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )
                oPrinter:SayBitmap( 20, 100, "\system\lgrl01.bmp" , 110, 110)
                
                //nLinha += nEspacoLin*2
                //oPrinter:Say( nLinha, nColuna, "CNPJ: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + Space(8) /*+ Transform(SM0->M0_INSC, "@R 99.999.999-99")*/, oTfont14)
                
                //nLinha += nEspacoLin*2
                //oPrinter:Say( nLinha, nColuna, AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB, oTfont14)
                //oPrinter:Say( nLinha, nColuna+1000, "Emitido em "+dtoc(date())+'-'+time(), oTfont14)
                
                //nLinha += nEspacoLin*2
                //oPrinter:Say( nLinha, nColuna, "CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - "+"Fone/Fax: "+SM0->M0_TEL, oTfont14)
                //oPrinter:Say( nLinha, nColuna+1000, "Emitido em "+dtoc(date())+'-'+time(), oTfont14)
                //oPrinter:Say( nLinha, nColuna+1700, "Página "+cvaltochar(nPagina), oTfont14)
            
                nColuna := 70
                nEspacoLin := 35

            //título relatório
                
                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                                
                nLinha += nEspacoLin
                cTexto := "ORDEM DE PRODUÇÃO - "+aDados[1,5]
                oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)
        
                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna, "Processo: "+aDados[nFrom,6]       ,oTfont14)
                oPrinter:Say( nLinha, nColuna+800, "Cortar: "  +aDados[nFrom,21]  ,oTfont14)
                oPrinter:Say( nLinha, nColuna+1600, "Qtd de Tiras/Peça: "         ,oTfont14)

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna     ,"Produto: "   +rtrim(aDados[nFrom,2])+' - '+rtrim(aDados[nFrom,3]),oTfont14)
                oPrinter:Say( nLinha, nColuna+1400,"Quantidade: "+cvaltochar(aDados[nFrom,4])+' - '+Posicione("SB1",1,xFilial("SB1")+aDados[nFrom,2],"B1_UM"),oTfont14)
                
                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna     , "Cod. do Cliente: "+aDados[nFrom,16]     ,oTfont14)
                
                cTexto := "Total de Horas: " + alltrim(Transform(aDados[nFrom,23],"@E 99,999,999,999.9999"))
                oPrinter:Say( nLinha, nColuna+1400, cTexto                                  ,oTfont14)
                
                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna     , "Cliente: "        +aDados[nFrom,17]     ,oTfont14)
                
                cTexto := "Peças por Hora: " + alltrim(Transform(aDados[nFrom,24],"@E 99,999,999,999.9999"))
                oPrinter:Say( nLinha, nColuna+1400, cTexto ,oTfont14)
                
                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna     , "Máquina:"         +cMaquina             ,oTfont14)
                
                cTexto := "Ciclo Padrão: " + alltrim(Transform(aDados[nFrom,25],"@E 99,999,999,999"))
                oPrinter:Say( nLinha, nColuna+1400, cTexto                                   ,oTfont14)
                
                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna     , "Data de Início: " +aDados[nFrom,1]      ,oTfont14)
                
                cTexto := "Hora de Início: " + alltrim(Transform(aDados[nFrom,20],"@R 99:99"))
                oPrinter:Say( nLinha, nColuna+1400, cTexto     ,oTfont14)
                
                nLinha += nEspacoLin
                cTexto := "Embalagem Padrão: " + alltrim(Transform(aDados[nFrom,26],"@E 99,999,999,999"))
                oPrinter:Say( nLinha, nColuna     , cTexto                     ,oTfont14)
                
                //oPrinter:Say( nLinha, nColuna+1400, "Class. ABC: "                           ,oTfont14)

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                
                nLinha += nEspacoLin
                cTexto := "Relação de Matérias Primas"
                oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                nLinha += nEspacoLin
                oPrinter:Say( nLinha, nColuna     , "Código"     ,oTfont14)
                oPrinter:Say( nLinha, nColuna+400 , "Descrição"  ,oTfont14)
                oPrinter:Say( nLinha, nColuna+1700, "Qtd de Uso" ,oTfont14)
                oPrinter:Say( nLinha, nColuna+2000, "UM"         ,oTfont14)

                cCodProd := ""
                For nI:=1 to len(aDados)
                    If cCodProd <> aDados[nI,12] .and. aDados[nI,19] == aDados[nFrom,19]
                        cCodProd := aDados[nI,12] 
                        nLinha += nEspacoLin
                        oPrinter:Say( nLinha, nColuna     , aDados[nI,12]                                           ,oTfont14)
                        oPrinter:Say( nLinha, nColuna+400 , aDados[nI,14]                                           ,oTfont14)
                        oPrinter:Say( nLinha, nColuna+1700, alltrim(Transform(aDados[nI,13],"@E 99,999,999,999.9999")) ,oTfont14)
                        oPrinter:Say( nLinha, nColuna+2000, Posicione("SB1",1,xFilial("SB1")+aDados[nI,12],"B1_UM") ,oTfont14)
                    EndIf
                Next nI

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                                
                nLinha += nEspacoLin
                cTexto := "ACOMPANHAMENTO DE PRODUÇÃO"
                oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                nLinAnt := nLinha
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                nLinha += nEspacoLin
                nColAnt := nColuna
                nEspCol := 240
             
                oPrinter:Say( nLinha, nColuna             , "Turno:"       ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=(nEspCol/2), "Data:"        ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol    , "Hr. Início:"  ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol    , "Produção:"    ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol+50 , "Acumulado:"   ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol+30 , "Rejeitado:"   ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol    , "Hr. Término:" ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol-30 , "Matrícula:"   ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol    , "Cód. Parada:" ,oTfont14)
                oPrinter:Say( nLinha, nColuna+=nEspCol    , "Máq."         ,oTfont14)
                
                nLinha += nEspacoLin
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)                
                
                nColuna := nColAnt

                nQtdPag := 0
                While nQtdPag <= 17
                    nLinha += nEspacoLin*1.5 //1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                    nQtdPag++
                Enddo

                nEspCol := 230
                nColuna+=(nEspCol/2)
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol+50
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol+50
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
                nColuna+=nEspCol
                oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical

                nLinha += nEspacoLin*4.5
                cCodBar := aDados[1,5]
                oPrinter:Code128C( nLinha+5, 1000, cCodBar, 40 )

                CYN->(DbSelectArea("CYN"))
                CYN->(DbGoTop())
                While !(CYN->(EOF()))
                    nColuna := nColAnt
                    nEspCol := 800
                    nLinha += nEspacoLin*1.5
                        
                    oPrinter:Say( nLinha, nColuna              , alltrim(CYN->CYN_CDSP)+' - '+alltrim(CYN->CYN_DSSP),oTfont14)
                    CYN->(DbSkip()) 

                    If !(CYN->(EOF()))
                        oPrinter:Say( nLinha, nColuna+=nEspCol , alltrim(CYN->CYN_CDSP)+' - '+alltrim(CYN->CYN_DSSP),oTfont14)
                        CYN->(DbSkip())
                    EndIf

                    If !(CYN->(EOF()))
                        oPrinter:Say( nLinha, nColuna+=nEspCol , alltrim(CYN->CYN_CDSP)+' - '+alltrim(CYN->CYN_DSSP),oTfont14)
                        CYN->(DbSkip())
                    EndIf

                Enddo

        oPrinter:EndPage() 
        
        If MV_PAR03 == 1
            //Iprime página para as requisções
            oPrinter:StartPage()

                //armazena número da página
                nPagina+= 1

                //insere box ao redor da página
                    nHeight := oPrinter:NPAGEHEIGHT
                    nWidght := oPrinter:NPAGEWIDTH

                    nHeight := nHeight-(nHeight*0.05)
                    nWidght := nWidght-(nWidght*0.015)

                    oPrinter:Box(nHeight,nWidght,20,20)

                //dados empresa
                    nLinha  := 70
                    nColuna := 70
                    nEspacoLin := 25

                    DbSelectArea("SM0")
                    DbSetOrder(1)
                    While !EOF() .and. SM0->M0_CODFIL <> FwCodFil()
                        DbSkip()
                    Enddo 
            
                    cTexto := ALLTRIM(SM0->M0_NOMECOM)+' - '+rtrim(SM0->M0_FILIAL)
                    oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )
                    oPrinter:SayBitmap( 20, 100, "\system\lgrl01.bmp" , 110, 110)
                    
                    //nLinha += nEspacoLin*2
                    //oPrinter:Say( nLinha, nColuna, "CNPJ: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + Space(8) /*+ Transform(SM0->M0_INSC, "@R 99.999.999-99")*/, oTfont14)
                    
                    //nLinha += nEspacoLin*2
                    //oPrinter:Say( nLinha, nColuna, AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB, oTfont14)
                    //oPrinter:Say( nLinha, nColuna+1000, "Emitido em "+dtoc(date())+'-'+time(), oTfont14)
                    
                    //nLinha += nEspacoLin*2
                    //oPrinter:Say( nLinha, nColuna, "CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - "+"Fone/Fax: "+SM0->M0_TEL, oTfont14)
                    //oPrinter:Say( nLinha, nColuna+1000, "Emitido em "+dtoc(date())+'-'+time(), oTfont14)
                    //oPrinter:Say( nLinha, nColuna+1700, "Página "+cvaltochar(nPagina), oTfont14)
                
                    nColuna := 70
                    nEspacoLin := 35

                //título relatório
                    
                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                                    
                    nLinha += nEspacoLin
                    cTexto := "ORDEM DE PRODUÇÃO - "+aDados[1,5]
                    oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
            
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna, "Processo: "+aDados[nFrom,6]       ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+800, "Cortar: "  +aDados[nFrom,21]  ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+1600, "Qtd de Tiras/Peça: "         ,oTfont14)

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna     ,"Produto: "   +rtrim(aDados[nFrom,2])+' - '+rtrim(aDados[nFrom,3]),oTfont14)
                    oPrinter:Say( nLinha, nColuna+1400,"Quantidade: "+cvaltochar(aDados[nFrom,4])+' - '+Posicione("SB1",1,xFilial("SB1")+aDados[nFrom,2],"B1_UM"),oTfont14)
                    
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna     , "Cod. do Cliente: "+aDados[nFrom,16]     ,oTfont14)
                    
                    cTexto := "Total de Horas: " + alltrim(Transform(aDados[nFrom,23],"@E 99,999,999,999.9999"))
                    oPrinter:Say( nLinha, nColuna+1400, cTexto                                  ,oTfont14)
                    
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna     , "Cliente: "        +aDados[nFrom,17]     ,oTfont14)
                    
                    cTexto := "Peças por Hora: " + alltrim(Transform(aDados[nFrom,24],"@E 99,999,999,999.9999"))
                    oPrinter:Say( nLinha, nColuna+1400, cTexto ,oTfont14)
                    
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna     , "Máquina:"         +cMaquina             ,oTfont14)
                    
                    cTexto := "Ciclo Padrão: " + alltrim(Transform(aDados[nFrom,25],"@E 99,999,999,999"))
                    oPrinter:Say( nLinha, nColuna+1400, cTexto                                   ,oTfont14)
                    
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna     , "Data de Início: " +aDados[nFrom,1]      ,oTfont14)
                    
                    cTexto := "Hora de Início: " + alltrim(Transform(aDados[nFrom,20],"@R 99:99"))
                    oPrinter:Say( nLinha, nColuna+1400, cTexto     ,oTfont14)
                    
                    nLinha += nEspacoLin
                    cTexto := "Embalagem Padrão: " + alltrim(Transform(aDados[nFrom,26],"@E 99,999,999,999"))
                    oPrinter:Say( nLinha, nColuna     , cTexto                     ,oTfont14)
                    
                    //oPrinter:Say( nLinha, nColuna+1400, "Class. ABC: "                           ,oTfont14)

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                    
                    nLinha += nEspacoLin
                    cTexto := "Relação de Matérias Primas"
                    oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna     , "Código"     ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+400 , "Descrição"  ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+1700, "Qtd de Uso" ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+2000, "UM"         ,oTfont14)

                    cCodProd := ""
                    For nI:=1 to len(aDados)
                        If cCodProd <> aDados[nI,12] .and. aDados[nI,19] == aDados[nFrom,19]
                            cCodProd := aDados[nI,12] 
                            nLinha += nEspacoLin
                            oPrinter:Say( nLinha, nColuna     , aDados[nI,12]                                           ,oTfont14)
                            oPrinter:Say( nLinha, nColuna+400 , aDados[nI,14]                                           ,oTfont14)
                            oPrinter:Say( nLinha, nColuna+1700, alltrim(Transform(aDados[nI,13],"@E 99,999,999,999.9999")) ,oTfont14)
                            oPrinter:Say( nLinha, nColuna+2000, Posicione("SB1",1,xFilial("SB1")+aDados[nI,12],"B1_UM") ,oTfont14)
                        EndIf
                    Next nI

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                                    
                    nLinha += nEspacoLin
                    cTexto := "REQUISIÇÃO DE MATERIAIS"
                    oPrinter:SayAlign( nLinha,nColuna,cTexto,oTfont14,nWidght,,, 2, 1 )

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    nLinAnt := nLinha
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                    nLinha += nEspacoLin
                    nColAnt := nColuna
                    nEspCol := 240
                
                    oPrinter:Say( nLinha, nColuna             , "Código:"       ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol    , "Data:"        ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol    , "Hora:"         ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol    , "Qtd. Req.:"    ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol+50 , "Dtd. Acum.:"   ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol+30 , "Qtd. Devolv.:" ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol    , "RIR:"          ,oTfont14)
                    oPrinter:Say( nLinha, nColuna+=nEspCol-30 , "Visto:"        ,oTfont14)
                    
                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)                
                    
                    nColuna := nColAnt

                    nQtdPag := 0
                    While nQtdPag <= 37
                        nLinha += nEspacoLin*1.5 //1.5
                        oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                        nQtdPag++
                    Enddo

                    nEspCol := 230
                    nColuna+=nEspCol
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol+50
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol+50
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol
                    oPrinter:Line(nLinAnt, nColuna , nHeight, nColuna,0,"-7")  //cria linha vertical
                    nColuna+=nEspCol
                    //oPrinter:Line(nLinAnt, nColuna , nLinha, nColuna,0,"-7")  //cria linha vertical
            oPrinter:EndPage() 
        EndIf
    Enddo

    oPrinter:cPathPDF:= cPathInServer 

    oPrinter:Preview()  

Return

Static Function GetOP()
    Local aDados := {}
    
    BeginSql Alias "QRY"
        SELECT
            CONVERT(char,convert(date,C2_DATPRI),103) AS 'EMISSAO'
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
			,D4_COD AS 'EMPENHO'
			,D4_QTDEORI AS 'QTDEMP'
			,RTRIM((SELECT B1_DESC FROM %table:SB1% WHERE D_E_L_E_T_ = '' AND B1_COD = D4_COD)) AS 'DESCEMP'
            ,B1_XPASSO AS 'PASSO'
            ,G2_LOTEPAD/G2_TEMPAD AS 'PECASHORA'
            ,C2_QUANT / (G2_LOTEPAD/G2_TEMPAD) AS 'TOTALHORA'
            ,3600 / (G2_LOTEPAD/G2_TEMPAD) AS 'CICLO'
            ,C2_XHORA AS 'HORA'
            ,(SELECT TOP 1 CONVERT(VARCHAR,B5_ESPESS)+' x '+CONVERT(VARCHAR,B5_LARG)+' x '+CONVERT(VARCHAR,B5_COMPR)+' mm' FROM SB5010 WHERE D_E_L_E_T_ = '' AND B5_COD = B1_COD) as 'CORTAR'
            ,B1_QE AS 'EMB'
            ,B1_XTIRA AS 'TIRA'
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
		LEFT JOIN %table:SD4% SD4
			ON SD4.D4_FILIAL = C2_FILIAL AND D4_OP = C2_NUM+C2_ITEM+C2_SEQUEN AND SD4.D_E_L_E_T_ = ''
        WHERE
            SC2.D_E_L_E_T_ = ''
            AND C2_FILIAL = %Exp:xfilial("SC2")%
            AND C2_NUM+C2_ITEM+C2_SEQUEN = %Exp:SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN%
            AND G2_OPERAC >= %Exp:cOperIni%
            AND G2_OPERAC <= %Exp:cOperFim%
            AND LEFT(D4_COD,3) <> 'MOD'
        ORDER BY
            C2_NUM+C2_ITEM+C2_SEQUEN, G2_OPERAC
    EndSql

    If QRY->(EOF())
        Aviso("Atenção","Não foram encontrados dados para os parâmetros informados. Confira se o produto está empenhado e se a operação informada está correta.")
    Else

        While !(QRY->(EOF()))
            aAdd(aDados,{;
                QRY->EMISSAO,;    //01
                QRY->PRODUTO,;    //02
                QRY->DESC,;       //03
                QRY->QTD,;        //04
                QRY->OP,;         //05
                QRY->OPERACAO,;   //06
                QRY->DESTCOD,;    //07
                QRY->DESTDES,;    //08
                QRY->CLIENTE,;    //09
                QRY->CODCLI,;     //10
                QRY->ORIGEM,;     //11
                QRY->EMPENHO,;    //12
                QRY->QTDEMP,;     //13
                QRY->DESCEMP,;    //14
                QRY->PASSO,;      //15
                QRY->CODCLI,;     //16
                QRY->CLIENTE,;    //17
                QRY->PECASHORA,;  //18
                QRY->OPERAC,;     //19
                QRY->HORA,;       //20
                QRY->CORTAR,;     //21
                QRY->TIRA,;       //22
                QRY->TOTALHORA,;  //23
                QRY->PECASHORA,;  //24
                QRY->CICLO,;      //25
                QRY->EMB,;        //26
            })
            QRY->(DbSkip())
        Enddo

    EndIf

    QRY->(DbCloseArea())
    
Return aDados
