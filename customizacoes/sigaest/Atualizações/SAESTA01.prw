// Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TBiCONN.CH"

/*_________________________________________________________________________________
* ��������������������������������������������������������������������������������*
* +------------+--------------------+--------------------+----------------------+�*
* � Program    � SAESTA01           � Author             � Matheus Vin�cius     ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Description� Cria markbrowse dos produtos a serem transferidos.              ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Date       � 30/09/2019         � Last Modified time �  30/09/2019          ��*
* +------------+--------------------+--------------------+----------------------+�*
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/

User Function SAESTA01()
    
    Local cFilter := ""
    Private oMark
    Static aMarcados := {}


    cFilter := "SB2->B2_QATU > 0 .and. SB2->B2_LOCAL=='"+GETMV("MV_XESP003")+"'"
    // Instanciamento da classe
    oMark := FWMarkBrowse():New()

    oMark:SetAlias('SB2')

    oMark:SetDescription('Selecione o(s) produto(s) a ser(em) transferido(s).')
    oMark:SetMenuDef( 'SAESTA01' )
    oMark:AddFilter("Armaz�m Transfer�ncia",cFilter,.T.,.T.,,.F.,,,"01")
    oMark:SetSeeAll(.F.) //Indica se o usu�rio tem permiss�o para visualizar registros de outras filiais
    oMark:SetChgAll(.F.) //Indica se o usu�rio tem permiss�o para alterar registros de outras filiais

    // Define o campo que ser� utilizado para a marca��o
    oMark:SetFieldMark( 'B2_XOK' )

    // Ativacao da classe
    oMark:Activate()

Return

/*_________________________________________________________________________________
* ��������������������������������������������������������������������������������*
* +------------+--------------------+--------------------+----------------------+�*
* � Program    � SAESTA01           � Author             � Matheus Vin�cius     ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Description� Seta as op��es do menu                                         ��*
* �            �                                                                ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Date       � 04/05/2019         � Last Modified time �  04/05/2019          ��*
* +------------+--------------------+--------------------+----------------------+�*
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
Static Function MenuDef()

Local aRot := {}

    ADD OPTION aRot Title 'Confirmar' Action 'MsgRun("Gerando transfer�ncia...","Aguarde...",{||u_STESTA1B()})' OPERATION 3 ACCESS 0

Return aRot

/*_________________________________________________________________________________
* ��������������������������������������������������������������������������������*
* +------------+--------------------+--------------------+----------------------+�*
* � Program    � SAESTA01B          � Author             � Matheus Vin�cius     ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Description� Executa inclus�o de solicita��o de transfer�ncia - MATA311     ��*
* �            �                                                                ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Date       � 30/09/2019         � Last Modified time �  30/09/2019          ��*
* +------------+--------------------+--------------------+----------------------+�*
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/
User Function STESTA1B()
    Local aArea         := GetArea()
    Local aDadosIte     := {}
    Local cMarca        := oMark:Mark()
    Private aItens      := {}
    Private aDadoscab   := {}
    Private aRotina     := {}
    Private cCodigo     := GetSxeNum("NNS","NNS_COD")
    Private oModel      := Nil
    Private lMsErroAuto := .F.
 
    // RpcSetEnv("T1","D MG 01")  //comentar se via menu
 
    oModel  := FwLoadModel ("MATA311")

    NNS->(DbSelectArea("NNS"))
    NNS->(DbSetOrder(1))
    While NNS->(DbSeek(xFilial("NNS") + cCodigo)) 
        cCodigo := soma1(cCodigo)
    Enddo

    aAdd(aDadoscab, {"NNS_FILIAL", xFilial("NNS")     , Nil})
    aAdd(aDadoscab, {"NNS_COD"   , cCodigo            , Nil})
    aAdd(aDadoscab, {"NNS_DATA"  , ddatabase          , Nil})
    aAdd(aDadoscab, {"NNS_SOLICT", RetCodUsr()        , Nil})
    aAdd(aDadoscab, {"NNS_CLASS" , GetMV("MV_XESP006"), Nil})
    aAdd(aDadoscab, {"NNS_ESPECI", 'SPED'             , Nil})
 
    SB2->(DbGoTop())
    While !SB2->( EOF() )
        If oMark:IsMark(cMarca) .and. SB2->B2_QATU > 0 .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_LOCAL == GetMV("MV_XESP003")
            aDadosIte := {}
            aAdd(aDadosIte, {"NNT_FILIAL" , SB2->B2_FILIAL      , Nil})
            aAdd(aDadosIte, {"NNT_FILORI" , SB2->B2_FILIAL      , Nil})
            aAdd(aDadosIte, {"NNT_PROD"   , SB2->B2_COD         , Nil})
            aAdd(aDadosIte, {"NNT_LOCAL"  , SB2->B2_LOCAL       , Nil})
            aAdd(aDadosIte, {"NNT_QUANT"  , SB2->B2_QATU        , Nil})
            aAdd(aDadosIte, {"NNT_FILDES" , GETMV("MV_XESP001") , Nil})
            aAdd(aDadosIte, {"NNT_PRODD" ,  SB2->B2_COD         , Nil})
            aAdd(aDadosIte, {"NNT_LOCLD" ,  GETMV("MV_XESP002") , Nil})
            aAdd(aDadosIte, {"NNT_TS"    ,  GETMV("MV_XESP004") , Nil})
            aAdd(aDadosIte, {"NNT_TE"    ,  GETMV("MV_XESP005") , Nil})
            //aAdd(aDadosIte, {"NNT_SERIE" ,  GETMV("MV_XESP007") , Nil})
            //no item o array precisa de um nivel superior.
            aAdd(aItens,aDadosIte)
        EndIf
        SB2->( dbSkip() )
    Enddo
    //Chamando a inclus�o - Modelo 1
    lMsErroAuto := .F.
 
    FWMVCRotAuto( oModel,"NNS",3,{{"NNSMASTER", aDadoscab},{"NNTDETAIL", aItens}})
 
    //Se houve erro no ExecAuto, mostra mensagem
        If lMsErroAuto
        MostraErro()
    //Sen�o, mostra uma mensagem de inclus�o
    Else
        //MsgInfo("Registro incluido!", "Aten��o")
        MsgRun("Efetivando transfer�ncia...","Aguarde...",{||SAESTA01C()})    
    EndIf
 
    RestArea(aArea)
 
Return Nil

Static Function SAESTA01C()
    Private cOpId311  := "011" //Opera��o Indicada para EFETIVA��O
        
    oModel  := FwLoadModel ("MATA311") 

    aRotina := {} //obrigat�rio para funcionamento da rotina

    aItens    := {}

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