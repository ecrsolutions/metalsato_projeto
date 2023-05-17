//Bibliotecas
#Include "TOTVS.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWPrintSetup.ch"

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTA06           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Realiza pagamentos de Solicitação de Filiais                   ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 16/12/2019         ¦ Last Modified time ¦  16/12/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTA06
    Local aTamanho    := MsAdvSize() 
	Local nJanLarg    := aTamanho[5]
	Local nJanAltu    := aTamanho[6]
    Local aHead       := {}
    Local aHead2      := {}
    Local aAlter      := {"PAF_QUANT","LOCAL"}
    Local aAlter2     := {}
    Local aButtons    := {}
    Local aCampos     := {}
    Local aCampos2    := {}
    Local aArea         := GetArea()
    Private aCols     := {}
    Private aCols2    := {}
    Private oBrw      := Nil
    Private oDlg      := Nil

    nAltIni := aTamanho[1]
    nAltFim := nJanAltu/2

    If PAE->PAE_STATUS == 'C'
        cMsg := 'Solicitação cancelada anteriormente. Não pode ser atendida.'
        alert(cMsg)
        return
    ElseIf PAE->PAE_STATUS == "E" 
        cMsg := 'Solicitação já encerrada. Não pode ser alterada.'
        alert(cMsg)
        return
    EndIf

    //carrega aCols1
    PAF->(dbSelectArea("PAF"))
    PAF->(dbSetOrder(1))
    If PAF->(dbSeek(xFilial("PAF")+PAE->PAE_CODIGO))
        While PAF->PAF_CODIGO == PAE->PAE_CODIGO .and. !EOF()
            aAdd(aCols ,{   PAF->PAF_ITEM,;
                            PAF->PAF_PRODUT,;
                            Posicione("SB1",1,xFilial("SB1")+PAF->PAF_PRODUT,"B1_DESC"),;
                            Posicione("SB1",1,xFilial("SB1")+PAF->PAF_PRODUT,"B1_UM"),;
                            0,;
                            SPACE(TAMSX3("B1_LOCPAD")[1]),;
                            .F.})
        
            PAF->(DbSkip())
        Enddo
    EndIf
    PAF->(DbCloseArea())

    //carrega aCols2
    NNT->(dbSelectArea("NNT"))
    NNT->(dbSetOrder(2))
    If NNT->(dbSeek(xFilial("NNT")+PAE->PAE_CODIGO))
        While NNT->NNT_XSOLIC == PAE->PAE_CODIGO .and. !EOF()
            aAdd(aCols2,{   NNT->NNT_PROD,;
                            Posicione("SB1",1,xFilial("SB1")+NNT->NNT_PROD,"B1_DESC"),;
                            Posicione("SB1",1,xFilial("SB1")+NNT->NNT_PROD,"B1_UM"),;
                            NNT->NNT_QUANT,;
                            NNT->NNT_DOC,;
                            NNT->NNT_SERIE,;
                            Dtoc(Posicione("SD2",3,xFilial("SD2")+NNT->NNT_DOC+NNT->NNT_SERIE,"D2_EMISSAO")),;
                            .F.})
            NNT->(DbSkip())
        Enddo
    EndIf

    aAdd(aCampos, { "PAF_ITEM"    , "Item"            ,"PAF_ITEM"    })
    aAdd(aCampos, { "PAF_PRODUT"  , "Código"          ,"PAF_PRODUTO" })
    aAdd(aCampos, { "PAF_DESC"    , "Descrição"       ,"PAF_DESC"    })
    aAdd(aCampos, { "B1_UM"       , "U.M."            ,"UM"          })
    aAdd(aCampos, { "PAF_QUANT"   , "Qtd. Entregue"   ,"PAF_QUANT"   })
    aAdd(aCampos, { "B1_LOCPAD"   , "Armazém"         ,"LOCAL"       })

    aAdd(aCampos2, { "NNT_PROD"    , "Código"          ,"PRODUTO"     })
    aAdd(aCampos2, { "PAF_DESC"    , "Código"          ,"DESCRICAO"   })
    aAdd(aCampos2, { "NNT_UM"      , "U.M."            ,"UM"          })
    aAdd(aCampos2, { "NNT_QUANT"   , "Qtd. Entregue"   ,"NNT_QUANT"   })
    aAdd(aCampos2, { "NNT_DOC"     , "NF"              ,"NNT_DOC"     })
    aAdd(aCampos2, { "NNT_SERIE"   , "Serie"           ,"NNT_SERIE"   })
    aAdd(aCampos2, { "D2_EMISSAO"  , "Emissão"         ,"D2_EMISSAO"  })

    aHead  := GetAheader(aCampos)
    aHead2 := GetAheader(aCampos2)

    DEFINE MsDialog oDlg TITLE "Solicitação de Transferência" FROM 000,000 TO nJanAltu,nJanLarg PIXEL
        
        oGroup1 := TGroup():New(nAltIni+30,1,nAltFim*0.45,(nJanLarg/2),'Dados Solicitação '+PAE->PAE_CODIGO+'. Solicitado por: '+PAE->PAE_NOME,oDlg,,,.T.) 
        oBrw    := MsNewGetDados():New(nAltIni+45,2,nAltFim*0.44,(nJanLarg/2)-5,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter,0,99,"u_VldEsta6",,"AllwaysTrue",oDlg,aHead,aCols)

        oGroup2 := TGroup():New(nAltFim*0.47,1,nAltFim*0.96,(nJanLarg/2),'Entregas Geradas',oDlg,,,.T.) 
        oBrw2   := MsNewGetDados():New(nAltFim*0.55,2,nAltFim*0.92,(nJanLarg/2)-5,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter2,0,99,"AllwaysTrue",,"AllwaysTrue",oDlg,aHead2,aCols2)

        oDlg:bInit := {||  EnchoiceBar(oDlg,{|| MsgRun("Gerando Transferência... ","Aguarde...",{||SetTransf()}),SetKey(VK_F4,{|| }),oDlg:End()},{|| SetKey(VK_F4,{|| }),oDlg:End()},,aButtons,,,.F.,.T.,.T.,.T.,.F.,)}
		SetKey(VK_F4,{|| SAEST6B()})
    ACTIVATE MSDIALOG oDlg CENTERED
