#include "totvs.ch"

/*------------------------------------------------------------------*
|Função:															|			
|xOrcamento															|	
|																	|
|Autor:																|
|Bruno Romero														|
|																	|
|Data:																|
|03/05/2021															|
|																	|
|Descrição:															|
|Impressão de relatório de integração com o Word/PDF.				|
|Relatório inserido no menu Outras Ações da rotina de Orçamento		|
|																	|	
*------------------------------------------------------------------*/

User Function xOrcamento()

Local aItens     := {}
Local nK         := 0
Local nItem      := 0 
Local nVaLiq 	 := 0 
Local nValMerc   := 0
Local nPrcLista  := 0
Local nAcresFin  := 0
Local nDesconto  := 0
Local nAliqPis	 := 0 
Local nAliqCof	 := 0 
Local nAliqIpi   := 0
Local nAliqIcm   := 0
Local nAliqSol   := 0 
Local nVlrIpi	 := 0
Local nVlrIcm	 := 0
Local nVlrSol    := 0
Local nValCOF    := 0 
Local nValPIS	 := 0 
Local nTotMerc   := 0
Local nTotServ   := 0
Local nTotIpi    := 0
Local nTotSol    := 0
Local nTotFrete  := 0
Local cArqName   := Upper(GetNewPar("ES_ORCAMEN", "xORCAMENTO.DOT"))
Local cPDFName   := StrTran(cArqName, ".DOT", ".PDF")
Local cPathLoc   := "C:\MODELOS"
Local cArqLoc    := cPathLoc + "\" + cArqName
Local cPDFLoc    := cPathLoc + "\" + cPDFName 
Local cPathSrv   := "\MODELOS"
Local cArqSrv    := cPathSrv + "\" + cArqName
Local cPDFSrv    := cPathSrv + "\" + cPDFName 
Local cNome      := ""
Local cInscr     := ""
Local cCGC       := ""
Local cEnd       := ""
Local cCliente   := ""
Local cCEP       := ""
Local cBairro    := ""
Local cMun       := ""
Local cUF        := ""
Local cContat    := ""
Local cEmail     := ""
Local cTel       := ""
Local cFax       := ""
Local cCel       := ""
Local cDepto     := ""
Local cConsultor := ""
Local cNomVend   := ALLTRIM(SCJ->CJ_XUSER)
Local oDialog    := Nil
Local oFont1     := TFont():New(,,16,,.T.)
Local cPara      := ""
Local cCC        := ""
Local cBCC       := ""
Local cAssunto   := ""
Local nOpcao     := 0
Local cSitCof	 := ""
Local cSitPis	 := ""
Local cTesF		 := ""
Local nF		 := 0
Local aIpif 	 := {}
Local aTotf		 := 0

//+----------------------------------------------------+
//| Verifica se existe o diretório de modelos na pasta |
//| local do usuário. Caso não exista cria o diretório | 
//+----------------------------------------------------+
If !ExistDir(cPathLoc) .And. MakeDir(cPathLoc) <> 0
	Aviso("Atenção", "Não foi possível criar a pasta de modelos: " + cPathLoc, {"Ok"}) 
	Return .F.
EndIf
	
//+----------------------------------------------------+
//| Verifica se já existe um arquivo local na máquina  |
//| do usuário, e caso exista deleta o mesmo.          | 
//+----------------------------------------------------+
If Len(Directory(cArqLoc)) > 0
	If FErase(cArqLoc) < 0// Apaga o arquivo
		Aviso("Atenção", "Não foi possível excluir o arquivo " + cArqLoc + ". Verifique se o mesmo está aberto ou sendo utilizado por outro programa.", {"Ok"})
		Return .F.
	EndIf
EndIf

//+--------------------------------------------------------------------+
//| Efetua copia do arquivo do server para a estação local do usuário  |
//+--------------------------------------------------------------------+
If !CpyS2T(cArqSrv, cPathLoc, .T.)
	Aviso("Atenção", "Não foi possível Efetuar a cópia do arquivo de modelo do servidor para o computador do usuário.", {"Ok"})
	Return .F.
