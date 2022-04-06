#INCLUDE "RWMAKE.CH"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#DEFINE NUMITENS 999

USER FUNCTION AT400F4()
LOCAL oDlg												
LOCAL oGetF4											
LOCAL oSay1												
LOCAL oSay2												
LOCAL oSay3												
LOCAL nOpcA     := 0										
LOCAL aArea     := { Alias(), IndexOrd() , Recno() }	
Local aAreaAB5	:= AB5->(GetArea())
Local aAreaABA	:= ABA->(GetArea())
Local aAreaAB8  := AB8->(GetArea())
LOCAL aSavAcols := {}									
LOCAL nSavN		:= 0									
LOCAL aAux		:= {} 								
LOCAL bSetKey											
LOCAL cPrompt   := "APONTAMENTOS COM REGRAS DE DESCONTO" 
LOCAL nCntFor   := 0										
LOCAL nUsado    := Len(aHeaderAB5)						
LOCAL nPosItem  := aScan(aHeaderAB5,{|x| AllTrim(x[2])=="AB5_SUBITE"})		
LOCAL nPosPrd   := aScan(aHeaderAB4,{|x| AllTrim(x[2])=="AB4_CODPRO"})		
LOCAL nPosNSer  := aScan(aHeaderAB4,{|x| AllTrim(x[2])=="AB4_NUMSER"})		
LOCAL nItAcols  := If(Type("N")=="U",1,N)									
LOCAL cProduto  := ""									
LOCAL cNumSer   := "" 									
LOCAL lAltera   := .F.									
LOCAL lInclui   := .F. 									
LOCAL lRetorno  := .T.     								
LOCAL aAlter    := {"AB5_CODPRO","AB5_QUANT","AB5_VUNIT","AB5_XDESCO","AB5_XVALDE","AB5_PRCLIS","AB5_XPRZ","AB5_XOBS","AB5_CODSER","AB5_OPER"} 
LOCAL nRecAB4   := 0
LOCAL aBotao    := {}
LOCAL nDesCli   := M->AB3_XDESC
Local cNumOs    := ""
Local cUltNum   := ""
Local nx	    := 0	
PRIVATE aColsMain 										
PRIVATE nMAIN   := nItAcols								


AADD(aBotao,{"Impostos",{|| AT400Impos()},"Imposto..","Imposto" })

IF aRotina[ nOpcF4, 4 ] == 3
	lInclui := .T.
ELSEIF aRotina[ nOpcF4, 4 ] == 4
	lAltera := .T.
ENDIF


nRecAB4 := aCols[n,8]
aSavAcols	:= aClone(aCols)
aColsMain   := aClone(aCols)
nSavN		:= nItAcols
cNumSer		:= aSavaCols[nItAcols][nPosNSer]
aHeader		:= aClone(aHeaderAB5)
IF ( EMPTY(aColsAB5) .OR. LEN(aColsAB5)<=nItAcols )
	aadd(aAux,Array(nUsado+1))
	FOR nCntFor := 1 TO nUsado
		IF IsHeadRec(aHeaderAB5[nCntFor][2])
			aAux[1][nCntFor] := 0
		ELSEIF IsHeadAlias(aHeaderAB5[nCntFor][2])
			aAux[1][nCntFor] := "AB5"
		ELSE
			aAux[1][nCntFor] := CriaVar(aHeaderAB5[nCntFor][2],.T.)
		ENDIF
	NEXT nCntFor
	aAux[1][nUsado+1] := .F.
	aAux[1][nPosItem] := "01"
	FOR nCntFor := LEN(aColsAB5)+1 TO ( nItAcols )
		aadd(aColsAB5,aClone(aAux))
	NEXT nCntFor
ENDIF