Return

User Function VldEsta6()
    Local lRet := .T.
    Local aArea         := GetArea()
    If ReadVar() == "M->PAF_QUANT"
        If !Empty(oBrw:aCols[n,6])
            If SB2->(dbSetOrder(1), dbSeek(xFilial("SB2")+oBrw:aCols[n,2]+oBrw:aCols[n,6]))
                If !(SB2->(SaldoSb2()) > M->PAF_QUANT)
                    alert("Saldo indisponível. Quantidade atual: "+cvaltochar(SB2->(SaldoSb2())))
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

    If ReadVar() == "M->LOCAL"
        If !Empty(oBrw:aCols[n,6])
            If SB2->(dbSetOrder(1), dbSeek(xFilial("SB2")+oBrw:aCols[n,2]+&(ReadVar())))
                If !(SB2->(SaldoSb2()) > M->PAF_QUANT)
                    alert("Saldo indisponível. Quantidade atual: "+cvaltochar(SB2->(SaldoSb2())))
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return lRet

Static Function SetTransf()
    Local aArea         := GetArea()
    Local aDadosIte := {}
    Local aItens    := {}
    Local nI        := ""
    Private lMsErroAuto := Nil

    For nI:=1 to Len(oBrw:aCols)
        If !(oBrw:aCols[nI,len(oBrw:aCols[nI])]) .and. oBrw:aCols[nI,5] > 0
            aDadosIte := {}
            aAdd(aDadosIte, {"NNT_FILIAL" , FWCodFil()          , Nil})
            aAdd(aDadosIte, {"NNT_FILORI" , FWCodFil()          , Nil})
            aAdd(aDadosIte, {"NNT_PROD"   , oBrw:aCols[nI,2]    , Nil})
            aAdd(aDadosIte, {"NNT_LOCAL"  , oBrw:aCols[nI,6]    , Nil})
            aAdd(aDadosIte, {"NNT_QUANT"  , oBrw:aCols[nI,5]    , Nil})
            aAdd(aDadosIte, {"NNT_FILDES" , GETMV("MV_XESP001") , Nil})
            aAdd(aDadosIte, {"NNT_PRODD"  , oBrw:aCols[nI,2]    , Nil})
            aAdd(aDadosIte, {"NNT_LOCLD"  , GETMV("MV_XESP002") , Nil})
            aAdd(aDadosIte, {"NNT_TS"     , GETMV("MV_XESP004") , Nil})
            aAdd(aDadosIte, {"NNT_TE"     , GETMV("MV_XESP005") , Nil})
            //aAdd(aDadosIte, {"NNT_SERIE"  , GETMV("MV_XESP007") , Nil})
            aAdd(aDadosIte, {"NNT_XSOLIC" , PAE->PAE_CODIGO     , Nil})
            //no item o array precisa de um nivel superior.
            aAdd(aItens,aDadosIte)
        EndIf
    Next nI

    //executa transferência entre filiais
    MsgRun("Efetivando transferência...","Aguarde...",{||u_SAESTA05(aItens)})

    If lMsErroAuto
        DisarmTransaction()
        MostraErro()
        lRet := .F.
    Else
        //atualiza PAE010
        SetPAE()
    EndIf

    //EndTran()
    RestArea(aArea)
Return

Static Function GetAheader(aCampos)
    Local aHead := {}
    Local nI := 0
    Local nX := 0
    Local aArea         := GetArea()

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
	RestArea(aArea)
Return aHead

