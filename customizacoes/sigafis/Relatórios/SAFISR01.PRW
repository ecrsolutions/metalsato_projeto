#INCLUDE "totvs.ch"     
#INCLUDE "topconn.ch"
#DEFINE ENTER CHR(13) + CHR(10)
/*____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+-------------------+------+------------+¦¦
¦¦¦ Programa  ¦ SAFISR01   ¦ Autor ¦Cristian Gutierrez ¦ Data ¦ 07/03/2012 ¦¦¦
¦¦+-----------+------------+-------+-------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Relatorio para Suframa                                     ¦¦¦
¦¦¦  (cont.)  ¦ Informacoes de faturamento de produtos acabados por NCM    ¦¦¦
¦¦+-----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function SAFISR01()
/*+------------------------------------------------------------------------+¦\
¦¦¦ Declaracao de variaveis                                                ¦¦¦
\¦+------------------------------------------------------------------------+*/
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio 	"
Local cDesc2         := "de acordo com os parametros informados pelo usuario.	"
Local cDesc3         := "Relatorio da Suframa por NCM - Faturamento				"
Local cPict          := ""
Local titulo       	:= "Relatorio da Suframa por NCM - Faturamento"
Local nLin         	:= 80
Local Cabec1 			:= "NCM           CFOP            Quantidade                   Valor "
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 				:= {}

Private lEnd         := .F.
Private lAbortPrint	:= .F.
Private CbTxt        := ""
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "SAFISR01"
Private nTipo        := 18
Private aReturn    	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey   	:= 0
Private cPerg      	:= "SAFISR01"
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= "SAFISR01"
Private cString		:= "SD2"
/*+------------------------------------------------------------------------+¦\
¦¦¦ Valida existencia das perguntas e cria se necessario os parametros 		¦¦¦
\¦+------------------------------------------------------------------------+*/
ValidPerg(  Padr(cPerg,len(SX1->X1_GRUPO)," ") )
Pergunte( Padr(cPerg,len(SX1->X1_GRUPO)," ") , .T. )
/*+------------------------------------------------------------------------+¦\
¦¦¦ Monta a interface padrao com o usuario...										¦¦¦
\¦+------------------------------------------------------------------------+*/
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27 
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
   Return
Endif
nTipo := If(aReturn[4]==1,15,18)
/*+------------------------------------------------------------------------+¦\
¦¦¦ Processamento. RPTSTATUS monta janela com a regua de processamento. 	¦¦¦
\¦+------------------------------------------------------------------------+*/
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return
/*____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+-------------------+------+------------+¦¦
¦¦¦ Programa  ¦ RUNREPORT  ¦ Autor ¦Cristian Gutierrez ¦ Data ¦ 07/03/2012 ¦¦¦
¦¦+-----------+------------+-------+-------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ¦¦¦
¦¦¦  (cont.)  ¦ monta a janela com a regua de processamento. 			      ¦¦¦
¦¦+-----------+------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
/*+------------------------------------------------------------------------+¦\
¦¦¦ Declaracao de variaveis                                                ¦¦¦
\¦+------------------------------------------------------------------------+*/
Local cQuery 		:= ""
Local cTes			:= ""
Local cMvPar03		:= AllTrim( mv_par03 )
Local cMvPar04		:= AllTrim( mv_par04 )
Local nTotalVenda   := 0
Local nTotalDev		:= 0
Local nX            := Nil

/*+------------------------------------------------------------------------+¦\
¦¦¦ Tratamento da variável com os TES a serem considerados no relatório    ¦¦¦
\¦+------------------------------------------------------------------------+*/
If !Empty( cMvPar03 )
	cTes	:= "('"
	
	For nX := 1 To Len( cMvPar03 )
		cTes 	+= Substr( cMvPar03 , nX , 3 ) + "','"
		nX 	+= 3
	Next nX  
	
	cTes := Substr( cTes , 1 , Len( cTes ) - 2 ) +  ")"
