//Bibliotecas
#Include 'Protheus.ch'

/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ SAESTA07           ¦ Author             ¦ 		                 ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Realiza ajuste de movimentos RE3-DE3/Re9/mOd-gGF                           ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 11/03/2020         ¦ Last Modified time ¦ 11/03/2020           ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function SAESTA07()
    Local cPerg    := Padr("SAESTA07",len(SX1->X1_GRUPO))
    Private lAchou := .F.
    Private nTotal := Nil
    Private aLog   := {}

    If Pergunte(cPerg,.T.)
        If MV_PAR05 <= GetMv("MV_ULMES")
            alert("O período inicial não pode ser menor ou igual ao último fechamento realizado!")
            return
        EndIf
        
        RptStatus({|| ProcesMod()}  , "Aguarde...", "Processando MOD/GGF...")
        RptStatus({|| ProcesRE3()}, "Aguarde...", "Processando RE3...")
        RptStatus({|| ProcesRE9()}, "Aguarde...", "Processando RE9...")

        If len(aLog) > 0
            cMsg := "Processamento concluído com sucesso! Caso queira salvar o log da operação escolha a opção desejada abaixo."
            aOp  := {"Salvar Txt","Salvar Planinha","Fechar"}
            nOpc := Aviso("SFESTA01",cMsg,aOp) 
            If nOpc == 1
                fSalvTxt()
            ElseIf nOpc == 2
                fSalvExc()
            EndIf
        Else
            cMsg := "Não foram encontrados itens a serem incluídos/alterados durante o processamento!"
            aOp  := {"Fechar"}
            nOpc := Aviso("SFESTA01",cMsg,aOp) 
        EndIf      

    EndIf



Return Nil

/*-----------------------------------------------*
 | Função: ProcesMod                             |
 | Descr.: Processa os registros na SD3          |
 *-----------------------------------------------*/
