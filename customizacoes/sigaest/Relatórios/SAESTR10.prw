#include "Rptdef.CH"
#include "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"

User Function SAESTR10()
    Local cFileName       := "SAESTR10_"+Dtos(MSDate())+StrTran(Time(),":","")
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
    Local aCols           := {}
    Local nI              := 0
    //Local aArea           := GetArea()
    Private aTMP          := {}
    Private nHeight       := 80
    Private nWidght       := 150
    Private nMaxLine      := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter 

    //PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO 'EST'

    If !Pergunte("SAESTR10  ",.T.)
        return
    Else

        aCols := GetSZ1()

        oPrinter := FWMSPrinter():New(cFileName,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,,/*alltrim(cPrinter)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)
        
        oPrinter:SetPortrait()

        oTFont10   := TFont():New('ARIAL',,-10,.T.)
        oTFont12   := TFont():New('ARIAL',,-12,.T.)
        oTFont16   := TFont():New('ARIAL',,-16,.T.)
        oTFont14   := TFont():New('ARIAL',,-14,.T.)

        oTFont14:Bold := .T.

        oPrinter:SetPaperSize(0,nHeight,nWidght) 

        aAdd(aSize,oPrinter:PaperSize())  //Retorna o tamanho do papel.
        aAdd(aSize,oPrinter:nHorzSize())  //Retorno largura da página.
        aAdd(aSize,oPrinter:nVertSize())  //Retorno altura da página.
        aAdd(aSize,oPrinter:nHorzRes())   //Retorna a resolução horizontal da impressora configurada.
        aAdd(aSize,oPrinter:nVertRes())   //Retorna a resolução vertical da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelX()) //Retorna a resolução vertical, em pixels, da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelY()) //Retorna a resolução horizontal, em pixels, da impressora configurada.

        For nI = 1 to Len(aCols)
            oPrinter:StartPage()

            nLinha  := 10
            nColuna := 30
            nEspLin := 7
            nEspCol := 430

                        
            oPrinter:Say( nLinha , nColuna           , "Fornecedor:" ,oTFont14,,)
            oPrinter:Say( nLinha , nColuna+nEspCol *1, "Num.Pedido:" ,oTFont14,,)
            oPrinter:Say( nLinha , nColuna+nEspCol *2, "Nota Fiscal:",oTFont14,,)

            oPrinter:Say( nLinha+nEspLin*2, nColuna           , LEFT(aCols[nI,1]+SPACE(20),20)  ,oTFont14,,)
            oPrinter:Say( nLinha+nEspLin*2, nColuna+nEspCol *1, aCols[nI,2]                     ,oTFont14,,)
            oPrinter:Say( nLinha+nEspLin*2, nColuna+nEspCol *2, aCols[nI,3]                     ,oTFont14,,)
            
            cCodBar:= rtrim(Replace(aCols[nI,2],"-",""))+rtrim(Replace(aCols[nI,3],"-",""))  
            oPrinter:Code128( nLinha+nEspLin*4.2,nColuna, cCodBar, 0.96, 34 , .F.,,380 )
            
            //oPrinter:FWMSBAR("CODE128" /*cTypeBar*/,1.2/*nRow*/ ,12.5/*nCol*/ ,cCodBar  /*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,.F./*lHorz*/, /*nWidth*/,/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)  
            //oPrinter:Int25(nLinha,nColuna-nEspCol*3,cCodBar,0.73,40,.F.,.F., oTFont10)
            //nLinha += 10

            oPrinter:Say(  nLinha+nEspLin*11, nColuna, "Item:",oTFont12,,)
            oPrinter:Say(  nLinha+nEspLin*12.5, nColuna, aCols[nI,4]  ,oTFont12,,)
            //nLinha += 10

            cCodBar := LEFT(aCols[nI,4]+SPACE(25),25)
            cCodBar += RIGHT("000000000000"+replace(alltrim(TRANSFORM(acols[ni,12],"@E 999999999.999")),",",""),12)
            cCodBar += LEFT(aCols[nI,09]+SPACE(2),2)

            oPrinter:Code128( nLinha+nEspLin*13.5,nColuna, cCodBar, 0.96, 34 , .F.,,380 )

            
            oPrinter:Say( nLinha+nEspLin*22.0, nColuna, "Descri��o do item:",oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*23.5, nColuna, Left(aCols[nI,5],43),oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*25.0, nColuna, "Empresa:"           ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*26.5, nColuna, aCols[nI,6]         ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*28.0, nColuna, "Qtde Vol:"         ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*29.5, nColuna, "1/1"               ,oTFont12,,)

            oPrinter:Say( nLinha+nEspLin*22.0, nColuna+nEspCol*1.3, "Quantidade:"             ,oTFont14,,)
            oPrinter:Say( nLinha+nEspLin*23.5, nColuna+nEspCol*1.3, cValToChar(aCols[nI,12])  ,oTFont14,,)
            oPrinter:Say( nLinha+nEspLin*25.0, nColuna+nEspCol*1.3, "Data de Entrega:"         ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*26.5, nColuna+nEspCol*1.3, dtoc(stod(aCols[nI,7]))   ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*28.0, nColuna+nEspCol*1.3, "Outros:"                  ,oTFont12,,)


            oPrinter:Say( nLinha+nEspLin*22.0, nColuna+nEspCol*1.8, "Hora de Entrega:"                               ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*23.5, nColuna+nEspCol*1.8, Transform(left(aCols[nI,8]+"00",4), "@N 99:99") ,oTFont12,,)
            

            
            oPrinter:Say( nLinha+nEspLin*22.0, nColuna+nEspCol*2.4, "UM:"               ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*23.5, nColuna+nEspCol*2.4, aCols[nI,09]        ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*25.0, nColuna+nEspCol*2.4, "Setor:"            ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*26.5, nColuna+nEspCol*2.4, aCols[nI,10]        ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*28.0, nColuna+nEspCol*2.4, "Local de Entrega:" ,oTFont12,,)
            oPrinter:Say( nLinha+nEspLin*29.5, nColuna+nEspCol*2.4, aCols[nI,11]        ,oTFont12,,)

            oPrinter:EndPage()
            
        Next nI
        
        oPrinter:cPathPDF:= cPathInServer 
    
        oPrinter:Preview()  

    EndIf
      //RESET ENVIRONMENT    
