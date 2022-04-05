
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Bruno Romero                                               |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
 
User Function MVCMd3()
    Local oBrowse   := Nil
     
    
    oBrowse := FWMBrowse():New()
     
    
    oBrowse:SetAlias("SBM")
 
    
    oBrowse:SetDescription("Grp.Produtos XXX")
    oBrowse:DisableDetails()
     
    
    oBrowse:AddLegend( "SBM->BM_PROORI == '1'", "GREEN",    "Original" )
    oBrowse:AddLegend( "SBM->BM_PROORI == '0'", "RED",    "Não Original" )
     
    
    oBrowse:Activate()
    
Return Nil

Static Function ModelDef()
    Local oModel         := Nil
    Local oStPai         := FWFormStruct(1, 'SBM')
    Local oStFilho       := FWFormStruct(1, 'SB1')
    Local aSB1Rel        := {}
     
    
    oModel := MPFormModel():New('MVCMd3M',/*bPre*/,/*bPos*/,,/*bCan*/)
    oModel:AddFields('SBMMASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('SB1DETAIL','SBMMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre*/,/*bPos*/,/*bLoad*/)  
     
    
    aAdd(aSB1Rel, {'B1_FILIAL',    'BM_FILIAL'} )
    aAdd(aSB1Rel, {'B1_GRUPO',    'BM_GRUPO'}) 
     
    oModel:SetRelation('SB1DETAIL', aSB1Rel, SB1->(IndexKey(1))) 
    oModel:GetModel('SB1DETAIL'):SetUniqueLine({"B1_FILIAL","B1_COD"})    
     
    oModel:SetPrimaryKey({})
     
    
    oModel:SetDescription("Grupo de Produtos ")
    oModel:GetModel('SBMMASTER'):SetDescription('Modelo Grupo')
    oModel:GetModel('SB1DETAIL'):SetDescription('Modelo Produtos')


    oStFilho:AddField( ; 
            AllTrim( 'Incremento' ) , ; // [01] C Titulo do campo
            AllTrim( 'Campo de Auto Incremento' ) , ; // [02] C ToolTip do campo
            'B1_INCRE' , ; // [03] C identificador (ID) do Field
            'C' , ; // [04] C Tipo do campo
            6   , ; // [05] N Tamanho do campo
            0   , ; // [06] N Decimal do campo
            NIL , ; // [07] B Code-block de validação do campo FwBuildFeature( STRUCT_FEATURE_VALID,"Pertence('12')")
            NIL , ; // [08] B Code-block de validação When
            NIL , ; // [09] A Lista de valores permitido do campo
            NIL , ; // [10] L Indica se o campo tem preenchimento obrigatório
            NIL , ; // [11] B Code-block de inicializacao do campo FwBuildFeature( STRUCT_FEATURE_INIPAD, "'2'" )
            NIL , ; // [12] L Indica se trata de um campo chave
            NIL , ; // [13] L Indica se o campo pode rece ual ADvPl utilizando o MVC
            .T. )   // [14] L Indica se o campo é virtualber valor em uma operação de update.

    oModel:AddCalc('COUNTTOTAL','SBMMASTER','SB1DETAIL','B1_PRV1','TOTAL','COUNT')
    
Return oModel
 
Static Function ViewDef()
    Local oView        := Nil
    Local oModel       := FWLoadModel('MVCMd3')
    Local oStPai       := FWFormStruct(2, 'SBM')
    Local oStFilho     := FWFormStruct(2, 'SB1')
    Local oCount       := FWCalcStruct( oModel:GetModel('COUNTTOTAL') )  
    
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    
    oView:AddField('VIEW_SBM',oStPai,'SBMMASTER')
    oView:AddGrid ('VIEW_SB1',oStFilho,'SB1DETAIL')

    
    oView:CreateHorizontalBox('SBMMASTER',30)
    oView:CreateHorizontalBox('SB1DETAIL',50)
     
    
    oView:SetOwnerView('VIEW_SBM','SBMMASTER')
    oView:SetOwnerView('VIEW_SB1','SB1DETAIL')
     
    
    oView:EnableTitleView('VIEW_SBM','Grupo')
    oView:EnableTitleView('VIEW_SB1','Produtos')

    oStFilho:AddField('B1_INCRE' ;
                            , ; // [01] C Nome do Campo
                        '01' , ; // [02] C Ordem
                        AllTrim( 'Incremento' ) , ; // [03] C Titulo do campo
                        AllTrim( 'Campo de incremento' ) , ; // [04] C Descrição do campo
                        { 'Exemplo de Campo Incremento' } , ; // [05] A Array com Help
                        'C' , ; // [06] C Tipo do campo
                        '@!' , ; // [07] C Picture
                        NIL , ; // [08] B Bloco de Picture Var
                        '' , ; // [09] C Consulta F3
                        .T. , ; // [10] L Indica se o campo é evitável
                        NIL , ; // [11] C Pasta do campo
                        NIL , ; // [12] C Agrupamento do campo
                        NIL, ; // [13] A Lista de valores permitido do campo (Combo)
                        NIL , ; // [14] N Tamanho Máximo da maior opção do combo
                        NIL , ; // [15] C Inicializador de Browse
                        .T. , ; // [16] L Indica se o campo é virtual
                        NIL ) // [17] C Pictu
    
    
    oView:AddIncrementField("VIEW_SB1","B1_INCRE")

    
    oView:AddField( 'VCALC_ID', oCount, 'COUNTTOTAL' ) 
    oView:CreateHorizontalBox( 'INFERIOR', 20) 
    oView:SetOwnerView('VCALC_ID','INFERIOR')

Return oView

Static Function MenuDef()
Return FWMVCMenu('MVCMd3')