Static Function ProcesMod()
    Local nI := Nil

    SD3->(DbSelectArea("SD3"))
    SD3->(DbSetOrder(4))

    SD4->(DbSelectArea("SD4"))
    SD4->(DbSetOrder(2))

    SB1->(DbSelectArea("SB1"))
    SB1->(DbSetOrder(1))

    SG1->(DbSelectArea("SG1"))
    SG1->(DbSetOrder(1))
    
    nItens := 0
    BeginSql Alias "QRY"
       SELECT * FROM
                %table:SD3% SD3
           WHERE
                SD3.D_E_L_E_T_ = ''
                AND D3_ESTORNO = ''
                AND D3_CF = 'PR0'
                AND D3_OP      BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
                AND D3_COD     BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
                AND D3_EMISSAO BETWEEN %Exp:dtos(MV_PAR05)% AND %Exp:dtos(MV_PAR06)% 
            ORDER BY D3_OP
    EndSql

    //Conta quantos registros existem, e seta no tamanho da régua
    Count To nTotal
    SetRegua(nTotal)
    QRY->(DbGoTop())
    While !QRY->(EOF())
        If SD3->(DbSeek(xFilial("SD3")+QRY->D3_NUMSEQ))
            
            //reinicia a variavel que controla se o componente ja foi apontado
            lAchou := .F.

            //busca os produtos mods
            aMod := {}
            GetModGGfA(QRY->D3_COD,QRY->D3_QUANT,@aMod,SD3->D3_EMISSAO)
            
            //varre os apontamentos para verificar se deve excluir algum produto mod/gg apontado errado
            While !SD3->(EOF()) .and. SD3->D3_NUMSEQ == QRY->D3_NUMSEQ
                
                If SB1->(DbSeek(xFilial("SB1")+SD3->D3_COD))
                    //filtra somente os produtos mod/ggf que foram consumidos
                    If SB1->B1_TIPO $ "MO,GG" .and. left(SD3->D3_CF,2) = "RE"
                        
                        //veifica se o componente esta na estrutura, caso contrario deleta da tabela
                        If ascan(aMod,{|x|x[1] == SD3->D3_COD}) == 0
                            lRet := Reclock("SD3",.F.)
                                dbDelete()
                            MsUnlock()
                        EndIf
                    EndIf
                EndIf
                SD3->(DbSkip())   
            Enddo

            For nI  := 1 to len(aMod)
                nRecDest := GetRecno(QRY->D3_NUMSEQ,QRY->D3_OP,aMod[nI,1])
                //posiciona no recno e faz a alteracao
                If nRecDest > 0
                    
                    //posiciona no registro a ser alterado
                    SD3->(DbGoTo(nRecDest))
                    
                    //valida se a quantidade apontada é difente a quantidade calculada na estrutura atual
                    If SD3->D3_QUANT <> aMod[nI,2]
                        
                        nQtdAnt := SD3->D3_QUANT
                        
                        //realiza alteração da quantidade
                        lRet := Reclock("SD3",.F.)
                            SD3->D3_QUANT := aMod[nI,2]
                        MsUnlock()

                        //armazena o log 
                        If lRet
                            If nQtdAnt <> SD3->D3_QUANT
                                aAdd(aLog,{SD3->D3_COD,SD3->D3_OP,SD3->D3_NUMSEQ,nQtdAnt,SD3->D3_QUANT,"Registro alterado"})
                            Else
                                aAdd(aLog,{SD3->D3_COD,SD3->D3_OP,SD3->D3_NUMSEQ,nQtdAnt,SD3->D3_QUANT,"Registro não modificado"})
                            EndIf
                        Else
                            aAdd(aLog,{SD3->D3_COD,SD3->D3_OP,SD3->D3_NUMSEQ,nQtdAnt,SD3->D3_QUANT,"Erro ao alterar"})
                        EndIf

                    EndIf
                //realiza a inclusao
                Else

                    If SB1->(DbSeek(xFilial("SB1")+aMod[nI,1]))
                        lRet := Reclock("SD3",.T.)
                            SD3->D3_FILIAL  := QRY->D3_FILIAL
                            SD3->D3_TM      := "999"
                            SD3->D3_COD     := SB1->B1_COD
                            SD3->D3_UM      := SB1->B1_UM
                            SD3->D3_QUANT   := aMod[nI,2]
                            SD3->D3_CF      := Iif(SB1->B1_APROPRI == "I","RE2","RE1")
                            SD3->D3_OP      := QRY->D3_OP
                            SD3->D3_LOCAL   := SB1->B1_LOCPAD
                            SD3->D3_DOC     := QRY->D3_DOC
                            SD3->D3_EMISSAO := stod(QRY->D3_EMISSAO)
                            SD3->D3_GRUPO   := SB1->B1_GRUPO
                            SD3->D3_NUMSEQ  := QRY->D3_NUMSEQ
                            SD3->D3_TIPO    := SB1->B1_TIPO
                            SD3->D3_USUARIO := UsrRetName(RetCodUsr())
                            SD3->D3_CHAVE   := "E0"
                            SD3->D3_IDENT   := QRY->D3_IDENT
                        MsUnlock()
                    EndIf

                    //armazena o log 
                    If lRet
                        aAdd(aLog,{SB1->B1_COD,QRY->D3_OP,SD3->D3_NUMSEQ,0,SD3->D3_QUANT,"Registro incluido"})
                    Else
                        aAdd(aLog,{SB1->B1_COD,QRY->D3_OP,SD3->D3_NUMSEQ,0,SD3->D3_QUANT,"Erro ao incluir"})
                    EndIf
                EndIf
            Next nI         
        EndIf

        //Incrementa a mensagem na régua
        nTotal++
        IncRegua()

        QRY->(DbSkip())  
    Enddo

    QRY->(DbCloseArea())

Return nil

/*-----------------------------------------------*
 | Função: GetModGGfA                            |
 | Descr.: Retorna estrutura do produto          |
 *-----------------------------------------------*/
