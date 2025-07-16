//Bibliotecas
#Include "TOTVS.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTA02           ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Solicitação entre filiais                                      ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 16/12/2019         ¦ Last Modified time ¦  16/12/2019          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

//Variáveis Estáticas
Static cTitulo   := "Solicitação entre Filiais"
Static cTitPAE   := "- Cabeçalho"
Static cTitPAF   := "- Itens"
Static cAliasPAE := "PAE"
Static cAliasPAF := "PAF"
Static cFonte    := "SAESTA02"

User Function SAESTA02()

	Local aArea   := GetArea()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasPAE)
	oBrowse:SetMenuDef(cFonte)
	oBrowse:SetDescription(cTitulo)
	oBrowse:AddLegend("Empty(PAE->PAE_STATUS)"  ,"GREEN" , "Ativo")
    oBrowse:AddLegend("PAE->PAE_STATUS == 'A'"  ,"YELLOW", "Em Atendimento")
    oBrowse:AddLegend("PAE->PAE_STATUS == 'C'"  ,"GRAY"  , "Cancelado")
	oBrowse:AddLegend("PAE->PAE_STATUS == 'E'"  ,"RED"   , "Encerrado")
	oBrowse:Activate()
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} MenuDef
//Define as opções de menu que estarão disponíveis no browse
/*/

Static Function MenuDef()
Local aRotina := {}
    ADD OPTION aRotina Title 'Incluir'       Action 'VIEWDEF.SAESTA02' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'       Action 'VIEWDEF.SAESTA02' OPERATION 4 ACCESS 0
    ADD OPTION aRotina Title 'Visualizar'    Action 'VIEWDEF.SAESTA02' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Atender'       Action 'u_SAESTA06'       OPERATION 3 ACCESS 0
    //ADD OPTION aRotina Title 'Teste'         Action 'u_SetPAE'         OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Elim.Resíduo'  Action 'u_ElimRes()'      OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'       Action 'VIEWDEF.SAESTA02' OPERATION 5 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'      Action 'u_SAESTR07()'     OPERATION 2 ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
//Model - Define Model
/*/
Static Function ModelDef()
	Local oModel
	Local oStPAE := FWFormStruct(1,cAliasPAE)
	Local oStPAF := FWFormStruct(1,cAliasPAF)
	Local aPAFRel := {} //Relacionamento Master-Detail 
	Local bVldPos := {|oModel| PAEPos(oModel)} // Bloco de cóigo das validações
    Local lPAF_XVOL   :=  PAF->(FieldPos('PAF_XVOL')) > 0

	//Instanciando o modelo, nao é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
		oModel := MPFormModel():New( "PAEMODEL",/*bPre*/, bVldPos, /*bCommit*/,/*bCancel*/)

	// Atribuindo formulários para o modelo	
		oModel:AddFields( "PAECABEC", , oStPAE )
		oModel:AddGrid( "PAFGRID" , "PAECABEC", oStPAF)
		oModel:SetPrimaryKey( {"PAE_FILIAL", "PAE_CODIGO"} ) // Setando a chave primária da rotina

	//Criando o relacionamento
		aAdd(aPAFRel,{"PAF_FILIAL", "FWxFilial('PAF')"})
		aAdd(aPAFRel,{"PAF_CODIGO", "PAE_CODIGO"} )

		//oModel:SetRelation("PAFGRID", aPAFRel, PAF->(IndexKey(1)))
		oModel:SetRelation("PAFGRID", aPAFRel, PAF->(IndexKey(1)))
        oModel:GetModel('PAFGRID'):SetUniqueLine({'PAF_PRODUT'})
	
	// Setando as propriedades na grid, o inicializador da Filial e Tabela, para nao dar mensagem de coluna vazia
	//oStPAF:SetProperty("ZI_OPESP",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"PAF->PAF_COD"))

	// Setando as propriedades na grid
		oModel:GetModel( "PAFGRID" ):SetUniqueLine( { "PAF_PRODUT" } )

	// Adicionando descricao ao modelo
		oModel:SetDescription( cTitulo )

	// Setando a descricao dos formularios
        oModel:GetModel( "PAECABEC" ):SetDescription( cTitPAE )
		oModel:GetModel( "PAFGRID"  ):SetDescription( cTitPAF )

    // Setando proprieda dos campos
        //oStrMt:SetProperty("ZSF_MAT"   , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "SRA->RA_MAT"))
        //oStrMt:SetProperty("ZSF_NOMFUN", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "SRA->RA_NOME"))
        oStPAE:SetProperty( 'PAE_CODIGO' , MODEL_FIELD_INIT ,FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxeNum("PAE","PAE_CODIGO")'))
        oStPAE:SetProperty( 'PAE_USER'   , MODEL_FIELD_INIT ,FwBuildFeature(STRUCT_FEATURE_INIPAD, 'RetCodUsr()'                  ))
        oStPAE:SetProperty( 'PAE_NOME'   , MODEL_FIELD_INIT ,FwBuildFeature(STRUCT_FEATURE_INIPAD, 'UsrRetName(RetCodUsr())'      ))
        oStPAE:SetProperty( 'PAE_EMISSA' , MODEL_FIELD_INIT ,FwBuildFeature(STRUCT_FEATURE_INIPAD, 'ddatabase'                    ))  
        oStPAE:SetProperty( 'PAE_HORA'   , MODEL_FIELD_INIT ,FwBuildFeature(STRUCT_FEATURE_INIPAD, 'time()'                       ))                                                          
        oStPAF:SetProperty( 'PAF_PRODUT' , MODEL_FIELD_VALID,{|| VldField()                                                       })
        If lPAF_XVOL
            oStPAF:SetProperty( 'PAF_XVOL'   , MODEL_FIELD_WHEN,{|| .F. })
        EndIf
        //oModel:SetActivate({|oModel| MVCInit(oModel)}) // FOCO
Return oModel

/*/{Protheus.doc} ViewDef
// View - Define View
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel(cFonte)
	Local oStPAE := FWFormStruct(2,cAliasPAE)
	Local oStPAF := FWFormStruct(2,cAliasPAF)
	Local oView
    Local lPAF_XVOL   :=  PAF->(FieldPos('PAF_XVOL')) > 0

	//Criando a view que sera o retorno da funcao e setando o modelo da rotina
		oView := FWFormView():New()
		oView:SetModel( oModel )

	//Atribuindo formularios para interface
		oView:AddField("VIEW_PAE",oStPAE,"PAECABEC")
		oView:AddGrid("VIEW_PAF",oStPAF,"PAFGRID")

    //Caso não tenha interação do usuário no master
        //oView:SetOnlyView("VIEW_PAE")

	//Criando um container com nome tela com 100%
	    oView:CreateHorizontalBox("CABEC",35)
	    oView:CreateHorizontalBox("ITEM" ,65)
	
    //O formulario da interface sera colocado dentro do container
        oView:SetOwnerView( 'VIEW_PAE', 'CABEC' )
        oView:SetOwnerView( 'VIEW_PAF', 'ITEM' )
	
	//Colocando titulo do formulario
	oView:EnableTitleView("VIEW_PAE","Dados " + cTitPAE	)
	oView:EnableTitleView("VIEW_PAF","Dados " + cTitPAF	)

	//Forca o fechamento da janela na confirmacao
	oView:SetCloseOnOk( { ||.T. } )

    //Define campos incrementais
	oView:AddIncrementField( "VIEW_PAF", "PAF_ITEM" )

    //Define campos que não serão exibidos
        oStPAE:RemoveField( "PAE_FILIAL" )
        oStPAE:RemoveField( "PAE_STATUS" )
	    oStPAF:RemoveField( "PAF_CODIGO" )
        oStPAF:RemoveField( "PAF_FILIAL" )

Return oView

Static Function MVCInit(oModel)
    If oModel:GetOperation() == 3 //VALIDA SE É INCLUSÃO
        oModel:LoadValue("PAECABEC", "PAE_CODIGO", oModel:GetValue("PAECABEC", "PAE_CODIGO"))
    EndIf
    //oModel:LoadValue("PAECABEC", "PAE_USER", oModel:GetValue("PAECABEC", "PAE_CODIGO"))
    //oModel:LoadValue("PAECABEC", "PAE_NOME", oModel:GetValue("PAECABEC", "PAE_CODIGO"))
    //oModel:LoadValue("PAECABEC", "PAE_E,I", oModel:GetValue("PAECABEC", "PAE_CODIGO"))
Return

Static Function PAEPos(oModel)
    Local lRet := .T.
    Local oModel   := FWModelActive()
    If oModel:GetOperation() == 3 //VALIDA SE É INCLUSÃO
    EndIf

Return lRet

Static Function VldField()
    Local cVar     := ReadVar()
    Local lRet     := .T.
    Local oView    := FWViewActive() //Objeto da View
    Local oModel   := FWModelActive()
    Local nTamDesc := TamSX3("PAF_DESC")[1]

	If cVar == "M->PAF_PRODUT"
        oModelPAF := oModel:GetModel("PAFGRID")
		cProduto  := oModelPAF:GetValue("PAF_PRODUT",oModelPAF:GetLine())

        If ExistCpo("SB1",cProduto)
            oModelPAF:SetValue("PAF_DESC",left(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"),nTamDesc))
        Else
            lRet := .f.
        EndIf
    EndIf
Return lRet

User Function ElimRes()
    If MsgYesNO("Deseja realmente cancelar? Após cancelar a solicitação não poderá ser mais atendida....","Atenção")
        RecLock("PAE", .F.)		
            PAE->PAE_STATUS := "C"		
        MsUnLock() //Confirma e finaliza a operação
    EndIf
Return

//pontos de entrada
User Function PAEMODEL()
    Local aParam := PARAMIXB
    Local xRet := .T.
    Local oObj := ''
    Local cIdPonto := ''
    Local cIdModel := ''
    Local lIsGrid := .F.
    Local nLinha := 0
    Local nQtdLinhas := 0
    Local cMsg := ''

    If aParam <> NIL
        
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := ( Len( aParam ) > 3 )

        If cIdPonto == 'MODELPOS'
            SetKey(VK_F4,{||})
            //cMsg := 'Chamada na validação total do modelo (MODELPOS).' + CRLF
            //cMsg += 'ID ' + cIdModel + CRLF

            //If  !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
            //    Help( ,, 'Help',, 'O MODELPOS retornou .F.', 1, 0 )
            //EndIf

        //ElseIf cIdPonto == 'FORMPOS'
            //cMsg := 'Chamada na validação total do formulário (FORMPOS).' + CRLF
            //cMsg += 'ID ' + cIdModel + CRLF

            //If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
            //    Help( ,, 'Help',, 'O FORMPOS retornou .F.', 1, 0 )
            //EndIf

        //ElseIf cIdPonto == 'FORMLINEPRE'
            //If aParam[5] == 'DELETE'
            //    cMsg := 'Chamada na pré validação da linha do formulário (FORMLINEPRE).' + CRLF
            //    cMsg += 'Onde esta se tentando deletar uma linha' + CRLF
            //    cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) +;
           
            //    cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) +; CRLF
            //    cMsg += 'ID ' + cIdModel + CRLF
            //EndIf
            
           // If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
           //     Help( ,, 'Help',, 'O FORMLINEPRE retornou .F.', 1, 0 )
           // EndIf

        ElseIf cIdPonto == 'FORMLINEPOS'
            //cMsg := 'Chamada na validação da linha do formulário (FORMLINEPOS).' 
            //cMsg += 'ID ' + cIdModel 
            //cMsg += 'É um FORMGRID com ' + Alltrim( Str( nQtdLinhas ) ) + ;
            //' linha(s).' + CRLF
            //cMsg += 'Posicionado na linha ' + Alltrim( Str( nLinha ) ) + CRLF

            //If !( xRet := ApMsgYesNo( cMsg + 'Continua ?' ) )
            //    Help( ,, 'Help',, 'O FORMLINEPOS retornou .F.', 1, 0 )
            //EndIf

        ElseIf cIdPonto == 'MODELCOMMITTTS'
            //ApMsgInfo('Chamada apos a gravação total do modelo e dentro da transação (MODELCOMMITTTS).' + CRLF + 'ID ' + cIdModel )
        ElseIf cIdPonto == 'MODELCOMMITNTTS'
            //ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)
        ElseIf cIdPonto == 'FORMCOMMITTTSPOS'
            //ApMsgInfo('Chamada apos a gravação da tabela do formulário (FORMCOMMITTTSPOS).' + CRLF + 'ID ' + cIdModel)
        ElseIf cIdPonto == 'MODELCANCEL'
            SetKey(VK_F4,{||})

            //cMsg := 'Chamada no Botão Cancelar (MODELCANCEL).' + CRLF + 'Deseja Realmente Sair ?'
        
            //If !( xRet := ApMsgYesNo( cMsg ) )
            //    Help( ,, 'Help',, 'O MODELCANCEL retornou .F.', 1, 0 )
            //EndIf

        ElseIf cIdPonto == 'MODELVLDACTIVE' 
            If aParam[1]:GetOperation() <> 3 .and. aParam[1]:GetOperation() <> 1
                If PAE->PAE_STATUS == 'C'
                    xRet := .F.
                    cMsg := 'Solicitação cancelada anteriormente. Não pode ser atendida.'
                    Help( ,, 'ATENÇÃO',, cMsg, 1, 0 )
                ElseIf PAE->PAE_STATUS == "E" 
                    xRet := .F.
                    cMsg := 'Solicitação já encerrada. Não pode ser alterada.'
                    Help( ,, 'ATENÇÃO',, cMsg, 1, 0 )
                ElseIf PAE->PAE_STATUS == "A" 
                    xRet := .F.
                    cMsg := 'Solicitação em atendimento. Não pode ser alterada.'
                    Help( ,, 'ATENÇÃO',, cMsg, 1, 0 )
                EndIf
            Else
                SetKey(VK_F4,{ || u_SAEST2B(aParam[1]) })
            EndIf

        ElseIf cIdPonto == 'BUTTONBAR'
            aBotoes := {}
            aAdd(aBotoes,{'Consultar Saldo', 'Consultar Saldo', { || u_SAEST2B(aParam[1]) }, 'Consultar Saldo' })
            Return aBotoes
        EndIf
    EndIf
Return xRet

User Function SAEST2B(oModel)
    Local aHead       := {}
    Local aCampos     := {}
    Local aAlter      := {}
    Local aCols       := {}
    Local aButtons    := {}

    aAdd(aCampos, { "NNT_LOCAL"    , "Armazém"            ,"LOCAL"    })
    aAdd(aCampos, { "PAF_PRODUT"   , "Disponível"         ,"PRODUTO"  })

    aHead  := GetAheader(aCampos)

    oModelSZR := oModel:GetModel("PAFGRID")
    cProduto  := oModelSZR:GetValue("PAF_PRODUT",oModelSZR:GetLine())

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

    DEFINE MSDIALOG oDlg2 TITLE  "Saldo(s) em Estoque - "+rtrim(cProduto) FROM 0,0 TO 300,500 PIXEL
        oBrw:= MsNewGetDados():New(30,2,150,250,GD_UPDATE,/*Eval(bLinOk)*/,"AllwaysTrue","AllwaysTrue",aAlter,0,99,"AllwaysTrue",,"AllwaysTrue",oDlg2,aHead,aCols)
        oDlg2:bInit := {||  EnchoiceBar(oDlg2,{|| oDlg2:End()},{|| oDlg2:End()},,aButtons,,,.F.,.T.,.T.,.T.,.F.,)}
        //DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg2:End())  ENABLE OF oDlg2
    ACTIVATE MSDIALOG oDlg2 CENTER
Return 

Static Function GetAheader(aCampos)
    Local aHead := {}
    Local nI := 0
    Local nX := 0

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
	
Return aHead


