#Include 'Protheus.ch'
#include "rwmake.ch"
#include "font.ch"
#include "totvs.ch"
#include "topconn.ch"
#include "FWPrintSetup.ch"

/*/{Protheus.doc} MCFINR01
(Rotina responsável pela impressão de Comprovante de Pagamento, de acordo com
os filtros escolhidos na tela de parametrização, e com os títulos escolhidos na
marcação de títulos a serem impressos.)
@author Marcel Robinson Grosselli
@since 13/09/2019
@version 1.0
/*/
User Function MCFINR01()
//  .----------------
// | Variáveis Locais
//  .----------------
Local _nOpc		:= 0
Local _cTitulo	:= "Parametrização das Informações"
Local _cDesc1	:= "Programa para impressão da Comprovantes de Pagamento."
Local _cDesc2	:= "Demonstrativo de Pagamento."
Local _aSay    	:= {}
Local _aButton 	:= {}

//  .-------------------
// | Variáveis Privates
//  .-------------------
Private cPerg		:= PADR("MCFINR01",Len(SX1->X1_GRUPO))
Private _nTam     	:= TamSX3("E2_NUM")[1]
Private aReturn  	:= {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private _nLastKey	:= 0
Private _cQry		:= ""
Private _cSE2   	:= RetSQLName("SE2")
Private _cSED   	:= RetSQLName("SED")
Private _cSA2   	:= RetSQLName("SA2")
Private _cMarca		:= GetMark()
Private _cCadastro 	:= "Seleção de Títulos para Impressão"
Private _aCampos   	:= {}
Private aRotina 	:= {}
Private _aTabTem 	:= {}
Private _cFile
Private oPrint
Private oFont06,oFont07,oFont10, oFont10n, oFont12,oFont14,oFont16
Private _cStartPath  := GetSrvProfString("StartPath","")
Private _cCamLogo    := _cStartPath + "LGMID99.PNG"
Private _dDataAtual  := ""
Private _cHoraAtual  := ""
Private _cNomeUser   := Alltrim(UsrRetName(__CUSERID))
Private _cNomeEmp    := ""
Private _nLin			:= 0
Private _nAglutina 	:= 1
Private _SomVlrPag 	:= 0
Private _nNumTitPg 	:= 0
Private _SomVlrTot 	:= 0
Private _oMark		:= Nil

// ---------------------------------------------------
//| Chamada da função para criar e validar perguntas
// ---------------------------------------------------
ValidPerg(cPerg)
Pergunte(cPerg,.F.)

If _nLastKey == 27
	Set Filter to
	Return
Endif

// ---------------------------------------------------
//| Tela inicial de Parametrização
// ---------------------------------------------------
aAdd( _aSay, _cDesc1 )
aAdd( _aSay, _cDesc2 )

aAdd( _aButton,{ 5,.T., {|x| Pergunte(cPerg)}} )
aAdd( _aButton,{ 1,.T., {|x| _nOpc := 1, oDlg:End() }} )
aAdd( _aButton,{ 2,.T., {|x| _nOpc := 2, oDlg:End() }} )

FormBatch( _cTitulo, _aSay, _aButton )

If _nOpc == 1
	If (mv_par05 < mv_par04) 
		Aviso("Erro","Da Data maior que Até a data. Por favor corrigir parâmetros.",{"Ok"})
		FormBatch( _cTitulo, _aSay, _aButton )    
	Else     	
		TelaTit()
	EndIf
Endif

Return

/*/{Protheus.doc} TelaTit
(Função responsável por montar a tela onde serão mostrados os resultados da tela de parâmetrização.)
@author Valcimar Costa da Silva
@since 24/02/2015
@version 1.0

/*/
Static Function TelaTit()
_SomVlrPag := 0
_SomVlrTot := 0

// -------------------------
//| Seleção da tabelas.
// -------------------------
SE2->(dbSetOrder(1)) //- Contas à Pagar
SA2->(dbSetOrder(1)) //- Fornecedor
SED->(dbSetOrder(1)) //- Cadastro de Naturezas

// ------------------------------------------------------
//| Adicionando Menu de Impressão na Tela de MarkBrowse
// ------------------------------------------------------
aRotina   := { { "Imprimir" ,"U_ImFXFINR01",0,4}}

// -------------------------------------------------------
//| Criando Tabela Temporária
// -------------------------------------------------------
aadd(_aTabTem,{"E5_OK","C",TamSX3("E5_OK")[1],0})
aadd(_aTabTem,{"E2_FORMPAG","C",TamSX3("E2_FORMPAG")[1],0})
aadd(_aTabTem,{"E5_DATA","D",TamSX3("E5_DATA")[1],0})
aadd(_aTabTem,{"E5_AUTBCO","C",TamSX3("E5_AUTBCO")[1],0})
aadd(_aTabTem,{"E2_IDCNAB","C",TamSX3("E2_IDCNAB")[1],0})
aadd(_aTabTem,{"E2_NUM","C",TamSX3("E2_NUM")[1],0})
aadd(_aTabTem,{"E5_BANCO","C",TamSX3("E5_BANCO")[1],0})
aadd(_aTabTem,{"E5_AGENCIA","C",TamSX3("E5_AGENCIA")[1],0})
aadd(_aTabTem,{"E5_CONTA","C",TamSX3("E5_CONTA")[1],0})
aadd(_aTabTem,{"E2_CODBAR","C",TamSX3("E2_CODBAR")[1],0})
aadd(_aTabTem,{"A2_NOME","C",TamSX3("A2_NOME")[1],0})
aadd(_aTabTem,{"A2_NREDUZ","C",TamSX3("A2_NREDUZ")[1],0})
aadd(_aTabTem,{"A2_CGC","C",TamSX3("A2_CGC")[1],0})
aadd(_aTabTem,{"A6_COD","C",TamSX3("A6_COD")[1],0})
aadd(_aTabTem,{"A6_NOME","C",TamSX3("A6_NOME")[1],0})
aadd(_aTabTem,{"E2_VENCTO","D",TamSX3("E2_VENCTO")[1],0})
aadd(_aTabTem,{"E2_VALOR","N",TamSX3("E2_VALOR")[1],TamSX3("E2_VALOR")[2]})
aadd(_aTabTem,{"E5_VALOR","N",TamSX3("E5_VALOR")[1],TamSX3("E5_VALOR")[2]})
aadd(_aTabTem,{"E5_VLDESCO","N",TamSX3("E5_VLDESCO")[1],TamSX3("E5_VLDESCO")[2]})
aadd(_aTabTem,{"E5_VLJUROS","N",TamSX3("E5_VLJUROS")[1],TamSX3("E5_VLJUROS")[2]})
aadd(_aTabTem,{"E5_VLMULTA","N",TamSX3("E5_VLMULTA")[1],TamSX3("E5_VLMULTA")[2]})
aadd(_aTabTem,{"E2_FORBCO","C",TamSX3("E2_FORBCO")[1],0})
aadd(_aTabTem,{"E2_FORAGE","C",TamSX3("E2_FORAGE")[1],0})
aadd(_aTabTem,{"E2_FAGEDV","C",TamSX3("E2_FAGEDV")[1],0})
aadd(_aTabTem,{"E2_FORCTA","C",TamSX3("E2_FORCTA")[1],0})
aadd(_aTabTem,{"E2_FCTADV","C",TamSX3("E2_FCTADV")[1],0})                        
aadd(_aTabTem,{"E2_XOUTENT","N",TamSX3("E2_XOUTENT")[1],TamSX3("E2_XOUTENT")[2]})
aadd(_aTabTem,{"E2_XMULTA","N",TamSX3("E2_XMULTA")[1],TamSX3("E2_XMULTA")[2]})
aadd(_aTabTem,{"E2_XJUROS","N",TamSX3("E2_XJUROS")[1],TamSX3("E2_XJUROS")[2]})
aadd(_aTabTem,{"E2_XCOMPET","D",TamSX3("E2_XCOMPET")[1],0})
aadd(_aTabTem,{"E2_CODREC","C",TamSX3("E2_CODREC")[1],0})   

_cFile := CriaTrab(_aTabTem, .T.)

DbUseArea(.T.,,_cFile,"TRB",.T.,.F.)


// -----------------------------------------------------------
//| Query para seleção dos dados que aparecerão na markbrowse
// -----------------------------------------------------------

_cQry := "SELECT "
_cQry += " E5_OK, E2_FORMPAG, E5_DATA, E5_AUTBCO, E2_IDCNAB, E2_NUM, E5_BANCO, E5_AGENCIA, E5_CONTA, E2_CODBAR, A2_NOME, A2_NREDUZ, "
_cQry += " A2_CGC, A6_COD, A6_NOME, E2_VENCTO, E2_VALOR, E5_VALOR, E5_VLDESCO, E5_VLJUROS, E5_VLMULTA, E2_FORBCO, E2_FORAGE, E2_FAGEDV, "
_cQry += " E2_FORCTA, E2_FCTADV, E2_XOUTENT, E2_XMULTA, E2_XJUROS, E2_XCOMPET, E2_CODREC  FROM SE2010 SE2 "
_cQry += " INNER JOIN SE5010 SE5 ON "
_cQry += " SE5.D_E_L_E_T_ = '' "
_cQry += " AND SE2.E2_FILIAL = SE5.E5_FILIAL "
_cQry += " AND SE2.E2_PREFIXO = SE5.E5_PREFIXO "
_cQry += " AND SE2.E2_NUM = SE5.E5_NUMERO "
_cQry += " AND SE2.E2_PARCELA = SE5.E5_PARCELA "
_cQry += " AND SE2.E2_TIPO = SE5.E5_TIPO "
_cQry += " AND SE2.E2_FORNECE = SE5.E5_CLIFOR "
_cQry += " AND SE2.E2_LOJA = SE5.E5_LOJA "
_cQry += " INNER JOIN SA2010 SA2 ON "
_cQry += " SA2.D_E_L_E_T_ ='' "
_cQry += " AND SA2.A2_COD = SE2.E2_FORNECE "
_cQry += " AND SA2.A2_LOJA = SE2.E2_LOJA "
_cQry += " INNER JOIN SA6010 SA6 ON "
_cQry += " SA6.D_E_L_E_T_ = '' "
_cQry += " AND E5_BANCO = A6_COD "
_cQry += " AND E5_AGENCIA = A6_AGENCIA "
_cQry += " AND E5_CONTA = A6_NUMCON "
_cQry += " WHERE "
_cQry += " SE2.D_E_L_E_T_ = '' "
_cQry += " AND SE5.E5_AUTBCO <>'' "
_cQry += " AND (E5_DATA BETWEEN '" + Dtos(mv_par02) + "' AND '" + Dtos(mv_par03) + "') "
_cQry += " AND (E2_FORMPAG BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "') "
_cQry += " AND (E2_FORNECE BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "') "

If mv_par01 == 1
	_cQry += "ORDER BY E2_FORMPAG"
EndIf

If mv_par01 == 2
	_cQry += "ORDER BY E5_DATA"
EndIf

If mv_par01 == 3
	_cQry += "ORDER BY E2_FORNECE"                      
EndIf

If mv_par01 == 4
	_cQry += "ORDER BY E2_NUM"
EndIf

dbUseArea(.T.,"TOPCONN", TcGenQry(,,CHANGEQUERY(_cQry)), "TMP", .T., .F. )

TcSetField("TMP","E5_DATA","D")
TcSetField("TMP","E2_VENCTO","D")
TcSetField("TMP","E2_XCOMPET","D")

// ------------------------------------------------------------
//| Tabela temporária recebendo dados resultante das consultas.
// ------------------------------------------------------------
While TMP->(!EOF())
	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->E5_OK      := TMP->E5_OK
	TRB->E2_FORMPAG := TMP->E2_FORMPAG
	TRB->E5_DATA    := TMP->E5_DATA
	TRB->E5_AUTBCO  := TMP->E5_AUTBCO 
	TRB->E2_IDCNAB  := TMP->E2_IDCNAB
	TRB->E2_NUM     := TMP->E2_NUM
	TRB->E5_BANCO	:= TMP->E5_BANCO 
	TRB->E5_AGENCIA	:= TMP->E5_AGENCIA 
	TRB->E5_CONTA   := TMP->E5_CONTA
	TRB->E2_CODBAR	:= TMP->E2_CODBAR 
	TRB->A2_NOME	:= TMP->A2_NOME 
	TRB->A2_NREDUZ  := TMP->A2_NREDUZ 
	TRB->A2_CGC  	:= TMP->A2_CGC 
	TRB->A6_COD  	:= TMP->A6_COD 
	TRB->A6_NOME    := TMP->A6_NOME 
	TRB->E2_VENCTO  := TMP->E2_VENCTO
	TRB->E2_VALOR	:= ROUND(TMP->E2_VALOR,2)
	TRB->E5_VALOR	:= ROUND(TMP->E5_VALOR,2) 
	TRB->E5_VLDESCO	:= ROUND(TMP->E5_VLDESCO,2) 
	TRB->E5_VLJUROS	:= ROUND(TMP->E5_VLJUROS,2)
	TRB->E5_VLMULTA := ROUND(TMP->E5_VLMULTA,2)
	TRB->E2_FORBCO  := TMP->E2_FORBCO
	TRB->E2_FORAGE	:= TMP->E2_FORAGE 
	TRB->E2_FAGEDV	:= TMP->E2_FAGEDV 
	TRB->E2_FORCTA	:= TMP->E2_FORCTA 
	TRB->E2_FCTADV	:= TMP->E2_FCTADV 
	TRB->E2_XOUTENT	:= ROUND(TMP->E2_XOUTENT,2)
	TRB->E2_XMULTA	:= ROUND(TMP->E2_XMULTA,2)
	TRB->E2_XJUROS	:= ROUND(TMP->E2_XJUROS,2)
	TRB->E2_XCOMPET	:= TMP->E2_XCOMPET 
	TRB->E2_CODREC 	:= TMP->E2_CODREC  
	
	TRB->(MsUnlock())	
	TMP->(dbskip())
EndDo

aadd(_aCampos,{"TRB->E5_OK","","Seleção"})
aadd(_aCampos,{"TRB->E2_FORMPAG","","Form Pagto"})
aadd(_aCampos,{"TRB->E5_DATA","","Data"})
aadd(_aCampos,{"TRB->E5_AUTBCO","","Autenticacao"})
aadd(_aCampos,{"TRB->E2_IDCNAB","","Id Cnab"})
aadd(_aCampos,{"TRB->E2_NUM","","Titulo"})
aadd(_aCampos,{"TRB->E5_BANCO","","Bco Pagto"})
aadd(_aCampos,{"TRB->E5_AGENCIA","","Agencia Pagto"})
aadd(_aCampos,{"TRB->E5_CONTA","","Conta Pagto."})
aadd(_aCampos,{"TRB->E2_CODBAR","","Cod. de Barras"})
aadd(_aCampos,{"TRB->A2_NOME","","Nome Fornecedor"})
aadd(_aCampos,{"TRB->A2_NREDUZ","","Nome Fantasia"})
aadd(_aCampos,{"TRB->A2_CGC","","CNPJ"})
aadd(_aCampos,{"TRB->A6_COD","","Cod. Banco"})
aadd(_aCampos,{"TRB->A6_NOME","","Nome Banco"})
aadd(_aCampos,{"TRB->E2_VENCTO","","Vencimento"})
aadd(_aCampos,{"TRB->E2_VALOR","","Valor Título"})
aadd(_aCampos,{"TRB->E5_VALOR","","Valor Pago"})
aadd(_aCampos,{"TRB->E5_VLDESCO","","Desconto"})
aadd(_aCampos,{"TRB->E5_VLJUROS","","Juros"})
aadd(_aCampos,{"TRB->E5_VLMULTA","","Multa"})
aadd(_aCampos,{"TRB->E2_FORBCO","","Bco Fornecedor"})
aadd(_aCampos,{"TRB->E2_FORAGE","","Agencia Forn"})
aadd(_aCampos,{"TRB->E2_FAGEDV","","Dv. Age"})
aadd(_aCampos,{"TRB->E2_FORCTA","","Conta Forn"})
aadd(_aCampos,{"TRB->E2_FCTADV","","Dv. Cta"})
aadd(_aCampos,{"TRB->E2_XOUTENT","","Outras Entidades"})
aadd(_aCampos,{"TRB->E2_XMULTA","","Multa Título"})
aadd(_aCampos,{"TRB->E2_XJUROS","","Juros Titulo"})
aadd(_aCampos,{"TRB->E2_XCOMPET","","Comeptencia"})
aadd(_aCampos,{"TRB->E2_CODREC","","Código Retencao"})

DbSelectArea("TRB")
dbgotop()

//  .---------------------------------
// | Monta Tela de Seleção de Títulos.
//  .---------------------------------
MarkBrow("TRB","E5_OK",,_aCampos,,@_cMarca,"u_MarcaAll()",,,,"U_MarcaBrow()",,,,,,,,.F.)

DbSelectArea("TRB")
Set Filter to

TRB->(DbCloseArea())
TMP->(DbCloseArea())

Return Nil

/*/{Protheus.doc} ImFXFINR01
(Função responsável pela impressão de relatório.)
@author Marcel Robinson Grosselli
@since 13/09/2019
@version 1.0
/*/
User Function ImFXFINR01()

CloseBrowse()
MontaRel()

Return

/*/{Protheus.doc} MarcaBrow
(User Function responsável pela marcação de título na tela resultante dos filtros
da tela de parametrização da rotina)
@author Marcel Robinson Grosselli
@since 13/09/2019
@version 1.0
/*/
User Function MarcaBrow()
dbSelectArea("TRB")

If IsMark("E5_OK", @_cMarca )
	Reclock("TRB",.F.)
	Replace TRB->E5_OK With Space(2)
	MsUnlock()
Else
	RecLock("TRB", .F. )
	Replace TRB->E5_OK With @_cMarca
	MsUnLock()
EndIf

MarkBRefresh()

Return

User Function MarcaAll()
Local nRecno := TRB->(Recno())
TRB->(DbGoTop())
While TRB->(!EOF())
	U_MarcaBrow()
	TRB->(DbSkip())
EndDo
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Marcel R. Grosselli   ³ Data ³ 13/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressão Comprovante de Pagamentos  				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel()
LOCAL oPrint, cMaxPar, cQuery, cDocumen, dDataIni
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
						SM0->M0_ENDCOB                                     ,; //[2]Endereço
						AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
						"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
						"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
						Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                            ,; //[6]CGC
						"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
						Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

LOCAL aDadosBanco
LOCAL aDatSacado

Private cNroDoc :=  " "
Private aDadosTit := {}
oPrint:= TMSPrinter():New( "Comprovante de Pagametos" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página

DbSelectArea("TRB")

TRB->(dbGoTop())
//ProcRegua(RecCount())
While !TRB->(EOF())
   cDocumen := DTOS(TRB->E5_DATA)+TRB->E5_AUTBCO
   While !EOF() .And. cDocumen == DTOS(TRB->E5_DATA)+TRB->E5_AUTBCO

  //    IncProc()

      If TRB->E5_OK <> _cMarca //Marked("E1_OK")
         dbSkip()
         Loop
      Endif
       
      aCB_RN_NN := {""}
      
      aDadosTit := {""}  

      aBolText    := {"","","","",""}
      aBolText[1] := "TESTE"
      aBolText[2] := ""
      aBolText[3]:= ""
      aBolText[4]:= ""
      aBolText[5] := ""

      Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)

      dbSkip()
   Enddo
EndDo

oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Marcel R. Grosselli   ³ Data ³ 13/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO COMPROVANTE DE PAGAMENTO                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
LOCAL oFont7
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0
Local cStartPath := GetSrvProfString("StartPath","")
Local cBmp := 030
Local cLogo := 030          
Local cDescform:=""

cBmp := cStartPath + "bradesco.bmp" //Logo do Banco Itau

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont7   := TFont():New("Arial"      ,9, 7,.T.,.F.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Arial"      ,9, 8,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8n  := TFont():New("Arial"      ,9, 8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Arial"      ,9, 9,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial"      ,9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial"      ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10n := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial"      ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont18  := TFont():New("Arial"      ,9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial"      ,9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial"      ,9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont23  := TFont():New("Arial"      ,9,23,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial"      ,9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial"      ,9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial"      ,9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial"      ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial"      ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página
                    
cDescform := POSICIONE("SX5",1,XFILIAL("SX5")+"58"+TRB->E2_FORMPAG,"X5_DESCRI")

nRow1 := -50

oPrint:Line (nRow1+0800,100,nRow1+0800,2200)  //LINHA
oPrint:Line (nRow1+1300,100,nRow1+1300,2200)  //LINHA
oPrint:Line (nRow1+1450,100,nRow1+1450,2200)  //LINHA
oPrint:Line (nRow1+1600,150,nRow1+1600,1800)  //LINHA
oPrint:Line (nRow1+1480,1810,nRow1+1680,1810)   //COLUNA
oPrint:Line (nRow1+1700,100,nRow1+1700,2200)  //LINHA

//cabeçalho
MCCabec()

//PAGADOR                                                                    
oPrint:Say  (nRow1+0520,400,"Empresa:",oFont8n)                      
oPrint:Say  (nRow1+0520,560,ALLTRIM(aDadosEmp[1])+" | CNPJ: "+aDadosEmp[6],oFont8)                      
oPrint:Say  (nRow1+0620,320,"Conta de Débito:",oFont8n)                      
oPrint:Say  (nRow1+0620,560,"Agência: "+ALLTRIM(TRB->E5_AGENCIA)+"-0 | Conta: "+ALLTRIM(TRB->E5_CONTA)+"-3",oFont8)  
oPrint:Say  (nRow1+0720,400,"Pagador:",oFont8n)                      
oPrint:Say  (nRow1+0720,560,ALLTRIM(aDadosEmp[1])+" | CNPJ: "+aDadosEmp[6],oFont8)                       
//FORNECEDOR
oPrint:Say  (nRow1+0850,380,"Favorecido:",oFont8n)                      
oPrint:Say  (nRow1+0850,560,TRB->A2_NOME,oFont8)
oPrint:Say  (nRow1+0850,1400,"CNPJ:",oFont8n)                      
oPrint:Say  (nRow1+0850,1500,TRB->A2_CGC,oFont8)                   
oPrint:Say  (nRow1+0950,300,"Número de Pagamento:",oFont8n)                      
oPrint:Say  (nRow1+0950,560,TRB->E2_IDCNAB,oFont8)
oPrint:Say  (nRow1+0950,1250,"Data de Pagamento:",oFont8n)                      
oPrint:Say  (nRow1+0950,1500,StrZero(Day(TRB->E5_DATA),2) +"/"+ StrZero(Month(TRB->E5_DATA),2) +"/"+ Right(Str(Year(TRB->E5_DATA)),4),oFont8)    
oPrint:Say  (nRow1+1050,400,"Agência :",oFont8n)                      
oPrint:Say  (nRow1+1050,560,alltrim(TRB->E2_FORAGE)+IIF(!EMPTY(TRB->E2_FAGEDV),"-"+TRB->E2_FAGEDV,""),oFont8)
oPrint:Say  (nRow1+1050,1390,"Conta :",oFont8n)                      
oPrint:Say  (nRow1+1050,1500,alltrim(TRB->E2_FORCTA)+"-"+TRB->E2_FCTADV,oFont8)
oPrint:Say  (nRow1+1150,380,"Finalidade :",oFont8n)                      
oPrint:Say  (nRow1+1150,1350,"Valor (R$):",oFont8n)                      
oPrint:Say  (nRow1+1150,1500,AllTrim(Transform(TRB->E5_VALOR,"@E 9,999,999.99")),oFont8)                                                                        
oPrint:Say  (nRow1+1250,380,"Uso Empresa:",oFont8n)                                    
//OBSERVAÇÃO 1
oPrint:Say  (nRow1+1350,150,"A transação acima foi realizada no Multpag Bradesco.",oFont8n)  
oPrint:Say  (nRow1+1400,150,IIF(TRB->E2_FORMPAG$"03|41","Obs.: A contabilização dos créditos através de"+SUBSTR(cDescform,1,3)+" fica condicionado ao aceite e processamento por parte do banco do destinatário",""),oFont8)
//RODAPÉ
oPrint:Say  (nRow1+1490,150,"SAC - Serviço de",oFont8)  
oPrint:Say  (nRow1+1490,350,"Alô Bradesco",oFont8n)  

oPrint:Say  (nRow1+1530,150,"Apoio ao Cliente",oFont8)                              
oPrint:Say  (nRow1+1530,350,"0800 704 8383",oFont8n)                                

oPrint:Say  (nRow1+1640,150,"Ouvidoria",oFont8)                              

oPrint:EndPage() // Finaliza a página

Return Nil

Static Function MCCabec()

oPrint:Line (nRow1+0150,100,nRow1+0150,2200)    //LINHA 
oPrint:Line (nRow1+0150,100,nRow1+1700,100)   //COLUNA
oPrint:Line (nRow1+0150,2200,nRow1+1700,2200) //COLUNA

If File(cBmp)
   oPrint:SayBitmap(nRow1+180,240,cBmp,250,250)
Endif

//CABEÇALHO
oPrint:Say  (nRow1+0200,560,"Comprovante de Transação Bancária",oFont10)                      
oPrint:Say  (nRow1+0250,560,cDescform,oFont8n)                      
oPrint:Say  (nRow1+0300,560,"N° de Controle: "+TRB->E2_IDCNAB+ " | Autenticação Bancária: "+TRB->E5_AUTBCO,oFont8n)   
oPrint:Line (nRow1+0470,100,nRow1+0470,2200)  //LINHA 

return

/*/{Protheus.doc} ValidPerg
(Função responsável pela perguntas.)
@author Marcel Robinson Grosselli
@since 13/09/2019
@version 1.0
/*/
Static Function ValidPerg(cPerg)
Local _aHelp := {}

aAdd(_aHelp, "Selecione a ordem da impressão do relatório.")
PutSx1(cPerg,"01",PADR("Ordem de Impressão        ",29)+":","","","mv_ch1", "N", 1,0,1 ,"C","",""   ,"","","mv_par01",;
"FORMPAG","","","","DATA","","","FORNECEDOR","","","NUMERO",;
"","","","","",_aHelp)

_aHelp := {}
aAdd(_aHelp, "Selecione data de Pagamento")
PutSx1(cPerg,"02",PADR("Da Data                ",29)+":","","","mv_ch2", "D", 8,0,0 ,"G","",""   ,"","","mv_par02",;
"","","","","","","","","","","",;
"","","","","",_aHelp)

_aHelp := {}
aAdd(_aHelp, "Selecione data de Pagamento")
PutSx1(cPerg,"03",PADR("Até a Data                ",29)+":","","","mv_ch3", "D", 8,0,0 ,"G","",""   ,"","","mv_par03",;
"","","","","","","","","","","",;
"","","","","",_aHelp)

_aHelp := {}
aAdd(_aHelp, "Selecione a Form. Pagto")
PutSx1(cPerg,"04",PADR("Da Forma Pagto                ",29)+":","","","mv_ch4", "C", 2,0,0 ,"G","","58"   ,"","","mv_par04",;
"","","","","","","","","","","",;
"","","","","",_aHelp)

_aHelp := {}
aAdd(_aHelp, "Selecione a Form. Pagto")
PutSx1(cPerg,"05",PADR("Até a Forma Pagto              ",29)+":","","","mv_ch5", "C", 2,0,0 ,"G","","58"   ,"","","mv_par05",;
"","","","","","","","","","","",;
"","","","","",_aHelp)

_aHelp := {}
aAdd(_aHelp, "Selecione o Fornecedor.")
PutSx1(cPerg,"06",PADR("Do Fornecedor                 ",29)+":","","","mv_ch6", "C", 6,0,0 ,"G","","SA2"   ,"","","mv_par06",;
"","","","","","","","","","","",;
"","","","","",_aHelp)

_aHelp := {}
aAdd(_aHelp, "Selecione o Fornecedor.")
PutSx1(cPerg,"07",PADR("Até o Fornecedor              ",29)+":","","","mv_ch7", "C", 6,0,0 ,"G","","SA2"   ,"","","mv_par07",;
"","","","","","","","","","","",;
"","","","","",_aHelp)

Return
