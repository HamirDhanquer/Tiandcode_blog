#include "totvs.ch"

/*/{Protheus.doc} cs01wsrestful
Servico REST em AdvPL para manutencao do cadastro de clientes (SA1).
@type class
@author Antigravity
@since 10/07/2026
@version 1.0
/*/
WSRESTFUL cs01wsrestful DESCRIPTION "Servico REST de Cadastro de Clientes (SA1)"
    WSDATA limit  as Integer
    WSDATA offset as Integer

    WSMETHOD GET DESCRIPTION "Retorna os dados do cliente ou lista de clientes" ;
        WSSYNTAX "/cs01wsrestful || /cs01wsrestful/{id}" ;
        PATH "/cs01wsrestful"

    WSMETHOD POST DESCRIPTION "Insere um novo cliente" ;
        WSSYNTAX "/cs01wsrestful" ;
        PATH "/cs01wsrestful"

    WSMETHOD PUT DESCRIPTION "Altera um cliente existente" ;
        WSSYNTAX "/cs01wsrestful/{id}" ;
        PATH "/cs01wsrestful/{id}"

    WSMETHOD DELETE DESCRIPTION "Exclui/inativa um cliente" ;
        WSSYNTAX "/cs01wsrestful/{id}" ;
        PATH "/cs01wsrestful/{id}"
END WSRESTFUL

/*/{Protheus.doc} cs01wsrestful::GET
Retorna os dados de um cliente especifico ou lista de clientes.
@type method
@author Antigravity
@since 10/07/2026
@return logical, Retorna .T. para indicar sucesso na requisicao HTTP
/*/
WSMETHOD GET WSSERVICE cs01wsrestful
    Local lSuccess    := .T. as Logical
    Local cResponse   := "" as Character
    Local oJsonRes    := JsonObject():New() as Object
    Local oJsonCli    := JsonObject():New() as Object
    Local aClientes   := {} as Array
    Local cAliasTmp   := "" as Character
    Local cQuery      := "" as Character
    Local cCod        := "" as Character
    Local cLoja       := "" as Character
    Local cId         := "" as Character
    Local nLimit      := 10 as Numeric
    Local nOffset     := 0 as Numeric
    Local nCont       := 0 as Numeric
    Local nAdded      := 0 as Numeric
    Local nPos        := 0 as Numeric

    // Garante que a tabela SA1 esta aberta no ambiente de dados
    If ! Select("SA1") > 0
        OpenFile("SA1")
    EndIf

    // Se houver parametros no path, trata como busca individual por ID (Codigo ou Codigo-Loja)
    If Len(Self:aURLParms) > 0
        cId := Self:aURLParms[1]
        nPos := At("-", cId)
        
        If nPos > 0
            cCod  := SubStr(cId, 1, nPos - 1)
            cLoja := SubStr(cId, nPos + 1)
        Else
            cCod  := cId
            cLoja := "01" // Loja padrao Protheus
        EndIf
        
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
        
        If SA1->(DbSeek(xFilial("SA1") + PadR(cCod, TamSx3("A1_COD")[1]) + PadR(cLoja, TamSx3("A1_LOJA")[1])))
            oJsonCli["code"]      := AllTrim(SA1->A1_COD)
            oJsonCli["store"]     := AllTrim(SA1->A1_LOJA)
            oJsonCli["name"]      := AllTrim(SA1->A1_NOME)
            oJsonCli["shortName"] := AllTrim(SA1->A1_NREDUZ)
            oJsonCli["type"]      := AllTrim(SA1->A1_TIPO)
            oJsonCli["state"]     := AllTrim(SA1->A1_EST)
            oJsonCli["address"]   := AllTrim(SA1->A1_END)
            oJsonCli["city"]      := AllTrim(SA1->A1_MUN)
            
            cResponse := oJsonCli:ToJson()
            Self:SetContentType("application/json")
            Self:SetResponse(cResponse)
            Self:SetResponseCode(200)
        Else
            oJsonRes["error"] := "Cliente nao encontrado: " + cId
            cResponse := oJsonRes:ToJson()
            Self:SetContentType("application/json")
            Self:SetResponse(cResponse)
            Self:SetResponseCode(404)
        EndIf
    Else
        // Busca lista de clientes com paginacao por query params
        If ! Empty(Self:GetQueryParam("limit"))
            nLimit := Val(Self:GetQueryParam("limit"))
        EndIf
        If ! Empty(Self:GetQueryParam("offset"))
            nOffset := Val(Self:GetQueryParam("offset"))
        EndIf
        
        If nLimit <= 0
            nLimit := 10
        EndIf
        If nOffset < 0
            nOffset := 0
        EndIf
        
        cAliasTmp := GetNextAlias()
        
        cQuery := " SELECT A1_COD, A1_LOJA, A1_NOME, A1_NREDUZ, A1_TIPO, A1_EST, A1_END, A1_MUN "
        cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
        cQuery += " WHERE A1_FILIAL = '" + xFilial("SA1") + "' "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "
        
        cQuery := ChangeQuery(cQuery)
        DbUseArea(.T., "TOPCONN", TCGetConn(), cQuery, cAliasTmp, .T., .T.)
        
        // Ignora registros ate atingir o offset
        While nCont < nOffset .And. ! (cAliasTmp)->(Eof())
            (cAliasTmp)->(DbSkip())
            nCont++
        EndDo
        
        // Adiciona registros ate atingir o limite
        While nAdded < nLimit .And. ! (cAliasTmp)->(Eof())
            oJsonCli := JsonObject():New()
            oJsonCli["code"]      := AllTrim((cAliasTmp)->A1_COD)
            oJsonCli["store"]     := AllTrim((cAliasTmp)->A1_LOJA)
            oJsonCli["name"]      := AllTrim((cAliasTmp)->A1_NOME)
            oJsonCli["shortName"] := AllTrim((cAliasTmp)->A1_NREDUZ)
            oJsonCli["type"]      := AllTrim((cAliasTmp)->A1_TIPO)
            oJsonCli["state"]     := AllTrim((cAliasTmp)->A1_EST)
            oJsonCli["address"]   := AllTrim((cAliasTmp)->A1_END)
            oJsonCli["city"]      := AllTrim((cAliasTmp)->A1_MUN)
            
            AAdd(aClientes, oJsonCli)
            
            nAdded++
            (cAliasTmp)->(DbSkip())
        EndDo
        
        (cAliasTmp)->(DbCloseArea())
        
        oJsonRes["items"] := aClientes
        oJsonRes["count"] := Len(aClientes)
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(200)
    EndIf
