#Include "Rwmake.ch"
#Include "Tbiconn.ch"

User Function TesteXML(cCodEmp,cCodFil,cTipo,cNota,cSerie)
	Local aRet, cPath
	Local cArq := "\XML_NF.xml"
	
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil MODULO "FAT" TABLES "SA1", "ADZ", "ADY"
	
	SetFunName("SPEDNFE")
	
	If cTipo == "S"
		SF2->(dbSetOrder(1))
		If SF2->(dbSeek(XFILIAL("SF2")+cNota+PADR(cSerie,Len(SF2->F2_SERIE))))
			aRet := ExecBlock("XmlNfeSef",.F.,.F.,{{"1","",SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA,{}},"4.00","4.00",{"",""}}) //,cNotaOri,cSerieOri)
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