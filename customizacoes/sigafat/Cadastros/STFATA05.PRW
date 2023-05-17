//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "Rptdef.CH"
#include "FWPrintSetup.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ STFATA05            ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Cadastros de Romaneios de Entrega                              ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 20/01/2020         ¦ Last Modified time ¦  20/01/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


User Function STFATA05()

//Variaveis Estaticas
Static cTitulo := "Romaneio de Entrega"
Static cTitMdl1 := "- Cabecalho"
Static cTitMdl2 := "- Itens"
Static cAliasSF2 := "SF2"
//Static cAliasPAB := "PAB"
Static cFonte := "STFATA05"

Local aArea   := GetArea()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAliasSF2)
oBrowse:SetMenuDef(cFonte)
oBrowse:SetDescription(cTitulo)

//oBrowse:AddLegend("SZ2->Z2_STATUS == '1'", "GREEN", "Ativo" )
//oBrowse:AddLegend("SZ2->Z2_STATUS == '2'", "RED", "Bloqueado" )
//oBrowse:SetFilterDefault( "SZ3->Z3_ITEM == '0001'" )

oBrowse:DisableDetails()
oBrowse:Activate()

RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
/*/

Static Function MenuDef()
	Local aRotina := {}

    ADD OPTION aRotina Title 'Visualizar'       Action 'VIEWDEF.STFATA05' OPERATION 2 ACCESS 0
    //ADD OPTION aRotina Title 'Alterar'          Action 'VIEWDEF.STFATA05' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Gerar Romaneio'   Action 'u_STFAT5B'        OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'         Action 'u_STFAT5E'        OPERATION 3 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
//Model - Cadastro de Romaneio de Entrega
/*/

