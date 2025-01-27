#Include "totvs.ch"

user function MTA110MNU
aAdd(aRotina,{ "Impr SC Customizado", "u_X110Impri", 0 , 2, 0, .F.})
Return



user Function X110Impri( cAlias, nRecno, nOpc )
Local xRet     := .T.

xRet := u_xMatr140( cAlias, nRecno, nOpc )

dbSelectArea("SC1")

//Restaura o pergunte do MATA110
Pergunte("MTA110",.F.)

Return( xRet )
