#include "rwmake.ch"
/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ SF2520E    ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 17/12/2019 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada de exclusão da nota de saída                 ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SF2520E()
	Local cAlias := Alias()
	
	// Exclui os registros referente aos kanbans faturados
	SZ3->(dbSetOrder(1))
	SZ3->(dbSeek(XFILIAL("SZ3")+SF2->F2_DOC+SF2->F2_SERIE,.T.))
	While !SZ3->(Eof()) .And. XFILIAL("SZ3")+SF2->F2_DOC+SF2->F2_SERIE == SZ3->Z3_FILIAL+SZ3->Z3_DOC+SZ3->Z3_SERIE

		// Subtrai a quantidade entregue no Pedido Sato
		SZ1->(dbSetOrder(1))
		If SZ1->(dbSeek(XFILIAL("SZ1")+SZ3->Z3_NUM+SZ3->Z3_PRODUTO))
			RecLock("SZ1",.F.)
			SZ1->Z1_QTDENT := Max(SZ1->Z1_QTDENT - SZ3->Z3_QUANT,0)
			MsUnLock()
		Endif
		
		// Subtrai a quantidade entregue no Kanban Eletrônico
		SZ2->(dbSetOrder(1))     //Z2_FILIAL+Z2_CLIENTE+Z2_LOJA+Z2_PRODUTO+DTOS(Z2_DATENT)+Z2_HORENT+Z2_SETENT
		If SZ2->(dbSeek(XFILIAL("SZ2")+SF2->F2_CLIENTE+SF2->F2_LOJA+SZ3->Z3_PRODUTO+DtoS(SZ3->Z3_DATENT)+SZ3->Z3_HORENT+SZ3->Z3_SETENT))
			RecLock("SZ2",.F.)
			SZ2->Z2_QTDENT := Max(SZ2->Z2_QTDENT - SZ3->Z3_QUANT,0)
			MsUnLock()
		Endif
		
		RecLock("SZ3",.F.)
		dbDelete()
		MsUnLock()
		
		SZ3->(dbSkip())
	Enddo
	
	dbSelectArea(cAlias)
	
Return