Return (lSuccess)

/*/{Protheus.doc} cs01wsrestful::POST
Cria um novo cliente (SA1) no sistema utilizando a rotina MSExecAuto MATA030.
@type method
@author Antigravity
@since 10/07/2026
@return logical, Retorna .T. para indicar sucesso na requisicao HTTP
/*/
WSMETHOD POST WSSERVICE cs01wsrestful
    Local lSuccess      := .T. as Logical
    Local cResponse     := "" as Character
    Local oJsonBody     := JsonObject():New() as Object
    Local oJsonRes      := JsonObject():New() as Object
    Local aAuto         := {} as Array
    Local cError        := "" as Character
    Local cCod          := "" as Character
    Local cLoja         := "" as Character
    Local cNome         := "" as Character
    Local cNReduz       := "" as Character
    Local cTipo         := "" as Character
    Local cEst          := "" as Character
    Local cEnd          := "" as Character
    Local cMun          := "" as Character
    Local cLogErro      := "" as Character
    Private lMsErroAuto := .F. as Logical

    // Garante que a tabela SA1 esta aberta
    If ! Select("SA1") > 0
        OpenFile("SA1")
    EndIf

    // Faz o parse do corpo JSON recebido
    cError := oJsonBody:FromJson(Self:GetContent())
    
    If ! Empty(cError)
        oJsonRes["error"] := "JSON invalido: " + cError
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(400)
        Return .T.
    EndIf

    // Recupera os parametros do JSON
    If oJsonBody:GetNames() <> NIL
        If oJsonBody:IsProperty("code")
            cCod := oJsonBody["code"]
        EndIf
        If oJsonBody:IsProperty("store")
            cLoja := oJsonBody["store"]
        EndIf
        If oJsonBody:IsProperty("name")
            cNome := oJsonBody["name"]
        EndIf
        If oJsonBody:IsProperty("shortName")
            cNReduz := oJsonBody["shortName"]
        EndIf
        If oJsonBody:IsProperty("type")
            cTipo := oJsonBody["type"]
        EndIf
        If oJsonBody:IsProperty("state")
            cEst := oJsonBody["state"]
        EndIf
        If oJsonBody:IsProperty("address")
            cEnd := oJsonBody["address"]
        EndIf
        If oJsonBody:IsProperty("city")
            cMun := oJsonBody["city"]
        EndIf
    EndIf

    // Trata valores nulos ou vazios para chaves obrigatorias
    If Empty(cLoja)
        cLoja := "01"
    EndIf
    
    If Empty(cCod)
        // Obtem o proximo codigo sequencial para SA1
        cCod := GetSxeNum("SA1", "A1_COD")
    EndIf

    If Empty(cNome) .Or. Empty(cTipo) .Or. Empty(cEst)
        oJsonRes["error"] := "Campos obrigatorios ausentes: 'name', 'type', 'state' sao requeridos."
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(400)
        Return .T.
    EndIf

    // Monta o array para a rotina ExecAuto de Clientes (MATA030)
    aAuto := {}
    AAdd(aAuto, {"A1_COD",    PadR(cCod, TamSx3("A1_COD")[1]),     NIL})
    AAdd(aAuto, {"A1_LOJA",   PadR(cLoja, TamSx3("A1_LOJA")[1]),   NIL})
    AAdd(aAuto, {"A1_NOME",   PadR(cNome, TamSx3("A1_NOME")[1]),   NIL})
    AAdd(aAuto, {"A1_NREDUZ", PadR(cNReduz, TamSx3("A1_NREDUZ")[1]), NIL})
    AAdd(aAuto, {"A1_TIPO",   cTipo,                               NIL})
    AAdd(aAuto, {"A1_EST",    cEst,                                NIL})
    AAdd(aAuto, {"A1_END",    PadR(cEnd, TamSx3("A1_END")[1]),     NIL})
    AAdd(aAuto, {"A1_MUN",    PadR(cMun, TamSx3("A1_MUN")[1]),     NIL})

    // Executa a inclusao via ExecAuto MATA030 (opcao 3 = Inclusao)
    lMsErroAuto := .F.
    MSExecAuto({|x, y| MATA030(x, y)}, aAuto, 3)

    If lMsErroAuto
        cLogErro := GetAutoGRLog()
        oJsonRes["error"] := "Falha na gravacao do cliente."
        oJsonRes["detail"] := AllTrim(cLogErro)
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(500)
    Else
        // Confirma a numeracao sequencial consumida
        ConfirmSxe()
        
        oJsonRes["success"] := .T.
        oJsonRes["code"] := AllTrim(cCod)
        oJsonRes["store"] := AllTrim(cLoja)
        oJsonRes["message"] := "Cliente gravado com sucesso."
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(201)
    EndIf
