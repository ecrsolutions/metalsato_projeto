#INCLUDE "protheus.ch"
#include "totvs.ch"


User Function GQREENTR()

    Local cTesRetBe := SuperGetMV('MV_XRETBEN',.F.,'033')

    If SF4->F4_CODIGO $ cTesRetBe .And. Type("aOPBenef") == "A" .And. !Empty(aOPBenef) .And. l103Class
        aOPBenef := {}
    EndIF

Return .T.
