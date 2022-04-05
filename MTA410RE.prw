#Include "Protheus.ch"
#Include "TopConn.ch"

Static oBmpVerde    := LoadBitmap( GetResources(), "BR_VERDE")
Static oBmpVermelho := LoadBitmap( GetResources(), "BR_VERMELHO")
Static oBmpPreto    := LoadBitmap( GetResources(), "BR_PRETO")
Static oBmpOK := LoadBitmap(GetResources(),'LBOK')
Static oBmpNO := LoadBitmap(GetResources(),'LBNO') 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³         ³ Autor ³ Bruno Romero          ³ Data ³20/09/2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Pedido de venda ³                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Realizar reserva de itens Automatico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³     Nenhum                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³     Nenhum                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³    MTA410RE                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  Saída do pedido de venda e saida da LIberação de Pedido   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

User Function MTA410RE()

Local aArea := GetArea()
    //Objetos da Janela
    Private oDlg
    Private oMsGetSC6
    Private aColsSC6 := {}
    Private oBtnRes
    Private oBtnFech
    Private oBtnLege
	Private oBtnExc
    //Tamanho da Janela
    Private    nJanLarg    := 700
    Private    nJanAltu    := 500
    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-20)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)
	Private cButton :=    "QPushButton         {background: #35ACCA;" 
			cButton +=                          "border: 1px solid #096A82;"
			cButton +=                          "outline:0; border-radius: 5px;" 
			cButton +=                          "font: normal 12px Arial;" 
			cButton +=                          "padding: 6px;color: #ffffff;}" 
			cButton +=    "QPushButton:pressed {background-color: #3AAECB;"
			cButton +=                          "border-style: inset;" 
			cButton +=                          "border-color: #35ACCA;" 
			cButton +=                          "color: #ffffff; }"
    //Dados do Pedido/Reserva
    Private cPedido		:= SC5->C5_NUM
    Private aOPERACAO  	:= {}
    Private cNUMERO    	:= "" 	
    Private cPRODUTO   	:= ""
    Private cLOCAL     	:= ""
    Private nQUANT     	:= 0
    Private aLOTE      	:= {}
    Private cUserId  	:= RetCodUsr() 
    Private cUserName	:= UsrRetName(cUserId)
    Private _CNOMEPROG	:= FUNNAME()    
    Private lOK			:= .F. 

IF ALLTRIM(_CNOMEPROG) == 'MATA410' .OR. ALLTRIM(_CNOMEPROG) == 'MATA416' 
 
	IF INCLUI = .T. .OR. ALTERA = .T. 

		Processa({|| faCols()}, "Processando")

		DEFINE MSDIALOG oDlg TITLE "Reserva de Produto" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
			
			
			@ 004, 003 SAY "Reserva de"          SIZE 200, 030 FONT oFontSubN OF oDlg COLORS RGB(031,073,125) PIXEL
			@ 014, 003 SAY "Produtos no Estoque" SIZE 200, 030 FONT oFontSubN OF oDlg COLORS RGB(031,073,125) PIXEL
			
			
			@ 006, (nJanLarg/2-001)-(0052*01) BUTTON oBtnRes   PROMPT "Reservar"      SIZE 050, 018 OF oDlg ACTION (fIncReserv())     FONT oFontBtn PIXEL 
			@ 006, (nJanLarg/2-001)-(0052*02) BUTTON oBtnLege  PROMPT "Legenda"      SIZE 050, 018 OF oDlg ACTION (fLegenda())       FONT oFontBtn PIXEL
			@ 006, (nJanLarg/2-001)-(0052*03) BUTTON oBtnFech  PROMPT "Fechar"     SIZE 050, 018 OF oDlg ACTION (oDlg:End())       FONT oFontBtn PIXEL
			@ 006, (nJanLarg/2-001)-(0052*04) BUTTON oBtnExc   PROMPT "Excluir"      SIZE 050, 018 OF oDlg ACTION (fExcReserv())     FONT oFontBtn PIXEL
		oList := TCBrowse():New( 029 , 003, 350, 220,,{ ' ','  ','Item','Produto','Qtd Vend.','Saldo Dispo',;
														'Saldo Lib','Qtd.Entregue','Reservar','Num. Reserva',;
														'Armazem','Endereco','Série','Observacao'			  },;                                                    
														{5,5,15,50,30,30,30,30,30,50,25,40,40,100},;
														oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,{|| fValid()},, ) 
		
		oList:SetArray(aColsSC6) 
			
			
			oList:bLine := {||{     aColsSC6[oList:nAt,01],;
									aColsSC6[oList:nAt,02],; 
									aColsSC6[oList:nAt,03],; 
									aColsSC6[oList:nAt,04],; 
									aColsSC6[oList:nAt,05],;
									aColsSC6[oList:nAt,06],;
									aColsSC6[oList:nAt,07],;
									aColsSC6[oList:nAt,08],;
									aColsSC6[oList:nAt,09],;
									aColsSC6[oList:nAt,10],;
									aColsSC6[oList:nAt,11],;
									aColsSC6[oList:nAt,12],;
									aColsSC6[oList:nAt,13],;
									aColsSC6[oList:nAt,14] } } 
			
			
			oList:bLDblClick :=  {|| CheckField() }
			oList:bHeaderClick := {|o, nCol| oList:GoColumn(1),fClickHead() } 
			oList:lAdjustColSize := .F.
			oList:nScrollType := 0       
			oList:bSeekChange := {|| fValid() }
			
			oBtnRes:SetCss(cButton)

			ACTIVATE MSDIALOG oDlg CENTERED 
	Endif