EndIf
/*+------------------------------------------------------------------------+¦\
¦¦¦ Monta a query para selecao de registros - Dados de Vendas              ¦¦¦
\¦+------------------------------------------------------------------------+*/
cQuery := " SELECT SB1.B1_POSIPI, LEFT(D2_CF,1) AS CF , SUM( D2_QUANT ) AS D2_QUANT , SUM( D2_TOTAL ) AS D2_TOTAL , @@ROWCOUNT AS REGS						"+ENTER
cQuery += " FROM "+ RetSqlName( "SD2" ) +" SD2 (NOLOCK), "+ RetSqlName( "SB1" ) +" SB1 (NOLOCK) , "+ RetSqlName( "SF4" ) +" SF4 (NOLOCK) 					"+ENTER
cQuery += " WHERE SD2.D2_FILIAL		= '"+ xFilial( "SD2" ) +"'  																													"+ENTER
cQuery += "   AND SD2.D2_EMISSAO		BETWEEN '"+ DtoS( mv_par01 ) +"' AND '"+ DtoS( mv_par02 ) +"'																		"+ENTER
cQuery += "   AND SD2.D_E_L_E_T_		= ''																																					"+ENTER
cQuery += "   AND SB1.B1_FILIAL		= '"+ xFilial( "SB1" ) +"'  																													"+ENTER
cQuery += "   AND SB1.B1_COD			= SD2.D2_COD																																		"+ENTER
cQuery += "   AND SB1.B1_TIPO			IN ('PA','PI')																																		"+ENTER
cQuery += "   AND SB1.D_E_L_E_T_		= ''																																					"+ENTER
cQuery += "   AND SF4.F4_FILIAL		= '"+ xFilial( "SF4" ) +"'  																													"+ENTER
cQuery += "   AND SF4.F4_CODIGO		= SD2.D2_TES																																		"+ENTER
If !Empty( cTes )
	cQuery += "AND SF4.F4_CODIGO		IN " + cTes +  "																																	"+ENTER
EndIf	
cQuery += "   AND SF4.F4_DUPLIC		= 'S'																																					"+ENTER
cQuery += "   AND SF4.D_E_L_E_T_		= ''																																					"+ENTER
cQuery += " GROUP BY SB1.B1_POSIPI, LEFT(D2_CF,1)																																		"+ENTER
cQuery += " ORDER BY SB1.B1_POSIPI, LEFT(D2_CF,1)																																		"+ENTER

If Select( "TMP" ) > 0 ; dbSelectArea( "TMP" ) ; dbCloseArea() ; EndIf
TcQuery cQuery New Alias "TMP"
/*+------------------------------------------------------------------------+¦\
¦¦¦SETREGUA -> Indica quantos registros serao processados para a regua 		¦¦¦
\¦+------------------------------------------------------------------------+*/
dbSelectArea( "TMP" )
dbGoTop()

SetRegua( TMP->REGS * 2 )                              
/*+------------------------------------------------------------------------+¦\
¦¦¦ Loop principal do relatorio															¦¦¦
\¦+------------------------------------------------------------------------+*/
While !TMP->( EOF() )
	IncRegua()
	/*+------------------------------------------------------------------------+¦\
	¦¦¦ Verifica o cancelamento pelo usuario...                             	¦¦¦
	\¦+------------------------------------------------------------------------+*/
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
	/*+------------------------------------------------------------------------+¦\
	¦¦¦ Impressao do cabecalho do relatorio. . .                            	¦¦¦
	\¦+------------------------------------------------------------------------+*/
   If nLin > 55
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
		/*+------------------------------------------------------------------------+¦\
		¦¦¦ Identificacao dos dados impressos   												¦¦¦
		\¦+------------------------------------------------------------------------+*/
		@nLin , 000 pSay "D A D O S  R E F E R E N T E S  À  F A T U R A M E N T O "
		nLin ++
		nLin ++
   Endif
	/*+------------------------------------------------------------------------+¦\
	¦¦¦ Impressao dos detalhes do relatorio. . .                            	¦¦¦
	\¦+------------------------------------------------------------------------+*/
   @nLin , 000 pSay TMP->B1_POSIPI
   @nLin , 015 pSay TMP->CF
   @nLin , 024 pSay TMP->D2_QUANT Picture( "@E 999,999,999,999" )
   @nLin , 050 pSay TMP->D2_TOTAL Picture( "@E 999,999,999,999.99" )
   
   nTotalVenda += TMP->D2_TOTAL
   
   nLin ++
   TMP->( dbSkip() ) 
   
   if TMP->( EOF() )   
	@nLin , 024 pSay "Total -> "
   	@nLin , 050 pSay nTotalVenda Picture( "@E 999,999,999,999.99" )
   	nLin ++
   Endif
