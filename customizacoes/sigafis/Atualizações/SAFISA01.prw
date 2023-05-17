#include "Protheus.ch"
#include "Tbiconn.ch"

User Function SAFISA01()

    PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO 'EST' 
    
    BeginSql Alias "QRY"   
        SELECT
            F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_EMISSAO,F1_TIPO
            ,F2_CHVNFE AS 'F2CHAVE'
            ,F3_CHVNFE
            ,F1_CHVNFE
            ,FT_CHVNFE
            ,SF1.R_E_C_N_O_ AS 'F1RECNO'
            ,SF3.R_E_C_N_O_ AS 'F3RECNO'
            ,SFT.R_E_C_N_O_ AS 'FTRECNO'
        FROM %table:SF1% SF1
        LEFT JOIN %table:SF2% SF2
        ON
            F2_DOC         = F1_DOC
            AND F2_SERIE   = F1_SERIE
            AND SF2.D_E_L_E_T_ = ''
        INNER JOIN %table:SF3% SF3
        ON
            F3_NFISCAL = F1_DOC
            AND F3_SERIE = F1_SERIE
            AND F3_FILIAL = F1_FILIAL
            AND F3_CLIEFOR = F1_FORNECE
            AND F3_LOJA = F1_LOJA
            AND SF3.D_E_L_E_T_ = ''
        INNER JOIN %table:SFT% SFT 
        ON 
            FT_NFISCAL = F1_DOC
            AND FT_SERIE = F1_SERIE
            AND FT_FILIAL = F1_FILIAL
            AND FT_CLIEFOR = F1_FORNECE
            AND FT_LOJA = F1_LOJA
            AND SFT.D_E_L_E_T_ = ''
        WHERE
            SF1.D_E_L_E_T_ = ''
            AND (F1_CHVNFE = '' OR F3_CHVNFE = '' OR FT_CHVNFE = '')
            AND F1_ESPECIE = 'SPED'
            AND F1_FILIAL+F1_DOC+F1_SERIE IN ( SELECT D1_FILIAL+D1_DOC+D1_SERIE 
                                            FROM %table:SD1% SD1 WHERE 
                                            D_E_L_E_T_ = ''
                                            AND D1_TES IN (SELECT F4_CODIGO FROM %table:SF4%  WHERE D_E_L_E_T_ = '' AND F4_TRANFIL = '1'))
            AND F1_DTDIGIT >= '20200201'
            AND F1_TIPO = 'N'
    EndSql

    If QRY->(EOF())
        conout("Nao foram encontradas notas pendentes "+'-'+Dtos(MSDate())+'-'+Time())
    EndIf 

    While !QRY->(EOF())

        conout("Atualizando chave Doc: "+QRY->F1_DOC+"-"+QRY->F1_SERIE+"  "+QRY->F1_EMISSAO+"...")

        If empty(QRY->F1_CHVNFE)
            SF1->(DbSelectArea("SF1"))
            SF1->(DbGoTo(QRY->F1RECNO))
            RecLock("SF1",.F.)
                SF1->F1_CHVNFE := QRY->F2CHAVE
            MsUnLock()
        EndIf

        If empty(QRY->F3_CHVNFE)
            SF3->(DbSelectArea("SF3"))
            SF3->(DbGoTo(QRY->F3RECNO))
            RecLock("SF3",.F.)
                SF3->F3_CHVNFE := QRY->F2CHAVE
            MsUnLock()
        EndIf

        If empty(QRY->FT_CHVNFE)
            SFT->(DbSelectArea("SFT"))
            SFT->(DbGoTo(QRY->FTRECNO))
            RecLock("SFT",.F.)
                SFT->FT_CHVNFE := QRY->F2CHAVE
            MsUnLock()
        EndIf

        QRY->(DbSkip())
    Enddo

    RESET ENVIRONMENT
    
Return