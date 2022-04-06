#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

USER FUNCTION AT450OKA()

Local vArea     := GetArea()
Local aAreaAB5	:= AB5->(GetArea())
Local aAreaABA	:= ABA->(GetArea())
Local aAreaAB8  := AB8->(GetArea())
Local Status    := .T.
Local aStruct   := {}
Local cOS       := AB6->AB6_NUMOS
Local aArquiOS  := {}
Local nY        := 1
Local nX        := 1
Local cMens     := ""
Local cMensOrc  := ""
Local cMensAO   := ""
Local cAtenOS   := ""
Local cOrc      := "" 
Local cUltNum   := ""
If FunName() == "TECA450" 
    If ALTERA = .T. 
        AADD(aStruct,{"OS"               ,"C",8 ,0})
        AADD(aStruct,{"Item"             ,"C",2 ,0})
        AADD(aStruct,{"SubItem"          ,"C",6 ,0})
        AADD(aStruct,{"Produto"          ,"C",20,0})
        AADD(aStruct,{"Descricao"        ,"C",30,0})
        AADD(aStruct,{"Servico"          ,"C",6 ,0})
        AADD(aStruct,{"Quantidade"       ,"N",12,2})
        AADD(aStruct,{"ValorUnit"        ,"N",12,2})
        AADD(aStruct,{"ValorTot"         ,"N",12,2})
        AADD(aStruct,{"PrecoList"        ,"N",12,2})
        AADD(aStruct,{"Armazem"          ,"C",2 ,0})
        AADD(aStruct,{"PercDesc"         ,"N",8 ,2})
        AADD(aStruct,{"ValorDesc"        ,"N",8 ,2})
        AADD(aStruct,{"Tecnico"          ,"C",14,0})
        AADD(aStruct,{"Seq"              ,"C",2 ,0})
        AADD(aStruct,{"Orcamento"        ,"C",6 ,0})
        AADD(aStruct,{"STATUSDEL"        ,"C",1 ,0})
        
        aArquiOS := CriaTrab(aStruct,.T.)
        DbUseArea(.T.,,aArquiOS,"TTRC")

        FOR nX := 1 TO LEN(aColsAB8)
            FOR nY:= 1 TO LEN(aColsAB8[nX])
                If !EMPTY(LEN(aColsAB8))
                    Reclock("TTRC",.T.)
                        TTRC->OS        := Alltrim(cOS+aColsAB8[nX][nY][1])
                        TTRC->Item      := aColsAB8[nX][nY][1]
                        TTRC->SubItem   := aColsAB8[nX][nY][2]
                        TTRC->Produto   := aColsAB8[nX][nY][3]
                        TTRC->Descricao := aColsAB8[nX][nY][4]
                        TTRC->Servico   := aColsAB8[nX][nY][5]
                        TTRC->Quantidade:= aColsAB8[nX][nY][6]
                        TTRC->ValorUnit := aColsAB8[nX][nY][7]
                        TTRC->ValorTot  := aColsAB8[nX][nY][8]
                        TTRC->PrecoList := aColsAB8[nX][nY][11]
                        TTRC->Armazem   := aColsAB8[nX][nY][13]
                        TTRC->PercDesc  := aColsAB8[nX][nY][15]                            
                        TTRC->ValorDesc := aColsAB8[nX][nY][16]
                        TTRC->Tecnico   := Posicione("AB9",1,xFilial("AB9")+cOS+aColsAB8[nX][nY][1],"AB9_CODTEC")
                        TTRC->Seq       := Posicione("AB9",1,xFilial("AB9")+cOS+aColsAB8[nX][nY][1],"AB9_SEQ")
                        If !EMPTY(AB7->AB7_NUMORC)
                        TTRC->Orcamento := left(AB7->AB7_NUMORC,6)
                        Else
                        TTRC->Orcamento := Posicione("AB9",1,xFilial("AB9")+cOS+aColsAB8[nX][nY][1],"AB9_NUMORC")                                    
                        Endif
                        If aColsAB8[nX][nY][20]
                            TTRC->STATUSDEL := "T" 
                        Else
                            TTRC->STATUSDEL :=  "F"
                        Endif
                    MsUnlock()
                Endif
            Next nY
        Next nX
        If !EMPTY(TTRC->(LASTREC()))
            DbCreateIndex("IndTemp","OS+Item+SubItem+Produto ",{|| OS+Item+SubItem+Produto })
            dbSetIndex("IndTemp")
        Endif
        ABA->(DbSetOrder(6))
        AB5->(DbSetOrder(1)) 
        DbSelectArea("TTRC")
        DbGoTop()
            While TTRC->(!EOF())
                IF !EMPTY(TTRC->Seq)
                    If ABA->(Dbseek(xFilial("ABA")+TTRC->OS+TTRC->Tecnico+TTRC->Seq+TTRC->SubItem)) 
                        If      TTRC->STATUSDEL ==  "F"
                                RecLock("ABA",.F.)
                                    ABA->ABA_CODPRO     := TTRC->Produto
                                    ABA->ABA_DESCRI     := TTRC->Descricao
                                    ABA->ABA_QUANT      := TTRC->Quantidade
                                    ABA->ABA_LOCAL      := TTRC->Armazem
                                    ABA->ABA_CODSER     := TTRC->Servico
                                ABA->(MsUnlock())
                        Elseif  TTRC->STATUSDEL == "T"
                                Reclock("ABA",.F.)
                                    ABA->(DbDelete())
                                ABA->(MsUnlock())
                        Endif
                    Elseif TTRC->STATUSDEL ==  "F" 
                        cUltNum := NUMIT(xFilial("ABA"),TTRC->OS,TTRC->Tecnico,TTRC->Seq)
                        Reclock("ABA",.T.)
                            ABA->ABA_FILIAL := xFilial("ABA")
                            ABA->ABA_ITEM   := StrZero(Val(SOMASTR(cUltNum,"01")),2,0)  
                            ABA->ABA_CODPRO := TTRC->Produto
                            ABA->ABA_QUANT  := TTRC->Quantidade
                            ABA->ABA_LOCAL  := TTRC->Armazem
                            ABA->ABA_CODSER := TTRC->Servico
                            ABA->ABA_NUMOS  := TTRC->OS                                    
                            ABA->ABA_CODTEC := TTRC->Tecnico
                            ABA->ABA_SEQ    := TTRC->Seq
                            ABA->ABA_SUBOS  := TTRC->SubItem
                            ABA->ABA_DESCRI := TTRC->Descricao
                        ABA->(MsUnlock())
                    Endif
                    If  TTRC->OS != cAtenOS
                        cAtenOS := TTRC->OS
                        cMensAO   += " Atendimento da O.S. "+cAtenOS+" para o item "+TTRC->Item+" foi atualizado. "+CHR(13)
                    Endif
                Else
                    If  TTRC->OS != cAtenOS
                        cAtenOS := TTRC->OS
                        cMensAO   += " Não possui atendimento da O.S. para a Ordem de serviço "+TTRC->OS+" Item "+TTRC->Item+CHR(13)
                    Endif    
                Endif
                AB5->(DbsetOrder(1))
                IF !EMPTY(TTRC->Orcamento)                           
                    IF AB5->(DbsEEK(xFilial("AB5")+TTRC->Orcamento+TTRC->Item+IIF(LEN(ALLTRIM(TTRC->SubItem))>2,SUBSTR(ALLTRIM(TTRC->SubItem),5,2),TTRC->SubItem)))//AB5_FILIAL, AB5_NUMORC, AB5_ITEM, AB5_SUBITE, R_E_C_N_O_, D_E_L_E_T_ 
                        IF  TTRC->STATUSDEL ==  "F"
                            RecLock("AB5",.F.)
                            AB5->AB5_CODPRO     := TTRC->Produto
                            AB5->AB5_DESPROD    := TTRC->Descricao
                            AB5->AB5_CODSER     := TTRC->Servico
                            AB5->AB5_QUANT      := TTRC->Quantidade
                            AB5->AB5_VUNIT      := TTRC->ValorUnit
                            AB5->AB5_TOTAL      := TTRC->ValorTot
                            AB5->AB5_PRCLIS     := TTRC->PrecoList
                            AB5->AB5_XDESCO     := TTRC->PercDesc
                            AB5->AB5_XVALDE     := TTRC->ValorDesc
                            AB5->(MsUnlock())
                        Elseif  TTRC->STATUSDEL == "T"
                            RecLock("AB5",.F.)
                                AB5->(DbDelete())
                            AB5->(MsUnlock())
                        Endif
                    Elseif TTRC->STATUSDEL ==  "F"    
                            RecLock("AB5",.T.)
                            AB5->AB5_FILIAL     := xFilial("AB5")
                            AB5->AB5_NUMORC     := TTRC->Orcamento                                
                            AB5->AB5_ITEM       := TTRC->Item
                            AB5->AB5_SUBITE     := IIF(LEN(ALLTRIM(TTRC->SubItem))>2,SUBSTR(ALLTRIM(TTRC->SubItem),5,2),TTRC->SubItem)
                            AB5->AB5_CODPRO     := TTRC->Produto
                            AB5->AB5_DESPROD    := TTRC->Descricao
                            AB5->AB5_CODSER     := TTRC->Servico
                            AB5->AB5_QUANT      := TTRC->Quantidade
                            AB5->AB5_VUNIT      := TTRC->ValorUnit
                            AB5->AB5_TOTAL      := TTRC->ValorTot
                            AB5->AB5_PRCLIS     := TTRC->PrecoList
                            AB5->AB5_XDESCO     := TTRC->PercDesc
                            AB5->AB5_XVALDE     := TTRC->ValorDesc
                            AB5->AB5_XPRZ       := "07"
                            AB5->(MsUnlock())
                    Endif
                    IF TTRC->Orcamento != cOrc
                        cOrc := TTRC->Orcamento
                        cMensOrc   += " Orcamento "+TTRC->Orcamento+" foi atualizado para o item "+TTRC->Item+CHR(13)
                    Endif
                Else
                    IF TTRC->Orcamento != cOrc
                        cOrc := TTRC->Orcamento
                        cMensOrc   += " Não tem Orçamento para esta Ordem de serviço "+TTRC->OS+" Item "+TTRC->Item+CHR(13)
                    Endif
                Endif
            TTRC->(DbSkip())
            Enddo
        TTRC->(dbcloseArea())
        cMens := cMensAO+cMensOrc    
        
    Endif
Endif
RestArea(aAreaAB5)
RestArea(aAreaABA)
RestArea(aAreaAB8)
RestArea(vArea)
Return Status

STATIC FUNCTION NUMIT(FIL,OS,TEC,SEQ)
LOCAL   aArea  := ABA->(GETAREA())
LOCAL   cNUM   := ""
DbSelectArea("ABA")
DbSetOrder(6)
Dbseek(FIL+OS+TEC+SEQ)
    WHILE ABA->(!EOF()) .AND. ABA->ABA_NUMOS = OS .AND. ABA_CODTEC = TEC .AND. ABA_SEQ = SEQ
        IF cNUM < ABA->ABA_ITEM
            cNUM := ABA->ABA_ITEM
        Endif
        ABA->(DbSkip())
    Enddo
RestArea(aArea)
RETURN cNUM
