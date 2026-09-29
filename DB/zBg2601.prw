#include "Include.ch"
#include "Topconn.ch"

/*/{Protheus.doc} zBg2601
(long_description)
@type user function
@author Hamir Dhanquer
@since 29/09/2026
@version 1.0
Obs: Tabela Temporaria 
/*/
User Function zBg2601()
    Local aFields := {}
    Local oTempTable 
    Local cAlias := GetNextAlias()
    Local cQuery 
    Local xT 


    // Criar objeto 
    oTempTable := FWTemporaryTable():New( cAlias )

    // Array com os campos da tabela
    aadd(aFields, {"DATA", "D", 8 , 0})
    aadd(aFields, {"CONTRATO"   , "C", 30, 0})
    aadd(aFields, {"VALOR"  , "N", 3 , 1})

    // Adiciona os campos ao objeto
    oTempTable:SetFields( aFields )

    // Adiciona os indices ao objeto
    oTempTable:AddIndex("1", {"DATA"} )

    // Criacao da tabela temporaria
    oTempTable:Create()

    // Incluir Registros na tabela temporaria
    If RecLock(cAlias,.T.)

       (cAlias)->DATA := Date()
       (cAlias)->CONTRATO := '123456789'
       (cAlias)->VALOR := 100.00
       cAlias>(MsUnlock())
    EndIf

    // Funções interessantes para manipulação da tabela temporaria

    xT := GetTableNameForTCFunctions() //Retorna o nome da tabela para ser usado em funções do DBAccess
    xT := oTempTable:GetRealName() //Retorna o nome real da tabela temporaria
    xT := oTempTable:GetTableNameForQuery()() //Retorna o nome real da tabela temporaria
    xT := oTempTable:GetAlias() //Retorna o alias utilizado pelo arquivo.
    xT := oTempTable:Zap() //Retorna o alias utilizado pelo arquivo.
    xT := oTempTable:Delete()  //Apaga a Tabela.
Return 
