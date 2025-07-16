#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTR07           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Rotina para impressão das solicitações ao dep. realizadas      ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 20/01/2019         ¦ Last Modified time ¦  20/01/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTR07()
    Local aArea   := GetArea()
    Local aDados  := {}
    Local cVolumes      :=    ''
    Local lPAF_XVOL   :=  PAF->(FieldPos('PAF_XVOL')) > 0


    PAF->(DbSelectArea("PAF"))
    PAF->(DbSetOrder(1))
    If PAF->(dbSeek(xFilial("PAF")+PAE->PAE_CODIGO))
        While !PAF->(EOF()) .and. PAE->PAE_CODIGO == PAF->PAF_CODIGO
            If lPAF_XVOL
                cVolumes    +=  AllTrim( PAF->PAF_XVOL ) + ','
            EndIf
            aAdd(aDados,{PAF->PAF_ITEM,;    //1
                        PAF->PAF_PRODUT,;   //2
                        PAF->PAF_DESC,;     //3
                        PAF->PAF_QUANT})    //4
            PAF->(DbSkip())
        Enddo

        If !Empty( cVolumes )
            cVolumes    :=  SubStr( cVolumes, 1, Len( cVolumes ) - 1 )

        Else
            cVolumes    :=  '--'

        EndIf
    EndIf

    //realiza impressão da simulação
    MsgRun("Imprimindo..."    ,"Aguarde...",{|| GetReport(aDados, cVolumes)  })

    RestArea(aArea)
Return

Static Function GetReport(aDados, cVolumes)
    Local cFileName       := "SAESTR07_"+Dtos(MSDate())+StrTran(Time(),":","")
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
    Local nFrom           := 0
    Local nPagina         := 0
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
    oTFont12   := TFont():New('ARIAL',,-12,.T.)
    oTFont12_2 := TFont():New('ARIAL',,-12,.T.)

    oTFont16:Bold := .T.
    oTFont12:Bold := .T.

    aAdd(aSize,oPrinter:PaperSize()) //Retorna o tamanho do papel.
    aAdd(aSize,oPrinter:nHorzSize()) //Retorno largura da página.
    aAdd(aSize,oPrinter:nVertSize()) //Retorno altura da página.
    aAdd(aSize,oPrinter:nHorzRes())  //Retorna a resolução horizontal da impressora configurada.
    aAdd(aSize,oPrinter:nVertRes())  //Retorna a resolução vertical da impressora configurada.
    aAdd(aSize,oPrinter:nLogPixelX())//Retorna a resolução vertical, em pixels, da impressora configurada.
    aAdd(aSize,oPrinter:nLogPixelY())//Retorna a resolução horizontal, em pixels, da impressora configurada.

    While nFrom < len(aDados)
        nFrom ++
    
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
                nColuna := 420
                nEspacoLin := 25

                DbSelectArea("SM0")
                DbSetOrder(1)
                While !EOF() .and. SM0->M0_CODFIL <> '010101'
                    DbSkip()
                Enddo 
        
                oPrinter:Say( nLinha, nColuna, ALLTRIM(SM0->M0_NOMECOM),oTFont16)
                oPrinter:SayBitmap( 20, 100, "\system\lgrl01.bmp" , 220, 220)

                
                oPrinter:Say( nLinha, nColuna+1000, "Emitido em "+dtoc(date())+'-'+time(), oTFont12)
                oPrinter:Say( nLinha, nColuna+1700, "Página "+cvaltochar(nPagina), oTFont12)
            
                nColuna := 70
                nEspacoLin := 35

            //título relatório
                
                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                                
                nLinha += nEspacoLin*2
                oPrinter:SayAlign( nLinha,nColuna,"Solicitação de materiais - Almoxarifado",oTFont16,nWidght,,, 2, 1 )

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)
            
            // cabeçalho 
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Solicitação: "+PAE->PAE_CODIGO            ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Data Solicitação: "+dtoc(PAE->PAE_EMISSA) ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Data Necessidade: "+dtoc(PAE->PAE_DTNEC)  ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Solicitante: "+PAE->PAE_NOME              ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Volumes: "+cVolumes                       ,oTFont12)

            //cabeçalho colunas
                nLinha += nEspacoLin*2
                oPrinter:Say( nLinha, nColuna+0000, "Item"        ,oTFont16)
                oPrinter:Say( nLinha, nColuna+0260, "Produto"     ,oTFont16)
                oPrinter:Say( nLinha, nColuna+1800, "Quantidade"  ,oTFont16)

            //cria linha horizontal
                nLinha += nEspacoLin
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)

            //itens colunas
                nQtdPag := 0
                While nQtdPag <= 25
                    If nFrom <= len(aDados)
                        nLinha += nEspacoLin*2
                        oPrinter:Say( nLinha, nColuna+0000, aDados[nFrom,1] ,oTFont16)
                        oPrinter:Say( nLinha, nColuna+0260, rtrim(aDados[nFrom,2])+' - '+rtrim(aDados[nFrom,3]) ,oTFont16)
                        oPrinter:Say( nLinha, nColuna+1800, alltrim(Transform(aDados[nFrom,4],"@E 99,999,999,999.9999")) ,oTFont16)
                        nQtdPag++
                    Else
                        exit
                    EndIf

                    nFrom++
                Enddo
        
        oPrinter:EndPage() 

    Enddo

    oPrinter:cPathPDF:= cPathInServer 

    oPrinter:Preview()  

Return
