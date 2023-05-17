#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"


User Function STFATR03()

	Private oReport  := Nil
	Private oSecCab1,oSecCab2,oSecCab3	 := Nil
	Private cPerg 	 := PadR ("STFATR03", Len (SX1->X1_GRUPO))


	PutSx1(cPerg,"01","Id Romaneio?"  ,'','',"mv_ch1","C",TamSx3 ("PAA_ID")[1] ,0,,"G","","PAA","","","mv_par01","","","","","","","","","","","","","","","","")

	ReportDef()
	oReport:PrintDialog()

Return Nil


Static Function ReportDef()

	oReport := TReport():New("STFATR03","Romaneio de Entrega",cPerg,{|oReport| PrintReport(oReport)},"Impressão de Romaneio de Entrega.",,,,,,,,,,50,)

	oReport:SetLandscape(.T.)       
	oreport:nfontbody:=10
	oReport:HideParamPage(.T.)   
	oReport:SetLineHeight(60)

	//TRCEll():New(1-oParent, 2-cName,3-cAlias,4-cTitle,5-cPicture,6-nSize,7-lPixel,8-{|| bBlock },9-cAlign ,10-lLineBreak,;
	//11-cHeaderAlign,12-lCellBreak,13-nColSpace,14-lAutoSize,15-nClrBack,16-nClrFore,17-lBold)

	oSecCab1 := TRSection():New( oReport , "Cabeçalho", {"QRY1"} )   
	oSecCab1:SetLineStyle(.T.)
	oSecCab1:SetCols(1)    

	TRCell():New( oSecCab1,"PAA_ID"	       ,"QRY1",,,40,,,,,,)
	TRCell():New( oSecCab1,"DA3_PLACA"     ,"QRY1","Veículo",,40,,,,,,)
	TRCell():New( oSecCab1,"PAA_DATA"      ,"QRY1",,,10,,,,,,)
	TRCell():New( oSecCab1,"PAA_NOME"      ,"QRY1","Motorista",,40,,,,,,)
	TRCell():New( oSecCab1, "Motorista:____________________________",)
	TRCell():New( oSecCab1, "Encarregado:____________________________",)    

	oSecCab1:SetBorder("ALL")

	oSecCab2 := TRSection():New( oReport , "Itens", {"QRY2"} )
	oSecCab2:SetLineHeight(60)

	TRCell():New( oSecCab2, "PAB_ITEM"    , "QRY2",			,,TAMSX3("PAB_ITEM")[1]    	,,,,,,)
	TRCell():New( oSecCab2, "NOME"        , "QRY2","Nome"	,,TAMSX3("PAB_CLIENTE")[1] 	,,,,,,)
	TRCell():New( oSecCab2, "PAB_DOC"     , "QRY2",			,,TAMSX3("PAB_DOC")[1]     	,,,,,,)
	TRCell():New( oSecCab2, "PAB_SERIE"   , "QRY2",			,,TAMSX3("PAB_SERIE")[1]   	,,,,,,)
	TRCell():New( oSecCab2, "VOLUME"      , "QRY2","Volume"	,,15    					,,,,,,)
	TRCell():New( oSecCab2, "PAB_HRSAI"   , "QRY2",		   	,,5    						,,,,,,)
	TRCell():New( oSecCab2, "PAB_HRCHEG"  , "QRY2",			,,5    						,,,,,,)
	TRCell():New( oSecCab2, "PAB_KMSAI"   , "QRY2",			,,10    					,,,,,,)
	TRCell():New( oSecCab2, "PAB_KMENT"   , "QRY2",			,,10    					,,,,,,)
	//TRCell():New( oSecCab2, "PAB_OBS"     , "QRY2",,,10 ,,,,,,)

	//oSecCab2:SetBorder("ALL")
		oSecCab2:Cell("PAB_ITEM"):SetBorder("ALL")
		oSecCab2:Cell("NOME"):SetBorder("ALL")
		oSecCab2:Cell("PAB_DOC"):SetBorder("ALL")
		oSecCab2:Cell("PAB_SERIE"):SetBorder("ALL")
		oSecCab2:Cell("VOLUME"):SetBorder("ALL")
		oSecCab2:Cell("PAB_HRSAI"):SetBorder("ALL")
		oSecCab2:Cell("PAB_HRCHEG"):SetBorder("ALL")
		oSecCab2:Cell("PAB_KMSAI"):SetBorder("ALL")
		oSecCab2:Cell("PAB_KMENT"):SetBorder("ALL")
		//oSecCab2:Cell("PAB_OBS"):SetBorder("ALL")

		oSecCab2:Cell("VOLUME"):SetAlign("CENTER")
		oSecCab2:Cell("PAB_DOC"):SetAlign("CENTER")
		oSecCab2:Cell("PAB_SERIE"):SetAlign("CENTER")
		oSecCab2:Cell("PAB_HRSAI"):SetAlign("CENTER")
		oSecCab2:Cell("PAB_HRCHEG"):SetAlign("CENTER")

	oReport:Say( 100 , 10 , "Motorista" , , 100 , , ,  ) 
Return Nil

Static Function PrintReport(oReport)

	Pergunte(cPerg,.F.)

	oSecCab1:BeginQuery()

		BeginSql Alias "QRY1"

			SELECT *
			FROM  %table:PAA% PAA
			LEFT JOIN %table:DA4% DA4
				ON PAA_CODMOT = DA4_COD AND DA4.D_E_L_E_T_ = '' 
			LEFT JOIN %table:DA3% DA3
				ON PAA_VEICUL = DA3_COD AND DA3.D_E_L_E_T_ = ''  	
			WHERE PAA.PAA_FILIAL =  %xFilial:PAA% 
			AND PAA.D_E_L_E_T_ = '' 
			AND PAA_ID = %exp:MV_PAR01%
		EndSql
		
	oSecCab1:EndQuery()
	oSecCab1:Print()	

	oSecCab2:EndQuery()	
		BeginSql Alias "QRY2"
			SELECT 
				PAB_ID, PAB_ITEM 
				,(SELECT A1_NOME FROM %table:SA1% WHERE D_E_L_E_T_ = '' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA) AS NOME
				, PAB_DOC, PAB_SERIE
				, CONVERT(VARCHAR,ISNULL(PAB_VOLUME,F2_VOLUME1))+' - '+F2_ESPECI1 AS VOLUME
				, PAB_HRSAI, PAB_HRCHEG, PAB_KMSAI, PAB_KMENT, PAB_OBS  
				, PAB_VOLUME
			FROM %table:PAB% PAB 
			LEFT JOIN %table:SF2% SF2 
				ON PAB_DOC = SF2.F2_DOC
				AND SF2.D_E_L_E_T_ = '' 
				AND PAB_SERIE = SF2.F2_SERIE 
			WHERE 
				PAB.PAB_FILIAL = %xFilial:PAB% 
				AND PAB.D_E_L_E_T_ = ' ' 
				AND PAB_ID = %exp:MV_PAR01%
			ORDER BY PAB_ITEM
		EndSql
		
	oSecCab2:EndQuery()
	oSecCab2:Print()    



Return Nil 

              