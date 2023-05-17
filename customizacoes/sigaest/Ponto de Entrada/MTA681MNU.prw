#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
/*_________________________________________________________________________________
* ¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Program    ¦ MTA681MNU          ¦ Author             ¦ Matheus Vinícius     ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Description¦ Adiciona rotinas no menu da MATA681 - Apontamento mod. II      ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
* ¦ Date       ¦ 11/01/2020         ¦ Last Modified time ¦  11/01/2020          ¦¦*
* +------------+--------------------+--------------------+----------------------+¦*
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

User Function MTA681MNU()
    aadd(aRotina,{'Consulta Apontamentos','u_SAESTC01()' , 0 , 3,0,NIL}) 
    /************************************************************
    ONDE: Parametros do array a Rotina: 
    1. Nome a aparecer no cabecalho 
    2. Nome da Rotina associada 
    3. Reservado 
    4. Tipo de Transação a ser efetuada:     
        4.1 - Pesquisa e Posiciona em um Banco de Dados     
        4.2 - Simplesmente Mostra os Campos     
        4.3 - Inclui registros no Bancos de Dados     
        4.4 - Altera o registro corrente     
        4.5 - Remove o registro corrente do Banco de Dados 
    5. Nivel de acesso 6. Habilita Menu Funcional
    ************************************************************/
Return