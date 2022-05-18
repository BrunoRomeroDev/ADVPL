#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

User Function rel002()
	Local oReport   := nil
	Local oSection1 := Nil
	Local oSection2 := Nil
    Local cPerg     := Padr("REL002",10)

    Pergunte(cPerg,.F.)
	
	oReport := TReport():New("REL002","Pedido de Venda",cPerg,{|oReport| ReportPrint(oReport)},"Itens do Pedidos de Venda ")
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport     , "Numero Pedido"   , {"SC5"}, , .F., .T.)
	TRCell():New(oSection1,"C5_NUM"		    ,"cAlias"           ,"Pedido de Venda","@!",40)
	TRCell():New(oSection1,"C5_CLIENTE"     ,"cAlias"           ,"Num. Cliente"	  ,"@!",50)
    TRCell():New(oSection1,"C5_XNOME"       ,"cAlias"           ,"Nome CLiente"   ,"@!",30)
	
	oSection2:= TRSection():New(oReport     , "Produtos", {"SC6"}, NIL, .F., .T.)
	TRCell():New(oSection2,"C6_PRODUTO"   	,"cAlias","Produto"		,"@!",20)
	TRCell():New(oSection2,"C6_DESCRI"  	,"cAlias","Descrição"	,"@!",50)
	TRCell():New(oSection2,"C6_QTDVEN"	    ,"cAlias","QTD"	        ,"@E 9999",4)	
	TRCell():New(oSection2,"C6_VALOR"	    ,"cAlias","Preco Venda"	,"@E 999,999,999.99",12)
    TRCell():New(oSection2,"ValorTotal"	    ,"cAlias","valor Total"	,"@E 999,999,999.99",12)	

	TRFunction():New(oSection2:Cell("ValorTotal")," ","SUM",/*oBREAK*/,"Total por Pedido",/*cPicture*/,/*uFórmula*/,.T.,.F.,.F.,oSection2,/*bCondition*/,/*lDISABLE*/,/*bCanPrint*/)

    oReport:SetTotalInLine(.F.)
	oSection2:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")		
    oReport:PrintDialog()	

Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)	 
	Local cQuery    := ""		
	Local cAlias    := GetNextAlias()
    Local nAtual    := 0
	Local nTotal    := 0
    Local cControl  := ""

    cQuery := " SELECT C5_NUM,C5_CLIENTE,C5_XNOME,C6_PRODUTO,C6_DESCRI,C6_QTDVEN,C6_VALOR,C6_NUM,(C6_QTDVEN*C6_VALOR) as ValorTotal 
	cQuery += " FROM "+RETSQLNAME("SC5")+" AS SC6 INNER JOIN  "+RETSQLNAME("SC6")+" AS SC5 ON C5_NUM = C6_NUM "
	cQuery += " WHERE SC5.D_E_L_E_T_ = '' AND SC6.D_E_L_E_T_ = '' AND "
	cQuery += " C5_FILIAL = '"+xFilial("SC5")+"' AND "
	cQuery += " C6_FILIAL = '"+xFilial("SC6")+"' AND "
	cQuery += " C5_NUM BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "	
    cQuery += " ORDER BY C5_NUM "

	TCQUERY cQuery NEW ALIAS (cAlias)	
	Count to nTotal

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())
	
	oReport:SetMeter((cAlias)->(LastRec()))	

	
	While (cAlias)->(!Eof())
		
        If oReport:Cancel()
			Exit
		EndIf
        
        cControl := (cAlias)->C5_NUM
        nAtual++

		
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
					
		oSection1:Init()		
		oSection1:Cell("C5_NUM"):SetValue((cAlias)->C5_NUM)
		oSection1:Cell("C5_CLIENTE"):SetValue((cAlias)->C5_CLIENTE)
        oSection1:Cell("C5_XNOME"):SetValue((cAlias)->C5_XNOME)				
		oSection1:Printline()

		oSection2:init()
		
		
		While (cAlias)->C6_NUM == cControl .AND. (cAlias)->(!Eof())
			oReport:IncMeter()		
		
			oSection2:Cell("C6_PRODUTO"):SetValue((cAlias)->C6_PRODUTO)
			oSection2:Cell("C6_DESCRI"):SetValue((cAlias)->C6_DESCRI)
			oSection2:Cell("C6_QTDVEN"):SetValue((cAlias)->C6_QTDVEN)			
			oSection2:Cell("C6_VALOR"):SetValue((cAlias)->C6_VALOR)	
            oSection2:Cell("ValorTotal"):SetValue((cAlias)->ValorTotal)		
			oSection2:Printline()
	
 			(cAlias)->(dbSkip())
 		EndDo
       		
 		oSection2:Finish() 		
 		oSection1:Finish()

	Enddo
    (cAlias)->(DbCloseArea())
Return
