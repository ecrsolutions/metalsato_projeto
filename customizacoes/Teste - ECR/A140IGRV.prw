#include "rwmake.ch"
#include "Topconn.ch"
#include "protheus.ch"

User Function A140IGRV()
 
	Local cDoc		:= ParamIxb[1]  // Numero da Nota
	Local cSerie	:= ParamIxb[2]  // Série da Nota
	Local cCod		:= ParamIxb[3]  // Código do Fornecedor
	Local cLoja		:= ParamIxb[4] 	// Loja do Fornecedor
	Local oXml		:= ParamIxb[5] // XML
	local cUni		:= ""
	local nPrc		:= 0
	local cDesc		:= ""
	local nQuant 	:= 0
	local oProd 	as object
	local aItens	:= {}
	local i 		:= 0

	if valtype(oXml:_INFNFE:_DET) == "O"
 
		oProd  := oXml:_INFNFE:_DET:_PROD
		cUni   := oProd:_UCOM:TEXT
		nPrc   := VAL(oProd:_VPROD:TEXT)
		cDesc  := oProd:_XPROD:TEXT
		nQuant := VAL(oProd:_QCOM:TEXT)
		nItem  := PADL(oXml:_INFNFE:_DET:_NITEM:TEXT,4,"0")

		DbSelectArea("SDT")
		DbSetOrder(8)
		IF SDT->(DBSEEK(xFilial("SDT")+cCod+cLoja+cDoc+cSerie+nItem))
			RecLock("SDT", .F.)
			SDT->DT_XMLUN  	:= cUni
			SDT->DT_XMLQTD 	:= nQuant
			SDT->DT_XMLDESC	:= cDesc
			//SDT->DT_XMLPRC 	:= nPrc
			MsUnlock()
		ENDIF

	elseif valtype(oXml:_INFNFE:_DET) == "A"

		aItens := oXml:_INFNFE:_DET

		if Len(aItens) > 0
			for i := 1 to len(aItens)
				oProd  := aItens[i]:_PROD
				cUni   := oProd:_UCOM:TEXT
				nPrc   := Round(VAL(oProd:_VPROD:TEXT),2)
				cDesc  := oProd:_XPROD:TEXT
				nQuant := Round(VAL(oProd:_QCOM:TEXT),2)
				nItem  := PADL(aItens[i]:_NITEM:TEXT,4,"0")

				DbSelectArea("SDT")
				DbSetOrder(8)
				IF SDT->(DBSEEK(xFilial("SDT")+cCod+cLoja+cDoc+cSerie+nItem))
					RecLock("SDT", .F.)
					SDT->DT_XMLUN  	:= cUni
					SDT->DT_XMLQTD 	:= nQuant
					SDT->DT_XMLDESC	:= cDesc
				//	SDT->DT_XMLPRC 	:= nPrc
					MsUnlock()
				ENDIF

			NEXT i

		ENDIF

	ENDIF







Return
