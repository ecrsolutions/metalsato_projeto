/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ MT103FIM   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 14/01/2021 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada na Classificacao da NF                       ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MT103FIM()
	Local aSE2, aSE2NF, aSE2PA, aVlrPA, cBusca, nRegSE2, nTotal
	Local aPA       := {}
	Local aNF       := {}
	Local nErros    := 0
	Local cSeek     := SE2->(XFILIAL("SE2"))+cSerie+cNFiscal
	Local aContabil := {}
	Local bBlock    := Nil
	Local aEstorno  := {}
	Local nSldComp  := 0
	Local nTaxaPA   := 0
	Local nTaxaNF   := 0
	Local nHdl      := 0
	Local nOperacao := 0
	Local aRecSE5   := {}
	Local aNDFDados := {}
	Local lHelp     := .T.
	Local cFunName  := FunName()
	
	If ParamIXB[1] <> 4 .Or. ParamIXB[2] <> 1
		Return
	Endif
	
	Private lMsErroAuto := .F.
	
	// Processa a exclusão dos títulos provisórios
	SE2->(dbSetOrder(1))
	SE2->(dbSeek(cSeek,.T.))
	While !SE2->(Eof()) .And. cSeek == SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM
		
		If SE2->E2_FORNECE+SE2->E2_LOJA <> cA100For+cLoja
			SE2->(dbSkip())
			Loop
		Endif
		
		If SE2->E2_SALDO == SE2->E2_VALOR .And. Trim(SE2->E2_TIPO) == "PR"
			aSE2 := {	{"E2_PREFIXO", SE2->E2_PREFIXO, Nil},;
						{"E2_NUM"    , SE2->E2_NUM    , Nil},;
						{"E2_PARCELA", SE2->E2_PARCELA, Nil},;
						{"E2_TIPO"   , SE2->E2_TIPO   , Nil},;
						{"E2_NATUREZ", SE2->E2_NATUREZ, Nil},;
						{"E2_FORNECE", SE2->E2_FORNECE, Nil},;
						{"E2_LOJA"   , SE2->E2_LOJA   , Nil},;
						{"E2_EMISSAO", SE2->E2_EMISSAO, Nil},;
						{"E2_VENCTO" , SE2->E2_VENCTO , Nil},;
						{"E2_VALOR"  , SE2->E2_VALOR  , Nil}}
			
			lMsErroAuto := .F.
			
			RecLock("SE2",.F.)
			SE2->E2_ORIGEM := "FINA050"
			MsUnLock()
			
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aSE2,,5)   // Opcao 5 = Exclusao.
			
			If lMsErroAuto
				RecLock("SE2",.F.)
				SE2->E2_ORIGEM := "SF1140I"
				MsUnLock()
				
				nErros++
			Endif
		ElseIf Trim(SE2->E2_TIPO) == "NF"
			AAdd( aNF , SE2->(Recno()) )
		ElseIf Trim(SE2->E2_TIPO) $ MVPAGANT
			AAdd( aPA , SE2->(Recno()) )
		Endif
		
		SE2->(dbSkip())
	Enddo
	
	If nErros == 0
		SetFunName("FINA750")   // Define a função sendo a do Financeiro para caso seja necessário estornar a compensação
		
		If !FinCmpAut(aNF, aPA, aContabil, bBlock, aEstorno, nSldComp, dDatabase, nTaxaPA ,nTaxaNF, nHdl, nOperacao, aRecSE5, aNDFDados, lHelp)
			Help("XAFCMPAD",1,"HELP","XAFCMPAD","Não foi possível a compensação"+CRLF+" do titulo do adiantamento",1,0)
		Else
			MsgInfo("Compensação Automática Concluída","Atenção")
		EndIf
		
		SetFunName(cFunName)
	ElseIf nErros > 1
		Alert("Ocorreu erro na exclusão de dois ou mais títulos provisórios !")
	ElseIf nErros > 0
		Alert("Ocorreu erro na exclusão de um título provisório !")
	Endif
	
Return