Return (lSuccess)

/*/{Protheus.doc} cs01wsrestful::PUT
Altera os dados de um cliente existente (SA1) atraves da rotina MSExecAuto MATA030.
@type method
@author Antigravity
@since 10/07/2026
@return logical, Retorna .T. para indicar sucesso na requisicao HTTP
/*/
WSMETHOD PUT WSSERVICE cs01wsrestful
    Local lSuccess      := .T. as Logical
    Local cResponse     := "" as Character
    Local oJsonBody     := JsonObject():New() as Object
    Local oJsonRes      := JsonObject():New() as Object
    Local aAuto         := {} as Array
    Local cError        := "" as Character
    Local cCod          := "" as Character
    Local cLoja         := "" as Character
    Local cId           := "" as Character
    Local cNome         := "" as Character
    Local cNReduz       := "" as Character
    Local cTipo         := "" as Character
    Local cEst          := "" as Character
    Local cEnd          := "" as Character
    Local cMun          := "" as Character
    Local cLogErro      := "" as Character
    Local nPos          := 0 as Numeric
    Private lMsErroAuto := .F. as Logical

    // Garante que a tabela SA1 esta aberta
    If ! Select("SA1") > 0
        OpenFile("SA1")
    EndIf

    // Verifica se informou o ID no path da URL
    If Len(Self:aURLParms) > 0
        cId := Self:aURLParms[1]
        nPos := At("-", cId)
        
        If nPos > 0
            cCod  := SubStr(cId, 1, nPos - 1)
            cLoja := SubStr(cId, nPos + 1)
        Else
            cCod  := cId
            cLoja := "01"
        EndIf
    Else
        oJsonRes["error"] := "Codigo do cliente nao informado no path da URL."
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(400)
        Return .T.
    EndIf

    // Faz o parse do corpo JSON recebido
    cError := oJsonBody:FromJson(Self:GetContent())
    
    If ! Empty(cError)
        oJsonRes["error"] := "JSON invalido: " + cError
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(400)
        Return .T.
    EndIf

    // Posiciona o cursor no cliente desejado
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
    
    If ! SA1->(DbSeek(xFilial("SA1") + PadR(cCod, TamSx3("A1_COD")[1]) + PadR(cLoja, TamSx3("A1_LOJA")[1])))
        oJsonRes["error"] := "Cliente nao encontrado para alteracao: " + cId
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(404)
        Return .T.
    EndIf

    // Inicia a montagem do aAuto com a chave do registro
    aAuto := {}
    AAdd(aAuto, {"A1_COD",    SA1->A1_COD,     NIL})
    AAdd(aAuto, {"A1_LOJA",   SA1->A1_LOJA,    NIL})

    // Adiciona os campos opcionais recebidos no JSON
    If oJsonBody:GetNames() <> NIL
        If oJsonBody:IsProperty("name")
            cNome := oJsonBody["name"]
            AAdd(aAuto, {"A1_NOME", PadR(cNome, TamSx3("A1_NOME")[1]), NIL})
        EndIf
        If oJsonBody:IsProperty("shortName")
            cNReduz := oJsonBody["shortName"]
            AAdd(aAuto, {"A1_NREDUZ", PadR(cNReduz, TamSx3("A1_NREDUZ")[1]), NIL})
        EndIf
        If oJsonBody:IsProperty("type")
            cTipo := oJsonBody["type"]
            AAdd(aAuto, {"A1_TIPO", cTipo, NIL})
        EndIf
        If oJsonBody:IsProperty("state")
            cEst := oJsonBody["state"]
            AAdd(aAuto, {"A1_EST", cEst, NIL})
        EndIf
        If oJsonBody:IsProperty("address")
            cEnd := oJsonBody["address"]
            AAdd(aAuto, {"A1_END", PadR(cEnd, TamSx3("A1_END")[1]), NIL})
        EndIf
        If oJsonBody:IsProperty("city")
            cMun := oJsonBody["city"]
            AAdd(aAuto, {"A1_MUN", PadR(cMun, TamSx3("A1_MUN")[1]), NIL})
        EndIf
    EndIf

    // Executa a alteracao via ExecAuto MATA030 (opcao 4 = Alteracao)
    lMsErroAuto := .F.
    MSExecAuto({|x, y| MATA030(x, y)}, aAuto, 4)

    If lMsErroAuto
        cLogErro := GetAutoGRLog()
        oJsonRes["error"] := "Falha na alteracao do cliente."
        oJsonRes["detail"] := AllTrim(cLogErro)
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(500)
    Else
        oJsonRes["success"] := .T.
        oJsonRes["code"] := AllTrim(cCod)
        oJsonRes["store"] := AllTrim(cLoja)
        oJsonRes["message"] := "Cliente alterado com sucesso."
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(200)
    EndIf
