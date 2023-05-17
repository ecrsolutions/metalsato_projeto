#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ SAFINR01³ Autor ³ Marcel R. Grosselli    ³ Data ³ 26/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO ITAU                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SAFINR01 (cPrefixo,cNumero)

LOCAL	aPergs     := {} 

Default cPrefixo   := ""
Default cNumero    := ""

PRIVATE lExec      := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "M"
titulo   := "Boleto do Itau"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "SAFINR01"
lEnd     := .F.
cPerg    := PADR("SAFINR01",Len(SX1->X1_GRUPO))
nTam     := TamSX3("E1_NUM")[1]
nTam2    := TamSX3("E1_PARCELA")[1]
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0

Aadd(aPergs,{"De Prefixo"      ,"","","mv_ch1","C", 3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo"     ,"","","mv_ch2","C", 3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero"       ,"","","mv_ch3","C",nTam,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero"      ,"","","mv_ch4","C",nTam,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela"      ,"","","mv_ch5","C",nTam2,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela"     ,"","","mv_ch6","C",nTam2,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao"      ,"","","mv_ch7","D", 8,0,0,"G","","MV_PAR07","","","","01/01/00","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao"     ,"","","mv_ch8","D", 8,0,0,"G","","MV_PAR08","","","","31/12/06","","","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1(cPerg,aPergs)
If Empty(cNumero)
    Pergunte(cPerg,.T.)
else
   SE1->(dbSetOrder(1))
   SE1->(dbSeek(xFilial("SE1") + cPrefixo + cNumero))
   mv_par01 := cPrefixo
   mv_par02 := cPrefixo
   mv_par03 := cNumero
   mv_par04 := cNumero
   mv_par05 := "   "
   mv_par06 := "ZZZ"
   mv_par07 := SE1->E1_EMISSAO
   mv_par08 := SE1->E1_EMISSAO
EndIf

If nLastKey == 27
	Set Filter to
	Return
Endif

cIndexName	:= Criatrab(Nil,.F.)                                                                          

cIndexKey	:= "E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA+E1_TIPO+E1_PARCELA+DTOS(E1_EMISSAO)"
cFilter		+= "E1_FILIAL=='"+SE1->(xFilial())+"'.And.E1_SALDO>0.And."
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And." 
cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And.E1_NUM<='" + MV_PAR04 + "'.And."
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And."
cFilter		+= "DTOS(E1_EMISSAO)>='"+DTOS(mv_par07)+"'.and.DTOS(E1_EMISSAO)<='"+DTOS(mv_par08)+"'.And. "
cFilter		+= "E1_TIPO $ 'BO ,NF ,BOL,FT ,DP ' .and. "
cFilter     += "E1_NUMBCO <> '   '" 

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")

cMarca	:= GetMark()

DbSelectArea("SE1")
dbGoTop()

DEFINE MSDIALOG oDlg TITLE "Seleção de Titulos" FROM 00,00 TO 400,700 PIXEL

oMark := MsSelect():New( "SE1", "E1_OK",,  ,, cMarca, { 001, 001, 170, 350 } ,,, )

oMark:oBrowse:Refresh()
oMark:bAval               := { || ( Marcar( cMarca ), oMark:oBrowse:Refresh() ) }
oMark:oBrowse:lHasMark    := .T.
oMark:oBrowse:lCanAllMark := .F.

DEFINE SBUTTON oBtn1 FROM 180,310 TYPE 1 ACTION (lExec := .T.,oDlg:End()) ENABLE
DEFINE SBUTTON oBtn2 FROM 180,280 TYPE 2 ACTION (lExec := .F.,oDlg:End()) ENABLE

ACTIVATE MSDIALOG oDlg CENTERED
	
dbGoTop()
If lExec
	Processa({|lEnd|MontaRel()})
Endif

DbSelectArea("SE1")
Set Filter to

RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())

Return Nil

Static Function Marcar(cMarca,oSom)
   Local lOk := .T.

      RecLock("SE1",.F.)
      SE1->E1_OK := If( E1_OK <> cMarca , cMarca, Space(Len(E1_OK)))
      MsUnLock()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 06/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS			     ³±±
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
LOCAL aBolText := {"", "", ""}

LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat     := 0

Private cNroDoc :=  " "
Private aDadosTit
oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página

dbGoTop()
ProcRegua(RecCount())
While !EOF()
   dDataIni := mv_par11
   cDocumen := E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA
   While !EOF() .And. cDocumen == E1_PREFIXO+E1_NUM+E1_CLIENTE+E1_LOJA

      IncProc()

      If E1_OK <> cMarca //Marked("E1_OK")
         dbSkip()
         Loop
      Endif

      //Posiciona o SA1 (Cliente)
      SA1->(DbSetOrder(1))
      SA1->(DbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))
     
      // Calcula o total de parcelas geradas para o titulo
      cQuery := "SELECT MAX(E1_PARCELA)E1_PARCELA FROM "+RetSQLName("SE1")+" WHERE D_E_L_E_T_=' ' AND E1_FILIAL='"
      cQuery += SE1->(XFILIAL())+"' AND E1_NUM='"+E1_NUM+"' AND E1_PREFIXO='"+E1_PREFIXO+"' AND E1_CLIENTE='"
      cQuery += E1_CLIENTE+"' AND E1_LOJA='"+E1_LOJA+"'"
      dbUseArea( .T., "TOPCONN", TcGenQry(,,CHANGEQUERY(cQuery)), "YYY", .T., .F. )
      cMaxPar := E1_PARCELA
      dbCloseArea()
      dbSelectArea("SE1")

      cBanco 	:= "341"             
      cAgencia  := Substr(GetMv("MV_XAGITA1"),01,05)
      cConta 	:= Substr(GetMv("MV_XCCITA1"),01,10)
      cSbConta  := Substr(GetMv("MV_XSBITA1"),01,03)  
          
      //Posiciona o SA6 (Bancos)
      SA6->(DbSetOrder(1))
      SA6->(DbSeek(xFilial("SA6")+cBanco+PadR(cAgencia,05)+PadR(cConta,10),.T.))

      //Posiciona na Arq de Parametros CNAB
      SEE->(DbSetOrder(1))
      SEE->(DbSeek(xFilial("SEE")+cBanco+PadR(cAgencia,05)+PadR(cConta,10)+PadR(cSbConta,03),.T.))
    
      DbSelectArea("SE1")
      aDadosBanco := {"341" /*SA6->A6_COD*/,;                                                   // [1]Codigo do Banco
                      SA6->A6_NREDUZ,;                                                          // [2]Nome do Banco
                      SUBSTR(SA6->A6_AGENCIA, 1, 5),;                                           // [3]Agência
                      SUBSTR(SA6->A6_NUMCON,1,5) ,;                                             // [4]Conta Corrente
                      SA6->A6_DVCTA  ,;                                                         // [5]Dígito da conta corrente
                      SEE->EE_CODCART,;                                                         // [6]Codigo da Carteira
                      SA6->A6_NUMBCO}                                                           // [7]Numero do Banco
      
      If Empty(SA1->A1_ENDCOB) .Or. "MESMO" $ SA1->A1_ENDCOB
         aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;        // [1]Razão Social
         AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;        // [2]Código
         AllTrim(SA1->A1_END )                            ,;        // [3]Endereço
         AllTrim(SA1->A1_MUN )                            ,;        // [4]Cidade
         SA1->A1_EST                                      ,;        // [5]Estado
         SA1->A1_CEP                                      ,;        // [6]CEP
         SA1->A1_CGC									  ,;        // [7]CGC
         " "           									  ,;      	// [8]PESSOA
         AllTrim(SA1->A1_BAIRRO)                           }        // [9]Bairro   
      Else
         aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;    	// [1]Razão Social
         AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;    	// [2]Código
         AllTrim(SA1->A1_ENDCOB)                          ,;    	// [3]Endereço
         AllTrim(SA1->A1_MUNC)	                          ,;    	// [4]Cidade
         SA1->A1_ESTC	                                  ,;    	// [5]Estado
         SA1->A1_CEPC                                     ,;    	// [6]CEP
         SA1->A1_CGC								      ,;		// [7]CGC
         " "           								      ,;    	// [8]PESSOA
         AllTrim(SA1->A1_BAIRROC)                          }        // [9]Bairro   
      Endif

      nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

      //Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo. 
      //Abaixo apenas uma sugestao
      cNroDoc := Strzero(Val(Alltrim(SE1->E1_NUM)),6)+StrZERO(Val(Alltrim(SE1->E1_PARCELA)),2)
      cNroDoc := STRZERO(Val(cNroDoc),11)

      aCB_RN_NN := Ret_cBarra( SE1->E1_PREFIXO , SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
                   Subs(aDadosBanco[1],1,3), aDadosBanco[3], aDadosBanco[4], aDadosBanco[5],;
                   aDadosBanco[7], cNroDoc , (SE1->E1_SALDO-(nVlrAbat+SE1->E1_DECRESC)), aDadosBanco[6], "9")

      aDadosTit := {E1_NUM+If(Empty(E1_PARCELA),"","-"+E1_PARCELA)+;
                    If(Empty(cMaxPar),"","/"+cMaxPar)       ,;  // [1] Número do título
                    E1_EMISSAO                              ,;  // [2] Data da emissão do título
                    dDataBase                               ,;  // [3] Data da emissão do boleto
                    E1_VENCTO                               ,;  // [4] Data do vencimento
                    SE1->E1_SALDO-(nVlrAbat+SE1->E1_DECRESC),;  // [5] Valor do título
                    aCB_RN_NN[3]                            ,;  // [6] Nosso número (Ver fórmula para calculo)
                    E1_PREFIXO                              ,;  // [7] Prefixo da NF
                    "DM"                                    ,;  // [8] Tipo do Titulo  // Antes -> E1_TIPO
                    E1_DECRESC							}  // [9] Decrescimo
            
  

      aBolText    := {"","","","",""}
   	  aBolText[1]:="JUROS DIARIO DE: R$ "+SUBSTR(AllTrim(Transform(E1_SALDO * E1_PORCJUR/100,"@E 9,999,999.99")),1,13)+" A PARTIR DO DIA: "+SUBSTR(DTOC(E1_VENCTO+1),1,10)
      aBolText[2]:= "" 
      aBolText[3]:= ""
      aBolText[4]:= ""
      aBolText[5]:= "" //reconhecidas por este sistema. Não cessa esta cobrança, podendo ocorrer protesto."      

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
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 06/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASERDO ITAU COM CODIGO DE BARRAS      ³±±
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
Local cLogo:= 030