aCols	:= aClone(aColsAB5[nItAcols])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Registros                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSELECTAREA("SA1")
dbSetOrder(1)
DbSeek(xFilial("SA1")+M->AB3_CODCLI+M->AB3_LOJA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza picture ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cPictureTot	:= PesqPict("AB5","AB5_TOTAL",14,M->AB3_MOEDA)

IF Type("lAt400Auto")=="U" .OR. !lAt400Auto
	bSetKey  := SetKey(VK_F4,)

	SetKey(VK_F4,{ ||  AT400F41(SB1->B1_COD)})  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a GetDados                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE cPrompt From 10,0 to 30,80
	@ 016,04 SAY RetTitle("AB3_CODCLI")+" "+M->AB3_CODCLI+"-"+M->AB3_LOJA+"/"+SA1->A1_NOME PIXEL
	@ 026,04 SAY RetTitle("AB4_CODPRO")+" "+cProduto+RetTitle("AB4_NUMSER")+" "+cNumSer PIXEL
	oGetF4 := MsGetDados():New(39,4,125,313,nOpcF4,"At400F4LOk","AllwaysTrue","+AB5_SUBITE",.T.,aAlter,NIL,NIL,NUMITENS,"U_AtValIt()")
	@ 128,005 SAY "Total: " SIZE 60,09 OF oDlg PIXEL //"Total: "
	@ 128,065 SAY oSay1 PROMPT 0 PICTURE cPictureTot SIZE 40,09 OF oDlg PIXEL
	@ 128,105 SAY "Total do Cliente: " SIZE 60,09 OF oDlg PIXEL //"Total do Cliente: "
	@ 128,165 SAY oSay2 PROMPT 0 PICTURE cPictureTot SIZE 40,09 OF oDlg PIXEL
	@ 128,205 SAY "Total do Fabricante: " SIZE 60,09 OF oDlg PIXEL //"Total do Fabricante: "
	@ 128,265 SAY oSay3 PROMPT 0 PICTURE cPictureTot SIZE 40,09 OF oDlg PIXEL
	oDlg:Cargo  := {|n1,n2,n3| oSay1:SetText(n1),;
	oSay2:SetText(n2),;
	oSay3:SetText(n3) }
	At400Total(oDlg,.T.)
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,if(oGetF4:TudoOk(),oDlg:End(),nOpca:=0)},{||oDlg:End()},,@aBotao)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Volta a situacao anterior                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(VK_F4,Nil)
	SetKey(VK_F4,bSetKey)
	
	IF ( nOpcA == 1 ) .AND. ( lAltera .OR. lInclui )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada apos a confirmacao do apontamento                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ExistBlock( "AT400APN" )
			ExecBlock( "AT400APN", .F., .F. )
		ENDIF
		aColsAB5[nItAcols] := aClone(aCols)

		ABA->(DbSetOrder(6))
		AB8->(DbSetOrder(1)) 
		AB4->(DBGOTO(nRecAB4))
		IF AB4->AB4_TIPO == "2" 
			cNumOs := AB4->AB4_NUMOS
		ELSEIF AB4->AB4_TIPO == "1"
			cNumOs := AB4->AB4_OSORIG
		ENDIF
		PRIVATE cTecnico := Posicione("AB9",1,xFilial("AB9")+cNumOs,"AB9_CODTEC")
		PRIVATE cSeq	 := Posicione("AB9",1,xFilial("AB9")+cNumOs,"AB9_SEQ")
		PRIVATE nAbaVal	 := 0
		Private nAb8Val	 := 0

		If !EMPTY(cNumOs)
		FOR nx := 1 TO LEN(aCols)
			IF AB8->(DBSEEK(XFILIAL("AB8")+cNumOs+aCols[nx,1]))
				nAb8Val := 2
			ElseIf AB8->(DBSEEK(XFILIAL("AB8")+cNumOs+StrZero(val(aCols[nx,1]),6,0)))
				nAb8Val := 6
			EndIf
			IF ABA->(Dbseek(xFilial("ABA")+cNumOs+cTecnico+cSeq+aCols[nx,1])) 
				nAbaVal := 2
			ElseIF ABA->(Dbseek(xFilial("ABA")+cNumOs+cTecnico+cSeq+StrZero(val(aCols[nx,1]),6,0))) 
				nAbaVal := 6
			EndIf
			AB8->(DBSETORDER(1))
			IF AB8->(DBSEEK(XFILIAL("AB8")+cNumOs+IIF(nAb8Val >2,StrZero(val(aCols[nx,1]),6,0),aCols[nx,1]))) 
				If !aCols[nx,18]
					RECLOCK("AB8",.F.)
						AB8->AB8_CODPRO	:= aCols[nx,2] 	 //codigo
						AB8->AB8_DESPRO	:= aCols[nx,3]   //descricao
						AB8->AB8_CODSER	:= aCols[nx,4]	 //sesrvcio
						AB8->AB8_QUANT  := aCols[nx,5]   // Quantidade
						AB8->AB8_VUNIT  := aCols[nx,6]   // Preço Unitário
						AB8->AB8_TOTAL  := aCols[nx,7]   // Valor Total
						AB8->AB8_PRCLIS := aCols[nx,8]   // Preço de Lista
						AB8->AB8_XDESCO := aCols[nx,9]   // % de Desconto
						AB8->AB8_XVALDE := aCols[nx,10]  // Valor do Desconto
						AB8->AB8_XST    := aCols[nx,14]  // Possui ST. SIM / NAO
					MSUNLOCK()
				Else 
					RECLOCK("AB8",.F.)
					 AB8->(DbDeleTe())
					MSUNLOCK()
				EndIf
			elseif !aCols[nx,18]
					RECLOCK("AB8",.T.)
						AB8->AB8_FILIAL	:= xFilial("AB8")
						AB8->AB8_NUMOS	:= Pad(cNumOs,6)
						AB8->AB8_ITEM	:= aSavAcols[nItAcols][1]
						AB8->AB8_SUBITE	:= IIF(nAb8Val >2,StrZero(val(aCols[nx,1]),6,0),aCols[nx,1])	 //subitem
						AB8->AB8_CODPRO	:= aCols[nx,2]	 //codigo
						AB8->AB8_DESPRO	:= aCols[nx,3]	 //descricao
						AB8->AB8_CODSER	:= aCols[nx,4]	 //sesrvcio
						AB8->AB8_QUANT  := aCols[nx,5]   // Quantidade
						AB8->AB8_VUNIT  := aCols[nx,6]   // Preço Unitário
						AB8->AB8_TOTAL  := aCols[nx,7]   // Valor Total
						AB8->AB8_PRCLIS := aCols[nx,8]   // Preço de Lista
						AB8->AB8_XDESCO := aCols[nx,9]   // % de Desconto
						AB8->AB8_XVALDE := aCols[nx,10]  // Valor do Desconto
						AB8->AB8_XST    := aCols[nx,14]  // Possui ST. SIM / NAO
						AB8->AB8_ENTREG	:= 	DATE()
						AB8->AB8_DTGAR	:=	DATE()+90
						AB8->AB8_CODCLI	:=	AB3->AB3_CODCLI	
						AB8->AB8_LOJA	:=	AB3->AB3_LOJA
						AB8->AB8_CODPRD	:=	AB4->AB4_CODPRO
						AB8->AB8_NUMSER	:=	AB4->AB4_NUMSER
						AB8->AB8_TIPO	:=	Posicione("AB7",1,xFilial("AB7")+Pad(cNumOs,6)+aSavAcols[nItAcols][1],"AB7_TIPO")
						AB8->AB8_LOCAL	:=	POSICIONE("SB1",1,xFilial("SB1")+ aCols[nx,2],"B1_LOCPAD")
					MSUNLOCK()
			ENDIF			
			If ABA->(Dbseek(xFilial("ABA")+cNumOs+cTecnico+cSeq+IIF(nAbaVal >2,StrZero(val(aCols[nx,1]),6,0),aCols[nx,1]))) 
               If      !aCols[nx,18]
                        RecLock("ABA",.F.)
                            ABA->ABA_CODPRO     := aCols[nx,2]
                            ABA->ABA_DESCRI     := aCols[nx,3]
							ABA->ABA_CODSER     := aCols[nx,4]
                            ABA->ABA_QUANT      := aCols[nx,5]
                            ABA->(MsUnlock())
				Else  
						Reclock("ABA",.F.)
                            ABA->(DbDelete())
                        ABA->(MsUnlock())
                 Endif
            elseif !aCols[nx,18]
				cUltNum := NUMIT(xFilial("ABA"),cNumOs,cTecnico,cSeq)
				Reclock("ABA",.T.)
					ABA->ABA_FILIAL := xFilial("ABA")
         			ABA->ABA_ITEM   := StrZero(Val(SOMASTR(cUltNum,"01")),2,0)
					ABA->ABA_CODPRO := aCols[nx,2]
                    ABA->ABA_QUANT  := aCols[nx,5]
                    ABA->ABA_LOCAL  := POSICIONE("SB1",1,xFilial("SB1")+ aCols[nx,2],"B1_LOCPAD")
                    ABA->ABA_CODSER := aCols[nx,4]
                    ABA->ABA_NUMOS  := cNumOs
                    ABA->ABA_CODTEC := cTecnico
                    ABA->ABA_SEQ    := cSeq
                    ABA->ABA_SUBOS  := IIF(nAbaVal >2,StrZero(val(aCols[nx,1]),6,0),aCols[nx,1])
                    ABA->ABA_DESCRI := aCols[nx,3]
                ABA->(MsUnlock())
            Endif
		NEXT
		ENDIF
	ENDIF
	///oGetD:oBrowse:lDisablePaint := .F.
