#INCLUDE "TOTVS.CH"
#INCLUDE "Protheus.ch"

/*---------------------/{Protheus.doc} U_fAtuSB1()--------------------/
Função para ver os grupos de produto
@author Bruno Romero    
@since 03/02/2022
@version 1.0
@type function
/*---------------------*/
 
User Function fAtuSB1()

Local aArea := GetArea()

//Fontes
Local cFonte        := "Tahoma"
Local oFontBtn      := TFont():New(cFonte,,-14)

// objetos da Grid
Private oDlg         := NIL
Private oGridSB1     := NIL
Private oBtnFech     := NIL
Private oBtnPes      := NIL
Private oBtnPos      := NIL
Private oMGET        := NIL
Private aColsSB1     := {}
Private aHeadT       := {30,70,2,4,10,3,3,8,8}
Private aHeadSB1     := {'Código do Produto','Descrição   ','Armazem','Grupo Produto',;
                        'NCM   ','Tes Entr','Tes Saída','Preço Base','Preço Origem'}
Private cCodigo      := Space(TamSX3("B1_COD")[1])
Private lCancel      
lCancel := Pergunte("CADPRO",.T.)

IF lCancel

    DEFINE MSDIALOG oDlg TITLE "Manutenção Produtos" FROM 000,000 TO 500,940 COLORS 0, 16777215 PIXEL
           
    @ 006,058  BUTTON oBtnFech  PROMPT "Fechar"     SIZE 050,018 OF oDlg ACTION (oDlg:END())                                                            FONT oFontBtn PIXEL
    @ 006,003  BUTTON oBtnPes   PROMPT "Filtro"  SIZE 050,018 OF oDlg ACTION (Pergunte("CADPRO",.T.),Processa({|| faCols()},"Carregando Produtos"))  FONT oFontBtn PIXEL
    @ 010,355  BUTTON oBtnPos   PROMPT "="          SIZE 020,012 OF oDlg ACTION (fPosi())  FONT oFontBtn PIXEL
    
    @ 010,375  MSGET  oMGET  Var cCodigo F3 "SB1"   SIZE 080,010 OF oDlg PICTURE "@!" PIXEL      
        oGridSB1 := TCBrowse():New( 029 , 003, 465, 210,,aHeadSB1,;                                    
														aHeadT,;
														oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,{|| fPOSITIVO()},, )
        
        Processa({|| faCols()},"Carregando Produtos")
        
        oGridSB1:bLDblClick :=  {|| fAlterar() }
        oGridSB1:lAdjustColSize := .T.
        oGridSB1:nScrollType := 0  
        oGridSB1:SetFilter('Código do Produto', cCodigo, cCodigo)   
        oGridSB1:bValid := {||fPOSITIVO()}   

    ACTIVATE MSDIALOG oDlg CENTERED

ENDIF

RestArea(aArea)
Return

Static Function faCols()