cBmp := cStartPath + "ITAU.BMP" //Logo do Banco Itau   
cLogo := cStartPath + "LOGOSATO.BMP" //Logo da Empresa


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
oFont14  := TFont():New("Arial"      ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont18  := TFont():New("Arial"      ,9,18,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial"      ,9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont23  := TFont():New("Arial"      ,9,23,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial"      ,9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial"      ,9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial"      ,9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial"      ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial"      ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial"      ,9,21,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/

nRow1 := -50
                                                          
oPrint:Line (nRow1+0150,545,nRow1+0070, 545)
oPrint:Line (nRow1+0150,755,nRow1+0070, 755)

oPrint:Say  (nRow1+0084,180,"Banco Itaú S.A.",oFont14 )	// [2]Nome do Banco
If File(cBmp)
   oPrint:SayBitmap(nRow1+0080,100,cBmp,75,65)
Endif

oPrint:Say  (nRow1+0075,560,aDadosBanco[1]+"-7",oFont21 )		// [1]Numero do Banco     
oPrint:Say  (nRow1+0075,800,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0150,100 ,"Beneficiário",oFont8)
oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0150,1060,"Agência / Código do Beneficiário",oFont8)
oPrint:Say  (nRow1+0200,1060,Alltrim(aDadosBanco[3])+"/"+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5]), oFont10)

oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
oPrint:Say  (nRow1+0200,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela  

oPrint:Say  (nRow1+0250,100 ,"Pagador",oFont8)
oPrint:Say  (nRow1+0300,100 ,aDatSacado[1],oFont10)				//Nome

oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
oPrint:Say  (nRow1+0300,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont9)

oPrint:Say  (nRow1+0250,1225,"Nosso Número",oFont8)
   cString  := Transform(aDadosTit[6],"@R 999/99999999-9")
oPrint:Say  (nRow1+0300,1225,cString,oFont9) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0250,1510,"Valor do Documento",oFont8)
oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0350,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say  (nRow1+0400,0100,"com as características acima.",oFont10)
//oPrint:Say  (nRow1+0500,0100,cFatura,oFont8) 

oPrint:Say  (nRow1+0350,1060,"Data",oFont8)
oPrint:Say  (nRow1+0350,1410,"Assinatura",oFont8)
oPrint:Say  (nRow1+0450,1060,"Data",oFont8)
oPrint:Say  (nRow1+0450,1410,"Entregador",oFont8) 

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 ) 
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )   
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0165,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0205,1910,"(  )Ausente"                                  ,oFont8)
oPrint:Say  (nRow1+0245,1910,"(  )Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0285,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0325,1910,"(  )Não procurado"                            ,oFont8)
oPrint:Say  (nRow1+0365,1910,"(  )Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0405,1910,"(  )Desconhecido"                            	,oFont8)
oPrint:Say  (nRow1+0445,1910,"(  )Falecido"                                 ,oFont8)
oPrint:Say  (nRow1+0485,1910,"(  )Outros(anotar no verso)"                  ,oFont8)

// Aceite do Cliente


nRow1 := nRow1 + 565 //625
 
oPrint:Line (nRow1+0150, 100,nRow1+0150,2300)
oPrint:Line (nRow1+0080,600,nRow1+0150,600)
oPrint:Line (nRow1+0080,780,nRow1+0150,780)

If File(cBmp)
   oPrint:SayBitmap(nRow1+0080,100,cBmp,75,65)
Endif
oPrint:Say  (nRow1+0080, 180,"Banco Itaú S.A."  ,oFont14 )  // [2]Nome do Banco
oPrint:Say  (nRow1+0075, 613,aDadosBanco[1]+"-7",oFont18 )   // [1]Numero do Banco
oPrint:Say  (nRow1+0084, 810,aCB_RN_NN[2]       ,oFont11)    // Linha Digitavel do Codigo de Barras
oPrint:Say  (nRow1+0080,1940,"Recibo do Pagador" ,oFont11 )

oPrint:Line (nRow1+0250,100,nRow1+0250,2300 )
oPrint:Line (nRow1+0350,100,nRow1+0350,2300 )
oPrint:Line (nRow1+0420,100,nRow1+0420,2300 )
oPrint:Line (nRow1+0490,100,nRow1+0490,2300 )

oPrint:Line (nRow1+0350,500 ,nRow1+0490,500 )
oPrint:Line (nRow1+0420,750 ,nRow1+0490,750 )
oPrint:Line (nRow1+0350,1000,nRow1+0490,1000)
oPrint:Line (nRow1+0350,1300,nRow1+0420,1300)
oPrint:Line (nRow1+0350,1480,nRow1+0490,1480)

oPrint:Say  (nRow1+0150,100 ,"Local de Pagamento",oFont8n)
oPrint:Say  (nRow1+0190,100 ,"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ. APÓS O VENCIMENTO, SOMENTE NO ITAÚ",oFont9)
           
oPrint:Say  (nRow1+0150,1810,"Vencimento",oFont8n)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol    := 1830 //1810+(374-(len(cString)*20))
oPrint:Say  (nRow1+0190,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow1+0250,100 ,"Beneficiário",oFont8n)
oPrint:Say  (nRow1+0250,250 ,aDadosEmp[1] ,oFont10) //Nome + CNPJ
oPrint:Say  (nRow1+0290,100 ,"Endereço ",oFont8n)
oPrint:Say  (nRow1+0290,230 ,alltrim(aDadosEmp[2]) +" "+ alltrim(aDadosEmp[3])+" "+ alltrim(aDadosEmp[4]) ,oFont10) //Nome + CNPJ

oPrint:Say  (nRow1+0250,1305,"CNPJ"                                   ,oFont8n)
oPrint:Say  (nRow1+0250,1405,aDadosEmp[6]                             ,oFont10) //CNPJ

oPrint:Say  (nRow1+0250,1810,"Agência / Código do Beneficiário",oFont8n)
cString := Alltrim(aDadosBanco[3])+"/"+Alltrim(aDadosBanco[4])+"-"+Alltrim(aDadosBanco[5])
nCol    := 1830 //1810+(374-(len(cString)*20))
oPrint:Say  (nRow1+0290,nCol,PADL(cString,17) ,oFont11c)

oPrint:Say  (nRow1+0350,100 ,"Data do Documento"                            ,oFont8n)
oPrint:Say  (nRow1+0380,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow1+0350,505 ,"Nº do Documento"                              ,oFont8n)
oPrint:Say  (nRow1+0380,605 ,aDadosTit[7]+aDadosTit[1]                      ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0350,1005,"Espécie Doc."                                 ,oFont8n)
oPrint:Say  (nRow1+0380,1050,aDadosTit[8]                                   ,oFont10) //Tipo do Titulo

oPrint:Say  (nRow1+0350,1305,"Aceite"                                       ,oFont8n)
oPrint:Say  (nRow1+0380,1400,"N"                                            ,oFont10)

oPrint:Say  (nRow1+0350,1485,"Data do Processamento"                        ,oFont8n)
oPrint:Say  (nRow1+0380,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

oPrint:Say  (nRow1+0350,1810,"Nosso Número"                                 ,oFont8n)
cString := Transform(aDadosTit[6],"@R 999/99999999-9")
nCol    := 1830 //1810+(374-(len(cString)*20))
oPrint:Say  (nRow1+0380,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow1+0420,100 ,"Uso do Banco"                                 ,oFont8n)
oPrint:Say  (nRow1+0450,150 ,"           "                                  ,oFont10)

oPrint:Say  (nRow1+0420,505 ,"Carteira"                                     ,oFont8n)
oPrint:Say  (nRow1+0450,555 ,aDadosBanco[6]                                 ,oFont10)

oPrint:Say  (nRow1+0420,755 ,"Espécie"                                      ,oFont8n)
oPrint:Say  (nRow1+0450,805 ,"R$"                                           ,oFont10)

oPrint:Say  (nRow1+0420,1005,"Quantidade"                                   ,oFont8n)
oPrint:Say  (nRow1+0420,1485,"Valor"                                        ,oFont8n)

oPrint:Say  (nRow1+0420,1810,"(=)Valor do Documento"                     	,oFont8n)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol    := 1830 //1810+(374-(len(cString)*20))
oPrint:Say  (nRow1+0450,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow1+0490,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário.)",oFont8n)
oPrint:SayBitmap(nRow1+0500,1460,cLogo,0340,0386)
oPrint:Say  (nRow1+0590,100 ,aBolText[1]  ,oFont8)
oPrint:Say  (nRow1+0640,100 ,aBolText[2]  ,oFont8)
oPrint:Say  (nRow1+0690,100 ,aBolText[3]  ,oFont8)
oPrint:Say  (nRow1+0740,100 ,aBolText[4]  ,oFont8)
oPrint:Say  (nRow1+0790,100 ,aBolText[5]  ,oFont8)

oPrint:Say  (nRow1+0490,1810,"(-)Desconto / Abatimento"                    ,oFont8n)
cString := Alltrim(Transform(aDadosTit[9],"@EZ 99,999,999.99"))
nCol := 1830 //1810+(374-(len(cString)*22))
oPrint:Say  (nRow1+0520,nCol,PADL(cString,17) ,oFont11c)

//oPrint:Say  (nRow1+0560,1810,"(-)Outras Deduções"                          ,oFont8n)
oPrint:Say  (nRow1+0630,1810,"(+)Mora / Multa"                             ,oFont8n)
//oPrint:Say  (nRow1+0700,1810,"(+)Outros Acréscimos"                        ,oFont8n)
oPrint:Say  (nRow1+0770,1810,"(=)Valor Cobrado"                            ,oFont8n)
/*
oPrint:Say  (nRow1+0840,100 ,"Sacado"                                      ,oFont8n)
oPrint:Say  (nRow1+0840,230 ,aDatSacado[1]                                 ,oFont9 )
oPrint:Say  (nRow1+0840,1770,"CNPJ/CPF - "+aDatSacado[7]                   ,oFont9 ) //CNPJ

oPrint:Say  (nRow1+0880,230 ,aDatSacado[3]+" - "+aDatSacado[9]             ,oFont9 )
oPrint:Say  (nRow1+0920,230 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont9) // CEP+Cidade+Estado

oPrint:Say  (nRow1+0985, 100,"Sacador/Avalista"                            ,oFont8n)
oPrint:Say  (nRow1+1030,1620,"Autenticação Mecânica"                       ,oFont8n)
*/
oPrint:Line (nRow1+0150,1800,nRow1+0840,1800 )//LINHA LATERAL 1765
oPrint:Line (nRow1+0560,1800,nRow1+0560,2300 )
oPrint:Line (nRow1+0630,1800,nRow1+0630,2300 )
oPrint:Line (nRow1+0700,1800,nRow1+0700,2300 )
oPrint:Line (nRow1+0770,1800,nRow1+0770,2300 )
oPrint:Line (nRow1+0840,100 ,nRow1+0840,2300 )

/*
If File(cLogo)
  //              altT   largT      largI  altI
  oPrint:SayBitmap(1000,  350, cLogo, 1000, 600)
Endif
 */
/*
oPrint:Line (nRow1+1025,100 ,nRow1+1025,2300 )
  
vMens    := Array(4)
vMens[1] := "Recebimento através do cheque n.                                             do banco"
vMens[2] := "Esta quitação só terá validade após o pagamento do cheque pelo banco sacado."

oPrint:Say  (nRow1+1030,100 , vMens[1]                                     ,oFont8n)
oPrint:Say  (nRow1+1060,100 , vMens[2]                                     ,oFont8n)
  */
/*****************/
/* SEGUNDA PARTE */
/*****************/
nRow2 := nRow1 

oPrint:Say  (nRow2+0840,100 ,"Pagador"                                      ,oFont8n)
oPrint:Say  (nRow2+0840,230 ,aDatSacado[1]                                 ,oFont9 )
oPrint:Say  (nRow2+0840,1770,"CNPJ/CPF - "+aDatSacado[7]                   ,oFont9 ) //CNPJ

oPrint:Say  (nRow2+0880,230 ,aDatSacado[3]+" - "+aDatSacado[9]             ,oFont9 )
oPrint:Say  (nRow2+0920,230 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont9) // CEP+Cidade+Estado

oPrint:Say  (nRow2+0985, 100,"Sacador/Avalista"                            ,oFont8n)
oPrint:Say  (nRow2+0985, 1200,"CNPJ" 			                           ,oFont8n)
oPrint:Say  (nRow2+1030,1620,"Autenticação Mecânica"                       ,oFont8n)
  
//oPrint:Line (nRow2+0150,1800,nRow2+0840,1800 )
//oPrint:Line (nRow2+0560,1800,nRow2+0560,2300 )
//oPrint:Line (nRow2+0630,1800,nRow2+0630,2300 )
//oPrint:Line (nRow2+0700,1800,nRow2+0700,2300 )
//oPrint:Line (nRow2+0770,1800,nRow2+0770,2300 )
//oPrint:Line (nRow2+0840,100 ,nRow2+0840,2300 )

oPrint:Line (nRow2+1025,100 ,nRow2+1025,2300 )

/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := nRow2 + 1175

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+0030, nI, nRow3+0030, nI+30)
Next nI

oPrint:Line (nRow3+0150, 100,nRow3+0150,2300)
oPrint:Line (nRow3+0080, 660,nRow3+0150, 660)
oPrint:Line (nRow3+0080, 850,nRow3+0150, 850)

If File(cBmp)
    oPrint:SayBitmap(nRow3+0080,100,cBmp,75,65)
Endif
oPrint:Say  (nRow3+0080,180,"Banco Itaú S.A." ,oFont14 )  // [2]Nome do Banco

oPrint:Say  (nRow3+0075, 673,aDadosBanco[1]+"-7",oFont18 )   // [1]Numero do Banco
oPrint:Say  (nRow3+0084, 890,aCB_RN_NN[2]       ,oFont14)    // Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+0250,100,nRow3+0250,2300 )
oPrint:Line (nRow3+0350,100,nRow3+0350,2300 )
oPrint:Line (nRow3+0420,100,nRow3+0420,2300 )
oPrint:Line (nRow3+0490,100,nRow3+0490,2300 )

oPrint:Line (nRow3+0350,500 ,nRow3+0490,500 )
oPrint:Line (nRow3+0420,750 ,nRow3+0490,750 )
oPrint:Line (nRow3+0350,1000,nRow3+0490,1000)
oPrint:Line (nRow3+0350,1300,nRow3+0420,1300)
oPrint:Line (nRow3+0350,1480,nRow3+0490,1480)

oPrint:Say  (nRow3+0150,100 ,"Local de Pagamento",oFont8n)
oPrint:Say  (nRow3+0190,100 ,"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO ITAÚ. APÓS O VENCIMENTO, SOMENTE NO ITAÚ",oFont9)
           
oPrint:Say  (nRow3+0150,1810,"Vencimento",oFont8n)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol    := 1830  //1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+0190,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0250,100 ,"Beneficiário",oFont8n)
oPrint:Say  (nRow3+0290,100 ,aDadosEmp[1] ,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+0250,1305,"CNPJ"                                    ,oFont8n)
oPrint:Say  (nRow3+0290,1305,aDadosEmp[6]                              ,oFont10) //CNPJ

oPrint:Say  (nRow3+0250,1810,"Agência / Código do Beneficiário",oFont8n)
//cString := Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5])
cString := Alltrim(aDadosBanco[3])+"/"+alltrim(aDadosBanco[4])+"-"+alltrim(+aDadosBanco[5])
nCol    := 1830  //1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+0290,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0350,100 ,"Data do Documento"                            ,oFont8n)
oPrint:Say  (nRow3+0380,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)

oPrint:Say  (nRow3+0350,505 ,"Nº do Documento"                              ,oFont8n)
oPrint:Say  (nRow3+0380,605 ,aDadosTit[7]+aDadosTit[1]                      ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+0350,1005,"Espécie Doc."                                 ,oFont8n)
oPrint:Say  (nRow3+0380,1050,aDadosTit[8]                                   ,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+0350,1305,"Aceite"                                       ,oFont8n)
oPrint:Say  (nRow3+0380,1400,"N"                                            ,oFont10)

oPrint:Say  (nRow3+0350,1485,"Data do Processamento"                        ,oFont8n)
oPrint:Say  (nRow3+0380,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao

oPrint:Say  (nRow3+0350,1810,"Nosso Número"                                 ,oFont8n)
cString := Transform(aDadosTit[6],"@R 999/99999999-9")
nCol    := 1830  //1880+(374-(len(cString)*22))
oPrint:Say  (nRow3+0380,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0420,100 ,"Uso do Banco"                                 ,oFont8n)
oPrint:Say  (nRow3+0450,150 ,"           "                                  ,oFont10)

oPrint:Say  (nRow3+0420,505 ,"Carteira"                                     ,oFont8n)
oPrint:Say  (nRow3+0450,555 ,aDadosBanco[6]                                 ,oFont10)

oPrint:Say  (nRow3+0420,755 ,"Espécie"                                      ,oFont8n)
oPrint:Say  (nRow3+0450,805 ,"R$"                                           ,oFont10)

oPrint:Say  (nRow3+0420,1005,"Quantidade"                                   ,oFont8n)
oPrint:Say  (nRow3+0420,1485,"Valor"                                        ,oFont8n)

oPrint:Say  (nRow3+0420,1810,"(=)Valor do Documento"                     	,oFont8n)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol    := 1830   //1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+0450,nCol,PADL(cString,17),oFont11c)

oPrint:Say  (nRow3+0490,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do Beneficiário.)",oFont8n)
oPrint:Say  (nRow3+0590,100 ,aBolText[1]  ,oFont8)
oPrint:Say  (nRow3+0640,100 ,aBolText[2]  ,oFont8)
oPrint:Say  (nRow3+0690,100 ,aBolText[3]  ,oFont8)
oPrint:Say  (nRow3+0740,100 ,aBolText[4]  ,oFont8)
oPrint:Say  (nRow3+0790,100 ,aBolText[5]  ,oFont8)

oPrint:Say  (nRow3+0490,1810,"(-)Desconto / Abatimento"                    ,oFont8n)
cString := Alltrim(Transform(aDadosTit[9],"@EZ 99,999,999.99"))
nCol    := 1830  //1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+0520,nCol,PADL(cString,17),oFont11c)

//oPrint:Say  (nRow3+0560,1810,"(-)Outras Deduções"                          ,oFont8n)
oPrint:Say  (nRow3+0630,1810,"(+)Mora / Multa"                             ,oFont8n)
//oPrint:Say  (nRow3+0700,1810,"(+)Outros Acréscimos"                        ,oFont8n)
oPrint:Say  (nRow3+0770,1810,"(=)Valor Cobrado"                            ,oFont8n)

oPrint:Say  (nRow3+0840,100 ,"Pagador"                                      ,oFont8n)
oPrint:Say  (nRow3+0840,230 ,aDatSacado[1]                                 ,oFont9 )
oPrint:Say  (nRow3+0840,1770,"CNPJ/CPF - "+aDatSacado[7]                   ,oFont9 ) //CNPJ

oPrint:Say  (nRow3+0880,230 ,aDatSacado[3]+" - "+aDatSacado[9]             ,oFont9 )
oPrint:Say  (nRow3+0920,230 ,Transform(aDatSacado[6],"@R 99999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont9) // CEP+Cidade+Estado

oPrint:Say  (nRow3+0985,1850,"Código de Baixa:"  ,oFont9)

oPrint:Say  (nRow3+0985, 100,"Sacador/Avalista"                            ,oFont8n)
oPrint:Say  (nRow3+0985, 1200,"CNPJ" 			                           ,oFont8n)
oPrint:Say  (nRow3+1030,1580,"Autenticação Mecânica "  ,oFont8n)
oPrint:Say  (nRow3+1030,1900,"Ficha de Compensação "  ,oFont8)

oPrint:Line (nRow3+0150,1800,nRow3+0840,1800 )
oPrint:Line (nRow3+0560,1800,nRow3+0560,2300 )
oPrint:Line (nRow3+0630,1800,nRow3+0630,2300 )
oPrint:Line (nRow3+0700,1800,nRow3+0700,2300 )
oPrint:Line (nRow3+0770,1800,nRow3+0770,2300 )
oPrint:Line (nRow3+0840,100 ,nRow3+0840,2300 )

oPrint:Line (nRow3+1025,100 ,nRow3+1025,2300 )

MSBAR2("INT25",23.3,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,1.7,Nil,Nil,"A",.F.,100,100)

DbSelectArea("SE1")

oPrint:EndPage() // Finaliza a página

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Microsiga           º Data ³  06/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera SE1                        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(	cPrefixo,cNumero,cParcela,cTipo,cBanco,cAgencia,cConta,;
                            cDacCC,cNumBco,cNroDoc,nValor,cCart,cMoeda)
Local cNosso	  := ""
Local cDigNosso  := ""
Local cCampoL	  := ""
Local cFatorValor:= ""
Local cLivre	  := ""
Local cDigBarra  := ""
Local cBarra	  := ""
Local cParte1	  := ""
Local cDig1		  := ""
Local cParte2	  := ""
Local cDig2		  := ""
Local cParte3	  := ""
Local cDig3		  := ""
Local cParte4	  := ""
Local cParte5	  := ""
Local cDigital	  := ""
Local aRet		  := {}

cAgencia := Left(Alltrim(cAgencia),4)

// Nosso Numero
If Empty(SE1->E1_NUMBCO)
   cNosso := cCart + strzero(val(AllTrim(Str(Val(NossoNum()),8))),8)
   cNosso += Modulo10( cAgencia+Left(cConta,5)+cNosso )
Else
   cNosso := AllTrim(SE1->E1_NUMBCO)
Endif

//Campo Livre
cCampoL  := cNosso + cAgencia + AllTrim(cConta) + AllTrim(cDacCC) + "000"

// Campo livre do codigo de barra                   // verificar a conta
If nValor <= 0
   nValor := SE1->E1_VALOR
Endif
cFatorValor := Fator(SE1->E1_VENCTO) + StrZero(nValor * 100,10)

cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
cDigBarra := CALC_5p( cLivre )
cBarra    := SubStr(cLivre,1,4)+cDigBarra+SubStr(cLivre,5,39)

// composicao da linha digitavel
cParte1  := cBanco + cMoeda + SubStr(cCampoL,1,5)
cDig1    := DIGIT001( cParte1 )
cParte2  := SUBSTR(cCampoL,6,10)
cDig2    := DIGIT001( cParte2 )
cParte3  := SUBSTR(cCampoL,16,10)
cDig3    := DIGIT001( cParte3 )
cParte4  := cDigBarra
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cParte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cParte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cParte3,6,5)+cDig3+" "+;
			cParte4+" "+;
			cParte5

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)

DbSelectArea("SE1")

Return aRet

/*                                                                                          
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT001  ºAutor  ³Microsiga           º Data ³  06/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Unibanco                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DIGIT001(cVariavel)
   Local cBase, nUmDois, nSumDig, nDig, nAux, cValor, nDezena

   cBase   := cVariavel
   nUmDois := 2
   nSumDig := 0
   nAux    := 0
   For nDig:=Len(cBase) To 1 Step -1
      nAux    := Val(SubStr(cBase, nDig, 1)) * nUmDois
      nSumDig += (nAux - If( nAux < 10 , 0, 9))
      nUmDois := 3 - nUmDois
   Next
   cValor := AllTrim(Str(nSumDig,12))
   nAux   := 10 - Val(SubStr(cValor,Len(cValor),1))
   //nDezena := Val(AllTrim(Str(Val(SubStr(cValor,1,1))+1,12))+"0")
   //nAux    := nDezena - nSumDig

   If nAux == 10
      nAux := 0
   EndIf

Return(Str(nAux,1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Microsiga           º Data ³  06/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR  de vencimento para linha digitavel.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function Fator(dVencto)
   Local cData  := DTOS(dVencto)
   Local cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
Return(cFator)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_5p   ºAutor  ³Microsiga           º Data ³  06/10/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do nosso numero do                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CALC_5p(cVariavel,lNosso)
   Local cBase, nBase, nAux, nSumDig, nDig

   cBase   := cVariavel
   nBase   := 2
   nSumDig := 0
   nAux    := 0
   For nDig:=Len(cBase) To 1 Step -1
      nAux    := Val(SubStr(cBase, nDig, 1)) * nBase
      nSumDig += nAux
      nBase   += If( nBase == 9 , -7, 1)
   Next

   nAux := Mod(nSumDig * 10,11)
   If nAux == 0 .Or. nAux == 10
      If lNosso
         nAux := 0
      Else
         nAux := 1
      Endif
   Endif

Return(Str(nAux,1))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ Modulo10 ºAutor  ³Microsiga           º Data ³  36/11/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calculo do digito do nosso numero do pelo Modulo 10        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Modulo10(cVariavel)
   Local cBase, nBase, nAux, nSumDig, nDig

   cBase   := cVariavel
   nBase   := 2
   nSumDig := 0
   nAux    := 0
   For nDig:=Len(cBase) To 1 Step -1
      nAux    := Val(SubStr(cBase, nDig, 1)) * nBase
      nAux    -= If( nAux > 9 , 9, 0)
      nSumDig += nAux
      nBase   := If( nBase == 2 , 1, 2)
   Next

   nAux := 10 - Mod(nSumDig,10)
   If nAux == 10
      nAux := 0
   Endif

Return(Str(nAux,1))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 06/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
           "X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
           "X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
           "X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
           "X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
           "X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
           "X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
           "X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]	
 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
 	Endif	
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."

		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else
			aHelpEng := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next
Return