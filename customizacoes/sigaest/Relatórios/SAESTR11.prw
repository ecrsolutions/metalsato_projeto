#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'
/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTR11           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Planilha movimentacoes de estoque - SB9,SD1,SD2,SD3            ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 03/09/2020         ¦ Last Modified time ¦  03/09/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTR11
    Local cText1,cText2,cText3,cText4 := ""
    Private cPerg    := Padr("SAESTR11",len(SX1->X1_PERGUNTA)," ")
    Private aItens   := {}

    cText1 := "Este programa gera planilha com todas as movimentações registradas no período."
    cText2 := "Revisar o programa caso seja alterado o compartilhamento das seguintes tabelas:"
    ctext3 := "SB1,SD1,SF1,SF4,SD2,SD3,NNR."
    cText4 := "Desenvolvido especificamente para "+rtrim(SM0->M0_NOME)+"."
    
   DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE "Planilha Movimentações Estoque" PIXEL
        @ 16, 15 SAY cText1 SIZE 268, 8 OF oDlg PIXEL					
        @ 36, 15 SAY cText2 SIZE 268, 8 OF oDlg PIXEL					
        @ 46, 15 SAY cText3 SIZE 268, 8 OF oDlg PIXEL
        @ 60, 15 SAY cText4 SIZE 268, 8 OF oDlg PIXEL
        DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.t.)  ENABLE OF oDlg
        DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION MsgRun("Gerando Planilha...","Processando",{|| LoadValues() }) ENABLE OF oDlg
        DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End()      ENABLE OF oDlg
    
        
    ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function LoadValues()
    Local cFileName       := rtrim(cPerg)+Dtos(MSDate())+"-"+StrTran(Time(),":","")
    Local cPathInServer   := "c:\temp\"+cFileName+".xml"
    Local cGuia,cTabela   := ""
    Local lOk             := .F.
    
    Pergunte(cPerg, .F.)

    cGuia           := "MOV-ANALITICO"
    cTabela         := "MOV-ANALITICO - "+" Periodo: "+dtoc(mv_par01)+" - "+dtoc(mv_par02)
    
    //Gera arquivo excel
    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet(cGuia)

    BeginSql Alias "QRY"
        SELECT * FROM
        (SELECT
            'SD1' AS ORIGEM
            ,D1_FILIAL
            ,B1_TIPO
            ,D1_LOCAL
            ,CASE WHEN D1_LOCAL = %Exp:GETMV("MV_LOCPROC")% THEN 'PROCESSO' ELSE 'NPROCESSO' END AS OPERACAO
            ,D1_TES
            ,D1_CF
            ,D1_ITEM
            ,D1_COD
            ,D1_DOC
            ,D1_SERIE
            ,D1_CUSTO
            ,SD1.R_E_C_N_O_
        FROM %table:SD1% SD1
        INNER JOIN %table:SB1% SB1
        ON SD1.D1_COD = SB1.B1_COD AND SB1.%notDel% AND LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(D1_FILIAL,LEN(B1_FILIAL))
        INNER JOIN %table:SF4% SF4
        ON SF4.F4_CODIGO = SD1.D1_TES AND SF4.%notDel% AND LEFT(F4_FILIAL,LEN(F4_FILIAL)) = LEFT(D1_FILIAL,LEN(F4_FILIAL))
        WHERE
            SD1.%notDel%
            AND SD1.D1_DTDIGIT BETWEEN %exp:dtos(MV_PAR01)% AND %Exp:dtos(MV_PAR02)%
            AND SF4.F4_ESTOQUE = 'S'
        UNION ALL
        SELECT
            'SD3' AS ORIGEM
            ,D3_FILIAL
            ,B1_TIPO
            ,D3_LOCAL
            ,CASE WHEN D3_LOCAL = %Exp:GETMV("MV_LOCPROC")% THEN 'PROCESSO' ELSE 'NPROCESSO' END AS OPERACAO
            ,'' AS D3_TES
            ,D3_CF
            ,'' AS D3_ITEM
            ,D3_COD
            ,D3_DOC
            ,'' AS D3_SERIE
            ,CASE WHEN LEFT(D3_CF,2) = 'RE' THEN D3_CUSTO1 * -1 ELSE D3_CUSTO1 END AS D3_CUSTO1
            ,SD3.R_E_C_N_O_
        FROM %table:SD3% SD3
        INNER JOIN %table:SB1% SB1
        ON SD3.D3_COD = SB1.B1_COD AND SB1.%notDel% AND LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(D3_FILIAL,LEN(B1_FILIAL))
        INNER JOIN %table:NNR% NNR
        ON NNR.NNR_CODIGO = D3_LOCAL AND NNR.D_E_L_E_T_ = '' AND LEFT(NNR_FILIAL,LEN(NNR_FILIAL)) = LEFT(D3_FILIAL,LEN(NNR_FILIAL))
        WHERE
            SD3.%notDel%
            AND D3_EMISSAO BETWEEN %exp:dtos(MV_PAR01)% AND %Exp:dtos(MV_PAR02)%
            AND SD3.D3_ESTORNO = ' '
        UNION ALL
        SELECT
            'SD2' AS ORIGEM
            ,D2_FILIAL
            ,B1_TIPO
            ,D2_LOCAL
            ,CASE WHEN D2_LOCAL = %Exp:GETMV("MV_LOCPROC")% THEN 'PROCESSO' ELSE 'NPROCESSO' END AS OPERACAO
            ,D2_TES
            ,D2_CF
            ,D2_ITEM
            ,D2_COD
            ,D2_DOC
            ,D2_SERIE
            ,D2_CUSTO1*-1 AS D2_CUSTO1
            ,SD2.R_E_C_N_O_
        FROM %table:SD2% SD2
        INNER JOIN %table:SB1% SB1
        ON SD2.D2_COD = SB1.B1_COD AND SB1.%notDel% AND LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(D2_FILIAL,LEN(B1_FILIAL))
        INNER JOIN %table:SF4% SF4
        ON SF4.F4_CODIGO = SD2.D2_TES AND SF4.%notDel% AND LEFT(F4_FILIAL,LEN(F4_FILIAL)) = LEFT(D2_FILIAL,LEN(F4_FILIAL))
        WHERE
            SD2.%notDel%
            AND SD2.D2_EMISSAO BETWEEN %exp:dtos(MV_PAR01)% AND %Exp:dtos(MV_PAR02)%
            AND SF4.F4_ESTOQUE = 'S'
        UNION ALL
        SELECT
            'SB9' AS ORIGEM
            ,B9_FILIAL
            ,B1_TIPO
            ,B9_LOCAL
            ,CASE WHEN B9_LOCAL = %Exp:GETMV("MV_LOCPROC")% THEN 'PROCESSO' ELSE 'NPROCESSO' END AS OPERACAO
            ,'' AS B9_TES
            ,'' AS B9_CF
            ,'' AS B9_ITEM
            ,B9_COD
            ,B9_DATA AS B9_DOC
            ,'' AS B9_SERIE
            ,B9_VINI1
            ,SB9.R_E_C_N_O_
        FROM %table:SB9% SB9
        INNER JOIN %table:SB1% SB1 
        ON B9_COD = B1_COD AND SB1.%notDel% AND LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(B9_FILIAL,LEN(B1_FILIAL))
        INNER JOIN %table:NNR% NNR
        ON NNR.NNR_CODIGO = B9_LOCAL AND NNR.%notDel% AND LEFT(NNR_FILIAL,LEN(NNR_FILIAL)) = LEFT(B9_FILIAL,LEN(NNR_FILIAL))
        WHERE SB9.%notDel%
        AND SB9.B9_DATA = %Exp:GETMV("MV_ULMES")%
        UNION ALL
        SELECT
            'SD3' AS ORIGEM
            ,D3_FILIAL
            ,B1_TIPO
            ,%Exp:GETMV("MV_LOCPROC")% AS D3_LOCAL
            ,'PROCESSO' AS OPERACAO
            ,'' AS D3_TES
            ,D3_CF
            ,'' AS D3_ITEM
            ,D3_COD
            ,D3_DOC
            ,'' AS D3_SERIE
            ,CASE WHEN LEFT(D3_CF,2) = 'DE' THEN D3_CUSTO1 * -1 ELSE D3_CUSTO1 END AS D3_CUSTO1
            ,SD3.R_E_C_N_O_
        FROM %table:SD3% SD3
        INNER JOIN %table:SB1% SB1
        ON SD3.D3_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' AND LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(D3_FILIAL,LEN(B1_FILIAL))
        INNER JOIN %table:NNR% NNR
        ON NNR.NNR_CODIGO = D3_LOCAL AND NNR.D_E_L_E_T_ = '' AND LEFT(NNR_FILIAL,LEN(NNR_FILIAL)) = LEFT(D3_FILIAL,LEN(NNR_FILIAL))
        WHERE
            SD3.%notDel%
            AND D3_EMISSAO BETWEEN %exp:dtos(MV_PAR01)% AND %Exp:dtos(MV_PAR02)%
            AND SD3.D3_ESTORNO = ' '
            AND D3_CF IN ('RE3','DE3')) AS KARDEX
    EndSql

    If !QRY->(EOF())
        lOk := .t.
        oFWMsExcel:AddTable(cGuia,cTabela)
        oFWMsExcel:AddColumn(cGuia,cTabela,'FILIAL'         ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'TIPO ARMAZEM'   ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'TIPO PRODUTO'   ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'TABELA ORIGEM'  ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'TIPO MOVIMENTO' ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'DOCUMENTO'      ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'SERIE'          ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'TES'            ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'ARMAZEM'        ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'ITEM'           ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'PRODUTO'        ,1,1)
        oFWMsExcel:AddColumn(cGuia,cTabela,'CUSTO'          ,1,1)

        While !QRY->(EOF())
            If QRY->B1_TIPO $ MV_PAR03
                oFWMsExcel:AddRow(cGuia,cTabela,{;
                    QRY->D1_FILIAL,;
                    QRY->OPERACAO,;
                    QRY->B1_TIPO,;
                    QRY->ORIGEM,;
                    QRY->D1_CF,;
                    QRY->D1_DOC,;
                    QRY->D1_SERIE,;
                    QRY->D1_TES,;
                    QRY->D1_LOCAL,;
                    QRY->D1_ITEM,;
                    QRY->D1_COD,;
                    QRY->D1_CUSTO}) 
            EndIf

            QRY->(DbSkip())
        Enddo
    Endif

    QRY->(DbCloseArea())

    If lOk
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cPathInServer)
            
        //Abrindo o excel e abrindo o arquivo xml
        oExcel := MsExcel():New()            
        oExcel:WorkBooks:Open(cPathInServer)     
        oExcel:SetVisible(.T.)               
        oExcel:Destroy() 
    Else
        alert("Não foram encontrados movimentos para os parâmetros informados.")
    EndIf

Return
