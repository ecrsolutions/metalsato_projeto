#Include "Protheus.ch"
#Include "Rwmake.ch"

/*_________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Programa  ¦ SF1140I    ¦ Autor ¦ Ronilton O. Barros     ¦ Data ¦ 14/01/2021 ¦¦¦
¦¦+-----------+------------+-------+------------------------+-------------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada após a gravação da pré-nota de entrada         ¦¦¦
¦¦+-----------+-----------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SF1140I()
	GravaProvisorio()
Return
  
Static Function GravaProvisorio()
	Local nX, aArray
	Local nTam  := TamSX3("E2_PARCELA")[1]
	Local cNat  := GetMV("MV_XNATPRV",.F.,"00001")
	Local cFile := ""
	Local aParc := {}
	
	Private dF1_XDTEMB := CriaVar("F1_XDTEMB",.F.)
	Private dF1_XDTENT := CriaVar("F1_XDTENT",.F.)
	Private cF1_TRANSP := CriaVar("F1_TRANSP",.F.)
	Private cF1_COND   := CriaVar("F1_COND"  ,.F.)
	
	If Empty(aParc := u_STCargaProvisao(@cFile))
		Return
	Endif
	
	RecLock("SF1",.F.)
	SF1->F1_XDTEMB := dF1_XDTEMB
	SF1->F1_XDTENT := dF1_XDTENT
	SF1->F1_TRANSP := cF1_TRANSP
	SF1->F1_COND   := cF1_COND
	MsUnLock()
	
	// Exclui os títulos para uma nova gravação
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(XFILIAL("SE2")+cSerie+cNFiscal,.T.))
	While !SE2->(Eof()) .And. XFILIAL("SE2")+cSerie+cNFiscal == SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM
		If SE2->E2_TIPO = "PR" .And. SE2->E2_FORNECE+SE2->E2_LOJA == cA100For+cLoja .And. Empty(SE2->E2_BAIXA)
			RecLock("SE2",.F.)
			dbDelete()
			MsUnLock()
		Endif
		SE2->(dbSkip())
	Enddo
	
	lMsErroAuto := .F.
	
	For nX:=1 To Len(aParc)
		
		aArray := {	{ "E2_PREFIXO", SF1->F1_SERIE       , NIL },;
					{ "E2_NUM"    , SF1->F1_DOC         , NIL },;
					{ "E2_PARCELA", StrZero(nX,nTam)    , NIL },;
					{ "E2_TIPO"   , "PR"                , NIL },;
					{ "E2_NATUREZ", cNat                , NIL },;
					{ "E2_FORNECE", SF1->F1_FORNECE     , NIL },;
					{ "E2_LOJA"   , SF1->F1_LOJA        , NIL },;
					{ "E2_EMISSAO", dDataBase           , NIL },;
					{ "E2_VENCTO" , aParc[nX,1]         , NIL },;
					{ "E2_VENCREA", aParc[nX,1]         , NIL },;
					{ "E2_VALOR"  , aParc[nX,2]         , NIL },;
					{ "E2_ORIGEM" , "SF1140I"           , NIL },;
					{ "E2_HIST"   , "TITULO PROVISORIO" , NIL } }
			
		MsgRun("Gerando título provisório... ","Aguarde...",{|| MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3) })
		
		If lMsErroAuto
			MostraErro()
		Endif
	Next
	
	If !lMsErroAuto
		FErase(cFile)
	Endif
	
Return