ELSE
	IF MsGetDAuto(aAutoApont,"AT400F4LOk",{|| .T. },aAutoCab,aRotina[nOpcF4][4])
		aColsAB5[nItAcols] := aClone(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada apos a confirmacao do apontamento                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF ExistBlock( "AT400APN" )
			ExecBlock( "AT400APN", .F., .F. )
		ENDIF
	ELSE
		lRetorno := .F.
	ENDIF
ENDIF

aHeader 	:= aClone(aHeaderAB4)
aCols		:= aClone(aSavACols)
aColsMain:= NIL
N			:= nSavN

RestArea(aAreaAB5)
RestArea(aAreaABA)
RestArea(aAreaAB8)

DBSELECTAREA(aArea[1])
DBSETORDER(aArea[2])
DBGOTO(aArea[3])

RETURN(lRetorno)


STATIC FUNCTION At400Total(oDlg,lF4)
LOCAL nUsado	:= Len(aHeaderAB5)
LOCAL nCntFor	:= 0
LOCAL nCntFor2	:= 0
LOCAL nPosProd 	:= aScan(aHeaderAB5,{|x| AllTrim(x[2])=="AB5_CODPRO"})
LOCAL nPosTotal	:= aScan(aHeaderAB5,{|x| AllTrim(x[2])=="AB5_TOTAL"})
LOCAL nPosSer	:= aScan(aHeaderAB5,{|x| AllTrim(x[2])=="AB5_CODSER"})
LOCAL nTotGer	:= 0
LOCAL nTotCli	:= 0
LOCAL nTotFab	:= 0
IF ( lF4 )
	FOR nCntFOR := 1 TO LEN(aCols)
		IF ( LEN(aCols[nCntFor])==nUsado .OR. !aCols[nCntFor][nUsado+1] )
			nTotCli	+= AtVlrPagto(aCols[nCntFor][nPosSer],aCols[nCntFor][nPosTotal],"C")
			nTotFab	+= AtVlrPagto(aCols[nCntFor][nPosSer],aCols[nCntFor][nPosTotal],"F")
			nTotGer  += aCols[nCntFor][nPosTotal]
		ENDIF
	NEXT nCntFor
ELSE
	FOR nCntFOR := 1 To LEN(aColsAB5)
		FOR nCntFor2 := 1 To LEN(aColsAB5[nCntFor])
			IF ( LEN(aColsAB5[nCntFor][nCntFor2])==nUsado .OR. !aColsAB5[nCntFor][nCntFor2][nUsado+1] )
				nTotCli	+= AtVlrPagto(aColsAB5[nCntFor][nCntFor2][nPosSer],aColsAB5[nCntFor][nCntFor2][nPosTotal],"C")
				nTotFab	+= AtVlrPagto(aColsAB5[nCntFor][nCntFor2][nPosSer],aColsAB5[nCntFor][nCntFor2][nPosTotal],"F")
				nTotGer  += aColsAB5[nCntFor][nCntFor2][nPosTotal]
			ENDIF
		NEXT nCntFor2
	NEXT nCntFor
ENDIF
Eval(oDlg:Cargo,nTotGer,nTotCli,nTotFab)
RETURN(.T.)

USER FUNCTION AtValIt()
LOCAL lRet := .T.
LOCAL cNameField := ""
LOCAL cTipoPro := ""

BEGIN SEQUENCE
cNameField := ReadVar()

IF cNameField == "M->AB5_PRCLIS"
	
	cCodPro  := ALLTRIM(aCols[n][GDFieldPos("AB5_CODPRO")])
	cTipoPro := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cCodPro,"B1_TIPO"))
	IF cTipoPro <> "MO"
		MSGALERT("Somente produto M.O. podem ter seus valores alterados","")
		lRet := .F.
	ENDIF
