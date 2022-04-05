#include "totvs.ch"
#include "protheus.ch"
#include "rwmake.ch"
/*/{Protheus.doc} compara
description
@type function
@version  
@author Romero
@since 02/02/2022
@return variant, return_description
/*/
User Function compara()
Local aArea             := GetArea()

//Getdados------------
Local nSuperior         := C(60)			// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda         := C(004)			// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior         := C(150)			// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita          := C(245)			// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem

//Parametros de busca
Private cTabela         := "SF4"
Private cPrim           := Space(TamSx3("F4_CODIGO")[1]) 
Private cSeg            := Space(TamSx3("F4_CODIGO")[1])  

//Getdados--------------------
Private nOpc            := 3  // 1 - Visualizar , 2 - Incluir, 3 - Alterar
Private cLinhaOk  		:= "AllwaysTrue"	// Funcao executada para validar o contexto da linha atual do aCols    
Private cTudoOk 	   	:= "AllwaysTrue"	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols) 
Private cIniCpos        := ""
Private aAlter          := {}
Private nFreeze         := 000
Private nMax       		:= 999				// Numero maximo de linhas permitidas. Valor padrao 99                           
Private cCampoOk   		:= "AllwaysTrue"	// Funcao executada na validacao do campo        
Private cSuperApagar	:= ""				// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>      
Private cApagaOk   		:= "AllwaysFalse"   // Funcao executada para validar a exclusao de uma linha do aCols
Private aHeader		    := MontEstr(1)		// aHeader GetDados
Private aCols		    := MontEstr(2)		// aCols   GetDados

//Objeto grafico
Private	_oDlg1   
Private oEdit1         
Private oGetTrans


    @ C(001) , C(001) To C(350) , C(490) Dialog _oDlg1 Title "Dados Complementares"
    //@ C(001) , C(001) To C(450) , C(370) Dialog _oDlg1 Title "Comparacao de cadastros"

    @ C(004) ,  C(005) Say OemtoAnsi("Rotina: ") Size C(039),C(008) PIXEL OF _oDlg1
    @ C(003) ,  C(045) MsGet oEdit1 Var cTabela  VALID (MontEstr(2)) PICTURE "!@" Size C(035),C(006) PIXEL OF _oDlg1 

	// Tabela __________________________________________________________	
	@ C(015) ,  C(002) To C(050) , C(245) LABEL OemtoAnsi("Registro pra Comparar") PIXEL OF _oDlg1	
		
	@ C(028) , C(005) Say OemtoAnsi("Primeiro") PIXEL OF _oDlg1
	@ C(028) , C(045) MsGet oEdit1 Var cPrim  F3 "SF4" VALID (Update()) PICTURE "!@" Size C(040),C(006) PIXEL OF _oDlg1
	
    @ C(028) , C(100) SAY OemtoAnsi("Segundo") PIXEL OF _oDlg1
    @ C(028) , C(135) MsGet oEdit1 Var cSeg  F3 "SF4" VALID (Update()) PICTURE "!@" Size C(040),C(006) PIXEL OF _oDlg1 
	
    @ C(160) , C(095) Button OemtoAnsi("Sair") Size C(037),C(012) Action(_oDlg1:END()) PIXEL OF _oDlg1
	

    oGetTrans := MsNewGetDados():New( nSuperior, nEsquerda, nInferior, nDireita,;
				 nOpc, cLinhaOk, cTudoOk, cIniCpos, aAlter, nFreeze, nMax,;
				 cCampoOk, cSuperApagar, cApagaOk, _oDlg1, aHeader, aCols)

    Activate Dialog _oDlg1 Centered
    
RestArea(aArea)
Return

Static Function MontEstr(nOpcGet)

Local xArea   := GetArea()
Local aCabDet := {}
Local cont    := 1

If nOpcGet == 1  //aHeader

	DbSelectArea("SX3")
	DbSetOrder( 1 )
	Dbgotop()
	MsSeek( cTabela )
	
	While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == cTabela) .AND. cont <= 5 //aHeader
       // If AllTrim(X3_CAMPO) $ "F4_CODIGO,F4_TIPO,F4_ICM,F4_IPI,F4_TEXTO"
			
				AADD( aCabDet, { Alltrim(X3_TITULO), AllTrim(X3_CAMPO), X3_PICTURE, X3_TAMANHO, X3_DECIMAL,"","", X3_TIPO, "", "" } )
				cont++
			
		//Endif
		Dbskip()
	Enddo
	
Else
   	//Primerio Registro------------------------ 
	DbSelectArea( cTabela )
	DbSetOrder(1)
   	DbSeek( xFilial(cTabela) + cPrim )
   		While SF4->(!EOF()) .AND. SF4->F4_CODIGO == cPrim
				AADD(aCabDet,{SF4->&(aHeader[1][2]),SF4->&(aHeader[2][2]),;
			   			  SF4->&(aHeader[3][2]),SF4->&(aHeader[4][2]) ,;
						  SF4->&(aHeader[5][2]),Recno(), .F. } )
			   	Dbskip()
   	    Enddo
    //Segundo Registro------------------------       
   	DbSeek( xFilial(cTabela) + cSeg )
   		While SF4->(!EOF()) .AND. SF4->F4_CODIGO == cSeg 
   	    	AADD(aCabDet,{SF4->&(aHeader[1][2]),SF4->&(aHeader[2][2]),;
			   			  SF4->&(aHeader[3][2]),SF4->&(aHeader[4][2]) ,;
						  SF4->&(aHeader[5][2]),Recno(), .F. } )
   	    	Dbskip()
   	    Enddo
	   
	oGetTrans:Refresh()
	_oDlg1:Refresh()	
	
Endif	
RestArea(xArea)
Return( aCabDet )
Static Function Update()

oGetTrans:aCols := MontEstr(2)
oGetTrans:Refresh()
_oDlg1:Refresh()

Return

 
