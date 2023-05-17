#INCLUDE "rwmake.ch"

/*_____________________________________________________________________________________
¦ Função    ¦ PDSISE01   ¦ Autor ¦ Microsiga                ¦ Data ¦ 09/04/2019        ¦
+-----------+------------+-------+---------------------------------+------+------------+
¦ Descriçäo ¦ Converte a Linha Digitável em Código de Barras  U_PDSISE01()             ¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

user function PDSISE01()
 
    cCodbar :=""  
                                                                             
    cBanco := Substr(M->E2_LINDIG,1,4)
    cCampFree := Substr(M->E2_LINDIG,5,5)+Substr(M->E2_LINDIG,11,10)+Substr(M->E2_LINDIG,22,10)
    cDigCamp := Substr(M->E2_LINDIG,33,1)  
    cRetSisp3 := Substr(M->E2_LINDIG,34,4)
    cValCamp := Substr(M->E2_LINDIG,38,10)
    
    cCodbar := alltrim(cBanco)+alltrim(cDigCamp)+alltrim(cRetSisp3)+alltrim(cValCamp)+alltrim(cCampFree)
            
    if !EMPTY(cCodbar)
       if	!VldCodBar(cCodbar)
       		cCodbar :="" 
       endif
    endif
                                                                  
return cCodbar