ENDIF

END SEQUENCE

RETURN(lRet)

Static Function AT400Impos()

Local aArea	   := GetArea()
Local aDadosCFO:= {}
Local cTes     := ""
Local cCFO     := ""
Local nPosItem := aScan(aHeader,{|x| AllTrim(x[2])=="AB5_SUBITE"})
Local nPosPrd  := aScan(aHeader,{|x| AllTrim(x[2])=="AB5_CODPRO"})
Local nPosQtd  := aScan(aHeader,{|x| AllTrim(x[2])=="AB5_QUANT" })
Local nPosTot  := aScan(aHeader,{|x| AllTrim(x[2])=="AB5_TOTAL" })
Local nPosLis  := aScan(aHeader,{|x| AllTrim(x[2])=="AB5_PRCLIS"})
Local nPosServ := aScan(aHeader,{|x| AllTrim(x[2])=="AB5_CODSER"})
Local nItem     := 0
Local nPrcLista := 0
Local nValMerc  := 0
Local nDesconto := 0
Local oDlg      := Nil

AA5->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SA1->(dbSetOrder(1))

SA1->(MsSeek(xFilial("SA1")+M->AB3_CODCLI+M->AB3_LOJA))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Garante que os Arrays da Matxfis estao Limpos a cada chamada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisEnd()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a carga da MATXFIS com os dados do Cabecalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisIni(SA1->A1_COD,SA1->A1_LOJA,"C","N",SA1->A1_TIPO,,,,,"MATA461",,,,,SA1->A1_RECISS,,,,,,,,,,,)

