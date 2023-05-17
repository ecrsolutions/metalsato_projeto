#include "Rptdef.CH"
#Include 'FWMVCDef.ch'
#include "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"
/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTA05           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Executa inclusão de solicitação de transferência - MATA311     ¦¦*
* ¦            ¦                                                                ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 30/09/2019         ¦ Last Modified time ¦  30/09/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SAESTA05(aIte)
    Local lRet          := .T.
    Local aArea         := GetArea()
    Private aRotina       := {}
    Private cCodigo     := GetSxeNum("NNS","NNS_COD")
    Private aItens      := {}
    Private aDadoscab   := {}
    Private oModel      := Nil
    Private lMsErroAuto := .F.

    NNS->(DbSelectArea("NNS"))
    NNS->(DbSetOrder(1))
    While NNS->(DbSeek(xFilial("NNS") + cCodigo)) 
        cCodigo := soma1(cCodigo)
    Enddo

    aItens := aIte

    oModel  := FwLoadModel ("MATA311")

    //aRotina := {} //obrigatório para funcionamento da rotina

    //Adicionando os dados do cabeçalho
        aAdd(aDadoscab, {"NNS_FILIAL", xFilial("NNS")     , Nil})
        aAdd(aDadoscab, {"NNS_COD"   , cCodigo            , Nil})
        aAdd(aDadoscab, {"NNS_DATA"  , ddatabase          , Nil})
        aAdd(aDadoscab, {"NNS_SOLICT", RetCodUsr()        , Nil})
        aAdd(aDadoscab, {"NNS_CLASS" , GetMV("MV_XESP006"), Nil})
        aAdd(aDadoscab, {"NNS_ESPECI", 'SPED'             , Nil})

    //Chamando a inclusão - Modelo 1
    lMsErroAuto := .F.

    BeginTran()
    
        //verifica se o armazém destino existe para os produtos informados
        //VldLocDest()
        
        FWMVCRotAuto( oModel,"NNS",3,{{"NNSMASTER", aDadoscab},{"NNTDETAIL", aItens}})
        
        //Se houve erro no ExecAuto, mostra mensagem
        If lMsErroAuto
            DisarmTransaction()
            MostraErro()
            lRet := .F.
        //Senão, mostra uma mensagem de inclusão
        EndIf

    EndTran()

    //efetiva a transferência  
    If !lMsErroAuto
        MsgRun("Efetivando transferência...","Aguarde...",{||SAESTA01C()})           
    EndIf

    //transmite e imprime a nota
    If !lMsErroAuto .and. GetMv("MV_XESP010")
        Processa({|| GetDanfe(aDadoscab)}, "Aguarde! Buscando retorno SEFAZ...")         
    EndIf

    RestArea(aArea)

Return lRet

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTA01C          ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Efetiva inclusão de solicitação de transferência - MATA311     ¦¦*
* ¦            ¦                                                                ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 30/09/2019         ¦ Last Modified time ¦  30/09/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function SAESTA01C()
    Local aItens    := {}
    Private cOpId311  := "011" //Operação Indicada para EFETIVAÇÃO
        
    oModel  := FwLoadModel ("MATA311") 

    aRotina := {} //obrigatório para funcionamento da rotina

    NNS->(DbSetOrder(1))
    NNS->(DbSeek(xFilial("NNS") + cCodigo)) 

    lMsErroAuto := .F. 
    
    //BeginTran()
        
        FWMVCRotAuto( oModel,"NNS",4,{{"NNSMASTER", aDadoscab},{"NNTDETAIL", aItens}})
    
        //Se houve erro no ExecAuto, mostra mensagem
        If lMsErroAuto
            DisarmTransaction()
            MostraErro()
        EndIf

    //EndTran()

    NNS->(DbCloseArea()) 
    
Return

/*
Static Function VldLocDest()
    Local nI := ""
    SB2->(DbSelectArea("SB2"))
    DbSetOrder(2)
    For nI := 1 to len(aItens)
        If !(dbSeek(aItens[nI,6,2]+aItens[nI,8,2]+aItens[nI,7,2]))
            CriaSB2(aItens[nI,7,2],aItens[nI,8,2],aItens[nI,6,2])
        EndIf
    Next nI
    SB2->(DbCloseArea())
Return
*/

