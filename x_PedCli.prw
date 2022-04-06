#include 'protheus.ch'
#include 'parmtype.ch'

user function x_PedCli()

Local aArea    	:= GetArea()
Local aAreaSC5 	:= SC5->(GetArea())
Local lRet 		:= .T.
Local cCampo 	:= ReadVar() 
Local cPedCli	:= &(cCampo) 
Local cCliente	:= M->C5_CLIENTE
Local cLoja    	:= M->C5_LOJACLI
Local cNum		:= M->C5_NUM
     
DbSelectArea("SC5") 
SC5->(DbSetOrder(6)) 
	
	If !Empty(ALLTRIM(cPedCli)) 
		If SC5->(msSeek(xFilial("SC5") + cCliente + cLoja + cPedCli)) .AND. cNum <> SC5->C5_NUM
			MsgInfo("Cotação informada já existe no pedido: " + SC5->C5_NUM)
			lRet := .F.
    	EndIf
    EndIf

RestArea(aAreaSC5)
RestArea(aArea)

Return lRet
