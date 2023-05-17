#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"

User Function SAFATR02()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Estatistica de Entrega"
Local titulo         := "Estatistica de Entrega"

//                                1         2         3         4         5         6         7         8         9         10        11
//                       123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local Cabec1         := "CLIENTE                                           QTDE PROGR.    QTDE ENTREGUE "
Local Cabec2         := ""
Local aOrd := {}

Private nLin      := 80
Private cFilAtu   := ""
Private cLocExp   := ""
Private aEstoq    := {}
Private nTotProg  := 0
Private nTotEnt   := 0

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "Estatistica de Entrega" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "Estatistica de Entrega" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := PADR("SAFATR02",Len(SX1->X1_GRUPO))

Private cString    := "SZ1"

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

dbSelectArea(cString)
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . .                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQQQ := " SELECT Z1_CLIENTE, Z1_LOJA, SUM(SZ1.Z1_QUANT) AS QTD_PROG, SUM(SZ1.Z1_QTDENT) AS QTD_ENT "
cQQQ += " FROM " + RetSQLName("SZ1") + " SZ1 "
cQQQ += " WHERE SZ1.D_E_L_E_T_ = ' '" 
cQQQ += " AND SZ1.Z1_DATENT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' " 
cQQQ += " AND SZ1.Z1_CLIENTE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " 
cQQQ += " AND SZ1.Z1_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " 
cQQQ += " AND SZ1.Z1_TIPPED = '1' "
cQQQ += " GROUP BY SZ1.Z1_CLIENTE, Z1_LOJA" 

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQQQ), "BRA" , .T., .T.)

BRA->(DbGotop())

If !EMPTY(BRA->Z1_CLIENTE)
    While !EOF()
	    If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
		    cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		    nLin := 08
			@nLin,00       PSAY "Periodo de: "+DTOC(MV_PAR01)+" ate: "+DTOC(MV_PAR02)
	    	nLin += 2
        Endif
		cNomeCli := POSICIONE("SA1",1,xFilial("SA1")+BRA->Z1_CLIENTE+BRA->Z1_LOJA,"A1_NOME")
        @nLin,00       PSAY BRA->Z1_CLIENTE + "-" + BRA->Z1_LOJA
	    @nLin,pCol()+2 PSAY cNomeCli 
	    @nLin,pCol()+2 PSAY TRANSFORM(BRA->QTD_PROG, "@E 9999999")
	    @nLin,pCol()+2 PSAY TRANSFORM(BRA->QTD_ENT, "@E 9999999")
			
        nTotProg += BRA->QTD_PROG
        nTotEnt  += BRA->QTD_ENT
	    nLin++
				
	    dbSkip() // Avanca o ponteiro do registro no arquivo
		
    EndDo
	
	nLin++
    @nLin,38 PSAY "Total Geral: "
    @nLin,pCol()+2 PSAY TRANSFORM(nTotProg, "@E 9999999")
    @nLin,pCol()+2 PSAY TRANSFORM(nTotEnt, "@E 9999999")    
    nLin++
    @nLin,01 PSAY REPLI("-",127)
    nLin++
ENDIF

SET DEVICE TO SCREEN
dbCloseArea()

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

Static Function ValidPerg(cPerg)
Local i,j
_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)

aRegs :={}                                                                             //GET/COMBO
aAdd(aRegs,{cPerg,"01","Periodo de             ?", "" , "", "mv_ch1","D" ,08, 0 , 0 ,"G", "" , "MV_PAR01" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Periodo até            ?", "" , "", "mv_ch2","D" ,08, 0 , 0 ,"G", "" , "MV_PAR02" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Cliente de             ?", "" , "", "mv_ch3","C" ,06, 0 , 0 ,"G", "" , "MV_PAR03" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"04","Cliente at�            ?", "" , "", "mv_ch4","C" ,06, 0 , 0 ,"G", "" , "MV_PAR04" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SA1",""})
aAdd(aRegs,{cPerg,"05","Produto de             ?", "" , "", "mv_ch5","C" ,20, 0 , 0 ,"G", "" , "MV_PAR05" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SB1",""})
aAdd(aRegs,{cPerg,"06","Produto at�            ?", "" , "", "mv_ch6","C" ,20, 0 , 0 ,"G", "" , "MV_PAR06" , "",  "", "", "","","","","","","","","","","","","","","","","","","","","","SB1",""})

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