Static Function ModelDef()
	Local oModel
	Local oStSF2 := FWFormStruct(1,cAliasSF2)
	//Local oStPAB := FWFormStruct(1,cAliasPAB)
	Local aSF2Rel := {} //Relacionamento Master-Detail da SZ3 nao normalizada

	//Instanciando o modelo, nao e recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
		oModel := MPFormModel():New( "SF2MODEL",/*bPre*/, /*bPos*/, /*bCommit*/,/*bCancel*/)

	// Atribuindo formularios para o modelo
		oModel:AddFields( "SF2CABEC", , oStSF2 )
		//oModel:AddGrid( "PABGRID", "SF2CABEC", oStPAB)

	//Criando o relacionamento

		//Adiciona o relacionamento de Filho, Pai
		//aAdd(aSF2Rel,{"PAB_FILIAL","FWxFilial('PAB')"} )
		//aAdd(aSF2Rel,{"PAB_ID","SF2_ID"} )

		//oModel:SetRelation("PABGRID", aSF2Rel, PAB->(IndexKey(1)))

	
	// Setando as propriedades na grid, o inicializador da Filial e Tabela, para nao dar mensagem de coluna vazia
		//oStSZ3:SetProperty("ZI_OPESP",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"SZ3->Z3_COD"))

	// Setando as propriedades na grid
		//oStSZ4:SetProperty("Z4_OPESP",MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "SZ3->Z3_COD"))
		//oModel:GetModel( "PABGRID" ):SetUniqueLine( { "PAB_DOC","PAB_SERIE" } )

	// Adicionando descricao ao modelo
		oModel:SetDescription( cTitulo )

	// Setando a descricao dos formularios
		oModel:GetModel( "SF2CABEC" ):SetDescription( cTitMdl1 )
	//	oModel:GetModel( "PABGRID" ):SetDescription( cTitMdl2 )
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel(cFonte)
	Local oStSF2 := FWFormStruct(2,cAliasSF2)
	//Local oStPAB := FWFormStruct(2,cAliasPAB)
	Local oView

    //Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'F2_FILIAL'})    

	//Criando a view que sera o retorno da funcao e setando o modelo da rotina
		oView := FWFormView():New()
		oView:SetModel( oModel )

	//Atribuindo formularios para interface
		oView:AddField("VIEW_SF2",oStSF2,"SF2CABEC")
	//	oView:AddGrid("VIEW_PAB",oStPAB,"PABGRID")
	//	oView:SetNoDeleteLine("VIEW_PAB")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("CABEC",100)
	//oView:CreateHorizontalBox("ITEM",70)

	//Colocando titulo do formulario
	oView:EnableTitleView("VIEW_SF2","Dados " + cTitMdl1	)
	//oView:EnableTitleView("VIEW_PAB","Dados " + cTitMdl2	)

	//Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOk( { ||.T. } )

	//O formulario da interface sera colocado dentro do container
	oView:SetOwnerView( "VIEW_SF2" , "CABEC" )
	//oView:SetOwnerView( "VIEW_PAB", "ITEM" )

	//oView:AddIncrementField( "VIEW_PAB", "PAB_ITEM" )

	//oStSF2:RemoveField( "SF2_ID" )
	//oStPAB:RemoveField( "PAB_ID" )
    
	//oStSF2:RemoveField( "F2_DOC")
	//oStSF2:RemoveField( "F2_SERIE")
	//oStSF2:RemoveField( "F2_CLIENTE")
	//oStSF2:RemoveField( "F2_LOJA")
	oStSF2:RemoveField( "F2_COND")
	oStSF2:RemoveField( "F2_DUPL")
	//oStSF2:RemoveField( "F2_EMISSAO")
	oStSF2:RemoveField( "F2_EST")
	oStSF2:RemoveField( "F2_FRETE")
	oStSF2:RemoveField( "F2_SEGURO")
	oStSF2:RemoveField( "F2_ICMFRET")
	oStSF2:RemoveField( "F2_TIPOCLI")
	//oStSF2:RemoveField( "F2_VALBRUT")
	oStSF2:RemoveField( "F2_VALICM")
	oStSF2:RemoveField( "F2_BASEICM")
	oStSF2:RemoveField( "F2_VALIPI")
	oStSF2:RemoveField( "F2_BASEIPI")
	oStSF2:RemoveField( "F2_VALMERC")
	oStSF2:RemoveField( "F2_NFORI")
	oStSF2:RemoveField( "F2_DESCONT")
	oStSF2:RemoveField( "F2_SERIORI")
	oStSF2:RemoveField( "F2_TIPO")
	//oStSF2:RemoveField( "F2_ESPECI1")
	//oStSF2:RemoveField( "F2_ESPECI2")
	//oStSF2:RemoveField( "F2_ESPECI3")
	//oStSF2:RemoveField( "F2_ESPECI4")
	//oStSF2:RemoveField( "F2_VOLUME1")
	//oStSF2:RemoveField( "F2_VOLUME2")
	//oStSF2:RemoveField( "F2_VOLUME3")
	//oStSF2:RemoveField( "F2_VOLUME4")
	oStSF2:RemoveField( "F2_ICMSRET")
	//oStSF2:RemoveField( "F2_PLIQUI")
	//oStSF2:RemoveField( "F2_PBRUTO")
	//oStSF2:RemoveField( "F2_TRANSP")
	oStSF2:RemoveField( "F2_REDESP")
	oStSF2:RemoveField( "F2_VEND1")
	oStSF2:RemoveField( "F2_VEND2")
	oStSF2:RemoveField( "F2_VEND3")
	oStSF2:RemoveField( "F2_VEND4")
	oStSF2:RemoveField( "F2_VEND5")
	oStSF2:RemoveField( "F2_OK")
	oStSF2:RemoveField( "F2_FIMP")
	oStSF2:RemoveField( "F2_DTLANC")
	oStSF2:RemoveField( "F2_DTREAJ")
	oStSF2:RemoveField( "F2_REAJUST")
	oStSF2:RemoveField( "F2_DTBASE0")
	oStSF2:RemoveField( "F2_FATORB0")
	oStSF2:RemoveField( "F2_DTBASE1")
	oStSF2:RemoveField( "F2_FATORB1")
	oStSF2:RemoveField( "F2_VARIAC")
	oStSF2:RemoveField( "F2_FILIAL")
	oStSF2:RemoveField( "F2_BASEISS")
	oStSF2:RemoveField( "F2_VALISS")
	oStSF2:RemoveField( "F2_VALFAT")
	oStSF2:RemoveField( "F2_CONTSOC")
	oStSF2:RemoveField( "F2_BRICMS")
	oStSF2:RemoveField( "F2_FRETAUT")
	oStSF2:RemoveField( "F2_ICMAUTO")
	oStSF2:RemoveField( "F2_DESPESA")
	oStSF2:RemoveField( "F2_NEXTDOC")
	oStSF2:RemoveField( "F2_NEXTSER")
	oStSF2:RemoveField( "F2_ESPECIE")
	oStSF2:RemoveField( "F2_PDV")
	oStSF2:RemoveField( "F2_MAPA")
	oStSF2:RemoveField( "F2_ECF")
	oStSF2:RemoveField( "F2_PREFIXO")
	oStSF2:RemoveField( "F2_BASIMP1")
	oStSF2:RemoveField( "F2_BASIMP2")
	oStSF2:RemoveField( "F2_BASIMP3")
	oStSF2:RemoveField( "F2_BASIMP4")
	oStSF2:RemoveField( "F2_BASIMP5")
	oStSF2:RemoveField( "F2_BASIMP6")
	oStSF2:RemoveField( "F2_VALIMP1")
	oStSF2:RemoveField( "F2_VALIMP2")
	oStSF2:RemoveField( "F2_VALIMP3")
	oStSF2:RemoveField( "F2_VALIMP4")
	oStSF2:RemoveField( "F2_VALIMP5")
	oStSF2:RemoveField( "F2_VALIMP6")
	oStSF2:RemoveField( "F2_ORDPAGO")
	oStSF2:RemoveField( "F2_NFCUPOM")
	oStSF2:RemoveField( "F2_VALINSS")
	//oStSF2:RemoveField( "F2_HORA")
	oStSF2:RemoveField( "F2_MOEDA")
	oStSF2:RemoveField( "F2_REGIAO")
	oStSF2:RemoveField( "F2_VALCSLL")
	oStSF2:RemoveField( "F2_VALCOFI")
	oStSF2:RemoveField( "F2_VALPIS")
	oStSF2:RemoveField( "F2_LOTE")
	oStSF2:RemoveField( "F2_TXMOEDA")
	oStSF2:RemoveField( "F2_CLEOK")
	oStSF2:RemoveField( "F2_CHVCLE")
	oStSF2:RemoveField( "F2_IDCLE")
	oStSF2:RemoveField( "F2_VALIRRF")
	oStSF2:RemoveField( "F2_RECFAUT")
	oStSF2:RemoveField( "F2_CARGA")
	oStSF2:RemoveField( "F2_SEQCAR")
	oStSF2:RemoveField( "F2_BASEINS")
	oStSF2:RemoveField( "F2_PEDPEND")
	oStSF2:RemoveField( "F2_DESCCAB")
	oStSF2:RemoveField( "F2_DTENTR")
	oStSF2:RemoveField( "F2_FORMUL")
	oStSF2:RemoveField( "F2_TIPODOC")
	oStSF2:RemoveField( "F2_NFEACRS")
	oStSF2:RemoveField( "F2_TIPOREM")
	oStSF2:RemoveField( "F2_SEQENT")
	oStSF2:RemoveField( "F2_ICMSDIF")
	oStSF2:RemoveField( "F2_VALACRS")
	oStSF2:RemoveField( "F2_RECISS")
	oStSF2:RemoveField( "F2_MUNPRES")
	oStSF2:RemoveField( "F2_ESTPRES")
	oStSF2:RemoveField( "F2_RECOPI")
	oStSF2:RemoveField( "F2_NODIA")
	oStSF2:RemoveField( "F2_ORDSEP")
	oStSF2:RemoveField( "F2_NFELETR")
	oStSF2:RemoveField( "F2_NUMORC")
	oStSF2:RemoveField( "F2_VALCF3")
	oStSF2:RemoveField( "F2_VALFAC")
	oStSF2:RemoveField( "F2_VALFET")
	oStSF2:RemoveField( "F2_VALFMD")
	oStSF2:RemoveField( "F2_VALFMP")
	oStSF2:RemoveField( "F2_TIPORET")
	oStSF2:RemoveField( "F2_TOTEST")
	oStSF2:RemoveField( "F2_TOTFED")
	oStSF2:RemoveField( "F2_SERSAT")
	oStSF2:RemoveField( "F2_STATUS")
	oStSF2:RemoveField( "F2_TIPIMP")
	oStSF2:RemoveField( "F2_TOTMUN")
	oStSF2:RemoveField( "F2_TPCOMPL")
	oStSF2:RemoveField( "F2_TPFRETE")
	oStSF2:RemoveField( "F2_VALPS3")
	oStSF2:RemoveField( "F2_VALTST")
	oStSF2:RemoveField( "F2_VALINA")
	oStSF2:RemoveField( "F2_VEICUL1")
	oStSF2:RemoveField( "F2_VEICUL2")
	oStSF2:RemoveField( "F2_VLCPM")
	oStSF2:RemoveField( "F2_ESTCRED")
	oStSF2:RemoveField( "F2_FILDEST")
	oStSF2:RemoveField( "F2_DTESERV")
	oStSF2:RemoveField( "F2_EMINFE")
	oStSF2:RemoveField( "F2_FORMDES")
	oStSF2:RemoveField( "F2_HORNFE")
	oStSF2:RemoveField( "F2_HAWB")
	oStSF2:RemoveField( "F2_FLAGDEV")
	oStSF2:RemoveField( "F2_FRTCFOP")
	oStSF2:RemoveField( "F2_MENNOTA")
	oStSF2:RemoveField( "F2_IDRECOP")
	oStSF2:RemoveField( "F2_LTRAN")
	oStSF2:RemoveField( "F2_IDSA1")
	oStSF2:RemoveField( "F2_IDSA2")
	oStSF2:RemoveField( "F2_IDSED")
	oStSF2:RemoveField( "F2_BSREIN")
	oStSF2:RemoveField( "F2_CODNFE")
	oStSF2:RemoveField( "F2_DIACTB")
	oStSF2:RemoveField( "F2_CGCCLI")
	oStSF2:RemoveField( "F2_CHVNFE")
	oStSF2:RemoveField( "F2_CREDNFE")
	oStSF2:RemoveField( "F2_BASEIRR")
	oStSF2:RemoveField( "F2_BASEINA")
	oStSF2:RemoveField( "F2_BASPIS")
	oStSF2:RemoveField( "F2_BASEPS3")
	oStSF2:RemoveField( "F2_BASECF3")
	oStSF2:RemoveField( "F2_BASECPM")
	oStSF2:RemoveField( "F2_BASEFMP")
	oStSF2:RemoveField( "F2_VLR_FRT")
	oStSF2:RemoveField( "F2_VLSENAR")
	oStSF2:RemoveField( "F2_VEICUL3")
	oStSF2:RemoveField( "F2_VREINT")
	oStSF2:RemoveField( "F2_VALFDS")
	oStSF2:RemoveField( "F2_VALIMA")
	oStSF2:RemoveField( "F2_SERSUBS")
	oStSF2:RemoveField( "F2_SERMDF")
	oStSF2:RemoveField( "F2_TOTIMP")
	oStSF2:RemoveField( "F2_VALFUND")
	oStSF2:RemoveField( "F2_VALFASE")
	oStSF2:RemoveField( "F2_VALFAB")
	oStSF2:RemoveField( "F2_TXREF")
	oStSF2:RemoveField( "F2_UFDEST")
	oStSF2:RemoveField( "F2_UFORIG")
	oStSF2:RemoveField( "F2_PREFORI")
	oStSF2:RemoveField( "F2_REFMOED")
	oStSF2:RemoveField( "F2_REFTAXA")
	oStSF2:RemoveField( "F2_SDOC")
	oStSF2:RemoveField( "F2_SDOCMAN")
	oStSF2:RemoveField( "F2_SDOCMDF")
	oStSF2:RemoveField( "F2_SDOCNXT")
	oStSF2:RemoveField( "F2_SDOCORI")
	oStSF2:RemoveField( "F2_SDOCSUB")
	oStSF2:RemoveField( "F2_NFICMST")
	oStSF2:RemoveField( "F2_NFSUBST")
	oStSF2:RemoveField( "F2_PAFMD5")
	oStSF2:RemoveField( "F2_NTFECP")
	oStSF2:RemoveField( "F2_NUMMDF")
	oStSF2:RemoveField( "F2_BASEFUN")
	oStSF2:RemoveField( "F2_BASCOFI")
	oStSF2:RemoveField( "F2_BASCSLL")
	oStSF2:RemoveField( "F2_BASETST")
	oStSF2:RemoveField( "F2_BASFECP")
	oStSF2:RemoveField( "F2_DAUTNFE")
	oStSF2:RemoveField( "F2_CLIRET")
	oStSF2:RemoveField( "F2_CMUNDE")
	oStSF2:RemoveField( "F2_CMUNOR")
	oStSF2:RemoveField( "F2_CNO")
	oStSF2:RemoveField( "F2_CLIENT")
	oStSF2:RemoveField( "F2_BSFCCMP")
	oStSF2:RemoveField( "F2_BSFCPST")
	oStSF2:RemoveField( "F2_DESCZFR")
	oStSF2:RemoveField( "F2_CODRGS")
	oStSF2:RemoveField( "F2_DTDIGIT")
	oStSF2:RemoveField( "F2_DTTXREF")
	oStSF2:RemoveField( "F2_LOJADES")
	oStSF2:RemoveField( "F2_LOJARET")
	oStSF2:RemoveField( "F2_LOJENT")
	oStSF2:RemoveField( "F2_IDRGS")
	oStSF2:RemoveField( "F2_IDNF")
	oStSF2:RemoveField( "F2_IDCCE")
	oStSF2:RemoveField( "F2_GNRDIF")
	oStSF2:RemoveField( "F2_GNRFECP")
	oStSF2:RemoveField( "F2_FLAGRGS")
	oStSF2:RemoveField( "F2_FORDES")
	oStSF2:RemoveField( "F2_HAUTNFE")
	oStSF2:RemoveField( "F2_EVENFLG")
	oStSF2:RemoveField( "F2_XVEICUL")
	oStSF2:RemoveField( "F2_XMOTORI")
	oStSF2:RemoveField( "F2_XMSGNF")
	oStSF2:RemoveField( "F2_USERLGI")
	oStSF2:RemoveField( "F2_USERLGA")
	oStSF2:RemoveField( "F2_XNFORI")
	oStSF2:RemoveField( "F2_XSERORI")
	oStSF2:RemoveField( "F2_XDATREC")
	oStSF2:RemoveField( "F2_XHORREC")
	oStSF2:RemoveField( "F2_XUSRREC")

