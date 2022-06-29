#include 'TOTVS.ch'


/*/{Protheus.doc} MT240TOK
Encontra-se no FINAL da função de validação da inclusão e pode ser usado para validar a inclusão do movimento pelo usuário.
Link: https://centraldeatendimento.totvs.com/hc/pt-br/articles/1500004532861-MP-SIGAEST-MATA240-Pontos-de-Entrada-da-rotina-Movimenta%C3%A7%C3%A3o-Simples
@type function
@version 12.1.33
@author Philipe Maroli Lima
@since 27/06/2022
@return logical, return_description
/*/
User Function MT240TOK()
    Local lRet := .T.

    If Empty(SD3->D3_CC)

    EndIf

Return lRet