Endif

RestArea(aArea)

Return

Static Function faCols()

Local aAreaSC6 := SC6->(GETAREA())
Local nTotal := 0
Local nCount := 1
 
    DbSelectArea("SC6")
    DbSetOrder(1)
    DbSeek(xFilial("SC6")+cPedido)

    While  SC6->(!Eof()) .AND. SC6->C6_NUM == cPedido
        nTotal++
        SC6->(DbSkip())
    Enddo

    ProcRegua(nTotal)
    DbSeek(xFilial("SC6")+cPedido)

                 
    While  SC6->(!Eof()) .AND. SC6->C6_NUM == cPedido

        
        IncProc("Adicionando " + Alltrim(SC6->C6_PRODUTO) + " (" + cValToChar(nCount) + " de " + cValToChar(nTotal) + ")...")
        
            cQuerySal	:= " SELECT (B2_QATU-B2_QACLASS-B2_RESERVA)AS SALDOD FROM "+RetSqlName("SB2")+" SB2 "
            cQuerySal	+= " WHERE B2_COD = '"+SC6->C6_PRODUTO+"' AND B2_LOCAL = '"+SC6->C6_LOCAL+"' "
            cQuerySal	+= " AND D_E_L_E_T_ = '' "
            cQuerySal 	:= ChangeQuery (cQuerySal)   

            dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuerySal),'TQSAL',.F.,.T.) 

            AADD(aColsSC6,{oBmpNO,;
                        IIf(TQSAL->SALDOD >=SC6->C6_QTDVEN .AND.  gdFieldGet("C6_QTDLIB",nCount,.T.) == 0 .AND. SC6->C6_QTDENT < SC6->C6_QTDVEN,oBmpVerde,oBmpVermelho),;
                            SC6->C6_ITEM,;		
                            SC6->C6_PRODUTO,;		
                            SC6->C6_QTDVEN,;
                            TQSAL->SALDOD,;     
                            gdFieldGet("C6_QTDLIB",nCount,.T.),;
                            SC6->C6_QTDENT,;
							SC6->C6_QTDVEN,;
							"",;
                            SC6->C6_LOCAL,;
                            SC6->C6_LOCALIZ,;		
                            SC6->C6_NUMSERIE,;
                            SC6->C6_XOBSERV,;
                            })
            	nCount ++

                //Correcao do erro UM em branco
                /*IF  EMPTY(SC6->C6_UM) 
                Reclock("SC6",.F.)
                SC6->C6_UM  := POSICIONE("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_UM") 
                SC6->(MSUNLOCK())  
                Endif */

            TQSAL->(dbCloseArea())       
            SC6->(DbSkip())
    Enddo

RestArea(aAreaSC6)
Return

Static Function CheckField()

Local nLine      := oList:nAt
Local nColumn    := aScan(oList:aHeaders," ")  
Local oChecked   := oList:aArray[nLine,nColumn]
Local nColumnR   := aScan(oList:aHeaders,"Reservar")

    IF  oList:ColPos() == nColumn 
		IF oChecked == oBmpNO 
        	oList:aArray[nLine,nColumn] := oBmpOK
    	Else
        	oList:aArray[nLine,nColumn] := oBmpNO
		EndIf
    EndIf

	IF(oList:ColPos() == nColumnR )
		lEditCell(@aColsSC6,oList,"@R 99999",oList:ColPos())
	Else
		IF oList:ColPos() != nColumn
			alert("Não é possivel editar o campo")
		EndIf
	Endif

    oList:Refresh()

Return

Static Function fLegenda()

Local aLegenda := {}
            
    aAdd(aLegenda, {"BR_VERDE",    "OK"})
    aAdd(aLegenda, {"BR_VERMELHO", "Indisponível"})
     
    BrwLegenda("Grupo de Produtos", "Legenda", aLegenda)

Return

Static Function fClickHead()

Local n 
Local nColumn    := aScan(oList:aHeaders," ") 
Local lCheck     := .T.

    
	    For n := 1 TO Len(aColsSC6)
            IF oList:aArray[n,nColumn] == oBmpNO 
                lCheck := .F.
            Endif   
        Next

		IF lCheck
			For n := 1 TO Len(aColsSC6)            
					oList:aArray[n,nColumn] := oBmpNO             
			Next
		Else
		For n := 1 TO Len(aColsSC6)           
					oList:aArray[n,nColumn] := oBmpOK              
			Next
		EndIf
	

    oList:Refresh()
    
Return

Static function fIncReserv() 

