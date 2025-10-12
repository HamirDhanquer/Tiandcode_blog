#include "Protheus.ch"


/*/{Protheus.doc} FIRSTNFSE
(long_description)
@type user function
@author Hamir Dhanquer
@since 11/10/2025
@version 1.0
@Obs Adicionar rotinas no ações relacionadas da rotina FISA022
/*/
User Function FIRSTNFSE()
Local aArea := GetArea()

    Aadd(aRotina, {"Msg.NFSE", "U_avisoNFSE", 0, 10})

RestArea(aArea)
Return aRotina



/*/{Protheus.doc} nomeStaticFunction
    (Teste)
    @type  Static Function
    @author Hamir DHanquer
    @since 11/10/2025
    @version 1.0
/*/
User Function avisoNfSE()
    
    MsgInfo("Ponto de entrada p/aviso de NFSE","Abrindo NFSE")
Return 
