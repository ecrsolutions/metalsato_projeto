#INCLUDE "Protheus.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ STFATA03   ¦ Autor ¦ Ronilton O. Barros   ¦ Data ¦ 03/01/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Rotina de Faturamento do Kanban                               ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function STFATA03()
	Local aRotInc := {}
	
	AAdd( aRotInc , { "Incluir" , "u_FATIncluir('SZ1',0,3)", 0 , 3} )
	AAdd( aRotInc , { "Importar", "u_STFATP01", 0 , 7} )
	
	Private cCadastro := "Cadastro de Pedido Sato"
	Private cAlias1   := "SZ1"
	Private cAlias2   := "SZ2"
	Private aRotina   := {	{"Pesquisar"   ,"AxPesqui"       ,0,1} ,;
									{"Visualizar"  ,"u_FATIncluir"   ,0,2} ,;
									{"Manutenção"  ,aRotInc          ,0,3} ,;
									{"Alterar"     ,"u_FATIncluir"   ,0,4} ,;
									{"Excluir"     ,"u_FATIncluir"   ,0,5} ,;
									{"Faturar"     ,"u_FATFaturar"   ,0,6} ,;
									{"Legenda"     ,"u_FATLegenda"   ,0,7} }
	
    While u_FATFaturar("SZ1",0,6)
	Enddo
    
Return