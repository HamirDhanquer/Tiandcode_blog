
/*/{Protheus.doc} zTAPI001
(Envio de dados usando PUT e POST)
@type user function
@author Hamir
@since 21/11/2025
@version version
/*/
User Function zTAPI001()
    //Local cServer   := "10.172.22.122"                               // URL (IP) DO SERVIDOR
    //Local cPort     := "5085"                                        // PORTA DO SERVIÇO REST
    Local cURI      := "https://pedmais-dev.weduu.com/api" // URI DO SERVIÇO REST
    //Local cURI      := "http://" + cServer + ":" + (cPort + "/rest") // URI DO SERVIÇO REST
    Local cResource := "/mpr/upload_customers"                  // RECURSO A SER CONSUMIDO
    Local oRest     := FwRest():New(cURI)         
    Local cToken    := GeraWDToken()                   // CLIENTE PARA CONSUMO REST
    Local aHeader   := {} 
    Local cBody     := GetJson()         

    // PREENCHE CABEÇALHO DA REQUISIÇÃO
   // AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "Authorization: Bearer " + cToken)
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    //AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

    // INFORMA O RECURSO E INSERE O JSON NO CORPO (BODY) DA REQUISIÇÃO
    oRest:SetPath(cResource)
    //oRest:SetPostParams(cBody)

    // REALIZA O MÉTODO POST E VALIDA O RETORNO
    //If (oRest:Post(aHeader)) => OK
    If (oRest:Put(aHeader,cBody))
        ConOut("POST: " + oRest:GetResult())
    Else
        ConOut("POST: " + oRest:GetLastError())
    EndIf
Return (NIL)

// CRIA O JSON QUE SERÁ ENVIADO NO CORPO (BODY) DA REQUISIÇÃO
Static Function GetJson()
    Local cBody := ""

		cBody += ' { ' 
		cBody += ' "cnpj":            "05212086000187", '                 
		cBody += ' "cd_customer":     "000001", '    
		cBody += ' "note":            "A E B RAPOSO E CIA LTDA", ' 
		cBody += ' "name":            "A E B RAPOSO E CIA LTDA", ' 
		cBody += ' "uf":              "SP", ' 
		cBody += ' "shipping_type":   "C", ' 
		cBody += ' "payment_terms_1": "004", ' 
		cBody += ' "payment_type_id": "237-1221-0412023", '          
		cBody += ' "email":           "compras@raposo.net.br" ' 
		cBody += ' } ' 
Return cBody 

/*/{Protheus.doc} MPRWD01
(Gerar Token)
@author Hamir Dhanquer
@since 23/10/2025
@version 1.0
@type function
/*/
Static Function GeraWDToken()
    Local cToken    := ""
	Local oIntWd    as Object 

	oIntWd := custom.mpr.ConnectWeduu():New()
	cToken := oIntWd:wdToken()

	oIntWd:deActivate()
Return(cToken)
/*
Static Function GetJson()
    Local bObject := {|| JsonObject():New()}
    Local oJson   := Eval(bObject)

    oJson["code"]                               := "CLT024"
    oJson["branchId"]                           := "01"
    oJson["name"]                               := "MENIACX IMPORTAÇÕES CORP"
    oJson["shortName"]                          := "MENIACX CORP"
    oJson["type"]                               := 1
    oJson["strategicCustomerType"]              := "F"
    oJson["address"]                            := Eval(bObject)
    oJson["address"]["state"]                   := Eval(bObject)
    oJson["address"]["state"]["stateId"]        := "SP"
    oJson["address"]["address"]                 := "AVENIDA SOUZA CRUZ"
    oJson["address"]["city"]                    := Eval(bObject)
    oJson["address"]["city"]["cityDescription"] := "JARDIM ALVES CARMO"
Return (oJson:ToJson()) 
*/
