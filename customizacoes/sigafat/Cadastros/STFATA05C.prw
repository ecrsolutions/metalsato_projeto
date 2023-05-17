// Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ STFATA05C          ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Cria markbrowse das notas fiscais de Saída                     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 02/02/2020         ¦ Last Modified time ¦  02/02/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


User Function STFAT5C(cCliente,cLoja,cMotorista,cVeiculo,dDatade,dDataAte,cHorario)

Private oMark
Private cCli := cCliente
Private cLoj := cLoja
Private cMot := cMotorista
Private cVei := cVeiculo
Private dDe  := dDatade
Private dAte := dDataAte
Private cHra := cHorario
Static aMarcados := {}

    // Instanciamento do classe
    oMark := FWMarkBrowse():New()

    oMark:SetAlias('SF2')

    oMark:SetDescription('Selecione as notas desejadas.')
    oMark:SetMenuDef( 'STFAT5C' )
    oMark:SetMenuDef( 'STFATA05C' )

    cExpressao := " F2_CLIENTE == '"+cCliente+"' "
    cExpressao += " .AND. F2_LOJA == '"+cLoja+"' "
    cExpressao += " .AND. F2_EMISSAO >= '"+dtos(dDatade)+"' "
    cExpressao += " .AND. F2_EMISSAO >= '"+dtos(dDataAte)+"' "

    oMark:AddFilter("Cliente", cExpressao, .T., .T.)

    // Define o campo que sera utilizado para a marcação
    oMark:SetFieldMark( 'F2_XRMOK' )

    // Ativacao da classe
    oMark:Activate()

Return aMarcados

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ PESPA130           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Seta as opções do menu                                         ¦¦*
* ¦            ¦                                                                ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 04/05/2019         ¦ Last Modified time ¦  04/05/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


Static Function MenuDef()

Local aRotina := {}

    ADD OPTION aRotina Title 'Confirmar' Action 'U_STFAT5D(),CloseBrowse()' OPERATION 3 ACCESS 0

Return aRotina

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ PESPA130           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Atualiza array com as filiais marcadas.                        ¦¦*
* ¦            ¦                                                                ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 04/05/2019         ¦ Last Modified time ¦  04/05/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


User Function STFAT5D()

    Local aArea     := GetArea()
    Local cMarca    := oMark:Mark()
    Local cRomaneio := GetNextRom()
    Local lAchou    := .F.

    SF2->( dbGoTop() )
    
    While !SF2->( EOF() ) .and. SF2->F2_EMISSAO <= dAte
        If oMark:IsMark(cMarca) .and. SF2->F2_CLIENTE == cCli .and. SF2->F2_LOJA == cLoj .and. SF2->F2_EMISSAO >= dDe .and. SF2->F2_EMISSAO <= dAte
            lAchou := .T.
            RecLock("SF2", .F.)
                SF2->F2_XROMANE := cRomaneio 
                SF2->F2_XCODMOT := cMot
                SF2->F2_XNOMMOT := Posicione("DA4",1,xFilial("DA4")+cMot,"DA4_NOME")
                SF2->F2_XROMDT  := ddatabase
                SF2->F2_XROMHR  := cHra
                SF2->F2_XVEICUL := cVei
            MsUnLock() 
        EndIf

        SF2->( dbSkip() )
    End

    RestArea( aArea )

    If lAchou
        cTexto := "Romaneio "+cRomaneio+" gerado com sucesso!"
        MsgInfo(cTexto)
    Endif
Return

Static Function GetNextRom()
    Local cRomaneio := ""
    
    BeginSql Alias "TMP"
        SELECT MAX(F2_XROMANE) AS COD
        FROM %TABLE:SF2%
        WHERE
            F2_FILIAL = %EXP:XFILIAL("SF2")%
            AND D_E_L_E_T_ = ''
    EndSql

    If !TMP->(EOF())
        cRomaneio := soma1(TMP->COD)
    else
        cRomaneio := soma1("000000")
    EndIf
        
    TMP->(DbCLoseArea())

Return cRomaneio
