#Include "Rwmake.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ M460NUM    ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 22/10/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada para definição do numero da nota de saida    ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function M460NUM()
	//Local cTpNrNfs  := SuperGetMV("MV_TPNRNFS")
	
	If IsInCallStack("U_STFATA01")
		cNumero := __cNumNota
	//ElseIf IsInCallStack("U_SAESTA02") .or. IsInCallStack("U_SAESTA04")
	//	If Pergunte("SAESTA01  ",.T.)
	//		cNumero := MV_PAR01
	//	EndIf
	//ElseIf Empty(cNumero)
	//	cNumero := NxtSX5Nota( SX5->X5_CHAVE,.T.,cTpNrNfs,,,, /*cSerieId*/) // O parametro cSerieId deve ser passado para funcao NxtSx5Nota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
	Endif
Return

User Function M461SER()
Return