EndDo                                                                         
/*+------------------------------------------------------------------------+¦\
¦¦¦ Tratamento da variável com os TES a serem considerados no relatório    ¦¦¦
\¦+------------------------------------------------------------------------+*/
cTes	:= ""

If !Empty( cMvPar04 )
	cTes	:= "('"

	For nX := 1 To Len( cMvPar04 )
		cTes 	+= Substr( cMvPar04 , nX , 3 ) + "','"
		nX 	+= 3
	Next nX  

	cTes := Substr( cTes , 1 , Len( cTes ) - 2 ) +  ")"
EndIf	
/*+------------------------------------------------------------------------+¦\
¦¦¦ Monta a query para selecao de registros - Dados de Vendas              ¦¦¦
\¦+------------------------------------------------------------------------+*/
cQuery := " SELECT SB1.B1_POSIPI, LEFT(D1_CF,1) AS CF , SUM( D1_QUANT ) AS D1_QUANT , SUM( D1_TOTAL ) AS D1_TOTAL , @@ROWCOUNT AS REGS						"+ENTER
cQuery += " FROM "+ RetSqlName( "SD1" ) +" SD1 (NOLOCK), "+ RetSqlName( "SB1" ) +" SB1 (NOLOCK) , "+ RetSqlName( "SF4" ) +" SF4 (NOLOCK) 					"+ENTER
cQuery += " WHERE SD1.D1_FILIAL		= '"+ xFilial( "SD1" ) +"'  																													"+ENTER
cQuery += "   AND SD1.D1_EMISSAO		BETWEEN '"+ DtoS( mv_par01 ) +"' AND '"+ DtoS( mv_par02 ) +"'																		"+ENTER
cQuery += "   AND SD1.D1_TIPO			= 'D'																																					"+ENTER
cQuery += "   AND SD1.D1_FORMUL		= 'S'																																					"+ENTER
cQuery += "   AND SD1.D_E_L_E_T_		= ''																																					"+ENTER
cQuery += "   AND SB1.B1_FILIAL		= '"+ xFilial( "SB1" ) +"'  																													"+ENTER
cQuery += "   AND SB1.B1_COD			= SD1.D1_COD																																		"+ENTER
cQuery += "   AND SB1.B1_TIPO			IN ('PA','PI')																																		"+ENTER
cQuery += "   AND SB1.D_E_L_E_T_		= ''																																					"+ENTER
cQuery += "   AND SF4.F4_FILIAL		= '"+ xFilial( "SF4" ) +"'  																													"+ENTER
cQuery += "   AND SF4.F4_CODIGO		= SD1.D1_TES																																		"+ENTER
If !Empty( cTes )
	cQuery += "AND SF4.F4_CODIGO		IN " + cTes +  "																																	"+ENTER