Static Function GetModGGfA(cProdPai,nQtdPai,aMod,dDtApont)
    Local nRecAtu := Nil

    If SB1->(DbSeek(xFilial("SB1")+cProdPai))
        nQtdBase := Iif(SB1->B1_QB==0,1,SB1->B1_QB)
        cReviAtu := SB1->B1_REVATU

        If SG1->(DbSeek(xFilial("SG1")+cProdPai))
            While SG1->G1_FILIAL == xFilial("SG1") .and. SG1->G1_COD == cProdPai .and. !SG1->(EOF())
                nRecAtu := SG1->(Recno())
                If  cReviAtu >= SG1->G1_REVINI  .AND. cReviAtu <= SG1->G1_REVFIM  .and. dDtApont >= SG1->G1_INI .and. dDtApont <= SG1->G1_FIM 
                    If SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP))
                        If SB1->B1_TIPO $ "MO,GG" 
                            If SB1->B1_FANTASM <> "S"
                                aAdd(aMod,{SG1->G1_COMP,nQtdPai*SG1->G1_QUANT/nQtdBase})
                            Else
                                GetModGGfB(SG1->G1_COMP,nQtdPai*SG1->G1_QUANT/nQtdBase,@aMod,dDtApont)
                            EndIf
                        EndIf
                    EndIf
                EndIf
                SG1->(DbGoto(nRecAtu))
                SG1->(DbSkip())
            Enddo
        EndIf

    EndIf

Return

/*-----------------------------------------------*
 | Função: GetModGGfB                            |
 | Descr.: Retorna estrutura do produto          |
 *-----------------------------------------------*/
Static Function GetModGGfB(cProdPai,nQtdPai,aMod,dDtApont)
    Local nRecAtu := Nil

    If SB1->(DbSeek(xFilial("SB1")+cProdPai))
        nQtdBase := Iif(SB1->B1_QB==0,1,SB1->B1_QB)
        cReviAtu := SB1->B1_REVATU

        If SG1->(DbSeek(xFilial("SG1")+cProdPai))
            While SG1->G1_FILIAL == xFilial("SG1") .and. SG1->G1_COD == cProdPai .and. !SG1->(EOF())
                nRecAtu := SG1->(Recno())
                If  cReviAtu >= SG1->G1_REVINI  .AND. cReviAtu <= SG1->G1_REVFIM  .and. dDtApont >= SG1->G1_INI .and. dDtApont <= SG1->G1_FIM 
                    If SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP))
                        If SB1->B1_TIPO $ "MO,GG" 
                            If SB1->B1_FANTASM <> "S"
                                aAdd(aMod,{SG1->G1_COMP,nQtdPai*SG1->G1_QUANT/nQtdBase})
                            Else
                                GetModGGf(SG1->G1_COMP,nQtdPai*SG1->G1_QUANT/nQtdBase,@aMod)
                            EndIf
                        EndIf
                    EndIf
                EndIf
                SG1->(DbGoto(nRecAtu))
                SG1->(DbSkip())
            Enddo
        EndIf

    EndIf

Return

/*-----------------------------------------------*
 | Função: GetRecno                              |
 | Descr.: Retorna RECNO da SD3 conf. parametros |
 *-----------------------------------------------*/
Static Function GetRecno(cNumseq,cOp,cProduto)
    Local nRecno := 0
    
    BeginSql Alias "MOD"
        SELECT R_E_C_N_O_ AS 'RECNO'
        FROM %table:SD3% SD3
        WHERE  
            SD3.%Notdel%
            AND D3_NUMSEQ = %Exp:cNumseq%
            AND D3_OP     = %Exp:cOP%
            AND D3_COD    = %ExP:cProduto%
            AND D3_FILIAL = %Exp:xFilial("SD3")%
    EndSql

    If !MOD->(EOF())
        nRecno := MOD->RECNO
    EndIf

    MOD->(DbCloseArea())

Return nRecno

/*-----------------------------------------------*
 | Função: ProcesRE3                             |
 | Descr.: Transforma re3 em re4/de4             |
 *-----------------------------------------------*/
