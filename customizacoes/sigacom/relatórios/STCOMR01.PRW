#Include "Protheus.Ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STCOMR01   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 15/01/2021 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Relatorio de Documentos em Transito                           ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STCOMR01()
	Local cPerg := PADR("STCOMR01",Len(SX1->X1_GRUPO))
	
	Private oReport
	Private nPMO   := 0
	Private aTipos := {}
	
	ValidPerg(cPerg)
	Pergunte(cPerg,.F.)
	
	oReport := ReportDef(oReport,cPerg)
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	
	oReport:PrintDialog()

	//restaura perguntas
	Pergunte("MTA140",.F.)

Return

Static Function ReportDef(oReport,cPerg)
	Local oSection1
	Local cTitulo := "Documento em Transito"
	Local aOrdem  := Nil //{"Documento"}
	
	oReport := TReport():New(Trim(cPerg), cTitulo, cPerg , {|oReport| PrintReport(oReport,cPerg)},cTitulo)
	
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()
	oReport:PrintSHeader(.T.)
	
	//Cabeçalho do relatório
	oSection1 := TRSection():New(oReport, cTitulo, {},aOrdem, .F., .T.,"Total",.F.)
	TRCell():New(oSection1,"D1_FORNECE","TMP","Fornecedor" ,"@!",100,,{|| TMP->D1_FORNECE+'-'+TMP->D1_LOJA+' - '+Trim(TMP->A2_NREDUZ) },,,"LEFT")
	TRCell():New(oSection1,"F1_DOC"    ,"TMP","Nota"       ,"@!", 30,,{|| TMP->D1_DOC+'-'+TMP->D1_SERIE },,,"LEFT")
	TRCell():New(oSection1,"F1_EMISSAO","TMP","Emissão"    ,"@!", 40,,,,,"LEFT")
	TRCell():New(oSection1,"F1_XDTEMB" ,"TMP","Embarque"   ,"@!", 40,,,,,"LEFT")
	TRCell():New(oSection1,"F1_XDTENT" ,"TMP","Chegada"    ,"@!", 40,,,,,"LEFT")
	TRCell():New(oSection1,"D1_COD"    ,"TMP","Produto"    ,"@!", 80,,{|| TMP->D1_COD+' - '+TMP->B1_DESC },,,"LEFT")
	TRCell():New(oSection1,"D1_QUANT"  ,"TMP","Quant."     ,"@E 999,999.99" ,40,,,,,"RIGHT")
	TRCell():New(oSection1,"D1_TOTAL"  ,"TMP","Valor"      ,"@E 999,999,999.99",40,,,,,"RIGHT")
	
	TRFunction():New(oSection1:Cell("D1_TOTAL"), "TOTALNF", "SUM"    ,/*oBreak*/,,/*cPicture*/,,.T.,.F.)
	
Return oReport

Static Function PrintReport(oReport,cPerg)
	
	Private oSection1 := oReport:Section(1)
	
	oReport:cTitle := Trim(oReport:cTitle) + " - " + DtoC(mv_par01) + " a " + DtoC(mv_par02)
	
	ImprimeSecao(oSection1,MontaQuery(),{"F1_XDTEMB","F1_XDTENT","F1_EMISSAO"})
	
Return