Static Function GetDanfe (aDadoscab)
    Local cHoraInicio := TIME() // Armazena hora de inicio do processamento.. .
    Local nAtual      := 60
    Private lImpressao := .F.

    ProcRegua(30)
    NNT->(DbSelectArea("NNT"))
    NNT->(DbSetOrder(1))
    If NNT->(dbSeek(xFilial("NNT")+aDadoscab[2,2]))
        While ElapTime( cHoraInicio, TIME() ) <= "00:00:60" .and. ElapTime( cHoraInicio, TIME() ) >= "00:00:00" .and.!lImpressao
            IncProc("Tempo restante: " + cvaltochar(nAtual - val(StrTran(ElapTime( cHoraInicio, TIME() ),":",""))) + " segundos.")
            GetF2FIMP(NNT->NNT_FILIAL+NNT->NNT_DOC+NNT->NNT_SERIE)
        Enddo
    EndIf
    NNT->(DbCloseArea())
    
    If !lImpressao
        alert("Não foi possível obter retorno da Sefaz. Consulte a nf-e através da rotina NfeSefaz")
    EndIf

Return

Static Function GetF2FIMP(cDocumento)
    
    BeginSql ALias "TMPF2"
        SELECT F2_FIMP,F2_DOC,F2_SERIE
        FROM %table:SF2%
        WHERE
            D_E_L_E_T_ = ''
            AND F2_FILIAL+F2_DOC+F2_SERIE  = %Exp:cDocumento%
    EndSql
    
    If TMPF2->F2_FIMP == "S"
        lImpressao := .T.
        MsgRun("Imprimindo nota fiscal "+TMPF2->F2_DOC+"-"+TMPF2->F2_SERIE+"...","Aguarde...",{||Imprime(TMPF2->F2_DOC,TMPF2->F2_SERIE)})  
    EndIf

    TMPF2->(DbCloseArea())
Return

Static Function Imprime(cNota,cSerie)
    Local cFileName       := cTitulo+Dtos(MSDate())+StrTran(Time(),":","")
    Local cPathInServer   := "C:\temp\"
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local lTReport        := .F.
    Local lServer         := .F.
    Local lPDFAsPNG       := .T.
    Local lRaw            := .F.
    Local lViewPDF        := .T.
    Local nQtdCopy        := 1   
    Private nHeight       := 75
    Private nWidght       := 90
    Private nMaxLine      := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter     

    oPrinter := FWMSPrinter():New(cFileName,IMP_PDF,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,,/*alltrim(cPrinter)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)

    //Define as perguntas da DANFE
    Pergunte("NFSIGW",.F.)
    MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
    MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
    MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
    MV_PAR04 := 2                          //NF de Saida
    MV_PAR05 := 1                          //Frente e Verso = Sim
    MV_PAR06 := 2    

    //Cria a Danfe
    oDanfe := oPrinter 

    //Propriedades da DANFE
    oDanfe:SetResolution(78)
    oDanfe:SetPortrait()
    oDanfe:SetPaperSize(DMPAPER_A4)
    oDanfe:SetMargin(60, 60, 60, 60)

    //Força a impressão em PDF
    oDanfe:nDevice  := 6
    oDanfe:cPathPDF := cPasta                
    oDanfe:lServer  := .F.
    oDanfe:lViewPDF := .F.

    //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
    PixelX    := oDanfe:nLogPixelX()
    PixelY    := oDanfe:nLogPixelY()
    nConsNeg  := 0.4
    nConsTex  := 0.5
    oRetNF    := Nil
    nColAux   := 0
    nMaxItem  := 32

    //Chamando a impressão da danfe no RDMAKE
    //RptStatus({|lEnd| StaticCall(DANFEII, DanfeProc, @oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
    RptStatus({|lEnd| u_DanfeProc(@oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")

    oDanfe:Print()
    oDanfe:Preview()
    RestArea(aArea)
Return
