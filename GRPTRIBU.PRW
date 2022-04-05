
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function GRPTRIBU()


Local aArea := SX5->(GetArea())
Private oBrowse
Private cChaveAux := ""
	
	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias("SX5")
	
	oBrowse:SetDescription("Grupo Tributário")
	
	oBrowse:SetFilterDefault( "X5_TABELA == '21'" )
        
	
	oBrowse:DisableDetails()
	
	oBrowse:Activate()
	RestArea(aArea)
Return

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION 'PesqBrw' OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.GRPTRIB" OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.GRPTRIB" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.GRPTRIB" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.GRPTRIB" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"     ACTION "VIEWDEF.GRPTRIB" OPERATION 8 ACCESS 0
	ADD OPTION aRotina TITLE "Copiar"       ACTION "VIEWDEF.GRPTRIB" OPERATION 9 ACCESS 0

Return aRotina

Static Function ViewDef()
	Local oView
	Local oModel := ModelDef()
	Local oStr1:= FWFormStruct(2, 'SX5')
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	
	oView:AddField('Formulario' , oStr1,'CamposSX5' )
	
	oStr1:RemoveField( 'X5_DESCENG' )
	oStr1:RemoveField( 'X5_DESCSPA' )
	
	oView:CreateHorizontalBox( 'PAI', 100)
	
	oView:SetOwnerView('Formulario','PAI')
	oView:EnableTitleView('Formulario' , 'Grupo Tributário' )
	oView:SetViewProperty('Formulario' , 'SETCOLUMNSEPARATOR', {10})
	
	oView:SetCloseOnOk({||.T.})
Return oView
Static Function ModelDef()
	Local oModel
	Local oStr1:= FWFormStruct( 1, 'SX5', /*bAvalCampo*/,/*lViewUsado*/ ) 
    
    oModel := MPFormModel():New('GrupoTributario', /*bPreValidacao*/, { |oModel|GRPTRIBV( oModel )} , /*{ | oMdl | GRPTRIBC( oMdl ) }*/ ,, /*bCancel*/ )
	
	oModel:SetDescription('Grupo Tributário')
    
	oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_INIT,{||'21'} )
    
	oStr1:SetProperty('X5_TABELA' , MODEL_FIELD_WHEN,{|| .F. })
    
       
	oStr1:SetProperty("X5_CHAVE" , MODEL_FIELD_WHEN,{|oModel|oModel:GetOperation()== 3  })
    oStr1:SetProperty("X5_CHAVE" , MODEL_FIELD_WHEN,{|oModel|oModel:GetOperation()== 3  })
	oStr1:RemoveField( 'X5_DESCENG' )
	oStr1:RemoveField( 'X5_DESCSPA' )
	oStr1:RemoveField( 'X5_FILIAL' )
    
	oModel:AddFields("CamposSX5",/*cOwner*/,oStr1)
    
	oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE' })
    
	oModel:getModel('CamposSX5'):SetDescription('TabelaSX5')
Return oModel
    
Static Function GRPTRIBV( oModel )
	Local lRet      := .T.
	Local oModelSX5 := oModel:GetModel( 'CamposSX5' )
	Local nOpc      := oModel:GetOperation()
	Local aArea     := GetArea()
    
	Local cChave    := oModelSX5:GetValue('X5_CHAVE')
	Local cTabela   := oModelSX5:GetValue('X5_TABELA')
	Local cDescri   := oModelSX5:GetValue('X5_DESCRI')
	Begin Transaction
		If nOpc == 3 
			If Empty(cTabela)
				oModelSX5:SetValue('X5_TABELA','21')
			Endif
			dbSelectArea("SX5")
			SX5->(dbSetOrder(1))
			SX5->(dbGoTop())
			If(SX5->(dbSeek(xFilial("SX5")+cTabela+cChave)))
				If cChaveAux != cChave
					SFCMsgErro("A chave "+Alltrim(cChave)+" ja foi informada!","GRPTRIB")
					lRet := .F.
				EndIf
			Endif
			If Empty(cChave)
				SFCMsgErro("O campo chave é obrigatório!","GRPTRIB")
				lRet := .F.
			EndIf
			If Empty(cDescri)
				SFCMsgErro("O campo descrição é obrigatório!","GRPTRIB")
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			DisarmTransaction()
		EndIf
	End Transaction
	RestArea(aArea)
	FwModelActive( oModel, .T. )
Return lRet