Local n
Local sc6Area := GetArea("SC6")
Local sc0Area := GetArea("SC0") 
 
 			For n := 1 TO Len(aColsSC6)
              						
						If aColsSC6[n][1] == oBmpOK .AND. EMPTY(aColsSC6[n][10])
						   If aColsSC6[n][7] == 0 .AND. aColsSC6[n][8] < aColsSC6[n][5] .AND. aColsSC6[n][6] >= aColsSC6[n][9] .AND. aColsSC6[n][9] > 0
								
								aOPERACAO := {1,"PD",cPedido,AllTrim(cUserName),xFilial("SC6"),AllTrim(aColsSC6[n][14])} 
           						cPRODUTO  := aColsSC6[n][4]
                   				cLOCAL    := aColsSC6[n][11]
                   				nQUANT    := aColsSC6[n][9]
                   			   	aLOTE     := {"","",aColsSC6[n][12],aColsSC6[n][13]}  
                   			   	cNUMERO   := GetSxeNum("SC0","C0_NUM","C0_NUM"+ cEmpAnt)   
                   			    
                   				lOK := A430Reserv(aOPERACAO,cNUMERO,cPRODUTO,cLOCAL,nQUANT,aLOTE)
                   			                   			    
	                   			    IF lOK 
		                              	dbSelectArea("SC6")
		                                dbSetorder(1)
		                                If dbSeek(xFilial("SC6")+cPedido+aColsSC6[n][3]+aColsSC6[n][4])
		                                		Reclock("SC6",.F.)
							       				SC6->C6_RESERVA := cNUMERO 
							       				SC6->C6_QTDRESE	:= nQUANT	    
							    		   		SC6->(MsUnlock())					    			
							    	   	ENDIF    
							    	   	
							    		ConfirmSx8() 
							    			
							    		dbSelectArea("SC0")
							    		dbSetOrder(1)//C0_FILIAL, C0_NUM, C0_PRODUTO, C0_LOCAL, R_E_C_N_O_, D_E_L_E_T_
							    		IF dbSeek(xFilial("SC0")+cNUMERO+cPRODUTO+cLOCAL)
							    				Reclock("SC0",.F.)
							    				SC0->C0_QUANT  := 0
							    			    SC0->C0_QTDPED := nQUANT 
							    			    SC0->(MsUnlock())
						    			ENDIF 
										aColsSC6[n][10]:=cNUMERO

						    		ELSE
						    		
						    		RollbackSx8()
						    			
						    		ENDIF
						   Endif

	   					Endif

			 Next

		MSGINFO( "Verifique no Campo 'Num. Reserva' os itens reservados e suas respectivas reservas.","Info")
		oList:Refresh()
RestArea(sc6Area)
RestArea(sc0Area)	

Return  

Static Function fExcReserv()
	
Local aOPERACAO	
Local cPRODUTO
Local cLOCAL
Local nQUANT
Local aLOTE	
Local cNUMERO	
Local aAreaSC0 := SC0->(GetArea())
Local aAreaSC6 := SC6->(GetArea())			
Local lOK	:= .F.			
Local nL := oList:nRowPos			


	If  !EMPTY(aColsSC6[nL][10]) 
		DbSelectArea("SC0")
   		SC0->(DbSetOrder(1))
   		
		   IF!SC0->(DbSeek(xFilial("SC0")+aColsSC6[nL][10]+aColsSC6[nL][4]))
      			MSGINFO("Nao localizado o item para excluir","Info")
      			lOk:=.F.
      			Return lOk
   			EndIf

			aOPERACAO := {3,"PD",cPedido,AllTrim(cUserName),xFilial("SC6"),AllTrim(aColsSC6[nL][14])} 
			cPRODUTO  := aColsSC6[nL][4]
			cLOCAL    := aColsSC6[nL][11]
			nQUANT    := aColsSC6[nL][9]
			aLOTE     := {"","",aColsSC6[nL][12],aColsSC6[nL][13]}  
			cNUMERO   := aColsSC6[nL][10]

		lOk := a430Reserv(aOPERACAO,cNUMERO,cPRODUTO,cLOCAL,nQUANT,aLOTE)

		If lOK

			dbSelectArea("SC6")
			dbSetorder(1)
			If dbSeek(xFilial("SC6")+cPedido+aColsSC6[n][3]+aColsSC6[n][4])
					Reclock("SC6",.F.)
					SC6->C6_RESERVA := "" 
					SC6->C6_QTDRESE	:= 0	    
					SC6->(MsUnlock())					    			
			ENDIF  
			MSGINFO("Reserva "+aColsSC6[nL][10]+" excluída com sucesso ","Excluído!")
			aColsSC6[nL][10] := ""
		Else
			MSGINFO("Reserva "+aColsSC6[nL][10]+" NÂO foi excluída","")
		Endif

  Endif
oList:Refresh()
RestArea(aAreaSC6)
RestArea(aAreaSC0)
Return

Static Function fValid()
Local nL := oList:nRowPos 
Local nC := aScan(oList:aHeaders,"Reservar")

	IF aColsSC6[nL][nC] > aColsSC6[nL][5]
		alert("Quantidade de reserva não pode ser maior que a quantidade vendido")
		aColsSC6[nL][nC] := 0
		oList:Refresh()		
	Endif
	
Return