Static Function MontaQuery()
	Local cQry
	
	cQry := "SELECT SD1.D1_COD, SB1.B1_DESC, SD1.D1_QUANT, SD1.D1_TOTAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NREDUZ, SF1.F1_XDTEMB, SF1.F1_XDTENT, SF1.F1_EMISSAO"
	cQry += " FROM " + RetSQLName("SF1") + " SF1"
	cQry += " INNER JOIN " + RetSQLName("SD1") + " SD1 ON SD1.D_E_L_E_T_ = ' '"
	cQry += " AND SD1.D1_FILIAL = SF1.F1_FILIAL"
	cQry += " AND SD1.D1_DOC = SF1.F1_DOC"
	cQry += " AND SD1.D1_SERIE = SF1.F1_SERIE"
	cQry += " AND SD1.D1_FORNECE = SF1.F1_FORNECE"
	cQry += " AND SD1.D1_LOJA = SF1.F1_LOJA"
	cQry += " AND SD1.D1_COD >= '"+mv_par07+"'"
	cQry += " AND SD1.D1_COD <= '"+mv_par08+"'"
	cQry += " INNER JOIN " + RetSQLName("SA2") + " SA2 ON SA2.D_E_L_E_T_ = ' '"
	cQry += " AND SA2.A2_FILIAL = '"+SA2->(XFILIAL("SA2"))+"'"
	cQry += " AND SA2.A2_COD = SF1.F1_FORNECE"
	cQry += " AND SA2.A2_LOJA = SF1.F1_LOJA"
	cQry += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' '"
	cQry += " AND SB1.B1_FILIAL = '"+SB1->(XFILIAL("SB1"))+"'"
	cQry += " AND SB1.B1_COD = SD1.D1_COD"
	cQry += " WHERE SF1.D_E_L_E_T_ = ' '"
	cQry += " AND SF1.F1_FILIAL = '"+SF1->(XFILIAL("SF1"))+"'"
	cQry += " AND SF1.F1_XDTEMB >= '"+DtoS(mv_par01)+"'"
	cQry += " AND SF1.F1_XDTEMB <= '"+DtoS(mv_par02)+"'"
	cQry += " AND SF1.F1_XDTENT >= '"+DtoS(mv_par03)+"'"
	cQry += " AND SF1.F1_XDTENT <= '"+DtoS(mv_par04)+"'"
	cQry += " AND SF1.F1_FORNECE >= '"+mv_par05+"'"
	cQry += " AND SF1.F1_FORNECE <= '"+mv_par06+"'"
	
	If mv_par09 == 2    // Se não deseja exibir as notas classificadas
		cQry += " AND SF1.F1_STATUS = ' '"
	Endif
	
	cQry += " ORDER BY SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_DOC, SF1.F1_SERIE"
	
Return cQry

Static Function ImprimeSecao(oSection,cQry,aCmpData)
	Local nX
	Local aArea := GetArea()
	Local cTmp  := "TMP"  //GetNextAlias()
	
	Default aCmpData := {}

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQry)),cTmp,.T.,.T.)
	
	For nX:=1 To Len(aCmpData)
		TCSetField(cTmp,aCmpData[nX],"D",8,0)
	Next
	
	//Processa a impressão do cabeçalho
	oSection:Init()
	
	oReport:SetMeter((cTmp)->(RecCount()))
	
	(cTmp)->(dbGoTop())
	While !(cTmp)->(Eof())
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oReport:IncMeter()
		
		oSection:Printline()
		
		(cTmp)->(dbSkip())
	Enddo
	(cTmp)->(dbCloseArea())
	RestArea(aArea)
	
	oSection:Finish()

Return

Static Function ValidPerg(cPerg)
	Local nTam := TamSX3("B1_COD")[1]
	
	u_STPutSX1(cPerg,"01",PADR("Da Data de embarque      ",29)+"?","","","mv_ch1","D",   8,0,0,"G","","   ","","","mv_par01")
	u_STPutSX1(cPerg,"02",PADR("Ate a Data de embarque   ",29)+"?","","","mv_ch2","D",   8,0,0,"G","","   ","","","mv_par02")
	u_STPutSX1(cPerg,"03",PADR("Da Data de chegada       ",29)+"?","","","mv_ch3","D",   8,0,0,"G","","   ","","","mv_par03")
	u_STPutSX1(cPerg,"04",PADR("Ate a Data de chegada    ",29)+"?","","","mv_ch4","D",   8,0,0,"G","","   ","","","mv_par04")
	u_STPutSX1(cPerg,"05",PADR("Do Fornecedor            ",29)+"?","","","mv_ch5","C",   6,0,0,"G","","SA2","","","mv_par05")
	u_STPutSX1(cPerg,"06",PADR("Ate o Fornecedor         ",29)+"?","","","mv_ch6","C",   6,0,0,"G","","SA2","","","mv_par06")
	u_STPutSX1(cPerg,"07",PADR("Do Produto               ",29)+"?","","","mv_ch7","C",nTam,0,0,"G","","SB1","","","mv_par07")
	u_STPutSX1(cPerg,"08",PADR("Ate o Produto            ",29)+"?","","","mv_ch8","C",nTam,0,0,"G","","SB1","","","mv_par08")
	u_STPutSX1(cPerg,"09",PADR("Exibe notas classificadas",29)+"?","","","mv_ch9","N",   1,0,0,"C","","   ","","","mv_par09","Sim","","","","Nao")

Return
