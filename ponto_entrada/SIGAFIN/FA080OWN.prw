#Include 'Totvs.ch'

/*/{Protheus.doc} FA080OWN
Ponto de entrada na validação da confirmação da Baixa a Pagar (FINA080).
Valida regras de negócio antes de efetivar a baixa do título na SE2.

@type    User Function
@author   - tiandcode.com
@since   2026
@return  lRet, Logical, .T. permite a baixa | .F. bloqueia a baixa
/*/
User Function FA080OWN()
    Local aArea      := FwGetArea()
    Local aAreaSA2   := SA2->(FwGetArea())
    Local lRet       := .T.
    Local nValorLim  := 5000.00

    // 1. Validação de Fornecedor Bloqueado na SA2
    DbSelectArea("SA2")
    SA2->(DbSetOrder(1)) // A2_FILIAL + A2_COD + A2_LOJA
    If SA2->(MsSeek(FwXFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
        If SA2->A2_MSBLQL == "1"
            Help("", 1, "FA080OWN_FORN", , ;
                "O fornecedor " + AllTrim(SA2->A2_NOME) + " está bloqueado para movimentações.", ;
                1, 0, , , , , , {"Solicite o desbloqueio ao departamento de Cadastros antes de baixar o título."})
            lRet := .F.
        EndIf
    EndIf

    // 2. Validação de Alçada / Aprovação para títulos acima do limite
    If lRet .And. SE2->E2_VALOR > nValorLim
        Help("", 1, "FA080OWN_APROV", , ;
            "Títulos com valor superior a R$ 5.000,00 exigem aprovação financeira prévia.", ;
            1, 0, , , , , , {"Realize a liberação do título no fluxo de aprovação antes de efetuar a baixa."})
        lRet := .F.
    EndIf

    // Restaura as áreas originais para não desposicionar tabelas da rotina padrão
    FwRestArea(aAreaSA2)
    FwRestArea(aArea)
Return lRet
