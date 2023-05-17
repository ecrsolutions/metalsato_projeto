#Include "Rwmake.ch"

/*_______________________________________________________________________________
���������������������������������������������������������������������������������
��+-----------+------------+-------+----------------------+------+------------+��
��� Programa  � MT140TOK   � Autor � Ronilton O. Barros   � Data � 14/01/2021 ���
��+-----------+------------+-------+----------------------+------+------------+��
��� Descri��o � Ponto de entrada de valida��o da pr�-nota de entrada          ���
��+-----------+---------------------------------------------------------------+��
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function MT140TOK()
	Local aParc := u_STCargaProvisao()
	Local nTot  := a140Total[3]
	Local lRet  := .T.
	
	If Empty(aParc)
		lRet := MsgYesNo("N�o foram informados os t�tulos provis�rios! Deseja continuar mesmo assim ?","Titulos Provis�rios")
	Else
		aEval( aParc , {|x| nTot -= x[2] })
		If nTot <> 0
			lRet := .F.
			Alert("Valores dos titulos provisorios diferente do valor da pre nota. Valide a(s) parcela(s) informada(s)!")
		Endif
	Endif

Return lRet
