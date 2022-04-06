#INCLUDE "RWMAKE.CH"
#INCLUDE "Protheus.ch"
USER FUNCTION MA415END()
LOCAL _aRetUser   := {}
LOCAL cUserOld    := SCJ->CJ_XUSER
Local nTipo       := PARAMIXB[1] 
Local nOperacao   := PARAMIXB[2] 
Local aAreaSCK    := SCK->(GETAREA())
Private _NomCompl := ""

PswOrder(1) 

  IF PswSeek(RetCodUsr(),.T.)
    _aRetUser := PswRet(1)
    _NomCompl := alltrim(_aRetUser[1,4])
  ENDIF

  IF EMPTY(cUserOld)
    RECLOCK("SCJ",.F.)
    SCJ->CJ_XUSER := _NomCompl
    MSUNLOCK()
  ENDIF

  If nTipo == 1 
    If nOperacao == 1 .OR. nOperacao == 2
      Sendmail()
    Endif
  Endif 

RestArea(aAreaSCK)

RETURN()

Static Function Sendmail()

Local cCC, cBCC, cAnexo, cMsg
Local cPara      := GetMV("MV_ORCEMA") 
Local numOrc     := SCK->CK_NUM
Local cAssunto   := "Orcamento"+numOrc+"com Desconto Superior ao Permitido.
Local oServer    := tMailManager():New()
Local oMessage   := tMailMessage():New()
Local cSMTPAddr  := AllTrim(substr(GetMV("MV_RELSERV"),1,len(GetMV("MV_RELSERV"))-(len(cvaltochar(GetMV("MV_PORSMTP")))+1)))      // Endereco do servidor SMTP sem a porta inserida por padrao
Local cPopAddr   := AllTrim(GetMV("MV_POPSERV"))      // Endereco do servidor POP3
Local nSMTPPort  := GetMV("MV_PORSMTP")               // Porta do servidor SMTP
Local nPOPPort   := GetMV("MV_PORPOP3")               // Porta do servidor POP
Local cUser      := AllTrim(GetMV("MV_RELACNT"))      // Usuario que ira realizar a autenticacao
Local cPass      := AllTrim(GetMV("MV_RELPSW"))       // Senha do usuario
Local lAutentica := GetMV("MV_RELAUTH")               // Requer autenticação? 
Local lUseSSL    := GetMV("MV_RELSSL")                // Usa protocolo SSL (padrão = .F., porém utilizado pelo GMail por exemplo)
Local lUseTLS    := GetMV("MV_RELTLS")                // Usa protocolo TLS
Local nSMTPTime  := GetMV("MV_RELTIME")               // Timeout para o servidor de e-mail.
Local nError     := 0
Local nColor     := 1
Private lRet     := .F.

cMsg := "<table border='0'><tr bgcolor='Lavender'><td>Numero do Orcamento</td><td>" + SCK->CK_NUM +"</td>"+"<td>Usuário:</td><td> " +_NomCompl+ "</td></tr>"	
cMsg += "<tr bgcolor='Lavender'><td>Cliente: </td><td>" + SCK->CK_CLIENTE +"</td><td> " +POSICIONE("SA1",1,XFILIAL("SA1")+SCK->CK_CLIENTE, "A1_NOME") + "</td><td></td></tr></table>"
cMsg += "<table border='0'>"  
	      
cMsg += "<tr bgcolor='Lavender'><td>Produto</td>"  +;
        "<td>Descricao</td>"                       +;
        "<td>UM</td>"                              +;
        "<td>Qtd</td>"                             +;
        "<td>Preco Vend</td>"                      +;
        "<td>Valor</td>"                           +;
        "<td>Desconto %</td>"                      +;
        "<td>Valor Desc.</td></tr>"

dbSelectArea("SCK")
dbSetorder(1)
If SCK->(dbSeek(xFilial("SCK") + numOrc))
  While !SCK->(Eof())  .AND. numOrc == SCK->CK_NUM
    If SCK->CK_XDESCON > GetMV("MV_XPERDES")
      lRet := .T.
        If nColor % 2 == 0
          cMsg +="<tr bgcolor='AliceBlue'> "
        else
          cMsg +="<tr>"
        Endif

        cMsg += "<td>"+SCK->CK_PRODUTO                    +"</td>"+;
                "<td>"+SCK->CK_DESCRI                     +"</td>"+;
                "<td>"+PADR(SCK->CK_UM,2)                 +"</td>"+;
                "<td>"+cValtoChar(SCK->CK_QTDVEN)         +"</td>"+;
                "<td>"+cValtoChar(SCK->CK_PRCVEN)         +"</td>"+;
                "<td>"+cValtoChar(SCK->CK_VALOR)          +"</td>"+;
                "<td>"+cValtoChar(SCK->CK_XDESCON)        +"</td>"+;
                "<td>"+cValtoChar(SCK->CK_XVALDES)        +"</td></tr>"
        nColor++
    Endif
   SCK->(dbSkip())
  EndDo
  cMsg += "</table><BR> Itens do orçamento que nao ultrapassaram o limite de desconto nao estarão listados."
Endif
If lRet

    U_EVENTORC(_NomCompl,numOrc)
    
    oServer:setUseSSL(lUseSSL)
    oServer:SetUseTLS(lUseTLS)
    oServer:Init(cPopAddr, cSMTPAddr, cUser, cPass, nPOPPort, nSMTPPort)

    
    If oServer:SetSMTPTimeout(nSMTPTime) != 0
      ConOut("[MCSENDMAIL_ERROR_1] Falha ao definir timeout")
      Return 
    EndIf
    
    nError := oServer:SMTPConnect()
   
    If nError <> 0
      ConOut("[MCSENDMAIL_ERROR_2] Falha ao conectar: " + oServer:GetErrorString(nError))
      oServer:smtpDisconnect()
      Return 
    EndIf
                          
    
    If lAutentica
      nError := oServer:SMTPAuth(cUser, cPass)
      If nError <> 0
        ConOut("[MCSENDMAIL_ERROR_3] Falha ao autenticar: " + oServer:GetErrorString(nError))
        oServer:smtpDisconnect()
      Return 
      EndIf
    EndIf
      
    oMessage:Clear()
    oMessage:cFrom    := cUser
    oMessage:cTo      := AllTrim(cPara)
    oMessage:cCC      := AllTrim(cCC)
    oMessage:cBCC     := AllTrim(cBCC)
    oMessage:cSubject := cAssunto
    oMessage:cBody    := cMsg

    If !Empty(cAnexo)
      oMessage:AttachFile(cAnexo)
    EndIf
                                          
    nError := oMessage:Send(oServer)

    If nError <> 0
      ConOut("[MCSENDMAIL_ERROR_4]Falha ao enviar e-mail: " + oServer:getErrorString(nError))
      oServer:SMTPDisconnect()
      Return 
    EndIf

    oServer:smtpDisconnect()
    
Endif


Return 