Aadd(aDadosCFO,{"OPERNF"  , "S"})
Aadd(aDadosCFO,{"TPCLIFOR", SA1->A1_TIPO})
Aadd(aDadosCFO,{"UFDEST"  , SA1->A1_EST})
Aadd(aDadosCFO,{"INSCR"   , SA1->A1_INSCR})
Aadd(aDadosCFO,{"CONTR"   , SA1->A1_CONTRIB})

For nItem := 1 To Len(aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtem a TES e posiciona o cadastro de TES SF4³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AA5->(MsSeek(xFilial("AA5")+aCols[nItem][nPosServ]))
	
	If !Empty(AA5->AA5_TES)
		cTes := AA5->AA5_TES
	Else
		SB1->(MsSeek(xFilial("SB1")+aCols[nItem][nPosPrd]))
		cTes := SB1->B1_TS
	EndIf
	
	cCFO := ""
	If !Empty(cTes)
		SF4->(MsSeek(xFilial("SF4")+cTes))
		cCFO := MaFisCfo(,SF4->F4_CF,aDadosCFO)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula se ha desconto a partir do preco de lista³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValMerc  := aCols[nItem][nPosTot]
	nPrcLista := aCols[nItem][nPosLis]
	nDesconto := ( a410Arred( nPrcLista * aCols[nItem][nPosQtd] , "D2_DESCON" ) - nValMerc )
	nDesconto := Max(0,nDesconto)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega os itens para a MATXFIS. O uso do MaFisAdd em detrimento ao uso do MaFisIniLoad foi adotado afim de ³
	//³manter compatibilidade com o Pedido Vendas que utiliza o MaFisAdd na ocasiao desta implementacao no TECA400.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAdd(aCols[nItem][nPosPrd],; // 1-Codigo do Produto ( Obrigatorio )
	cTes,;                            // 2-Codigo do TES ( Opcional )
	aCols[nItem][nPosQtd],;  	      // 3-Quantidade ( Obrigatorio )
	nPrcLista,;		  				  // 4-Preco Unitario ( Obrigatorio )
	nDesconto,; 		              // 5-Valor do Desconto ( Opcional )
	"",;	   			              // 6-Numero da NF Original ( Devolucao/Benef )
	"",;				              // 7-Serie da NF Original ( Devolucao/Benef )
	0 ,;					          // 8-RecNo da NF Original no arq SD1/SD2
	0 ,;					          // 9-Valor do Frete do Item ( Opcional )
	0 ,;					          // 10-Valor da Despesa do item ( Opcional )
	0 ,;					          // 11-Valor do Seguro do item ( Opcional )
	0 ,;					          // 12-Valor do Frete Autonomo ( Opcional )
	nValMerc,;			              // 13-Valor da Mercadoria ( Obrigatorio )
	0 ,;					          // 14-Valor da Embalagem ( Opiconal )
	0 ,;					          // 15-RecNo do SB1
	0 ,;					          // 16-RecNo do SF4
	Iif(nPosItem > 0 , aCols[nItem,nPosItem] , "" ),; //17-Item
	0 ,;					          // 18-Despesas nao tributadas - Portugal
	0 ,;					          // 19-Tara - Portugal
	cCFO,;                            // 20-CFO
	{},;            	              // 21-Array para o calculo do IVA Ajustado (opcional)
	"",;				              // 22-Codigo Retencao - Equador
	0 ,;                              // 23-Valor Abatimento ISS
	"",;                              // 24-Lote Produto
	"",;                              // 25-Sub-Lote Produto
	0 ,;                              // 26-Valor do Abatimento ISS
	"",;                              // 27-Codigo ISS
	"")                               // 28-Classificação fiscal
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calculo do ISS conforme SA1->A1_INCISS       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( !Empty(cTes) .And. SA1->A1_INCISS == "N" .And. SF4->F4_ISS == "S" )
		nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
		nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
		MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
		MaFisAlt("IT_VALMERC",nValMerc,nItem)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Marca no MATXFIS se o Item estiver DELETADO  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aCols[nItem][Len(aHeader)+1]
		MaFisDel(nItem,aCols[nItem][Len(aHeader)+1])
	EndIf
	
