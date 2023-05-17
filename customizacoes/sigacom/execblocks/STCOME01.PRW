USER FUNCTION STCOME01(cCodigo,cCusto,cConta, cTES)

cGrupo := ""
cTipoC := ""
cF4Est := ""

if !Empty(cTES)
 DBSELECTAREA("SF4")
 dbsetorder(1)
 dbseek(XFILIAL("SF4")+cTES)

cF4Est := SF4->F4_ESTOQUE

Endif

IF cF4Est == "S"

    cConta :=SB1->B1_CONTA

RETURN cConta

ElseIF !Empty(cCusto) 

 DBSELECTAREA("SB1")
 dbsetorder(1)
 dbseek(XFILIAL("SB1")+cCodigo)

 cGrupo := SB1->B1_GRUPO 

 DBSELECTAREA("SBM")
 dbsetorder(1)
 dbseek(XFILIAL("SBM")+cGrupo)

 DBSELECTAREA("CTT")
 dbsetorder(1)
 dbseek(XFILIAL("CTT")+cCusto)
  
 cTipoC := CTT->CTT_TIPO00


   IF cTipoC == "01"  
      cConta := SBM->BM_CTACCD

   elseif cTipoC == "02"
      cConta := SBM->BM_CTACDF

   else 
      cConta := SBM->BM_CTADGA

   endif

endif 

return cConta


