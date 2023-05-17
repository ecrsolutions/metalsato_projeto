// Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ STESTA004          ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Executa inclusão de solicitação de transferência - MATA311     ¦¦*
* ¦            ¦ baseado no Documento de Entrada                                ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 30/09/2019         ¦ Last Modified time ¦  30/09/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SAESTA04()
    Local aArea         := GetArea()
    Local aRotBkp       := aRotina
    Local aDadosIte     := {}
    Local aItens        := {}
    Private lContinua   := .T.
    Private cArmDest    := GetMv("MV_XESP013")
    Private aAuto       := {}
    Private aItem       := {}
    Private aLinha      := {}
    Private aDadoscab   := {}
    Private oModel      := Nil
    Private lMsErroAuto := .F.
    
    BeginSql ALias "TMPTRANSF"
        SELECT D1_FILIAL AS 'FILIAL', D1_COD AS 'COD', D1_LOCAL AS 'LOC', SUM(D1_QUANT) AS 'QUANT'
        FROM %table:SD1%
        WHERE
            D_E_L_E_T_ = ''
            AND D1_FILIAL  = %Exp:FWFilial()%
            AND D1_DOC     = %Exp:SF1->F1_DOC%
            AND D1_SERIE   = %Exp:SF1->F1_SERIE%
            AND D1_FORNECE = %Exp:SF1->F1_FORNECE%
            AND D1_LOJA    = %Exp:SF1->F1_LOJA%
        GROUP BY    
            D1_FILIAL, D1_COD,D1_LOCAL
    EndSql
        
    While TMPTRANSF->( !EOF() )
        aDadosIte := {}
        aAdd(aDadosIte, {"NNT_FILIAL" , TMPTRANSF->FILIAL   , Nil})
        aAdd(aDadosIte, {"NNT_FILORI" , TMPTRANSF->FILIAL   , Nil})
        aAdd(aDadosIte, {"NNT_PROD"   , TMPTRANSF->COD      , Nil})
        aAdd(aDadosIte, {"NNT_QUANT"  , TMPTRANSF->QUANT    , Nil})
        aAdd(aDadosIte, {"NNT_FILDES" , GETMV("MV_XESP001") , Nil})
        aAdd(aDadosIte, {"NNT_PRODD" ,  TMPTRANSF->COD      , Nil})
        aAdd(aDadosIte, {"NNT_LOCLD" ,  GETMV("MV_XESP002") , Nil})
        aAdd(aDadosIte, {"NNT_TS"    ,  GETMV("MV_XESP004") , Nil})
        aAdd(aDadosIte, {"NNT_TE"    ,  GETMV("MV_XESP005") , Nil})

        //valida se foi informado armazem transitorio e se a nota e de terceiros
        If !empty(cArmDest) .and. SF1->F1_TIPO == "B"
            
            TransfArm()
            aAdd(aDadosIte, {"NNT_LOCAL"  , cArmDest        , Nil})

        ElseIf SF1->F1_TIPO == "B"
            alert("armazém destino não configurado no parâmetro MV_XESP013")
            lContinua := .F.
            exit
        Else
            aAdd(aDadosIte, {"NNT_LOCAL"  , TMPTRANSF->LOC  , Nil})
        EndIf

        //no item o array precisa de um nivel superior.
        aAdd(aItens,aDadosIte)

        TMPTRANSF->( dbSkip() )
    Enddo

    TMPTRANSF->(DbCloseArea())
    
    If lContinua
        //executa transferência entre filiais
        MsgRun("Efetivando transferência...","Aguarde...",{||u_SAESTA05(aItens)}) 
    EndIf  

    RestArea(aArea)
    aRotina := aRotBkp
Return

Static Function TransfArm()
    Local nOpcAuto := 0
    Local cDocumen := ""
    
    nOpcAuto := 3 // Inclusao
 

    //Cabecalho a Incluir Transferencia entre Armaem
    aAuto := {}
    cDocumen := GetSxeNum("SD3","D3_DOC")
    aadd(aAuto,{cDocumen,dDataBase})  

    //Itens a Incluir
    aItem  := {}
    aLinha := {}
                        
    //Posiciona no item
    SB1->( DbSeek( xFilial("SB1")+PadR( TMPTRANSF->COD, tamsx3('D3_COD') [1] ) ) )
            
    //Origem
    //aadd(aLinha,{"ITEM"      ,'00'+cvaltochar(1), Nil})
    aadd(aLinha,{"D3_COD"    , SB1->B1_COD                                      , Nil}) //Cod Produto origem
    aadd(aLinha,{"D3_DESCRI" , SB1->B1_DESC                                     , Nil}) //descr produto origem
    aadd(aLinha,{"D3_UM"     , SB1->B1_UM                                       , Nil}) //unidade medida origem
    aadd(aLinha,{"D3_LOCAL"  , TMPTRANSF->LOC                                   , Nil}) //armazem origem
    aadd(aLinha,{"D3_LOCALIZ", Space(tamsx3('D3_LOCALIZ') [1])                  , Nil}) 

    //Destino
    aadd(aLinha,{"D3_COD"    , SB1->B1_COD                                      , Nil}) //Cod Produto origem
    aadd(aLinha,{"D3_DESCRI" , SB1->B1_DESC                                     , Nil}) //descr produto origem
    aadd(aLinha,{"D3_UM"     , SB1->B1_UM                                       , Nil}) //unidade medida origem
    aadd(aLinha,{"D3_LOCAL"  , cArmDest                                         , Nil}) //armazem origem
    aadd(aLinha,{"D3_LOCALIZ", Space(tamsx3('D3_LOCALIZ') [1]) , Nil}) 
            
    //origem
    aadd(aLinha,{"D3_NUMSERI", ""                                               , Nil}) //Numero serie
    aadd(aLinha,{"D3_LOTECTL", Space(tamsx3('D3_LOTECTL') [1])                  , Nil}) //Lote Origem
    aadd(aLinha,{"D3_NUMLOTE", Space(tamsx3('D3_NUMLOTE') [1])                  , Nil}) //sublote origem
    aadd(aLinha,{"D3_DTVALID", ctod("31/12/2049")                               , Nil}) //data validade
    aadd(aLinha,{"D3_POTENCI", 0                                                , Nil}) // Potencia
    aadd(aLinha,{"D3_QUANT"  , TMPTRANSF->QUANT                                 , Nil}) //Quantidade
    aadd(aLinha,{"D3_QTSEGUM", 0                                                , Nil}) //Seg unidade medida
    aadd(aLinha,{"D3_ESTORNO", ""                                               , Nil}) //Estorno
    aadd(aLinha,{"D3_NUMSEQ" , ""                                               , Nil}) // Numero sequencia D3_NUMSEQ
            
    //destino
    aadd(aLinha,{"D3_LOTECTL", Space(tamsx3('D3_LOTECTL') [1])                  , Nil}) //Lote destino
    aadd(aLinha,{"D3_NUMLOTE", Space(tamsx3('D3_NUMLOTE') [1])                  , Nil}) //sublote destino
    aadd(aLinha,{"D3_DTVALID", ctod("31/12/2049")                               , Nil}) //validade lote destino
    aadd(aLinha,{"D3_ITEMGRD", ""                                               , Nil}) //Item Grade
                        
    aAdd(aAuto,aLinha)
    MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

    If lMsErroAuto
        MostraErro()
        lContinua := .F.
    EndIf

Return