#include "Rptdef.CH"
#include "FWPrintSetup.ch"
#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "Tbiconn.ch"
/*_________________________________________________________________________________
* ��������������������������������������������������������������������������������*
* +------------+--------------------+--------------------+----------------------+�*
* � Program    � MA650BUT           � Author             � Matheus Vin�cius     ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Description� Adiciona op��es no aRotina de Ordem de Produ��o                ��*
* +------------+--------------------+--------------------+----------------------+�*
* � Date       � 12/12/2019         � Last Modified time �  12/12/2019          ��*
* +------------+--------------------+--------------------+----------------------+�*
�����������������������������������������������������������������������������������
���������������������������������������������������������������������������������*/

User Function MA650BUT()
//N�o declarar o array aRotina
    //Adiciona um novo item no menu principal do MATA650
    aAdd(aRotina,{'Imprimir Etq.','u_SAESTR02()',0,5 })
    aAdd(aRotina,{'Imprimir OP.' ,'u_SAESTR04()',0,5 })
Return aRotina