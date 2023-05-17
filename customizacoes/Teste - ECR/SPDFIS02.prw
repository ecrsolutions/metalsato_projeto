#include "rwmake.ch"
#include "Topconn.ch"
#include "protheus.ch"

User Function SPDFIS02()
	Local aAliasIT  :=  ParamIXB[1]                                                 // Recebe o Alias principal
	Local aRet      :=  Array(4)                                                        // Array para armazenar dados do retorno da função
	Local aAreaAnt  :=  {}
	local cIdProd	:= 	""

	aAreaAnt  :=  GetArea()
	if "K200" $ aAliasIT
		cIdProd := "COD_ITEM"

		If SB1->(MSSEEK(xFilial("SB1")+(aAliasIT)->&cIdProd))

			aRet[1]  := SB1->B1_UM
			aRet[2]  := (aAliasIT)->QTD

			if SB1->B1_CONV > 0

				aRet[3]  := SB1->B1_CONV                           //Fator
				aRet[4]  :=  SB1->B1_TIPCONV                        //Tipo de Conversão

			else

				aRet[3]  :=  1
				aRet[4]  :=  'M'

			Endif

		Endif

	else
		cIdProd := "B1_COD"
		If GetNewPar( 'MV_ESTADO' ) == 'AM'

			If SB1->(MSSEEK(xFilial("SB1")+(aAliasIT)->&cIdProd))

				DbSelectArea('SDT')
				DbSetOrder(8)
				IF SDT->(MSSEEK(xFilial('SDT')+(aAliasIT)->FT_CLIEFOR+(aAliasIT)->FT_LOJA+(aAliasIT)->FT_NFISCAL+(aAliasIT)->FT_SERIE+(aAliasIT)->FT_ITEM))

					aRet[1]  :=  iif(!vazio(SDT->DT_XMLUN),SDT->DT_XMLUN,SB1->B1_UM)
					aRet[2]  :=  iif(!vazio(SDT->DT_XMLQTD),SDT->DT_XMLQTD,(aAliasIT)->FT_QUANT)

					if SB1->B1_CONV > 0

						aRet[3]  	:=  iif(SB1->B1_UM =  'KG' .AND.  aRet[1] == 'TN' , 0.001 , SB1->B1_CONV)           //Fator

					else

						aRet[3]  	:=  1
					Endif

					aRet[4]  		:=  'M'    						//Tipo de Conversão

				else

					aRet[1]  :=  SB1->B1_UM
					aRet[2]  := (aAliasIT)->FT_QUANT

					if SB1->B1_CONV > 0

						aRet[3]  := SB1->B1_CONV                           //Fator
						aRet[4]  :=  SB1->B1_TIPCONV                        //Tipo de Conversão

					else

						aRet[3]  :=  1
						aRet[4]  :=  'M'

					Endif

				Endif

			ENDIF

		Else

			If SB1->(MSSEEK(xFilial("SB1")+(aAliasIT)->&cIdProd))

				aRet[1]  :=  SB1->B1_UM
				aRet[2]  := (aAliasIT)->FT_QUANT

				if SB1->B1_CONV > 0

					aRet[3]  := SB1->B1_CONV                           //Fator
					aRet[4]  :=  SB1->B1_TIPCONV                        //Tipo de Conversão

				else

					aRet[3]  :=  1
					aRet[4]  :=  'M'

				Endif

			ENDIF

		ENDIF

	ENDIF
	RestArea(aAreaAnt)
Return aRet