Return


Static Function GetSZ1()

    Local aDados := {}

        BeginSql ALias "QRY"
            SELECT
                'METALURGICA SATO' AS 'TITULO'
                ,RTRIM(SZ1.Z1_PEDCLI)+'-'+RIGHT(LEFT(Z1_XPED,7),2)+'-'+RTRIM(Z1_LINPED) AS 'NUMPED'
                ,Z3_DOC+'-'+RTRIM(Z3_SERIE) AS 'DOC'
                ,ISNULL((SELECT TOP  1 A7_CODCLI FROM %table:SA7% WHERE D_E_L_E_T_ = '' AND A7_CLIENTE = Z1_CLIENTE AND A7_LOJA = Z1_LOJA AND A7_PRODUTO = Z1_PRODUTO),'') AS 'CODCLI' 
                ,ISNULL((SELECT TOP  1 B1_DESC FROM %table:SB1% WHERE D_E_L_E_T_ = '' AND B1_COD = Z1_PRODUTO),'') AS 'DESCRICAO' 
                ,LEFT(Z1_XPED,5) AS 'EMPRESA'
                ,Z3_DATENT AS 'DTENT'
                ,Z3_HORENT AS 'HRENT'
                ,ISNULL((SELECT TOP  1 B1_UM FROM %table:SB1% WHERE D_E_L_E_T_ = '' AND B1_COD = Z1_PRODUTO),'') AS 'UM' 
                ,Z1_SETENT AS 'SETOR'
                ,RTRIM(Z1_LOCENT) AS 'LOCENT'
                ,Z3_QUANT AS 'QTD'
            FROM %table:SZ3% SZ3
            LEFT JOIN %table:SZ1% SZ1
            ON
                Z3_PRODUTO = Z1_PRODUTO
                AND Z3_NUM = Z1_NUM
                AND SZ1.D_E_L_E_T_ = ''
            WHERE
                Z3_DOC = %Exp:MV_PAR01%
                and Z3_SERIE = %Exp:MV_PAR02%
                AND Z3_PRODUTO BETWEEN %EXP:MV_PAR03% AND %EXP:MV_PAR04%
        EndSql
    

        While !QRY->(EOF())
            aAdd(aDados,{QRY->TITULO,;
                        QRY->NUMPED,;
                        QRY->DOC,;
                        QRY->CODCLI,;
                        QRY->DESCRICAO,;
                        QRY->EMPRESA,;
                        QRY->DTENT,;
                        QRY->HRENT,;
                        QRY->UM,;
                        QRY->SETOR,;
                        QRY->LOCENT,;
                        QRY->QTD})
            QRY->(DbSkip())
        Enddo

        QRY->(DbCLoseArea())


Return aDados