Static Function SetPAE()
    Local lTotal   := .F.
    Local lParcial := .F.
    Local lAberto  := .F.
    Local aArea         := GetArea()

    PAF->(DbSelectArea("PAF"))
    PAF->(DbSetOrder(2))
    If PAF->(dbSeek(xFilial("PAF")+PAE->PAE_CODIGO))
        While !(PAF->(EOF())) .and. PAF->PAF_CODIGO == PAE->PAE_CODIGO
            NNT->(DbSelectArea("NNT"))
            NNT->(DbSetOrder(2))

            If NNT->(dbSeek(GetFil(PAE->PAE_CODIGO)+PAE->PAE_CODIGO))
                While !(NNT->(EOF())) .and. NNT->NNT_XSOLIC == PAE->PAE_CODIGO
                    If NNT->NNT_PROD == PAF->PAF_PRODUT .and. !Empty(NNT->NNT_DOC)
                        Reclock("PAF",.F.)
                            PAF->PAF_QUJE += NNT->NNT_QUANT
                        MsUnlock()
                    EndIf
                    NNT->(DbSkip())
                Enddo
            EndIf
        PAF->(DbSkip())
        Enddo
    EndIf

    PAF->(DbSetOrder(2))
    If PAF->(dbSeek(xFilial("PAF")+PAE->PAE_CODIGO))
        While !(PAF->(EOF()))
            If PAF->PAF_QUJE >= PAF->PAF_QUANT
                lTotal := .T.
            ElseIf PAF->PAF_QUJE < PAF->PAF_QUANT .and. PAF->PAF_QUJE > 0
                lParcial := .T.
            ElseIf PAF->PAF_QUJE < PAF->PAF_QUANT .and. PAF->PAF_QUJE == 0
                lAberto := .T.
            EndIf
            PAF->(DbSkip())
        Enddo
    EndIf

    If lTotal .and. !lParcial .and. !lAberto
        RecLock("PAE", .F.)		
            PAE->PAE_STATUS := "E"		
        MsUnLock() //Confirma e finaliza a operação
    ElseIf lParcial .or. (lTotal .and. lAberto)
        RecLock("PAE", .F.)		
            PAE->PAE_STATUS := "A"		
        MsUnLock() //Confirma e finaliza a operação
    EndIf
    RestArea(aArea)
Return

Static Function GetFil(cSolic)

    Local cRet := ""
    Local aArea := GetArea()

    BeginSql Alias "TMP"

        SELECT DISTINCT NNT_FILIAL FROM %TABLE:NNT% WHERE D_E_L_E_T_ = '' AND NNT_XSOLIC = %Exp:cSolic%

    EndSql

    If !TMP->(EOF())
        cRet := TMP->NNT_FILIAL
    EndIf

    TMP->(DbCloseArea())

    RestArea(aArea)

Return cRet

Static Function SAEST6B()
    Local aHead       := {}
    Local aCampos     := {}
    Local aAlter      := {}
    Local aCols       := {}
    Local aButtons    := {}
    Local aArea         := GetArea()

    If Type("n") == "U"
        Return
    EndIf

    cProduto := oBrw:aCols[n,2]

    aAdd(aCampos, { "NNT_LOCAL"    , "Armazém"            ,"LOCAL"    })
    aAdd(aCampos, { "PAF_PRODUT"   , "Disponível"         ,"PRODUTO"  })

    aHead  := GetAheader(aCampos)

    BeginSql Alias "TMPQRY"
        SELECT B2_FILIAL, B2_LOCAL, B2_QATU-B2_QEMP-B2_QACLASS-B2_RESERVA AS 'QTD'
        FROM %table:SB2%
        WHERE
            D_E_L_E_T_ = ''
            AND B2_COD = %Exp:cProduto%
            AND B2_QATU <> 0
        ORDER BY B2_FILIAL, B2_LOCAL
    EndSql

    //Carrega Acols
    cFilAtu := ""
    While !TMPQRY->(EOF())
        If TMPQRY->B2_FILIAL <> cFilAtu
            cFilAtu := TMPQRY->B2_FILIAL  
            
            //ADICIONA LINHA DA FILIAL
            aAdd(aCols,{   "",;
                            "Filial --> "+TMPQRY->B2_FILIAL,;
                            .F.})
        EndIf
            
        aAdd(aCols,{   TMPQRY->B2_LOCAL,;
                       alltrim(Transform(TMPQRY->QTD,"@E 9,999,999,999.9")),;
                        .F.})

        TMPQRY->(DbSkip())
    Enddo

    TMPQRY->(DbCloseArea())

    DEFINE MSDIALOG oDlg3 TITLE  "Saldo(s) em Estoque - "+rtrim(cProduto) FROM 0,0 TO 300,500 PIXEL
        oBrw3:= MsNewGetDados():New(30,2,150,250,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter,0,99,"AllwaysTrue",,"AllwaysTrue",oDlg3,aHead,aCols)
        oDlg3:bInit := {||  EnchoiceBar(oDlg3,{|| oDlg3:End()},{|| oDlg3:End()},,aButtons,,,.F.,.T.,.T.,.T.,.F.,)}
        //DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg2:End())  ENABLE OF oDlg2
    ACTIVATE MSDIALOG oDlg3 CENTER
    RestArea(aArea)
Return 