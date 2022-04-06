#INCLUDE "RWMAKE.CH"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

USER FUNCTION AT460GRV()
LOCAL aAB8Atu := {}
LOCAL nDesCli := POSICIONE("SA1",1,XFILIAL("SA1")+AB9->AB9_CODCLI+AB9->AB9_LOJA,"A1_XDESC")
Local cNumorc   := AB9->AB9_NUMORC
Local cNumos    := AB9->AB9_NUMOS
Local cNumItem  := RIGHT(cNumos,2)
Local nZ        := 0
Local ni		:= 0
Local aAreaAB5	:= AB5->(GetArea())
Local aAreaABA	:= ABA->(GetArea())
Local aAreaAB8  := AB8->(GetArea())

LOCAL nVend	  := POSICIONE("SA1",1,XFILIAL("SA1")+AB9->AB9_CODCLI+AB9->AB9_LOJA,"A1_VEND")
LOCAL nTpFret := POSICIONE("SA1",1,XFILIAL("SA1")+AB9->AB9_CODCLI+AB9->AB9_LOJA,"A1_TPFRET")

DbselectArea("AB3")
Dbsetorder (1)
If Dbseek(xFilial("AB3")+AB9->AB9_NUMORC)
	AB3->AB3_VEND1 := nVend
	AB3->AB3_TPFRET:= nTpFret
   ENDIF

ABA->(DbSetOrder(1))
ABA->(DbSeek(xFilial("ABA")+AB9->AB9_NUMOS+AB9->AB9_CODTEC+AB9->AB9_SEQ))
AB5->(DBSETORDER(1))
	IF AB5->(DBSEEK(XFILIAL("AB5")+AB9->AB9_NUMORC))
		WHILE AB5->(!EOF()) .AND. AB5->AB5_NUMORC = AB9->AB9_NUMORC
			IF nDesCli > 0
				RECLOCK("AB5",.F.)
				AB5->AB5_VUNIT  := AB5->AB5_VUNIT  - ((AB5->AB5_VUNIT  / 100) * nDesCli)
				AB5->AB5_TOTAL  := AB5->AB5_VUNIT * AB5->AB5_QUANT
				AB5->AB5_PRCLIS := AB5->AB5_VUNIT
				MSUNLOCK()
			ENDIF
			IF AB5->AB5_CODSER == "000014"
				AB5->AB5_XPRZ	:= "90"
				AB5->AB5_XOBS	:= Trim("IMPORT")
			ENDIF
			IF !EMPTY(ABA->ABA_SUBOS)
			AADD(aAB8Atu,{			AB9->AB9_NUMOS		,;//1-Nr. OS
									ABA->ABA_SUBOS		,;//2-SUbitem
									AB5->AB5_VUNIT		,;//3-Valor unitario
									AB5->AB5_TOTAL		,;//4-valor total
									AB5->AB5_PRCLIS		,;//5-preco lista
									AB5->AB5_FILIAL		,;//6-filial
									AB5->AB5_NUMORC     ,;//7-Nr. Orcamento
									AB5->AB5_ITEM       ,;//8-Item		
									AB5->AB5_CODPRO     ,;//9-Codigo produto
									AB5->AB5_DESPROD    ,;//10-Descricao
									AB5->AB5_CODSER     ,;//11-Servico
									AB5->AB5_QUANT      ,;//12-quantidade
									AB5->AB5_XDESCO     ,;//13-perc. desconto
									AB5->AB5_XVALDE     ,;//14-valor desconto
									AB5->AB5_XPRZ       ,;//15-Prazo
									AB5->AB5_XOBS 		})//16-Observacao
			ENDIF
			AB5->(DBSKIP())
			ABA->(DBSKIP())
		ENDDO
	ENDIF
	IF LEN(aAB8Atu) > 0
	FOR ni := 1 TO LEN(aAB8Atu)
			AB8->(DBSETORDER(1))
			IF AB8->(DBSEEK(XFILIAL("AB8")+aAB8Atu[ni,1]+aAB8Atu[ni,2]))
				RECLOCK("AB8",.F.)
				AB8->AB8_VUNIT  := aAB8Atu[ni,3]
				AB8->AB8_TOTAL  := aAB8Atu[ni,4]
				AB8->AB8_PRCLIS := aAB8Atu[ni,5]
				MSUNLOCK()
			ENDIF
		NEXT ni
	ENDIF
	IF ALTERA
		DbselectArea("AB5")
		DbsetOrder(1)
		DBGOTOP()
		DbSeek(xFilial("AB5")+cNumorc+cNumItem)
			While !AB5->(EOF()) .AND. AB5->AB5_NUMORC == cNumorc
				RecLock("AB5",.F.)
					AB5->(DbDELETE())
				AB5->(MSUNLOCK())
				AB5->(DBSKIP())
			ENDDO
			FOR nZ:= 1 TO Len(aAB8Atu)
				RecLock("AB5",.T.)
					AB5->AB5_FILIAL     := aAB8Atu[nZ,6]
					AB5->AB5_NUMORC     := aAB8Atu[nZ,7]
					AB5->AB5_ITEM       := aAB8Atu[nZ,8]
					AB5->AB5_SUBITE     := IIF(LEN(ALLTRIM(aAB8Atu[nZ,2]))>2,RIGHT(aAB8Atu[nZ,2],2),ALLTRIM(aAB8Atu[nZ,2]))
					AB5->AB5_CODPRO     := aAB8Atu[nZ,9]
					AB5->AB5_DESPROD    := aAB8Atu[nZ,10]
					AB5->AB5_CODSER     := aAB8Atu[nZ,11]
					AB5->AB5_QUANT      := aAB8Atu[nZ,12]
					AB5->AB5_PRCLIS     := aAB8Atu[nZ,5]
					AB5->AB5_VUNIT      := aAB8Atu[nZ,3]
					AB5->AB5_TOTAL      := aAB8Atu[nZ,4]
					AB5->AB5_XDESCO     := aAB8Atu[nZ,13]
					AB5->AB5_XVALDE     := aAB8Atu[nZ,14]
					AB5->AB5_XPRZ       := aAB8Atu[nZ,15]
					AB5->AB5_XOBS		:= aAB8Atu[nZ,16]
					AB5->(MsUnlock())
			Next nZ
	ENDIF
RestArea(aAreaAB5)
RestArea(aAreaABA)
RestArea(aAreaAB8)
RETURN()
