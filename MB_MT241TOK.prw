#include 'TOTVS.ch'

/*/{Protheus.doc} MT240TOK
Encontra-se no FINAL da fun√ß√£o de valida√ß√£o da inclus√£o e pode ser usado para validar a inclus√£o do movimento pelo usu√°rio.
Link: https://centraldeatendimento.totvs.com/hc/pt-br/articles/1500004532861-MP-SIGAEST-MATA240-Pontos-de-Entrada-da-rotina-Movimenta%C3%A7%C3%A3o-Simples
@type function
@version 12.1.33
@author Philipe Maroli Lima
@since 27/06/2022
@return logical, return_description
/*/
User Function MT241TOK()
	Local lRet := .T.
	Local lValida   := .T.
	Local nItens    := 0
	Local nPItemCTA  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D3_ITEMCTA"})
	Local nPProduto  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D3_COD"})
	Local cVldItem := ""

	lValida := IIF(FUNNAME() $ "MATA241",.T.,.F.)

	If lValida
		For nItens := 1 To Len(aCols)
			If Empty(Acols[nItens][nPItemCTA])
            /* EXECUTA OS PROCEDIMENTOS APENAS SE A LINHA N√O ESTIVER DELETADA */
				If aCols[nItens,Len(aHeader)+1] == .F. // .T. = Linha Deletada | .F. = Linha N„o Deletada
					cVldItem += "Item: " + CVALTOCHAR(nItens) + " Produto: " + Alltrim(Acols[nItens][nPProduto]) + CRLF
				EndIf
			EndIf
		Next nItens

		If !Empty(cVldItem)
			lRet := .F.
			cMsg	:= "O campo Item Cont·bil est· vazio nos itens: " + CRLF + Alltrim(cVldItem)
			cTitulo	:= "Item Cont·bil"
			u_MSGLOG(cMsg, cTitulo, 1, .F.)
		EndIf

		If Empty(CCC)
			lRet := .F.
			cMsg	:= "O campo Centro de Custo est· vazio."
			cTitulo	:= "Centro de Custo"
			u_MSGLOG(cMsg, cTitulo, 1, .F.)
		EndIf
	EndIf
Return lRet
