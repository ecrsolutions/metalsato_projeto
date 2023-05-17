#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

/*/{Protheus.doc} User Function STFATR05
	Relatório Romaneio Yamaha
	@type  Function
	@author matheus.vinicius
	@since 10/05/2023
/*/
User Function STFATR05()
	Private oReport  := Nil
	Private oSecCab1,oSecCab2,oSecCab3	 := Nil
	Private cPerg 	 := PadR ("STFATR05", Len (SX1->X1_GRUPO))

	u_STPutSx1(cPerg,"01","Data de?"  ,'','' ,"mv_ch1","D",TamSx3("D2_EMISSAO")[1];
		,0,,"G","","","","","mv_par01","","","","","","","","","","","","","","","","")
	u_STPutSx1(cPerg,"02","Data ate?"  ,'','',"mv_ch2","D",TamSx3("D2_EMISSAO")[1];
		,0,,"G","","","","","mv_par02","","","","","","","","","","","","","","","","")
	u_STPutSx1(cPerg,"03","Cli ate?"  ,'','',"mv_ch3","C",TamSx3("D2_CLIENTE")[1];
		,0,,"G","","SA1","","","mv_par02","","","","","","","","","","","","","","","","")
	u_STPutSx1(cPerg,"04","Cli ate?"  ,'','',"mv_ch4","C",TamSx3("D2_CLIENTE")[1];
		,0,,"G","","SA1","","","mv_par02","","","","","","","","","","","","","","","","")
	u_STPutSx1(cPerg,"05","Prod ate?"  ,'','',"mv_ch5","C",TamSx3("D2_COD")[1];
		,0,,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","")
	u_STPutSx1(cPerg,"06","Prod ate?"  ,'','',"mv_ch6","C",TamSx3("D2_COD")[1];
		,0,,"G","","SB1","","","mv_par02","","","","","","","","","","","","","","","","")

	ReportDef()
	oReport:PrintDialog()

Return Nil

Static Function ReportDef()

	oReport := TReport():New("STFATR05","Romaneio de Entrega NF's",cPerg,{|oReport| PrintReport(oReport)},"Impressão de Romaneio de Entrega NF's.",,,,,,,,,,50,)

	oReport:SetLandscape(.T.)       
	oreport:nfontbody:=9
	oReport:HideParamPage(.T.)   
	oReport:SetLineHeight(60)

	//TRCEll():New(1-oParent, 2-cName,3-cAlias,4-cTitle,5-cPicture,6-nSize,7-lPixel,8-{|| bBlock },9-cAlign ,10-lLineBreak,;
	//11-cHeaderAlign,12-lCellBreak,13-nColSpace,14-lAutoSize,15-nClrBack,16-nClrFore,17-lBold)	

	oSecCab1 := TRSection():New( oReport , "Cabeçalho", {"QRY1"} )   
	oSecCab1:SetLineStyle(.F.)
	oSecCab1:SetCols(1)    
	oSecCab1:SetBorder("ALL")

	TRCell():New( oSecCab1, "D2_DOC"      , "QRY2",,,10                    	,,,,,,)
	TRCell():New( oSecCab1, "D2_EMISSAO"  , "QRY2",,,10                    	,,,,,,)
	TRCell():New( oSecCab1, "F2_HORA"     , "QRY2",,,10                    	,,,,,,)
	TRCell():New( oSecCab1, "D2_QUANT"    , "QRY2",,,TAMSX3("D2_QUANT")[1] 	,,,,,,)
	TRCell():New( oSecCab1, "B1_COD"      , "QRY2",,,20 					,,,,,,)
	TRCell():New( oSecCab1, "A7_CODCLI"   , "QRY2",,,50  					,,,,,,)
	TRCell():New( oSecCab1, "B1_DESC"     , "QRY2",,,TAMSX3("B1_DESC")[1]   ,,,,,,)
	
Return Nil

Static Function PrintReport(oReport)
	Pergunte(cPerg,.F.)

	oSecCab1:BeginQuery()

		BeginSql Alias "QRY1"

			SELECT *
				,(SELECT TOP 1 A7_CODCLI FROM %table:SA7%  SA7 WHERE  SA7.D_E_L_E_T_= ' ' AND A7_PRODUTO = D2_COD AND A7_CLIENTE = D2_CLIENTE AND A7_LOJA = D2_LOJA ) AS A7_CODCLI
			FROM  %table:SD2% SD2	
			LEFT JOIN %table:SB1% SB1 
				on LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(D2_FILIAL,LEN(B1_FILIAL)) AND B1_COD = D2_COD AND SB1.%notDel%
			LEFT JOIN %table:SF2% SF2 ON F2_FILIAL = D2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SF2.%notDel%
			WHERE SD2.D2_FILIAL =  %xFilial:SD2% 
			AND SD2.D_E_L_E_T_ = '' 
			AND D2_EMISSAO BETWEEN %exp:dtos(MV_PAR01)% AND %exp:dtos(MV_PAR02)% 
			AND D2_CLIENTE BETWEEN %exp:MV_PAR03% AND %exp:MV_PAR04% 
			AND D2_LOJA    BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06% 
			ORDER BY D2_EMISSAO,D2_DOC,D2_ITEM
		EndSql
		
	oSecCab1:EndQuery()
	oSecCab1:Print()	
Return Nil 

              