Return oView


User Function STFAT5B()

	Local aMarcados := {}

	If Pergunte("STFATA05B  ",.T.)
		aMarcados := u_STFAT5C(MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR05,MV_PAR06,MV_PAR07)
	EndIf

Return 

User Function STFAT5E
    Local cFileName       := "STFAT5E"+Dtos(MSDate())+StrTran(Time(),":","")
    Local cPathInServer   := GetTempPath()
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local lTReport        := .F.
    Local lServer         := .F.
    Local lPDFAsPNG       := .T.
    Local lRaw            := .F.
    Local lViewPDF        := .T.
    Local nQtdCopy        := 1   
    Local aSize           := {}
    Local nFrom           := 1
    Local nPagina         := 0
	Local aDados          := {}
	Local cCliAtu         := ""
    Private nHeight       := 75
    Private nWidght       := 90
    Private n8000Line     := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter     

	IF Pergunte("STFAT5E   ",.T.)

		aDados := GetReport()

		IF Empty(aDados)
			alert("Não foram encontrados dados para o romaneio informado.")
			Return
		EndIF

	Else
		Return
	EndIf

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
    aAdd(aSize,oPrinter:nHorzSize()) //Retorno largura da página.
    aAdd(aSize,oPrinter:nVertSize()) //Retorno altura da página.
    aAdd(aSize,oPrinter:nHorzRes())  //Retorna a resolução horizontal da impressora configurada.
    aAdd(aSize,oPrinter:nVertRes())  //Retorna a resolução vertical da impressora configurada.
    aAdd(aSize,oPrinter:nLogPixelX())//Retorna a resolução vertical, em pixels, da impressora configurada.
    aAdd(aSize,oPrinter:nLogPixelY())//Retorna a resolução horizontal, em pixels, da impressora configurada.

    While nFrom <= len(aDados)
    
        oPrinter:StartPage()

            //armazena número da página
                nPagina+= 1

            //insere box ao redor da página
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
                While !EOF() .and. SM0->M0_CODFIL <> '010101'
                    DbSkip()
                Enddo 
        
                oPrinter:Say( nLinha, nColuna, ALLTRIM(SM0->M0_NOMECOM),oTFont16)
                oPrinter:SayBitmap( 20, 100, "\system\lgrl01.bmp" , 220, 220)

                
                oPrinter:Say( nLinha, nColuna+1250, "Emitido em "+dtoc(date())+'-'+time(), oTFont12)
                oPrinter:Say( nLinha, nColuna+1700, "Página "+cvaltochar(nPagina), oTFont12)
            
                nColuna := 70
                nEspacoLin := 35

            //título relatório

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                                
                nLinha += nEspacoLin*2
				cTitulo := "Romaneio de Entrega"
                oPrinter:SayAlign( nLinha,nColuna,cTitulo,oTFont16,nWidght,,, 2, 1 )

                //cria linha horizontal
                nLinha += nEspacoLin*1.5
                oPrinter:Line(nLinha , 20 , nLinha, nWidght)

            // cabeçalho 
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Romaneio: "+aDados[1,14]                          ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Cliente: "+aDados[1,9]                            ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Data Saída: "+Dtoc(Stod(aDados[1,11]))            ,oTFont12)
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Hora Saída: " +Transform(aDados[1,10],"@N 99:99") ,oTFont12)   
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Motorista: "  +aDados[1,12]                       ,oTFont12) 
                nLinha += nEspacoLin*1.5
                oPrinter:Say( nLinha, nColuna+0000, "Placa: "     +aDados[1,15]                        ,oTFont12)     
            
            //cabeçalho colunas
                nLinha += nEspacoLin*2
				oPrinter:Say( nLinha, nColuna+0010, "Cód. Sato"    ,oTFont12)
				oPrinter:Say( nLinha, nColuna+0300, "Cód. Cliente" ,oTFont12)
				oPrinter:Say( nLinha, nColuna+0900, "Produto"      ,oTFont12)
				oPrinter:Say( nLinha, nColuna+1900, "Quantidade"   ,oTFont12)

            //cria linha horizontal
                nLinha += nEspacoLin
                oPrinter:Line(nLinha , 20 , nLinha, nWidght) 

            //itens colunas
                nQtdPag := 0
                While nQtdPag <= 55
                    If nFrom <= len(aDados)

						If cCliAtu <> (aDados[nFrom,4]+aDados[nFrom,5])
							
							cCLiAtu := (aDados[nFrom,4]+aDados[nFrom,5])
								
							nLinha += nEspacoLin*2
                			oPrinter:Line(nLinha , 20 , nLinha, nWidght) 
							nLinha += nEspacoLin
							oPrinter:Say( nLinha, nColuna+0010, "Nota Fiscal: "+rtrim(aDados[nFrom,4])+"-"+rtrim(aDados[nFrom,5]) ,oTFont12)

							nQtdPag += 4

						EndIf

                        nLinha += nEspacoLin*1.5

                            oPrinter:Say( nLinha, nColuna+0010, aDados[nFrom,6]                                       ,oTFont12)
		                    oPrinter:Say( nLinha, nColuna+0300, aDados[nFrom,8]                                       ,oTFont12)
	                        oPrinter:Say( nLinha, nColuna+0900, aDados[nFrom,7]                                       ,oTFont12)
                            oPrinter:Say( nLinha, nColuna+1900, rtrim(Transform(aDados[nFrom,13],"@E 99,999,999,999")) ,oTFont12)

                        nQtdPag++
                    Else
                        exit
                    EndIf

                    nFrom++
                Enddo
        
        oPrinter:EndPage() 

    Enddo

    oPrinter:cPathPDF:= cPathInServer 

    oPrinter:Preview()  