EndIf	
cQuery += "   AND SF4.F4_DUPLIC		= 'S'																																					"+ENTER
cQuery += "   AND SF4.D_E_L_E_T_		= ''																																					"+ENTER
cQuery += " GROUP BY SB1.B1_POSIPI, LEFT(D1_CF,1)																																		"+ENTER
cQuery += " ORDER BY SB1.B1_POSIPI, LEFT(D1_CF,1)																																		"+ENTER

If Select( "TMP" ) > 0 ; dbSelectArea( "TMP" ) ; dbCloseArea() ; EndIf
TcQuery cQuery New Alias "TMP"

dbSelectArea( "TMP" )
dbGoTop()
/*+------------------------------------------------------------------------+¦\
¦¦¦ Identificacao dos dados impressos   												¦¦¦
\¦+------------------------------------------------------------------------+*/
nLin ++
@nLin , 000 pSay "D A D O S  R E F E R E N T E S  À  D E V O L U Ç Õ E S "
nLin ++
nLin ++
/*+------------------------------------------------------------------------+¦\
¦¦¦ Loop principal do relatorio															¦¦¦
\¦+------------------------------------------------------------------------+*/
While !TMP->( EOF() )
	/*+------------------------------------------------------------------------+¦\
	¦¦¦ Verifica o cancelamento pelo usuario...                             	¦¦¦
	\¦+------------------------------------------------------------------------+*/
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
	/*+------------------------------------------------------------------------+¦\
	¦¦¦ Impressao do cabecalho do relatorio. . .                            	¦¦¦
	\¦+------------------------------------------------------------------------+*/
   If nLin > 55
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
		nLin ++
		@nLin , 000 pSay "D A D O S  R E F E R E N T E S  À  D E V O L U Ç Õ E S "
		nLin ++
		nLin ++
   Endif
	/*+------------------------------------------------------------------------+¦\
	¦¦¦ Impressao dos detalhes do relatorio. . .                            	¦¦¦
	\¦+------------------------------------------------------------------------+*/
   @nLin , 000 pSay TMP->B1_POSIPI
   @nLin , 015 pSay TMP->CF
   @nLin , 024 pSay TMP->D1_QUANT Picture( "@E 999,999,999,999" )
   @nLin , 050 pSay TMP->D1_TOTAL Picture( "@E 999,999,999,999.99" )

   nTotalDev += TMP->D1_TOTAL

   nLin ++
   TMP->( dbSkip() ) 
   
   if TMP->( EOF() )   
	@nLin , 024 pSay "Total -> "
   	@nLin , 050 pSay nTotalDev Picture( "@E 999,999,999,999.99" )
   	nLin ++
   Endif


EndDo
/*+------------------------------------------------------------------------+¦\
¦¦¦ Finaliza a execucao do relatorio...                                		¦¦¦
\¦+------------------------------------------------------------------------+*/
SET DEVICE TO SCREEN
/*+------------------------------------------------------------------------+¦\
¦¦¦ Se impressao em disco, chama o gerenciador de impressao...          	¦¦¦
\¦+------------------------------------------------------------------------+*/
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif
MS_FLUSH()
Return
//------------------------------------------------------------------- 
//-              Rotina de criação das perguntas no SX1             -
//-          Desenvolvida por: Nilson Neto          Data: 15/02     -
//------------------------------------------------------------------- 
Static Function ValidPerg(cPerg)                                            

	PutSX1(cPerg,"01","Da Data       ?", "", "", "mv_ch1", "D", 08,00,00,"G","","   ","","","mv_par01")   	
	PutSX1(cPerg,"02","Até a Data    ?", "", "", "mv_ch2", "D", 08,00,00,"G","","   ","","","mv_par02")  
	PutSX1(cPerg,"03","TES Saida     ?", "", "", "mv_ch3", "C", 40,00,00,"G","","   ","","","mv_par03")  
	PutSX1(cPerg,"04","TES Devolucoes?", "", "", "mv_ch3", "C", 40,00,00,"G","","   ","","","mv_par04")  
	
Return Nil