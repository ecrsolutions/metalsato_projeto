#include "Rptdef.CH"
#include "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"

User Function SAESTR03(aEtiquetas)
Private aItens :=  {}  

    MsgRun("Imprimindo etiqueta... ","Aguarde!",{||Imprime(aEtiquetas)})

Return

Static Function Imprime(aEtiquetas)
    Local cFileName       := "SAESTR03_"+Dtos(MSDate())+'_'+StrTran(Time(),":","")
    Local cPathInServer   := GetTempPath()
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local lTReport        := .F.
    Local lServer         := .F.
    Local lPDFAsPNG       := .T.
    Local lRaw            := .F.
    Local lViewPDF        := .T.
    Local nQtdCopy        := 1   
    Local nHeight         := 70.8 //7,5 cm
    Local nWidght         := 100 //10cm
    Local nI,nX           := ""  
    Private nMaxLine      := 0
    Private nLinha        := 0
    Private nColuna       := 0
    Private nEspacoLin    := 0
    Private nEspacoCol    := 0
    Private oPrinter     
    PRIVATE oFont18N   := Nil

    oPrinter := FWMSPrinter():New(cFileName,IMP_PDF/*IMP_SPOOL*/,lAdjustToLegacy,cPathInServer,lDisableSetup,lTReport,/*oSetup*/,/*Alltrim(cImpress)*/,lServer,lPDFAsPNG,lRaw,lViewPDF,nQtdCopy)

        oTFont16 := TFont():New('Arial Black',,-16,.T.)
        oTFont14 := TFont():New('Arial Black',,-14,.T.)
        oTFont8  := TFont():New('Arial Black',,-8,.T.)
        oTFont10 := TFont():New('Arial Black',,-10,.T.)
        oTFont12 := TFont():New('Arial Black',,-12,.T.)

        
            
        oTFont16:nHeight   := -16
        oTFont8:nHeight    := -8
        oTFont10:nHeight   := -10

        oTFont16:Bold   := .T.
        oTFont14:Bold   := .T.
        oTFont8:Bold    := .T.
        oTFont10:Bold   := .T.
        oTFont12:Bold   := .T.

        oPrinter:SetPaperSize(0,nHeight,nWidght)                

        CB0->(DbSelectArea("CB0"))
        CB0->(DbSetOrder(1))

        For nI := 1 to len(aEtiquetas)     

            CB0->(DbGoTop())
            If CB0->(dbSeek(XFilial("CB0")+aEtiquetas[nI]))  
        
                oPrinter:StartPage()
                    nLinha  := 5
                    nEspLin := 7 
                    nLargura := nWidght*5.6
                    
                    oPrinter:Line(nLinha, 10 , nLinha, nLargura,0,"-7")
                    nLinAnt  := nLinha
                    nLinAnt2 := nLinha
                    nLinInic := nLinha
                    
                    nLinha += nEspLin    
                    oPrinter:Say(nLinha,20,"LPN" ,oTFont14)
                    
                    nLinha += nEspLin*1.5
                    cLPN :="5329"
                    cLPN += left(replace(dtoc(ddatabase),"/",""),4)+right(dtoc(ddatabase),2)
                    cLPN += right(rtrim(TiraZeros(CB0->CB0_CODETI)),5)
                    oPrinter:Say(nLinha,25 ,cLPN ,oTFont14)

                    cCodPro := CB0->CB0_CODPRO
                    If Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_XYAMAHA") == '1'
                        cTipo := "INSP"
                    ElseIf Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_XYAMAHA") == '2'
                        cTipo := "QA"
                    Else
                        cTipo := "NÃO DEFINIDO"
                    EndIf
                    oPrinter:Say(nLinha,380,cTipo  ,oTFont14)

                            
                    nEspLin := 10
                    nLinha += nEspLin*0.5
                    oPrinter:Line(nLinha    , 10  , nLinha, nLargura,0,"-7")
                    oPrinter:Line(nLinAnt2  , 360 , nLinha, 360     ,0,"-7")  //cria linha vertical
                    oPrinter:Line(nLinAnt2  , 450 , nLinha, 450     ,0,"-7")  //cria linha vertical


                    nLinha += nEspLin*1.5
                    cCodBar := Replace(cLPN,"-","")
                    oPrinter:Code128(nLinha-12.5,120, REPLACE(cCodBar,".",""), 1, 25 , .F.,,150 )
                    nLinha += nEspLin*1.8
                    oPrinter:Say(nLinha,185,""+cCodBar+""  ,oTFont10)

                    nLinha += nEspLin*.080
                    oPrinter:Line(nLinha, 10 , nLinha, nLargura,0,"-7")
                    nLinAnt2 := nLinha

                    nEspLin := 7  
                    nLinha  += nEspLin*1.2    
                    oPrinter:Say(nLinha,15  ,"Código"    ,oTFont14)
                    oPrinter:Say(nLinha,330 ,"Supplier"  ,oTFont14)
                    oPrinter:Say(nLinha,480 ,"User"      ,oTFont14)
                    
                    nLinha += nEspLin*1.5
                    SA7->(DbSelectArea("SA7"))
                    SA7->(DbSetOrder(1))
                    SA7->(DbGoTop())

                    cCOdCli := ""
                    While !SA7->(EOF())
                        If rtrim(SA7->A7_PRODUTO) == rtrim(cCodPro) .and. !EMPTY(SA7->A7_CODCLI)
                            cCodCli := rtrim(Replace(SA7->A7_CODCLI,"BE-",""))
                            exit
                        EndIf
                        SA7->(DbSkip())
                    Enddo    
                    oPrinter:Say(nLinha,25  , left(cCodCli,25)  ,oTFont14)
                    oPrinter:Say(nLinha,330 , "5329"            ,oTFont14)
                    oPrinter:Say(nLinha,480 , "9219"            ,oTFont14)

                    nEspLin := 10
                    nLinha += nEspLin*0.1

                    oPrinter:Line(nLinha    , 10          , nLinha, nLargura,0,"-7")
                    oPrinter:Line(nLinAnt2  , 320         , nLinha, 320     ,0,"-7")  //cria linha vertical
                    oPrinter:Line(nLinAnt2  , 470         , nLinha, 470     ,0,"-7")  //cria linha vertical
                    nLinAnt2 := nLinha

                    nLinha += nEspLin*1.2
                    cCodBar := rtrim(replace(cCodCli,"-",""))+"-5329-"+"9219" 
                    oPrinter:Code128(nLinha-10.5,90, REPLACE(cCodBar,".",""), 1 , 20 , .F.,,200)

                    nLinha += nEspLin*1.6
                    //oPrinter:Say(nLinha,155,""+cCodBar+""  ,oTFont10)

                    nLinha += nEspLin*0.30
                    oPrinter:Line(nLinha    , 10        , nLinha, nLargura,0,"-7")
                    nLinAnt3 := nLinha
                    

                    nLinha += nEspLin*1
                    nLinAnt2 := nLinha
                    nEspLin := 7 
                    oPrinter:Say(nLinha,15 ,"Nome"         ,oTFont14)
                    oPrinter:Say(nLinha,330,"Fornecedor"   ,oTFont14)
                    
                    nLinha += nEspLin*1.2
                    cDescricao := Posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
                    cDescricao := Left(cDescricao,20)      
                    oPrinter:Say(nLinha,25 ,cDescricao         ,oTFont14)
                    oPrinter:Say(nLinha,330,"METALURGICA SATO" ,oTFont14)

                    nLinha += nEspLin*0.4
                    oPrinter:Line(nLinAnt2   , 320      , nLinha, 320     ,0,"-7")  //cria linha vertical
                    oPrinter:Line(nLinha    ,  010      , nLinha, nLargura,0,"-7")
                    nLinAnt  := nLinha

                    nLinha += nEspLin*1.2    
                    oPrinter:Say(nLinha,15 ,"Qtd.:"                  ,oTFont14)
                    oPrinter:Say(nLinha,150,"Nf/Invoice"             ,oTFont14)
                    oPrinter:Say(nLinha,330,"Uso Exclus. do Fornec." ,oTFont14)
                    
                    nLinha += nEspLin*0.75
                    oPrinter:Say(nLinha,330 ,"Código: "+right(RTRIM(CB0->CB0_CODPRO),6)+' - '+dtoc(ddatabase)    ,oTFont12)
                    
                    nLinha += nEspLin*0.75
                    oPrinter:Say(nLinha,15 ,TiraZeros(cValtoChar(CB0->CB0_QTDE)) ,oTFont14)
                    
                    nLinha += nEspLin*0.20
                    oPrinter:Say(nLinha,330 ,"Lote: "  +RTRIM(CB0->CB0_OP)        ,oTFont12)

                    nEspLin  := 10
                    nLinha   += nEspLin*0.3 
                    oPrinter:Line(nLinha     , 10       , nLinha , nLargura,0,"-7")
                    oPrinter:Line(nLinAnt    , 140      , nLinha, 140      ,0,"-7")  //cria linha vertical
                    oPrinter:Line(nLinAnt3   , 320      , nLinha, 320      ,0,"-7")  //cria linha vertical
                    nLinAnt3 := nLinha
                                    
                    nLinha += nEspLin*0.2
                    
                    If CB0->CB0_QTDE < 10
                    	nQtdZero := 2
                    ElseIf CB0->CB0_QTDE < 99
                    	nQtdZero := 1
                    ElsE
                    	nQtdZero := 0
                    EndIf
                    
                    3-Len(cValToChar(cCodBar1))
                    
                    If CB0->CB0_QTDE < 99
                    	cCodBar1 := Strzero(CB0->CB0_QTDE,3)
                    Else
                    	cCodBar1 := cValtoChar(CB0->CB0_QTDE)
                    EndIf
                    //cTmpBar  := ""
                    //For nX := 1 to 4-len(cCodBar)
                    //    cTmpBar += "0"
                    //Next nX
                    
                    //cCodBar := cTmpBar + cCodBar1
                    oPrinter:Code128(nLinha,20, cCodBar1, 1, 30 , .F.,,60 )
                    //oPrinter:Code128(nLinha,20, cCodBar1,1,30, .F.)

                    cCodBar2 := TRANSFORM(CB0->CB0_XPESO,"@E 999999999.999")
                    cCodBar2 := REPLACE(cCodBar2,",",".")
                    oPrinter:Code128(nLinha,220, cCodBar2, 1, 30 , .F.,,165 )    

                    nLinha += nEspLin*3.3
                    oPrinter:Say(nLinha,050 ,cCodBar1 ,oTFont10)
                    oPrinter:Say(nLinha,320 ,cCodBar2 ,oTFont10)

                    nLinha += nEspLin*0.2
                    oPrinter:Line(nLinha     , 10       , nLinha , nLargura ,0 ,"-7")
                    oPrinter:Line(nLinInic   , 10       , nLinha , 10       ,0 ,"-7")  //cria linha vertical
                    oPrinter:Line(nLinInic   , nLargura , nLinha , nLargura ,0 ,"-7")  //cria linha vertical

                oPrinter:EndPage()
            EndIf

        Next nI

        //oPrinter:Print() 
        oPrinter:cPathPDF:= cPathInServer 
        oPrinter:Preview() 
                    
Return

Static Function TiraZeros(cTexto)
    Local aArea     := GetArea()
    Local cRetorno  := ""
    Local lContinua := .T.
    Default cTexto  := ""
 
    //Pegando o texto atual
    cRetorno := Alltrim(cTexto)
 
    //Enquanto existir zeros a esquerda
    While lContinua
        //Se a priemira posição for diferente de 0 ou não existir mais texto de retorno, encerra o laço
        If SubStr(cRetorno, 1, 1) <> "0" .Or. Len(cRetorno) ==0
            lContinua := .f.
        EndIf
         
        //Se for continuar o processo, pega da próxima posição até o fim
        If lContinua
            cRetorno := Substr(cRetorno, 2, Len(cRetorno))
        EndIf
    EndDo
     
    RestArea(aArea)
Return cRetorno
