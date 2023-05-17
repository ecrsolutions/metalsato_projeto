#Include "Rwmake.ch"
#Include "Tbiconn.ch"
#INCLUDE "PROTHEUS.CH"

User Function TesteXML(cCodEmp,cCodFil,cTipo,cNota,cSerie,cRdmake)
	Local aRet, cPath, aDados
	Local cArq := "\XML_NF.xml"
	Default cCodEmp := "01"
	Default cCodFil := "01"
	Default cTipo   := "S"
	
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil TABLES "SA1", "ADZ", "ADY"
	
	SetFunName("SPEDNFE")
	
	If cTipo == "S"
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek(XFILIAL("SF2")+cNota+PADR(cSerie,Len(SF2->F2_SERIE))))
			If Trim(SF2->F2_ESPECIE) == "SPED"
				aRet := ExecBlock("XmlNfeSef",.F.,.F.,{{"1","",SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA,{}},"4.00","4.00",{"",""}}) //,cNotaOri,cSerieOri)
			Else
				cArq := "\XML_NFS_"+SF2->F2_DOC+"_"+Trim(SF2->F2_SERIE)+".xml"

				//If Empty(cFuncExec)
					cFuncExec := If( cRdmake == Nil .Or. Empty(cRdmake) , getRDMakeNFSe(SM0->M0_CODMUN,"1"), cRdmake)
				//EndIf
				
				If cFuncExec == "nfseXMLEnv"
					aRet := { "", u_nfseXMLEnv( "1", SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA, "", {""} )[1] }
				ElseIf !Empty(cFuncExec) .And. ExistBlock(cFuncExec)
					aDados := {}
					aAdd(aDados,SM0->M0_CODMUN )
					aAdd(aDados,"1"            )
					aAdd(aDados,SF2->F2_EMISSAO)
					aAdd(aDados,SF2->F2_SERIE  )
					aAdd(aDados,SF2->F2_DOC    )
					aAdd(aDados,SF2->F2_CLIENTE)
					aAdd(aDados,SF2->F2_LOJA   )
					aAdd(aDados,""             )
					aAdd(aDados,{}             )
				
					aRet := { "", ExecBlock(cFuncExec,.F.,.F.,aDados)[1] }
					//aRet := { "", u_NfseM002(SM0->M0_CODMUN,"1",SF2->F2_EMISSAO, SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA)[1] }
				Else
					aRet := { "", ""}
				Endif
			Endif
			
			Memowrite(cArq,aRet[2])
		Endif
	Else
		SF1->(dbSetOrder(1))
		If SF1->(dbSeek(XFILIAL("SF1")+cNota+PADR(cSerie,Len(SF1->F1_SERIE))))
			aRet := ExecBlock("XmlNfeSef",.F.,.F.,{{"2","",SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA,{}},"3.10","3.10",{"",""}}) //,cNotaOri,cSerieOri)
			Memowrite(cArq,aRet[2])
		Endif
	Endif
	
	cPath := GetTempPath()
	If File(cPath+cArq)
		FErase(cPath+cArq)
	Endif
	CpyS2T(cArq, cPath, .T.)
	
	MsgInfo("Empresa: "+cEmpAnt+" / Filial: "+cFilAnt+". Acabou !","INFORMAÇÃO")
	
	RESET ENVIRONMENT
	
Return
