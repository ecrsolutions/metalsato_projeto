#include "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � PDSISE02 � Autor � Marcel R. Grosselli   � Data � 07/02/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecBlock para converter a linha digit�vel da Concecion�ria���
���          � em c�digo de barras.                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CNAB A PAGAR                                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/    
USER FUNCTION PDSISE02(cCodconc)
SETPRVT("cStr,cFgts")

cStr := ""          

cStr := ALLTRIM(M->E2_LINDIG)

IF VALTYPE(cStr) == NIL .OR. EMPTY(cStr)
	// Se o Campo est� em Branco n�o Converte nada.
	cStr := ""
ELSE
    cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
ENDIF   

RETURN(cStr)
                                                                             
    
