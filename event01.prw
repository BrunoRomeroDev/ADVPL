#include 'FWEVENTVIEWCONSTS.CH'

/**
* AUTOR: Bruno Romero
* DATA: 18/03/2022
* HORA: 12:19
* FINALIDADE DO PROGRAMA: CRIAR EVENTO CUSTOMIZADO. 
*   ENVIA O NUMERO DO ORCAMENTO E O NOME DO USU�RIO DO OR�AMENTO CASO TENHA ULTRAPASSADO O LIMITE DE DESCONTO
* TESTE: U_EVENTORC("ADMIN","000001")
*/

User Function EVENTORC(cUser,cNumero)

    Local cEventId := "Z01"

    Local cMensagem := "Or�amento "+cNumero+ " realizado pelo usu�rio "+cUser

    Local cTitulo := "Desconto Superior ao permitido "  //FUNCAO TIME PEGA O HORARIO ATUAL BASEADO NO S.O

    //RPCSETENV("01", "01") //ABERTURA DO AMBIENTE PASSANDO OS ARGUMENTOS EMPRESA E FILIAL RESPECTIVAMENTE
    
    EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventId, FW_EV_LEVEL_WARNING, "", cTitulo, cMensagem, .T.) //CHAMADA DO EVENTO

Return Nil

/* Voc� poder� alterar o quarto argumento passado na fun��o EventInsert por qualquer um dos valores listados abaixo. 
As outras constantes mantenha pois � padr�o. 
Palavra chave           Significado                 Cor 
FW_EV_LEVEL_INFO	    MENSAGEM DE INFORMAC�O	    CINZA
FW_EV_LEVEL_ERROR	    MENSAGEM DE ERRO	        VERMELHO
FW_EV_LEVEL_WARNING	    MENSAGEM DE ATEN��O	        AMARELO
*/
