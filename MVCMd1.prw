#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

User Function MVCMd1()
    Local oBrowse1
    
    oBrowse1 := FWMBrowse():New()
    oBrowse1:SetAlias("SBM")
    oBrowse1:SetDescription("Grp.Produtos")
    oBrowse1:AddLegend( "SBM->BM_PROORI == '1'", "GREEN",    "Original" )
    oBrowse1:AddLegend( "SBM->BM_PROORI == '0'", "RED",    "Nao Original" )
     
    oBrowse1:Activate()

Return Nil

Static Function ModelDef()
    Local oModel := Nil
    Local oStSBM := FWFormStruct(1, "SBM")

    oModel := MPFormModel():New("MVCMd1M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
    oModel:AddFields("FORMSBM",/*cOwner*/,oStSBM)
    oModel:SetPrimaryKey({'BM_FILIAL','BM_GRUPO'})
    oModel:SetDescription("Modelo de Dados do Cadastro ")
    oModel:GetModel("FORMSBM"):SetDescription("Formulário do Cadastro ")

Return oModel

Static Function ViewDef()
    Local oModel := FWLoadModel("MVCMd1")
    Local oStSBM := FWFormStruct(2, "SBM")  
    Local oView1 := Nil

    oView1 := FWFormView():New()
    oView1:SetModel(oModel)
    oView1:AddField("VIEW_SBM", oStSBM, "FORMSBM")
    oView1:CreateHorizontalBox("TELA",100)
    oView1:EnableTitleView('VIEW_SBM', 'Dados do Grupo de Produtos' )  
    oView1:SetCloseOnOk({||.T.})
    oView1:SetOwnerView("VIEW_SBM","TELA")

Return oView1

User Function MVC1Leg()
    Local aLegenda := {}
     
    AADD(aLegenda,{"BR_VERDE",        "Original"  })
    AADD(aLegenda,{"BR_VERMELHO",    "Não Original"})
     
    BrwLegenda("Grupo de Produtos", "Procedencia", aLegenda)

Return


Static Function MenuDef()
    Local aRot := {}
    
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.MVCMd1' OPERATION 1    ACCESS 0 
    ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_MVC1Leg'      OPERATION 6    ACCESS 0 
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.MVCMd1' OPERATION 3    ACCESS 0 
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.MVCMd1' OPERATION 4    ACCESS 0 
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.MVCMd1' OPERATION 5    ACCESS 0
    
Return aRot
 