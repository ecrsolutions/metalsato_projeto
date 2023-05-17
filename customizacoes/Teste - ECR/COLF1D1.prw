#include "rwmake.ch"
#include "Topconn.ch"
#include "protheus.ch"

user function COLF1D1()

	Local aCab      := PARAMIXB[1]
	Local aItens    := PARAMIXB[2]
	Local aRet      := {}
	local nX        := 0




	For nX := 1 To LEN(aItens)
 
		DbSelectArea("SDT")
		DbSetOrder(8)
		IF SDT->(DBSEEK(xFilial("SDT")+SDS->DS_FORNEC+SDS->DS_LOJA+SDS->DS_DOC+SDS->DS_SERIE+aItens[nX,1,2]))

			aAdd( aItens[nX],{"D1_XMLUN",  	SDT->DT_XMLUN   , NIL })
			aAdd( aItens[nX],{"D1_XMLQTD",  SDT->DT_XMLQTD  , NIL })
			aAdd( aItens[nX],{"D1_XMLDESC", SDT->DT_XMLDESC , NIL })
			aAdd( aItens[nX],{"D1_XMLPRC",  SDT->DT_XMLPRC  , NIL })
		ENDIF

	Next nX

	aRet := {aCab,aItens}



Return aRet