Next nItem

MaFisWrite(1)

DEFINE MSDIALOG oDlg TITLE "Impostos" FROM 009,000 TO 028,080

MaFisRodape(1,oDlg,,{005,005,308,080},Nil,.T.)

@ 095,005 SAY   RetTitle("F2_FRETE")    SIZE 040,010 PIXEL OF oDlg
@ 095,112 SAY   RetTitle("F2_SEGURO")   SIZE 040,010 PIXEL OF oDlg
@ 095,218 SAY   RetTitle("F2_DESCONT")  SIZE 040,010 PIXEL OF oDlg
@ 110,005 SAY   RetTitle("F2_FRETAUT")  SIZE 040,010 PIXEL OF oDlg
@ 110,112 SAY   RetTitle("F2_DESPESA")  SIZE 040,010 PIXEL OF oDlg
@ 110,218 SAY   RetTitle("F2_VALFAT")   SIZE 040,010 PIXEL OF oDlg
@ 125,005 SAY   "Total da Nota"                 SIZE 040,010 PIXEL OF oDlg   //"Total da Nota"
@ 095,050 MSGET MaFisRet(,"NF_FRETE")   PICTURE PesqPict("SF2","F2_FRETE"   ,16,2) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 095,157 MSGET MaFisRet(,"NF_SEGURO")  PICTURE PesqPict("SF2","F2_SEGURO"  ,16,2) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 095,263 MSGET MaFisRet(,"NF_DESCONTO")PICTURE PesqPict("SF2","F2_DESCONTO",16,2) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 110,050 MSGET MaFisRet(,"NF_AUTONOMO")PICTURE PesqPict("SF2","F2_FRETAUT" ,16,2) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 110,157 MSGET MaFisRet(,"NF_DESPESA") PICTURE PesqPict("SF2","F2_DESPESA" ,16,2) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 110,263 MSGET MaFisRet(,"NF_BASEDUP") PICTURE PesqPict("SF2","F2_VALFAT"  ,16,2) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 125,050 MSGET MaFisRet(,"NF_TOTAL")   PICTURE Iif(cPaisLoc=="CHI",TM(0,16,NIL),PesqPict("SF2","F2_VALBRUT",16,2)) SIZE 050,007 PIXEL WHEN .F. OF oDlg
@ 128,270 BUTTON "Fechar" SIZE 042,11 FONT oDlg:oFont ACTION oDlg:End() OF oDlg PIXEL // Botao Fechar

ACTIVATE MSDIALOG oDlg CENTERED ON INIT CursorArrow()

MaFisEnd()

RestArea(aArea)

RETURN()

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

Static Function AT400F41()
	MaViewSB2(SB1->B1_COD)     
Return