Local aArea     := GetArea()
Local nAtual    := 0 
Local nTotal    := 0
Local cQSB1     := ""
Local QSB1      := GetNextAlias()
Local aColaux   := {}

    cQSB1:= " SELECT B1_COD, "
    cQSB1+= " B1_DESC, "   
    cQSB1+= " B1_LOCPAD, "
    cQSB1+= " B1_GRUPO, "
    cQSB1+= " B1_POSIPI, "
    cQSB1+= " B1_TE, "
    cQSB1+= " B1_TS, "
    cQSB1+= " B1_PRV1, "
    cQSB1+= " B1_YUPRCEX "
    cQSB1+= " FROM "+RetSQLName('SB1')+" "
    cQSB1+= " WHERE B1_FILIAL = '" + FWxFilial('SB1') +"' AND B1_COD >=  '"+MV_PAR01+"' AND B1_COD <=  '"+MV_PAR02+" "
    cQSB1+= "' AND B1_GRUPO >='"+MV_PAR03+"'AND B1_GRUPO <='"+MV_PAR04+"' AND D_E_L_E_T_ = '' " 

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQSB1 ),QSB1, .F., .T. )
    DbSelectArea(QSB1)
    
    Count To nTotal
    ProcRegua(nTotal)

    (QSB1)->(DbGotop())

    While !((QSB1)->(EOF())) 
            
        AADD(aColaux, { (QSB1)->B1_COD      ,;
                        (QSB1)->B1_DESC     ,;
                        (QSB1)->B1_LOCPAD   ,;
                        (QSB1)->B1_GRUPO    ,;
                        (QSB1)->B1_POSIPI   ,;
                        (QSB1)->B1_TE       ,;
                        (QSB1)->B1_TS       ,;
                        (QSB1)->B1_PRV1     ,;
                        (QSB1)->B1_YUPRCEX  })
                           
        (QSB1)->(DbSkip())
        nAtual++
        IncProc("Adicionando " + Alltrim((QSB1)->B1_COD) + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")
    End

aColsSB1 := AClone(aColaux)
oGridSB1:SetArray(aColsSB1) 
oGridSB1:bLine := {||{  aColsSB1[oGridSB1:nAt,01],;
                        aColsSB1[oGridSB1:nAt,02],; 
                        aColsSB1[oGridSB1:nAt,03],; 
                        aColsSB1[oGridSB1:nAt,04],; 
                        aColsSB1[oGridSB1:nAt,05],;
                        aColsSB1[oGridSB1:nAt,06],;
                        aColsSB1[oGridSB1:nAt,07],;
                        Transform(aColsSB1[oGridSB1:nAT,08],'@E 99,999,999,999.99'),;
                        Transform(aColsSB1[oGridSB1:nAT,09],'@E 99,999,999,999.99')}}
                       
oGridSB1:Refresh() 
RestArea(aArea)
Return 


Static Function fAlterar()

Local aArea     := GetArea()
Local nPosCod   := aScan(aHeadSB1,"Código do Produto") 
Local nPosPB    := aScan(aHeadSB1,"Preço Base")
Local nPosPO    := aScan(aHeadSB1,"Preço Origem")
Local nValAntPB := aColsSB1[oGridSB1:nAt][nPosPB]
Local nValAntPO := aColsSB1[oGridSB1:nAt][nPosPO]


DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+aColsSB1[oGridSB1:nAt][nPosCod])

IF  oGridSB1:ColPos() == nPosPB .OR. oGridSB1:ColPos() == nPosPO
    
    lEditCell(@aColsSB1,oGridSB1,"@R 999999.99",oGridSB1:ColPos())

    IF aColsSB1[oGridSB1:nAt][nPosCod] == SB1->B1_COD

        If oGridSB1:nColPos == nPosPB
            If aColsSB1[oGridSB1:nAt][nPosPB] >= 0        
                RecLock("SB1",.F.)
                SB1->B1_PRV1       := aColsSB1[oGridSB1:nAt][nPosPB] 
                SB1->(MSUNLOCK())
            Else
                aColsSB1[oGridSB1:nAt][nPosPB] := nValAntPB
            Endif
        Endif

        If oGridSB1:nColPos == nPosPO
            If aColsSB1[oGridSB1:nAt][nPosPO] >= 0                
                RecLock("SB1",.F.)
                SB1->B1_YUPRCEX    := aColsSB1[oGridSB1:nAt][nPosPO] 
                SB1->(MSUNLOCK())
            Else
                aColsSB1[oGridSB1:nAt][nPosPO] := nValAntPO
            Endif        
        Endif

    Endif        
            

Endif
RestArea(aArea)
oGridSB1:Refresh()   

Return

Static Function fPosi()

Local nF        := 0
Local nPosCod   := aScan(aHeadSB1,"Código do Produto")

IF !EMPTY(cCodigo)
    For nF := 1 TO Len(aColsSB1)
        IF aColsSB1[nF][nPosCod] == cCodigo
            oGridSB1:GoPosition(nF)
        ENDIF
    NEXT
ENDIF


Return

Static Function fPOSITIVO()
Local lRet := .T.
Local nPosPB    := aScan(aHeadSB1,"Preço Base")

    IF aColsSB1[oGridSB1:nAt][nPosPB] >0
        Return lRet
    Else
        lRet := .F.
    ENDIF

Return lRet