Return (lSuccess)

/*/{Protheus.doc} cs01wsrestful::DELETE
Exclui logicamente (deleta) um cliente existente (SA1) atraves da rotina MSExecAuto MATA030.
@type method
@author Antigravity
@since 10/07/2026
@return logical, Retorna .T. para indicar sucesso na requisicao HTTP
/*/
WSMETHOD DELETE WSSERVICE cs01wsrestful
    Local lSuccess      := .T. as Logical
    Local cResponse     := "" as Character
    Local oJsonRes      := JsonObject():New() as Object
    Local aAuto         := {} as Array
    Local cCod          := "" as Character
    Local cLoja         := "" as Character
    Local cId           := "" as Character
    Local cLogErro      := "" as Character
    Local nPos          := 0 as Numeric
    Private lMsErroAuto := .F. as Logical

    // Garante que a tabela SA1 esta aberta
    If ! Select("SA1") > 0
        OpenFile("SA1")
    EndIf

    // Verifica se informou o ID no path da URL
    If Len(Self:aURLParms) > 0
        cId := Self:aURLParms[1]
        nPos := At("-", cId)
        
        If nPos > 0
            cCod  := SubStr(cId, 1, nPos - 1)
            cLoja := SubStr(cId, nPos + 1)
        Else
            cCod  := cId
            cLoja := "01"
        EndIf
    Else
        oJsonRes["error"] := "Codigo do cliente nao informado no path da URL."
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(400)
        Return .T.
    EndIf

    // Posiciona o cursor no cliente desejado
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
    
    If ! SA1->(DbSeek(xFilial("SA1") + PadR(cCod, TamSx3("A1_COD")[1]) + PadR(cLoja, TamSx3("A1_LOJA")[1])))
        oJsonRes["error"] := "Cliente nao encontrado para exclusao: " + cId
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(404)
        Return .T.
    EndIf

    // Monta o array minimo com a chave do registro para a exclusao
    aAuto := {}
    AAdd(aAuto, {"A1_COD",    SA1->A1_COD,     NIL})
    AAdd(aAuto, {"A1_LOJA",   SA1->A1_LOJA,    NIL})

    // Executa a exclusao via ExecAuto MATA030 (opcao 5 = Exclusao)
    lMsErroAuto := .F.
    MSExecAuto({|x, y| MATA030(x, y)}, aAuto, 5)

    If lMsErroAuto
        cLogErro := GetAutoGRLog()
        oJsonRes["error"] := "Falha na exclusao do cliente."
        oJsonRes["detail"] := AllTrim(cLogErro)
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(500)
    Else
        oJsonRes["success"] := .T.
        oJsonRes["code"] := AllTrim(cCod)
        oJsonRes["store"] := AllTrim(cLoja)
        oJsonRes["message"] := "Cliente excluido com sucesso."
        
        cResponse := oJsonRes:ToJson()
        Self:SetContentType("application/json")
        Self:SetResponse(cResponse)
        Self:SetResponseCode(200)
    EndIf
Return (lSuccess)
