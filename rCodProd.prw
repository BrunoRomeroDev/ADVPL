#Include "Protheus.ch"

User Function rCodProd()
	Local oReport := nil 

		oReport := RptDef()
		oReport:PrintDialog()

Return()

Static Function RptDef()
	Local oReport := Nil
	Local oSection1:= Nil
    Local cPergunta := "XCODPRO"

	oReport := TReport():New("Produtos", "Cadastro Produtos",cPergunta,{|oReport| ReportPrint( oReport ) }, "Imprime cadastro dos produtos")
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oSection1:= TRSection():New(oReport, "Produtos", {"SB1"}, NIL, .F., .T.)
	TRCell():New(oSection1, "B1_COD" ,"SB1","Produto" ,"@!",30 )
	TRCell():New(oSection1, "B1_DESC" ,"SB1","Descrção" ,"@!",100)
	TRCell():New(oSection1, "B1_LOCPAD" ,"SB1","Arm.Padrao" ,"@!",20 )
	TRCell():New(oSection1, "B1_POSIPI" ,"SB1","NCM" ,"@!",30 )
	TRFunction():New(oSection1:Cell("B1_COD"),NIL,"COUNT",,,,,.F.,.T.)

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local cQuery := ""
	Local cAlias := GetNextAlias()
    Local cQuery := ""

    cQuery := "SELECT B1_COD, B1_DESC, B1_LOCPAD, B1_POSIPI "
    cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
    cQuery += "WHERE SB1.D_E_L_E_T_ = '' "
    cQuery += "AND B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += "AND B1_MSBLQL <> '1' "
	cQuery += "AND B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
    cQuery := ChangeQuery(cQuery) 

    dbUseArea( .T., "TOPCONN", tcGenQry(,,cQuery), cAlias, .F., .F.)  
	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())

	oReport:SetMeter((cAlias)->(LastRec()))

	While !(cAlias)->( EOF() )
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()
		IncProc("Imprimindo " + alltrim((cAlias)->B1_DESC))		
		oSection1:Init()
		oSection1:Cell("B1_COD" ):SetValue((cAlias)->B1_COD )
		oSection1:Cell("B1_DESC" ):SetValue((cAlias)->B1_DESC )
		oSection1:Cell("B1_LOCPAD"):SetValue((cAlias)->B1_LOCPAD )
		oSection1:Cell("B1_POSIPI"):SetValue((cAlias)->B1_POSIPI)
		oSection1:Printline()
		(cAlias)->(dbSkip())		
		oReport:ThinLine()

	EndDo
	
	oSection1:Finish()
    (cAlias)->(DbCloseArea()) 
Return( NIL )
