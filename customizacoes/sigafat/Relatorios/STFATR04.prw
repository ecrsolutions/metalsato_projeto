#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"
/*_________________________________________________________________________________
* ��������������������������������������������������������������������������������*
* +------------+--------------------+--------------------+----------------------+�*
* � Program    � STFATR04           � Author             � Matheus Vin�cius     ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Description� Imprime carta de corre��o                                      ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Date       � 04/02/2020         � Last Modified time �  04/02/2020          ��*
* +------------+--------------------+--------------------+----------------------+�*
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/

User Function STFATR04()
	Local nHndERP := AdvConnection() // Recupera handler da conex�o atual com o DBAccess
  	Local cDBTSS  := "MSSQL/TSS"
  	Local cSrTSS  := "192.168.0.245"
	Local nHndOra := -1

    //PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' /*USER 'ADMIN' PASSWORD 'MSIGA!@#'*/ MODULO 'EST'
    
    IF !Pergunte("STFATR04  ",.T.)
        Return
    EndIf
	
    // Cria uma conex�o com um outro banco, outro DBAcces
	nHndOra := TcLink( cDBTSS, cSrTSS, 7890 )
	If nHndOra < 0
		UserException( "Falha ao conectar com " + cDBTSS + " em " + cSrTSS )
	Endif

    BeginSql ALias "TMP"
        SELECT 
            ID_EVENTO   AS 'ID'
            ,DATE_EVEN  AS 'EMISSAO'
            ,TIME_EVEN  AS 'HREVEN'
            ,TIME_TRANS AS 'HRTRANS'
            ,PROTOCOLO  AS 'PROTOCOLO'
            ,NFE_CHV    AS 'CHAVE'
            ,RTRIM(SUBSTRING(
                CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP))
                ,CHARINDEX('<xCorrecao>',CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)),1)+11
                ,CHARINDEX('</xCorrecao>',CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)),1)-CHARINDEX('<xCorrecao>',CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)),1)-11
            )) as 'CORRECAO'
            ,RTRIM(SUBSTRING(
                CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP))
                ,CHARINDEX('<xCondUso>',CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)),1)+10
                ,CHARINDEX('</xCondUso>',CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)),1)-CHARINDEX('<xCondUso>',CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000),XML_ERP)),1)-10
            )) as 'CONDUSO'
            ,SUBSTRING(NFE_CHV,7,14) as 'CNPJ'
            ,SUBSTRING(NFE_CHV,23,3) as 'SERIE'
            ,SUBSTRING(NFE_CHV,26,9) as 'NF'
        FROM SPED154
        WHERE
            D_E_L_E_T_ = ''
            AND TPEVENTO = '110110'
            AND CSTATEVEN = '135'
            AND CSTATENV  = '128'
            AND SUBSTRING(NFE_CHV,23,3) = %Exp:MV_PAR02%
            AND SUBSTRING(NFE_CHV,26,9) = %Exp:MV_PAR01%
        ORDER BY
            DATE_EVEN, HREVEN DESC
    EndSql

    If !empty(TMP->NF)
        MsgRun("Imprimindo..."    ,"Aguarde...",{|| GetReport(TMP->CNPJ,TMP->NF,TMP->SERIE,TMP->CHAVE,TMP->PROTOCOLO,TMP->ID,TMP->CORRECAO,TMP->EMISSAO,TMP->HREVEN,TMP->HRTRANS,TMP->CONDUSO)})
    Else
        cTitulo  := "ATEN��O!"
        cErro    := "N�o foi encontrada carta de corre��o para a nota fiscal/s�rie informada."
        cSolucao := "Verifique se os par�metros foram corrigidos corretamente e se a carta de corre��o foi autorizada."
        Help(NIL, NIL, cTitulo, NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
    EndIf

    If VALTYPE(nHndERP) <> "U"
        // Volta para conex�o DADOSADV12
        tcSetConn( nHndERP )
    EndIf
   
    TMP->(DbCloseArea())

	// Fecha a conex�o com o TSS
	TcUnlink( nHndOra )

    

    //RESET ENVIRONMENT
Return

Static Function GetReport(cCnpj,cNf,cSerie,cChave,cProtocolo,cId,cCorrecao,cEmissao,cHrEven,cHrTrans,cCondUso)
    
    Local cFileName       := "CCE"+Dtos(MSDate())+StrTran(Time(),":","")
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
    Local nPagina         := 0
    Private nHeight         := 75
    Private nWidght         := 90
    Private n8000Line      := 0
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
        aAdd(aSize,oPrinter:nHorzSize()) //Retorno largura da p�gina.
        aAdd(aSize,oPrinter:nVertSize()) //Retorno altura da p�gina.
        aAdd(aSize,oPrinter:nHorzRes())  //Retorna a resolu��o horizontal da impressora configurada.
        aAdd(aSize,oPrinter:nVertRes())  //Retorna a resolu��o vertical da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelX())//Retorna a resolu��o vertical, em pixels, da impressora configurada.
        aAdd(aSize,oPrinter:nLogPixelY())//Retorna a resolu��o horizontal, em pixels, da impressora configurada.
    
        //While nFrom < len(aDados)
        
            oPrinter:StartPage()

                //armazena n�mero da p�gina
                nPagina+= 1

                //insere box ao redor da p�gina
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
                    While !EOF() .and. SM0->M0_CGC <> cCnpj
                        DbSkip()
                    Enddo 
            
                    oPrinter:Say( nLinha, nColuna, ALLTRIM(SM0->M0_NOMECOM)+' - '+rtrim(SM0->M0_FILIAL),oTFont16)
                    oPrinter:SayBitmap( 20, 100, "\system\lgrl01.bmp" , 220, 220)
                    
                    nLinha += nEspacoLin*2
                    oPrinter:Say( nLinha, nColuna, "CNPJ: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + Space(8) + Transform(SM0->M0_INSC, "@R 99.999.999-99"), oTFont12)
                    
                    nLinha += nEspacoLin*2
                    oPrinter:Say( nLinha, nColuna, AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+" - "+SM0->M0_ESTCOB, oTFont12)
                    //oPrinter:Say( nLinha, nColuna+1000, "Emitido em "+dtoc(date())+'-'+time(), oTFont12)
                    
                    nLinha += nEspacoLin*2
                    oPrinter:Say( nLinha, nColuna, "CEP: "+Transform(SM0->M0_CEPCOB,"@R 99999-999")+" - "+"Fone/Fax: "+SM0->M0_TEL, oTFont12)
                    oPrinter:Say( nLinha, nColuna+1700, "P�gina "+cvaltochar(nPagina)+'/1', oTFont12)
               
                    nColuna := 70
                    nEspacoLin := 35

                //t�tulo relat�rio
                    
                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                                    
                    nLinha += nEspacoLin
                    oPrinter:SayAlign( nLinha,nColuna,"CARTA DE CORRE��O",oTFont16,nWidght,,, 2, 1 )

                    //cria linha horizontal
                    nLinha += nEspacoLin*1.5
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                    cTexto := "Informamos que foram efetuadas corre��es para a nota fiscal abaixo mencionada. "
                    cTexto += "Segu�m tamb�m os dados referente ao evento de corre��o realizado."
                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, nColuna, cTexto,oTFont12_2)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "Nota Fiscal: "+cNf,oTFont12)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "S�rie: "+cSerie,oTFont12)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "Protocolo: "+cvaltochar(cProtocolo),oTFont12)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "ID Evento: "+cId,oTFont12)

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "Emiss�o: "+dtoc(stod(cEmissao))+' - '+cHrEven,oTFont12)

                    cCodBar := cChave
                    oPrinter:Code128C( nLinha, 1300, cCodBar, 35 )

                    nLinha += nEspacoLin
                    oPrinter:Say( nLinha, 100, "Hora Registro: "+cHrTrans,oTFont12)
                    oPrinter:Say( nLinha, 1300, cChave ,oTFont12)

                    //cria linha horizontal
                    nLinha += nEspacoLin
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                    nLinha += nEspacoLin
                    cTexto := "A Carta de Corre��o � disciplinada pelo par�grafo 1�-A do art. 7� do Conv�nio S/N,"
                    cTexto += " de 15 de dezembro de 1970 e pode ser utilizada para regulariza��o de erro ocorrido na"
                    oPrinter:Say( nLinha, nColuna, cTexto,oTFont12_2)

                    nLinha += nEspacoLin
                    cTexto := "emiss�o de documento fiscal, desde que o erro n�o esteja relacionado com:"
                    oPrinter:Say( nLinha, nColuna, cTexto,oTFont12_2)

                    nLinha += nEspacoLin*2
                    cTexto := "I - as vari�veis que determinam o"
                    cTexto += " valor do imposto tais como: base de c�lculo, al�quota, diferen�a de pre�o, "
                    cTexto += " quantidade, valor da opera��o ou da presta��o;"
                    oPrinter:Say( nLinha, nColuna, cTexto,oTFont12_2)

                    nLinha += nEspacoLin*2
                    cTexto := "II - a corre��o de dados cadastrais que implique mudan�a do remetente ou do destinat�rio;"
                    oPrinter:Say( nLinha, nColuna, cTexto,oTFont12_2)

                    nLinha += nEspacoLin*2
                    cTexto := "III - a data de emiss�o ou de sa�da."
                    oPrinter:Say( nLinha, nColuna, cTexto,oTFont12_2)

                    //cria linha horizontal
                    nLinha += nEspacoLin*2
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)

                    nLinha += nEspacoLin
                    oPrinter:SayAlign( nLinha,nColuna,"Corre��es a serem adotadas",oTFont16,nWidght,nEspacoLin,, 2, 1 )

                    //cria linha horizontal
                    nLinha += nEspacoLin*2
                    oPrinter:Line(nLinha , 20 , nLinha, nWidght)
                    
                    nLinha += nEspacoLin
                    oPrinter:SayAlign( nLinha,nColuna,cCorrecao,oTFont12,nWidght-10,500,, 0, 2 )
                    
            oPrinter:EndPage() 

            oPrinter:cPathPDF:= cPathInServer 

            oPrinter:Preview()   
    Return