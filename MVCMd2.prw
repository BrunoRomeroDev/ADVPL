#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

User Function MVCMd2()
    Local aArea   := GetArea()
    Local oBrowser2
         
    oBrowser2 := FWMBrowse():New()
    oBrowser2:SetAlias("SB1")
    oBrowser2:SetDescription("Produtos")
    oBrowser2:Activate()
      
    RestArea(aArea)
Return Nil
 
Static Function ModelDef()
    
    Local oModel        := NIL
    Local oStruCab      := FWFormStruct(1, 'SB1', {|cCampo| AllTRim(cCampo)   $ "B1_COD;B1_DESC;B1_TIPO;B1_LOCPAD;B1_GRUPO;B1_POSIPI;B1_TE;B1_TS;B1_PRV1;B1_YUPRCEX"})
    Local oStruGrid     := FWFormStruct(1, 'SB1')
 
    oModel := MPFormModel():New('MVCMd2M', /*bPreValidacao*/,, /*bCommit*/, /*bCancel*/ )
    oModel:AddFields('FieldSB1', NIL, oStruCab)
    oModel:AddGrid('GridSB1', 'FieldSB1', oStruGrid, , )
    oModel:SetRelation('GridSB1',{{'B1_COD', 'B1_DESC'}}, SB1->(IndexKey(1)))
    oModel:SetDescription("Atualização Cadastro de Produto")
    oModel:SetPrimaryKey({"B1_FILIAL", "B1_COD"})
 
Return oModel
 
Static Function ViewDef()
    
    Local oView2        := NIL
    Local oModel    := FWLoadModel('MVCMd2')
    Local oStruCab  := FWFormStruct(2, "SB1", {|cCampo| AllTRim(cCampo)   $ "B1_COD;B1_DESC;B1_TIPO;B1_LOCPAD;B1_GRUPO;B1_POSIPI;B1_TE;B1_TS;B1_PRV1;B1_YUPRCEX"})
    Local oStruGRID := FWFormStruct(2, "SB1", {|cCampo| !(Alltrim(cCampo) $ "B1_COD;B1_DESC;B1_TIPO;B1_LOCPAD;B1_GRUPO;B1_POSIPI;B1_TE;B1_TS;B1_PRV1;B1_YUPRCEX")})
 
    oStruCab:SetNoFolder()

    oView2:= FWFormView():New() 
    oView2:SetModel(oModel)              
    oView2:AddField('VIEW_SB1', oStruCab, 'FieldSB1')
    oView2:AddGrid ('GRID_SB1', oStruGRID, 'GridSB1' )
    oView2:CreateHorizontalBox("ENCHOICE", 25)
    oView2:CreateHorizontalBox("GRID", 75)
    oView2:SetOwnerView('VIEW_SB1', "ENCHOICE")
    oView2:SetOwnerView('GRID_SB1', 'GRID')
    oView2:EnableControlBar(.T.)
 
Return oView2


Static Function MenuDef()
Return FWMVCMenu('MVCMd2')
