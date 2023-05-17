#Include 'Protheus.ch'

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ MTA650I            ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Grava Campos Customizados na tabela SC2                        ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 03/01/2020         ¦ Last Modified time ¦  03/01/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MTA650I()
    Local cOpPai   := SC2->C2_NUM+SC2->C2_ITEM+"001"
    Local cCliente := ""
    Local cLoja    := ""

    If SC2->C2_SEQUEN <> "001"
        cOpFilha := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
        cCliente := Posicione("SC2",1,xFilial("SC2")+cOpPai,"C2_XCODCLI")
        cLoja    := Posicione("SC2",1,xFilial("SC2")+cOpPai,"C2_XCODLOJ")
        cHora    := Posicione("SC2",1,xFilial("SC2")+cOpPai,"C2_XHORA"  )

        If dbSeek(xFilial("SC2")+cOpFilha)                                            
            RecLock("SC2",.F.)
                SC2->C2_XCODCLI := cCliente
                SC2->C2_XCODLOJ := cLoja
                SC2->C2_XUSER   := UsrRetName(RetCodUsr())
                SC2->C2_XHORA   := cHora
            MsUnLock()
        EndIf

    Else
        RecLock("SC2",.F.)
            SC2->C2_XUSER := UsrRetName(RetCodUsr())
        MsUnLock()
    EndIf
Return