Return

Static Function GetReport()
	Local aDados := {}
	BeginSql Alias "QRY"
		SELECT
			SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_COND, SF2.F2_DUPL, SF2.F2_EMISSAO, SF2.F2_EST
			,SD2.D2_COD, SD2.D2_QUANT
			,A7_CODCLI
			,B1_DESC
			,SF2.F2_XROMANE, SF2.F2_XNOMMOT, SF2.F2_XROMHR, SF2.F2_XROMDT,SF2.F2_XVEICUL,DA3_PLACA
			,(SELECT TOP 1 A1_NOME FROM %TABLE:SA1% WHERE A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND D_E_L_E_T_ = '') AS CLIENTE
		FROM %TABLE:SF2% SF2
		LEFT JOIN %TABLE:SD2% SD2 ON SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SD2.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:SA7% SA7 ON A7_PRODUTO = SD2.D2_COD AND A7_CLIENTE = SD2.D2_CLIENTE AND A7_LOJA = SD2.D2_LOJA AND SA7.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:SB1% SB1 ON SD2.D2_COD = B1_COD AND SB1.D_E_L_E_T_ = ''
		LEFT JOIN %TABLE:DA3% DA3 ON SF2.F2_XVEICUL = DA3.DA3_COD AND DA3.D_E_L_E_T_ = ''
		WHERE
			SF2.D_E_L_E_T_ = ''
			AND F2_XROMANE = %Exp:MV_PAR01%
		ORDER BY D2_DOC
	EndSql

	While !QRY->(EOF())
	
		aAdd(aDados,{QRY->F2_EMISSAO,;  //1
					QRY->F2_CLIENTE,;   //2
					QRY->F2_LOJA,;      //3
					QRY->F2_DOC,;       //4
					QRY->F2_SERIE,;     //5
					QRY->D2_COD,;       //6
					QRY->B1_DESC,;      //7
					QRY->A7_CODCLI,;    //8
					QRY->CLIENTE,;      //9
					QRY->F2_XROMHR,;    //10
					QRY->F2_XROMDT,;    //11
					QRY->F2_XNOMMOT,;   //12
					QRY->D2_QUANT,;     //13
					QRY->F2_XROMANE,;   //14
					QRY->DA3_PLACA})    //15

		QRY->(DbSkip())

	Enddo

	QRY->(DbCloseArea())

Return aDados