#INCLUDE "PROTHEUS.CH
#INCLUDE "TOTVS.CH   


User Function MASC5()
	Local aAreaSC5 := SC5->(GetArea()) 

	SC5->(DbSelectArea("SC5"))
	SC5->(DbSetOrder(10))
		
		IF SC5->(DbSeek(xFilial("SC5")+M->C5_CLIENTE+M->C5_LOJACLI+M->C5_XPEDCLI))
			MsgInfo("Registro Já Existe ") 
		ELSE
			MsgInfo("Registro NÃO Existe ")      		
		End if         	
				
	RestArea(aAreaSC5) 

Return 


