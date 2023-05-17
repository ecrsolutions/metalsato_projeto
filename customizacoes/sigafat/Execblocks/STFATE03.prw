#Include "Rwmake.ch"

/*_______________________________________________________________________________
���������������������������������������������������������������������������������
��+-----------+------------+-------+----------------------+------+------------+��
��� Programa  � STFATE03   � Autor � Ronilton O. Barros   � Data � 06/01/2020 ���
��+-----------+------------+-------+----------------------+------+------------+��
��� Descri��o � Rotina que armazena os pedidos de venda de beneficiamento     ���
��+-----------+---------------------------------------------------------------+��
���������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
User Function STFATE03(aPedidos)
   Static aRet := Nil

   If aPedidos <> Nil
      aRet := aClone(aPedidos)
   Endif

Return aRet