EndIf

// Obtem informações do cliente do orçamento
dbSelectArea("SA1")
SA1->(dbSetOrder(1)) // FILIAL + CLIENTE + LOJA
If SA1->(dbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
	
	cNome    := Capital(AllTrim(SA1->A1_NOME))
	cInscr   := SA1->A1_INSCR
	cCGC     := Transform(SA1->A1_CGC, StrTran(PicPes(SA1->A1_PESSOA), "%C", ""))
	cEnd     := Capital(AllTrim(SA1->A1_END))
	cCliente := SA1->A1_COD + "/" + SA1->A1_LOJA
	cCEP     := Transform(SA1->A1_CEP, "@R 99999-999")
	cBairro  := Capital(AllTrim(SA1->A1_BAIRRO))
	cMun     := Capital(AllTrim(SA1->A1_MUN))
	cUF      := SA1->A1_EST
	
EndIf

//+-----------------------------------------------+
//| Obtem informações do contato do orçamento     |
//+-----------------------------------------------+
dbSelectArea("SU5")
SU5->(dbSetOrder(1)) // FILIAL + CODCON + IDEXC
If SU5->(dbSeek(xFilial("SU5") + SCJ->CJ_CODCON))

	cContat := Capital(AllTrim(SU5->U5_CONTAT))
	cEmail  := SU5->U5_EMAIL
	cTel    := Iif(Empty(SU5->U5_DDD) .Or. Empty(SU5->U5_FCOM1)  , "", "(" + AllTrim(SU5->U5_DDD) + ") ") + Transform(SU5->U5_FCOM1, "@R 9999-9999")
	cFax    := Iif(Empty(SU5->U5_DDD) .Or. Empty(SU5->U5_FAX)    , "", "(" + AllTrim(SU5->U5_DDD) + ") ") + Transform(SU5->U5_FAX, "@R 9999-9999")
	cCel    := Iif(Empty(SU5->U5_DDD) .Or. Empty(SU5->U5_CELULAR), "", "(" + AllTrim(SU5->U5_DDD) + ") ") + Transform(SU5->U5_CELULAR, Iif(Len(AllTrim(SU5->U5_CELULAR)) == 8, "@R 9999-9999", "@R 9 9999-9999"))
	cDepto  := Capital(AllTrim(SU5->U5_XDEPTO))
	
EndIf

//+-----------------------------------------------+
//| Obtem informações do consultor/representante  |
//+-----------------------------------------------+
dbSelectArea("SA3")
SA3->(dbSetOrder(1)) // FILIAL + VENDEDOR
If SA3->(dbSeek(xFilial("SA3") + SA1->A1_VEND))

	cConsultor := Capital(AllTrim(SA3->A3_NREDUZ))
	
EndIf

//+-----------------------------------------------+
//| Inicia função fiscal para obter impostos      |
//+-----------------------------------------------+
MaFisSave()
MaFisEnd()
MaFisIni( SCJ->CJ_CLIENTE,; // Codigo Cliente/Fornecedor
          SCJ->CJ_LOJAENT,; // Loja do Cliente/Fornecedor
          "C"            ,; // C:Cliente , F:Fornecedor
          "N"            ,; // Tipo da NF( "N","D","B","C","P","I" )
          SA1->A1_TIPO   ,; // Tipo do Cliente/Fornecedor
          Nil            ,; // Relacao de Impostos que suportados no arquivo
          Nil            ,; // Tipo de complemento
          Nil            ,; // Permite Incluir Impostos no Rodape .T./.F.
          Nil            ,; // Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
          "MATA461")        // Nome da rotina que esta utilizando a funcao

//+-----------------------------------------------+
//| Carrega as informações dos itens do orçamento |
//+-----------------------------------------------+
dbSelectArea("SCK")
SCK->(dbSetOrder(2)) // FILIAL + CLIENTE + LOJA + NUMERO + ITEM + PRODUTO
If SCK->(dbSeek(xFilial("SCK") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA + SCJ->CJ_NUM))
	While !SCK->(Eof()) .And. SCK->CK_FILIAL + SCK->CK_CLIENTE + SCK->CK_LOJA + SCK->CK_NUM  == xFilial("SUB") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA + SCJ->CJ_NUM
	
		dbSelectArea("SB1")
		SB1->(dbSetOrder(1)) // FILIAL + PRODUTO
		SB1->(dbSeek(xFilial("SB1") + SCK->CK_PRODUTO))
		
		dbSelectArea("SF4")
		SF4->(dbSetOrder(1)) // FILIAL + TES
	    SF4->(dbSeek(xFilial("SF4") + SCK->CK_TES))
	    
	    cSitCof :=SF4->F4_CSTCOF
	    cSitPis :=SF4->F4_CSTPIS
		//+--------------------------------------------------------------+
		//| Calcula o preco de lista                                     |
		//+--------------------------------------------------------------+
		nItem++
		nValMerc  := SCK->CK_VALOR
		nPrcLista := SCK->CK_PRUNIT
		
		If ( nPrcLista == 0 )
			nPrcLista := A410Arred(nValMerc / SCK->CK_QTDVEN,"CK_PRCVEN")
		EndIf
		
		nAcresFin := A410Arred(SCK->CK_PRCVEN * SE4->E4_ACRSFIN / 100, "D2_PRCVEN") 
		nValMerc  += A410Arred(nAcresFin * SCK->CK_QTDVEN, "D2_TOTAL")
		nDesconto := A410Arred(nPrcLista * SCK->CK_QTDVEN, "D2_DESCON") - nValMerc
		nDesconto := Iif(nDesconto == 0, SCK->CK_VALDESC, nDesconto)
		nDesconto := Max(0, nDesconto)
		nPrcLista += nAcresFin
		nValMerc  += nDesconto
		
		//+--------------------------------------------------------------+
		//| Adiciona as variáveis nas funções fiscais                    |
		//+--------------------------------------------------------------+
		MaFisAdd(SCK->CK_PRODUTO	     			,;                		// Produto
				 SCK->CK_TES						,;                		// TES
				 SCK->CK_QTDVEN						,;                		// Quantidade
				 nPrcLista							,;                		// Preco unitario
				 nDesconto				  			,;                		// Valor do desconto
				 ""                     			,;                		// Numero da NF original
				 ""                     			,;                		// Serie da NF original
				 0                      			,;                		// Recno da NF original
				 0			            			,;                		// Valor do frete do item
				 0                      			,;                		// Valor da despesa do item
				 0                      			,;                		// Valor do seguro do item
				 0                     				,;                		// Valor do frete autonomo
				 nValMerc							,;			  			// Valor da mercadoria
				 0 )                                   	  					// Valor da embalagem 
		
		//+--------------------------------------------------------------+
		//| Calculo do ISS                                               |
		//+--------------------------------------------------------------+
		If SA1->A1_INCISS == "N" 
			If SF4->F4_ISS == "S"
				nPrcLista := a410Arred(nPrcLista / (1 - (MaAliqISS(nItem) / 100)), "D2_PRCVEN")
				nValMerc  := a410Arred(nValMerc / (1 - (MaAliqISS(nItem) / 100)), "D2_PRCVEN")
				MaFisAlt("IT_PRCUNI", nPrcLista, nItem)
				MaFisAlt("IT_VALMERC", nValMerc, nItem)
			EndIf
		EndIf
		
		nAliqCof := MaFisRet(nItem, "IT_ALIQCF2")
		nAliqPis := MaFisRet(nItem, "IT_ALIQPS2")
		nAliqIpi := MaFisRet(nItem, "IT_ALIQIPI")
		nAliqIcm := MaFisRet(nItem, "IT_ALIQICM")
		nAliqSol := MaFisRet(nItem, "IT_ALIQSOL") 
		nVlrIpi	 := MaFisRet(nItem, "IT_VALIPI" )
		nVlrIcm	 := MaFisRet(nItem, "IT_VALICM" )
		nVlrSol	 := MaFisRet(nItem, "IT_VALSOL" )
		nAliqCof := MaFisRet(nItem, "IT_ALIQCF2")   
		nValCOF  := MaFisRet(nItem, "IT_VALCF2" )
		nAliqPis := MaFisRet(nItem, "IT_ALIQPS2")
		nValPIS  := MaFisRet(nItem, "IT_VALPS2" )     
	 
		
		nValiq	 := SCK->CK_PRCVEN-((nValCOF/SCK->CK_QTDVEN)+(nValPIS/SCK->CK_QTDVEN)+(nVlrIcm/SCK->CK_QTDVEN))	
		
		If SB1->B1_TIPO == "MO"
			nTotServ += SCK->CK_VALOR
		Else
			nTotMerc += SCK->CK_VALOR
		EndIf
	      
		//+--------------------------------------------------------------+
		//| Tratamento IPI                   |
		//+--------------------------------------------------------------+ 
		
		cTesF := Posicione("SF4",1,xFilial("SF4")+MaFisRet(nItem,"IT_TES"),"F4_IPIFRET")
		IF cTesF == "S"
			AADD(aIpif,{SCK->CK_PRODUTO,SCK->CK_VALOR,nAliqIpi,nVlrIpi})
		ELSE
			nTotIpi  += nVlrIpi
		ENDIF 
		//------------------------------------      
		nTotSol  += nVlrSol
	
		//+--------------------------------------------------------------+
		//| Grava valores no array para uso posterior.                   |
		//+--------------------------------------------------------------+ 
		
		If !EMPTY(SCK->CK_PROPOST)
			_cEntreg := " - "
		Else
			_cEntreg := AllTrim(SCK->CK_XPRZENT) + Iif(Empty(SCK->CK_XPRZENT), "", " dias")
		EndIf             
		
		aAdd(aItens, {AllTrim(SCK->CK_ITEM),;
		              AllTrim(Transform(SCK->CK_QTDVEN, "@E 99,999")),;
		              AllTrim(SCK->CK_PRODUTO),;
		              AllTrim(AllTrim(SCK->CK_DESCRI) + Iif(Empty(SB1->B1_YNARRAT), "", " - " + AllTrim(SB1->B1_YNARRAT))),; 
		              AllTrim(Transform(nValiq, "@E 999,999,999.99")),;
		              AllTrim(Transform(SCK->CK_PRCVEN, "@E 999,999,999.99")),;
		              AllTrim(Transform(SCK->CK_VALOR, "@E 999,999,999.99")),;
		              AllTrim(SB1->B1_POSIPI),;     
		              AllTrim(Transform(nAliqPis, "@E 99.99")),;
		              AllTrim(Transform(nAliqCof, "@E 99.99")),;
		              AllTrim(Transform(nAliqIcm, "@E 99.99")),;
		              AllTrim(Transform(nAliqIpi, "@E 99.99")),;
		              AllTrim(Transform(nVlrSol , "@E 999,999,999.99")),;
		              _cEntreg,;
		              AllTrim(SCK->CK_OBS)})		
	
		SCK->(dbSkip())
	EndDo 

EndIf

nTotFrete := MaFisRet(nItem, "NF_FRETE" )  
	
		//+--------------------------------------------------------------+
		//| Soma o IPI com frete na base
		//+--------------------------------------------------------------+ 

		For nF := 1 To Len(aIpif)
			aIpif[nF][4] := (((((aIpif[nF][2]*100)/nTotMerc)/100)*SCJ->CJ_FRETE)+aIpif[nF][2])*(aIpif[nF][3]/100)
			aTotf	 += aIpif[nF][4]		
		Next nF 
		nTotIpi += aTotf
MaFisRestore()  


//+---------------------------------------------+
//| Verifica se já existe conexão com o Word    |
//+---------------------------------------------+
If Type("hWord") <> "U"
	OLE_CloseLink( hWord ) // Corta o link com o arquivo
	hWord := Nil
	
EndIf
//+-----------------+
//| Conecta ao Word |
//+-----------------+
hWord	:= OLE_CreateLink()
OLE_NewFile(hWord, cArqLoc)

//+-------------------------------------+
//| Montagem das variaveis do cabecalho |
//+-------------------------------------+
OLE_SetDocumentVar(hWord, "ORCAMENTO"   , SCJ->CJ_NUM)
OLE_SetDocumentVar(hWord, "EMISSAO"     , DtoC(SCJ->CJ_EMISSAO))
OLE_SetDocumentVar(hWord, "CLIENTE"     , cNome)
OLE_SetDocumentVar(hWord, "INSCRICAOEST", cInscr)
OLE_SetDocumentVar(hWord, "CGC"         , cCGC)
OLE_SetDocumentVar(hWord, "ENDERECO"    , cEnd)
OLE_SetDocumentVar(hWord, "CEP"         , cCEP)
OLE_SetDocumentVar(hWord, "BAIRRO"      , cBairro)
OLE_SetDocumentVar(hWord, "CIDADE"      , cMun)
OLE_SetDocumentVar(hWord, "UF"          , cUF)
OLE_SetDocumentVar(hWord, "SOLICITANTE" , cContat)
OLE_SetDocumentVar(hWord, "EMAIL"       , cEmail)
OLE_SetDocumentVar(hWord, "DEPARTAMENTO", cDepto)
OLE_SetDocumentVar(hWord, "TELEFONE"    , cTel)
OLE_SetDocumentVar(hWord, "FAX"         , cFax)
OLE_SetDocumentVar(hWord, "CELULAR"     , cCel)
OLE_SetDocumentVar(hWord, "CODIGO"      , cCliente)

//+------------------------------------------------------------------------+
//| variavel para identificar o numero total de linhas na parte variavel   |
//| Sera utilizado na macro do documento para execucao do for next         |
//+------------------------------------------------------------------------+
OLE_SetDocumentVar(hWord, 'prt_nroitens',str(Len(aItens)))

//+------------------------------------------------------------------------+
//| Define o nome do arquivo PDF que será gerado.                          |
//+------------------------------------------------------------------------+
OLE_SetDocumentVar(hWord, 'PathPDF', cPDFLoc)															

//+------------------------------------------------------------------------------------+
//| Montagem das variaveis dos itens.                                                  |
//| No documento word estas variaveis serao criadas dinamicamente da seguinte forma:   |
//| prt_equipamentos1, prt_equipamentos2 ... prt_equipamentos10                        |
//+------------------------------------------------------------------------------------+
For nK := 1 to Len(aItens)
	OLE_SetDocumentVar(hWord,"prt_item"        + AllTrim(Str(nK)), aItens[nK, 01])
	OLE_SetDocumentVar(hWord,"prt_quantidade"  + AllTrim(Str(nK)), aItens[nK, 02])
	OLE_SetDocumentVar(hWord,"prt_produto"     + AllTrim(Str(nK)), aItens[nK, 03])
	OLE_SetDocumentVar(hWord,"prt_descricao"   + AllTrim(Str(nK)), aItens[nK, 04])
	OLE_SetDocumentVar(hWord,"prt_valor_unit_liq"   + AllTrim(Str(nK)), aItens[nK, 05])	
	OLE_SetDocumentVar(hWord,"prt_valor_unit"  + AllTrim(Str(nK)), aItens[nK, 06])
	OLE_SetDocumentVar(hWord,"prt_valor_total" + AllTrim(Str(nK)), aItens[nK, 07])
	OLE_SetDocumentVar(hWord,"prt_ncm"         + AllTrim(Str(nK)), aItens[nK, 08])
	OLE_SetDocumentVar(hWord,"prt_pis"        + AllTrim(Str(nK)), aItens[nK, 09])
	OLE_SetDocumentVar(hWord,"prt_cofins"        + AllTrim(Str(nK)), aItens[nK, 10])
	OLE_SetDocumentVar(hWord,"prt_icms"        + AllTrim(Str(nK)), aItens[nK, 11])
	OLE_SetDocumentVar(hWord,"prt_ipi"         + AllTrim(Str(nK)), aItens[nK, 12])
	OLE_SetDocumentVar(hWord,"prt_icms_st"     + AllTrim(Str(nK)), aItens[nK, 13])
	OLE_SetDocumentVar(hWord,"prt_entrega"     + AllTrim(Str(nK)), aItens[nK, 14])
	OLE_SetDocumentVar(hWord,"prt_observacao"  + AllTrim(Str(nK)), aItens[nK, 15])
	
Next nK

//+-------------------------------------+
//| Montagem das variaveis do rodapé    |
//+-------------------------------------+
OLE_SetDocumentVar(hWord, "TIPOFRETE"       , Iif(Empty(SCJ->CJ_XFRETE), "", AllTrim(X3Combo("CJ_XFRETE", SCJ->CJ_XFRETE))))
OLE_SetDocumentVar(hWord, "VALORPRODUTO"    , AllTrim(Transform(nTotMerc,  "@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, "VALORSERVICO"    , AllTrim(Transform(nTotServ,  "@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, "VALORIPI"        , AllTrim(Transform(nTotIpi,   "@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, "VALORICMSST"     , AllTrim(Transform(nTotSol,   "@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, "VALORFRETE"      , AllTrim(Transform(SCJ->CJ_FRETE, "@E 999,999,999.99"))) ///OLE_SetDocumentVar(hWord, "VALORFRETE"      , AllTrim(Transform(nTotFrete, "@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, "VALORTOTAL"      , AllTrim(Transform(nTotMerc + nTotIpi + nTotServ + nTotSol + SCJ->CJ_FRETE, "@E 999,999,999.99")))
OLE_SetDocumentVar(hWord, "CONDPAGAMENTO"   , AllTrim(Posicione("SE4", 1, xFilial("SE4") + SCJ->CJ_CONDPAG, "E4_DESCRI")))
OLE_SetDocumentVar(hWord, "VALIDADEPROPOSTA", AllTrim(Str(SCJ->CJ_VALIDA - SCJ->CJ_EMISSAO)) + " Dias")
OLE_SetDocumentVar(hWord, "CONSULTOR"       , cConsultor)
OLE_SetDocumentVar(hWord, "VENDEDOR"        , cNomVend)
OLE_SetDocumentVar(hWord, "MENSAGEMNOTA"    , AllTrim(SCJ->CJ_XMENNF))

//+-----------------------------------------------------------------------+
//| Executa as macros do documentos para preenchimento das variáveis      |
//+-----------------------------------------------------------------------+
OLE_ExecuteMacro(hWord,"InsereItens")

OLE_ExecuteMacro(hWord,"UpdateHeaderFields")
		
//+-----------------------------------------------------------------------+
//| Atualizando as variaveis do documento do Word                         |
//+-----------------------------------------------------------------------+
OLE_UpdateFields(hWord)

//+-----------------------------------------------------------------------+
//| Verifica se já existe um arquivo PDF na máquina do usuário, e caso    |
//| exista deleta o mesmo.                                                | 
//+-----------------------------------------------------------------------+
If Len(Directory(cPDFLoc)) > 0
	If FErase(cPDFLoc) < 0// Apaga o arquivo
		Aviso("Atenção", "Não foi possível excluir o arquivo " + cPDFLoc + ". Verifique se o mesmo está aberto ou sendo utilizado por outro programa.", {"Ok"})
		Return .F.
	EndIf
EndIf

OLE_ExecuteMacro(hWord,"SaveToPDF")
OLE_CloseFile( hWord )
OLE_CloseLink( hWord )


Sleep(5000) // Aguarda atualização e gravações antes de abrir o arquivo 

nRet := ShellExecute("open", cPDFLoc, "", "", 1)

//+-----------------------------------------------------------------------+
//| Envia o arquivo PDF via e-mail para o contato do cliente.             |
//+-----------------------------------------------------------------------+
If nRet <= 32
	MsgStop( "Nao foi possivel abrir o arquivo " + cPDFLoc )
EndIf
	
Return .T.

