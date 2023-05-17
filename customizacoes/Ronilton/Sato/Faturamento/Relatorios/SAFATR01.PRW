#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function SAFATR01()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "FOLLOW UP DE ENTREGAS"
Local titulo         := "FOLLOW UP DE ENTREGAS"
Local nLin           := 80

//                                1         2         3         4         5         6         7         8         9         10        11
//                       123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local Cabec1         := "PEDIDO     PEDIDO        CLIENTE         CODIGO               COD. PROD.      DESCRIÇÃO     	                A ENTREGAR  DISPON."
Local Cabec2         := "SATO       CLIENTE                       PRODUTO               CLIENTE  "
Local aOrd := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "FOLLOW UP DE ENTREGAS" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private m_pag       := 01
Private wnrel       := "FOLLOW UP DE ENTREGAS" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg       := PADR("SAFATR01",Len(SX1->X1_GRUPO))

Private cString     := "SZ1"

dbSelectArea("SZ1")
dbSetOrder(1)

ValidPerg(cPerg)
Pergunte(cPerg,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nTotalEst := 0
Local nTotDia   := 0
Local bQuebra   := If( mv_par08 == 1, {|| BRA->ENTREGA }, {|| BRA->Z1_SETENT })
Local cQuebra   := ""
Local lPrimeiro := .T.

dbSelectArea(cString)
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . .                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQQQ := " SELECT CONVERT(char,convert(date,SZ1.Z1_DATENT),103) AS 'ENTREGA', SZ1.Z1_NUM, SZ1.Z1_PEDCLI, SZ1.Z1_SETENT, SZ1.Z1_TIPPED, SA1.A1_NREDUZ, SZ1.Z1_PRODUTO, SA7.A7_CODCLI, SB1.B1_DESC, SZ1.Z1_QUANT, (SZ1.Z1_QUANT - SZ1.Z1_QTDENT) AS Z1_SALDO "
cQQQ += " FROM " + RetSQLName("SZ1") + " SZ1 "
cQQQ += " INNER JOIN " + RetSQLName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ' ' AND SA1.A1_COD = SZ1.Z1_CLIENTE AND SA1.A1_LOJA = SZ1.Z1_LOJA"
cQQQ += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' AND SB1.B1_COD = SZ1.Z1_PRODUTO"
cQQQ += " INNER JOIN " + RetSQLName("SA7") + " SA7 ON SA7.D_E_L_E_T_ = ' ' AND SA7.A7_PRODUTO = SB1.B1_COD AND SA7.A7_CLIENTE = SA1.A1_COD AND SA7.A7_LOJA = SA1.A1_LOJA"
cQQQ += " WHERE SZ1.D_E_L_E_T_ = ' '" 
cQQQ += " AND SZ1.Z1_DATENT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " 
cQQQ += " AND SZ1.Z1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 
cQQQ += " AND SZ1.Z1_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 

If MV_PAR07 = 1
	cQQQ += " AND SZ1.Z1_TIPPED = '1' "
Else 
	cQQQ += " AND SZ1.Z1_TIPPED = '2' "
EndIf
If MV_PAR08 = 1
	cQQQ += " ORDER BY SZ1.Z1_DATENT"
Else 
	cQQQ += " ORDER BY SZ1.Z1_SETENT"
Endif

Titulo := AllTrim(Titulo) + If( mv_par09 == 3 , "", " - " + If( mv_par09 == 1 , "SEM SALDO", "COM SALDO"))

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQQQ), "BRA" , .T., .T.)

BRA->(DbGotop())

