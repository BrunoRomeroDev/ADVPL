#Include "Protheus.ch"

User Function LeArqTxt()

	Private nOpc      	:= 0
	Private cCadastro 	:= "Ler arquivo texto"
	Private aSay      	:= {}
	Private aButton   	:= {}

	aAdd( aSay, "O objetivo desta rotina e efetuar a leitura em um arquivo texto" )

	aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
	aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

	FormBatch( cCadastro, aSay, aButton )

	If nOpc == 1
		Processa( {|| Import() }, "Processando..." )
	EndIf

Return Nil

Static Function Import()

	Local cBuffer   	:= ""
	Local cFileOpen 	:= ""
	Local cTitulo1  	:= "Selecione o arquivo"
	Local cExtens   	:= "Arquivo TXT | *.txt"

	Private cMainPath := ""

	cFileOpen := cGetFile(cExtens,cTitulo1,,cMainPath,.T.)

	If !File(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não localizado",cCadastro)
		Return
	Endif

	FT_FUSE(cFileOpen)  
	FT_FGOTOP()

	ProcRegua(FT_FLASTREC()) 

	While !FT_FEOF()  
		IncProc()

		
		cBuffer := FT_FREADLN() 

		cMsg := "Filial: "		+SubStr(cBuffer,01,02) + Chr(13)+Chr(10)
		cMsg += "Código: "   	+SubStr(cBuffer,03,06) + Chr(13)+Chr(10)
		cMsg += "Loja: "  		+SubStr(cBuffer,09,02) + Chr(13)+Chr(10)
		cMsg += "Nome fantasia: " 	+SubStr(cBuffer,11,15) + Chr(13)+Chr(10)
		cMsg += "Valor: "   	     	+SubStr(cBuffer,26,14) + Chr(13)+Chr(10)
		cMsg += "Data: "          	+SubStr(cBuffer,40,08) + Chr(13)+Chr(10)

		MsgInfo(cMsg)

		FT_FSKIP()   
	EndDo

	FT_FUSE() 

	MsgInfo("Processo finalizada")

Return Nil
