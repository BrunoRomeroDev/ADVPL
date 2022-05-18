#Include "Protheus.ch"


User Function tVend()

Local oReport
	
	CriaPerg()	
 	Pergunte("XCLIVEND",.F.)
 	
	oReport := ReportDef()
  	oReport:PrintDialog()
    
Return( Nil )

Static Function ReportDef()

Local oReport
Local oSection
Local oBreak



oReport := TReport():New("ClinteXVendedor","Relatorio de Clientes X Vendedor","XCLIVEND",{|oReport| PrintReport(oReport)},"Relatorio de visitas de vendedores nos clientes")

oSection := TRSection():New(oReport,"Dados dos Clientes",{"SA1"} ) 

	TRCell():New(oSection,"A1_VEND"   , "SA1")
	TRCell():New(oSection,"A1_COD"    ," SA1","Cliente")
	TRCell():New(oSection,"A1_LOJA"   , "SA1")
	TRCell():New(oSection,"A1_NOME"   , "SA1")
	TRCell():New(oSection,"A1_END"    , "SA1")
	TRCell():New(oSection,"A1_CEP"    , "SA1")
	TRCell():New(oSection,"A1_CONTATO", "SA1")
	TRCell():New(oSection,"A1_TEL"    , "SA1")
	TRCell():New(oSection,"A1_EST"    , "SA1")


oBreak := TRBreak():New(oSection,oSection:Cell("A1_EST"),"Sub Total Estados")     

 TRFunction():New(oSection:Cell("A1_COD"   ), NIL, "COUNT", oBreak)

Return ( oReport )



Static Function PrintReport(oReport)

Local oSection := oReport:Section(1)
Local cPart := ""

oSection:BeginQuery()

	cPart := "% AND A1_COD >= '" + MV_PAR01 + "' "
	cPart += "  AND A1_COD <= '" + MV_PAR02 + "' %"
  
	BeginSql alias "QRYSA1"

		SELECT 
			A1_COD,
		A1_LOJA,
		A1_NOME,
		A1_VEND,
		A1_ULTVIS,
		A1_TEMVIS,
		A1_TEL,
		A1_CONTATO,
		A1_EST
		FROM %table:SA1% SA1
		WHERE A1_FILIAL = %xfilial:SA1% 
		AND A1_MSBLQL <> '1' 
		AND SA1.%notDel% 
		%exp:cPart%
		ORDER BY A1_EST Desc
	EndSql

aRetSql := GetLastQuery()
oSection:EndQuery()
oSection:Print()

Return( Nil )


Static Function CriaPerg()

Local _sAlias 	:= Alias()
Local aArea   	:= GetArea()
Local aRegs   	:= {}
Local nX		:= 0
Local cPerg		:= "XCLIVEND"

dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10) 
aCampos := {"GRUPO","ORDEM","PERGUNT","VARIAVL","TIPO","TAMANHO","DECIMAL","PRESEL","GSC","VALID","VAR01","DEF01","CNT01","VAR01","DEF01","CNT01","VAR02","DEF02","CNT02","VAR03","DEF03","CNT03","VAR04","DEF04","CNT04","VAR05","DEF05","CNT05","F3"}

aAdd(aRegs,{cPerg,"01","Cliente de			","","","mv_ch1" ,"C",TamSX3("A1_COD")[1]	,0,0,"G",""	,"MV_PAR01","","","","","","","","","","","","","","","SA1"})
aAdd(aRegs,{cPerg,"02","Cliente ate		  	","","","mv_ch2" ,"C",TamSX3("A1_COD")[1]	,0,0,"G",""	,"MV_PAR02","","","","","","","","","","","","","","","SA1"})

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aRegs)
	If	DbSeek( cPerg + aRegs[nx][02] )   
    	If	RecLock('SX1',.F.)
			Replace SX1->X1_GRUPO  		With aRegs[nx][01]
			Replace SX1->X1_ORDEM   	With aRegs[nx][02]
			Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
			Replace SX1->X1_PERSPA		With aRegs[nx][04]
			Replace SX1->X1_PERENG		With aRegs[nx][05]
			Replace SX1->X1_VARIAVL		With aRegs[nx][06]
			Replace SX1->X1_TIPO		With aRegs[nx][07]
			Replace SX1->X1_TAMANHO		With aRegs[nx][08]
			Replace SX1->X1_DECIMAL		With aRegs[nx][09]
			Replace SX1->X1_PRESEL		With aRegs[nx][10]
			Replace SX1->X1_GSC		  	With aRegs[nx][11]
			Replace SX1->X1_VALID		With aRegs[nx][12]
			Replace SX1->X1_VAR01		With aRegs[nx][13]
			Replace SX1->X1_DEF01	  	With aRegs[nx][14]
			Replace SX1->X1_DEF02		With aRegs[nx][17]
			Replace SX1->X1_DEF03		With aRegs[nx][20]
			Replace SX1->X1_DEF04		With aRegs[nx][23]
			Replace SX1->X1_DEF05		With aRegs[nx][26]
			Replace SX1->X1_F3   		With aRegs[nx][28]
			SX1->(MsUnlock())
		Else
			Help('',1,'REGNOIS')
		EndIf	
	Else
		If	RecLock('SX1',.T.)
			Replace SX1->X1_GRUPO  		With aRegs[nx][01]
			Replace SX1->X1_ORDEM   	With aRegs[nx][02]
			Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
			Replace SX1->X1_PERSPA		With aRegs[nx][04]
			Replace SX1->X1_PERENG		With aRegs[nx][05]
			Replace SX1->X1_VARIAVL		With aRegs[nx][06]
			Replace SX1->X1_TIPO		With aRegs[nx][07]
			Replace SX1->X1_TAMANHO		With aRegs[nx][08]
			Replace SX1->X1_DECIMAL		With aRegs[nx][09]
			Replace SX1->X1_PRESEL		With aRegs[nx][10]
			Replace SX1->X1_GSC		  	With aRegs[nx][11]
			Replace SX1->X1_VALID		With aRegs[nx][12]
			Replace SX1->X1_VAR01		With aRegs[nx][13]
			Replace SX1->X1_DEF01	  	With aRegs[nx][14]
			Replace SX1->X1_DEF02		With aRegs[nx][17]
			Replace SX1->X1_DEF03		With aRegs[nx][20]
			Replace SX1->X1_DEF04		With aRegs[nx][23]
			Replace SX1->X1_DEF05		With aRegs[nx][26]
			Replace SX1->X1_F3   		With aRegs[nx][28]
			SX1->(MsUnlock())
		Else
			Help('',1,'REGNOIS')
		EndIf	
	Endif
Next nX

dbSelectArea(_sAlias)
RestArea(aArea)

Return NIL