Static Function ProcesRE3()

    BeginSql Alias "RE3"        
        SELECT R_E_C_N_O_ as REGS,* FROM %table:SD3% SD3 
        WHERE 
            D3_FILIAL=%xFilial:SD3% 
            AND D3_EMISSAO BETWEEN %Exp:dtos(MV_PAR05)% AND %Exp:dtos(MV_PAR06)% 
            AND D3_ESTORNO<>'S'
            AND D3_CF IN ('RE3','DE3')
            AND SD3.%NotDel% 
    EndSql                                          
   
    locproc:=GETMV("MV_LOCPROC")    
    
    //Conta quantos registros existem, e seta no tamanho da régua
    Count To nTotal
    SetRegua(nTotal)
    RE3->(DbGoTop())

    While !RE3->(eof())
        IncProc("Processando ... "+RE3->D3_COD)
        dbSelectArea("SD3")              
        dbgoto(RE3->REGS)        
        userid:=SD3->D3_USUARIO
        
        BEGIN TRANSACTION
            //Converter RE3 para RE4
            RECLOCK("SD3",.F.)
                SD3->D3_CF     := "RE4"
                SD3->D3_TM     := "999"
                SD3->D3_CHAVE  := "E0"
                SD3->D3_LOCAL  := iif(RE3->D3_CF=="RE3",RE3->D3_LOCAL,locproc)
                SD3->D3_STSERV := ""
                SD3->D3_SEQCALC:= ""
            MSUNLOCK()

            aAdd(aLog,{SD3->D3_COD,SD3->D3_OP,SD3->D3_NUMSEQ,0,SD3->D3_QUANT,"RE3 - Registro alterado para RE4"})
        
            // Inserir RE3 como DE4
            RECLOCK("SD3",.T.)
                SD3->D3_FILIAL := RE3->D3_FILIAL
                SD3->D3_TM     := "499"
                SD3->D3_COD    :=RE3->D3_COD
                SD3->D3_UM     :=RE3->D3_UM
                SD3->D3_QUANT  :=RE3->D3_QUANT
                SD3->D3_CF     :="DE4"
                SD3->D3_CONTA  :=RE3->D3_CONTA
                SD3->D3_LOCAL  :=iif(RE3->D3_CF=="RE3",locproc,RE3->D3_LOCAL)
                SD3->D3_DOC    :=RE3->D3_DOC
                SD3->D3_GRUPO  :=RE3->D3_GRUPO
                SD3->D3_EMISSAO:=stod(RE3->D3_EMISSAO)
                SD3->D3_NUMSEQ :=RE3->D3_NUMSEQ
                SD3->D3_TIPO   :=RE3->D3_TIPO
                SD3->D3_USUARIO:=RE3->D3_USUARIO
                SD3->D3_CHAVE  :="E9"
            MSUNLOCK()

            aAdd(aLog,{SD3->D3_COD,SD3->D3_OP,SD3->D3_NUMSEQ,0,SD3->D3_QUANT,"RE3 - Registro incluído para DE4"})
        
        END TRANSACTION

        //Incrementa a mensagem na régua
        nTotal++
        IncRegua()

        RE3->(DbSkip())
    Enddo
    RE3->(dbCloseArea())
Return

/*-----------------------------------------------*
 | Função: ProcesRE9                              |
 | Descr.: Transforma re1/re2 em re9 para        |
 | produtos de terceiros                         |
 *-----------------------------------------------*/
Static Function ProcesRE9()
   
    BeginSql Alias "RE9"
        SELECT SD3.R_E_C_N_O_ as REGS,* FROM %table:SD3% SD3 
        LEFT JOIN %table:SB1% SB1 on LEFT(B1_FILIAL,LEN(B1_FILIAL)) = LEFT(D3_FILIAL,LEN(B1_FILIAL)) AND B1_COD = D3_COD AND SB1.%notDel%
        WHERE 
            SD3.D3_FILIAL=%xFilial:SD3% 
            AND D3_EMISSAO BETWEEN %Exp:dtos(MV_PAR05)% AND %Exp:dtos(MV_PAR06)% 
            AND D3_ESTORNO<>'S'
            AND D3_CF IN ('RE1','RE2')
            AND B1_TIPO = 'BN'
            AND SD3.%NotDel% 
    EndSql

    //Conta quantos registros existem, e seta no tamanho da régua
    Count To nTotal
    SetRegua(nTotal)
    RE9->(DbGoTop())

    While !RE9->(eof())
        IncProc("Processando ... "+RE9->D3_COD)
        dbSelectArea("SD3")              
        dbgoto(RE9->REGS)        
        
        BEGIN TRANSACTION
            //Converter para RE9
            RECLOCK("SD3",.F.)
                SD3->D3_CF     := "RE9"
            MSUNLOCK()    
        END TRANSACTION

        aAdd(aLog,{SD3->D3_COD,SD3->D3_OP,SD3->D3_NUMSEQ,0,SD3->D3_QUANT,"RE1RE2 - Registro alterado para RE9"})

        //Incrementa a mensagem na régua
        nTotal++
        IncRegua()
        
        RE9->(DbSkip())
    Enddo

   RE9->(DbCloseArea())

