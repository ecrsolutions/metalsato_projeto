#Include "Rwmake.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ MT140SAI   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 14/01/2021 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de entrada na exclusão de pré-nota de entrada           ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MT140SAI()
	Local cFile  := "\PRE" + Trim(cNFiscal) + Trim(cSerie) + "_" + Trim(cA100For) + Trim(cLoja) + ".txt"
	
	If File(cFile)
		FErase(cFile)
	Endif
	
	If ParamIXB[1] == 5   // Se for exclusão
		// Exclui os títulos provisórios gerados para o documento de entrada
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
	Endif
	
Return