While !BRA->(EOF())
	
	nTotalEst := CalculaSaldo(BRA->Z1_PRODUTO,"01") + CalculaSaldo(BRA->Z1_PRODUTO,"02")
	
	If mv_par09 == 1 .And. (nTotalEst - BRA->Z1_SALDO) > 0    // Imprime os SEM saldo
		BRA->(dbSkip())
		Loop
	ElseIf mv_par09 == 2 .And. (nTotalEst - BRA->Z1_SALDO) <= 0    // Imprime os COM saldo
		BRA->(dbSkip())
		Loop
	Endif
	
	If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) + 1
	Endif
	
	If cQuebra <> Eval(bQuebra)
		If !lPrimeiro
			@nLin,00 PSAY "Total de Itens: "
			@nLin,pCol()+2 PSAY TRANSFORM(nTotDia, "@E 99999")
			nLin := nLin + 2
		ENDIF
		@nLin,00 PSAY If( mv_par08 == 1 , "", "Local de ") + "Entrega: "
		@nLin,pCol()+2 PSAY BRA->(Eval(bQuebra))
		nLin++
		@nLin,00 PSAY REPLI("-",127)
		nLin++
		
		cQuebra   := BRA->(Eval(bQuebra))
		nTotDia   := 0
		lPrimeiro := .F.
	EndIF
	
	nTotDia++
	
	@nLin,00       PSAY BRA->Z1_NUM
	@nLin,pCol()+2 PSAY If (BRA->Z1_TIPPED == "1", "N","F")
	@nLin,pCol()+2 PSAY Left(BRA->Z1_PEDCLI,10)
	@nLin,pCol()+2 PSAY Left(BRA->A1_NREDUZ,15)
	@nLin,pCol()+1 PSAY BRA->Z1_PRODUTO
	@nLin,pCol()+1 PSAY Left(BRA->A7_CODCLI,15)
	@nLin,pCol()+2 PSAY Left(BRA->B1_DESC,30)
	@nLin,pCol()+2 PSAY TRANSFORM(BRA->Z1_SALDO, "@E 99999")
	@nLin,pCol()+2 PSAY TRANSFORM(nTotalEst, "@E 99999")
	nLin++
	
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo
dbCloseArea()
	
@nLin,00 PSAY "Total de Itens: "
@nLin,pCol()+2 PSAY TRANSFORM(nTotDia, "@E 99999")
nLin++

@nLin,01 PSAY REPLI("-",127)
nLin++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

Static Function CalculaSaldo(cProduto,cCodFil)
	Local cLocExp, aEstoq
	Local cFilAtu := cFilAnt

	cFilAnt := cCodFil
	cLocExp := AllTrim(GetMV("MV_XLOCEXP",.F.,"02"))
	aEstoq  := CalcEst(cProduto, cLocExp, dDataBase+1)
	cFilAnt := cFilAtu

Return aEstoq[1]

Static Function ValidPerg(cPerg)
Local i,j
Local _sAlias := Alias()
Local aRegs   := {}
DbSelectArea("SX1")
DbSetOrder(1)

aAdd(aRegs,{cPerg,"01","Periodo de             ?", "" , "", "mv_ch1","D" ,08, 0 , 0 ,"G", "" , "MV_PAR01" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Periodo até            ?", "" , "", "mv_ch2","D" ,08, 0 , 0 ,"G", "" , "MV_PAR02" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Cliente de             ?", "" , "", "mv_ch3","C" ,06, 0 , 0 ,"G", "" , "MV_PAR03" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"04","Cliente até            ?", "" , "", "mv_ch4","C" ,06, 0 , 0 ,"G", "" , "MV_PAR04" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"05","Produto de             ?", "" , "", "mv_ch5","C" ,20, 0 , 0 ,"G", "" , "MV_PAR05" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"06","Produto até            ?", "" , "", "mv_ch6","C" ,20, 0 , 0 ,"G", "" , "MV_PAR06" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"07","Tipo Pedido            ?", "" , "", "mv_ch7","N" ,01, 0 , 0 ,"C", "" , "MV_PAR07" , "Pedido Firme",  "", "", "","","Pedido Forecast","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Tipo Reltório          ?", "" , "", "mv_ch8","N" ,01, 0 , 0 ,"C", "" , "MV_PAR08" , "Data Entrega",  "", "", "","","Local Entrega","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"09","Quanto ao Saldo        ?", "" , "", "mv_ch9","N" ,01, 0 , 0 ,"C", "" , "MV_PAR09" , "Sem Saldo",  "", "", "","","Com Saldo","","","","","Todos","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return