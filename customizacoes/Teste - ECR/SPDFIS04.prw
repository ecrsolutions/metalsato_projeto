#include "rwmake.ch"
#include "Topconn.ch"
#include "protheus.ch"


#include 'protheus.ch'

User Function SPDFIS04()

	Local cFilial   := ParamIXB[1] //Filial
	Local cTipoMov  := ParamIXB[2] //Tipo Movimento (entrada ou saída)
	Local cSerie    := ParamIXB[3] //Série
	Local cNumDoc   := ParamIXB[4] //Nota Fiscal
	Local cClieFor  := ParamIXB[5] //Cliente/Fornecedor
	Local cLoja     := ParamIXB[6] //Loja
	Local cItem     := ParamIXB[7] //Item
	Local cCodProd  := ParamIXB[8] //Código do Produto
	Local cDescri   := ""
 
	DbSelectArea("SDT")
	DbSetOrder(8)
	IF SDT->(DBSEEK(xFilial("SDT")+cClieFor+cLoja+cNumDoc+cSerie+cItem))
		IF !VAZIO(ALLTRIM(SDT->DT_XMLDESC))
			cDescri := SDT->DT_XMLDESC
		
		elseif !VAZIO(ALLTRIM(SDT->DT_DESCFOR))
			cDescri := SDT->DT_DESCFOR
 
		ELSE
			DbSelectArea("SB1")
			DbSetOrder(1)
			IF ("SB1")->(dbSeek(xFilial("SB1")+cCodProd))
				cDescri := SB1->B1_DESC
			ENDIF
		ENDIF
	ELSE
		DbSelectArea("SB1")
		DbSetOrder(1)
		IF ("SB1")->(dbSeek(xFilial("SB1")+cCodProd))
			cDescri := SB1->B1_DESC
		ENDIF
	ENDIF

Return cDescri