Return

/*-----------------------------------------------*
 | Função: fSalvArq                              |
 | Descr.: Função para gerar um arquivo texto    |
 *-----------------------------------------------*/
Static Function fSalvTxt()
    Local cFileName := "SFESTA01-"+Dtos(MSDate())+"-"+StrTran(Time(),":","")
    Local cFileNom  := GetTempPath()+cFileName+".txt"
    Local cQuebra   := CRLF + "+=======================================================================+" + CRLF
    Local lOk       := .T.
    Local cTexto    := ""
    Local nI        := Nil
     
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
 
    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf
         
        //Montando a mensagem
        cGuia  := "Log SFESTA01 - Periodo: "+dtoc(MV_PAR05)+" - "+dtoc(MV_PAR06)

        cTexto := "Função   - "+ cGuia           + CRLF
        cTexto += "Usuário  - "+ cUserName       + CRLF
        cTexto += "Data     - "+ dToC(dDataBase) + CRLF
        cTexto += "Hora     - "+ Time()          + CRLF
        cTexto += cQuebra

    For nI := 1 to len(aLog)
            cTexto += "Componente: "       +aLog[nI,01]               + CRLF
            cTexto += "Ordem de Produção: "+aLog[nI,02]               + CRLF
            cTexto += "Cód. Numseq: "      +aLog[nI,03]               + CRLF
            cTexto += "Qtd. Anterior: "    +cvaltochar(aLog[nI,04])   + CRLF
            cTexto += "Qtd. Atual:"        +cvaltochar(aLog[nI,05])   + CRLF
            cTexto += "Status:"            +aLog[nI,06]               + CRLF
            cTexto += cQuebra
    Next nI

        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cTexto)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf
    EndIf
Return

/*-----------------------------------------------*
 | Função: fSalvExc                              |
 | Descr.: Função para gerar um arquivo excel    |
 *-----------------------------------------------*/
Static Function fSalvExc()
    Local cFileName       := "SFESTA01-"+Dtos(MSDate())+"-"+StrTran(Time(),":","")
    Local cPathInServer   := GetTempPath()+cFileName+".xml"
    Local nI := Nil

    cGuia   := "Log SFESTA01"
    cTabela := cGuia+" Periodo: "+dtoc(MV_PAR05)+" - "+dtoc(MV_PAR06)

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet(cGuia)
    oFWMsExcel:AddTable(cGuia,cTabela)
  
    oFWMsExcel:AddColumn(cGuia,cTabela,"Componente"     ,1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cGuia,cTabela,"Ordem Produção" ,1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cGuia,cTabela,"Cód. Numseq"    ,1,1) //1 = Modo Texto
    oFWMsExcel:AddColumn(cGuia,cTabela,"Qtd. Anterior"  ,1,2) //1 = Modo Numerico
    oFWMsExcel:AddColumn(cGuia,cTabela,"Quantidade"     ,1,2) //1 = Modo Numerico
    oFWMsExcel:AddColumn(cGuia,cTabela,"Status"         ,1,1) //1 = Modo Texto

    For nI := 1 to len(aLog)
        oFWMsExcel:AddRow(cGuia,cTabela,{;
            aLog[nI,01],;
            aLog[nI,02],;
            aLog[nI,03],;
            aLog[nI,04],;
            aLog[nI,05],;
            aLog[nI,06]}) 
    Next nI

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cPathInServer)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()            
    oExcel:WorkBooks:Open(cPathInServer)     
    oExcel:SetVisible(.T.)               
    oExcel:Destroy() 

Return
