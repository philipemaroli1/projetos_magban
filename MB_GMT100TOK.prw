#include 'TOTVS.ch'
#include "rwmake.ch"

/*------------------------------------------------------------------------------------------------------*
 | P.E.:  MT100TOK                                                                                      |
 | Desc:  P.E. é chamado na função A103Tudok(). Pode ser usado para validar a inclusao da NF.           |
 | Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok(). Para o controle do número de   |
 | vezes em que ele é chamado foi criada a variável lógica lMT100TOK, que quando for definida como      |
 | (.F.) o ponto de entrada será chamado somente uma vez.                                               |
 | Links: https://tdn.totvs.com/pages/releaseview.action?pageId=6085400                                 |
*------------------------------------------------------------------------------------------------------*/

/*/{Protheus.doc} GMT100TOK
Esse Ponto de Entrada é chamado 2 vezes dentro da rotina A103Tudok().
Para o controle do número de vezes em que ele é chamado foi criada a variável lógica lMT100TOK, que quando for
definida como (.F.) o ponto de entrada será chamado somente uma vez.
Links: https://tdn.totvs.com/pages/releaseview.action?pageId=6085400
@type function
@version 12.1.25
@author Gabriel Bravim Sales
@since 17/11/2021
@return logical, Verdadeiro ou Falso
/*/

User Function GMT100TOK()
    Local lRet      := .T.
    Local lValida   := .T.
    Local nItens    := 0
    Local nLoteAut  := 0

    Local nPItemNf  := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_ITEM"})
    Local nPCod     := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_COD"})
    Local nPQtd     := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_QUANT"})
    Local nPTES     := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_TES"})
    Local nPLote    := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_LOTECTL"})
    Local nPSLote   := aScan(aHeader,{|x|UPPER(Alltrim(x[2])) == "D1_NUMLOTE"})

    Local cItemNf   := ""
    Local cCodPrd   := ""
    Local nQtd      := 0
    Local cTES      := ""
    Local cLote     := ""
    Local cSLote    := ""

    Local cVldLote  := ""
    Local cRastro   := ""
    Local cGrupo    := ""

    /* Tratamento para não validar Lançamentos pela tela "Nota Fiscal Manual de Saída" (Módulo 09) e Inutilização de Notas */
    // lValida := IIF(FUNNAME() $ "MATA920/MATA410/SPEDNFE",.F.,.T.)
    
    /* Tratamento Validar apenas nas telas "Documento de Entrada" (Módulo 02) e "Nota Fiscal Manual de Entrada" (Módulo 09) */
    lValida := IIF(FUNNAME() $ "MATA910/MATA103",.T.,.F.)

    If lValida
        For nItens := 1 To Len(aCols)
            /* EXECUTA OS PROCEDIMENTOS APENAS SE A LINHA NÃO ESTIVER DELETADA */
            If aCols[nItens,Len(aHeader)+1] == .F.   // .T. = Linha Deletada | .F. = Linha Não Deletada
                cItemNf     := Acols[nItens][nPItemNf]
                cCodPrd     := Acols[nItens][nPCod]
                nQtd        := Acols[nItens][nPQtd]
                cTES        := Acols[nItens][nPTES]
                cLote       := Acols[nItens][nPLote]
                cSLote      := Acols[nItens][nPSLote]

                DbSelectArea("SB1")
                SB1->(dbSetOrder(1))
                SB1->(dbSeek(xFilial("SB1")+cCodPrd))
                cRastro     := SB1->B1_RASTRO
                cGrupo      := SB1->B1_GRUPO


                DbSelectArea("SF4")
                SF4->(dbSetOrder(1))
                SF4->(dbSeek(xFilial("SF4")+cTES))

                If SF4->F4_ESTOQUE $ "S" .And. (cRastro $ "L/S") .And. (Empty(cLote)) .And. nQtd > 0
                    If cVldLote == ""
                        cVldLote := "Item: " + cItemNf + " | Produto: " + AllTrim(cCodPrd)
                    Else
                        cVldLote := cVldLote + CRLF + "Item: " + cItemNf + " | Produto: " + AllTrim(cCodPrd)
                    EndIf

                    If cLote $ "AUTO"
                        nLoteAut++
                        Acols[nItens][nPLote] := GetSxeNum("SD1", "D1_LOTECTL")
                    EndIf
                Endif

            Endif
        Next nItens

        /* NÃO PERMITE SALVAR SE POSSUIR LOTES COM QUANTIDADE DIFERENTE DO TOTAL LÍQUIDO */
        If cVldLote != ""
            lRet	:= .F.
            cMsg	:= "Item(s) com Controle de Rastro Habilitado, porém o Lote Não foi Informado!:"+CRLF+cVldLote
            cTitulo	:= "Validação Rastro x Lote"
            u_MSGLOG(cMsg, cTitulo, 1, .F.)

        EndIf

        // If nLoteAut >= 1 .And. lRet	= .T.
        //     For nItens := 1 To Len(aCols)
        //         /* EXECUTA OS PROCEDIMENTOS APENAS SE A LINHA NÃO ESTIVER DELETADA */
        //         If aCols[nItens,Len(aHeader)+1] == .F.   // .T. = Linha Deletada | .F. = Linha Não Deletada
        //             If Acols[nItens][nPLote] = "AUTO"
        //                 Acols[nItens][nPLote] := ""
        //             EndIf
        //         Endif
        //     Next nItens
        // EndIf

    EndIf

    /* Utilizado para testar setando sempre falso e não salvar o documento */
    // If CNFISCAL = "000002740"
    //     lRet    := .F.
    // EndIf
    
    //VALIDAR SE OS CAMPOS DO AUTÔNOMO ESTÃO PREENCHIDOS NO DOCUMENTO DE ENTRADA
    If AllTrim(CTIPO) $ "N" .AND. FUNNAME() $ "MATA103"
        If AllTrim(CESPECIE) == "RPA"
            If Empty(SA2->A2_COD) .OR. image.pngEmpty(SA2->A2_CBO) .OR. Empty(DTOS(SA2->A2_DTNASC)) .OR. Empty(SA2->A2_OCORREN) .OR. Empty(SA2->A2_CATEG) .OR. Empty(SA2->A2_CODNIT) .OR. Empty(SA2->A2_CATEFD)
                lRet := .F.
                cMsg	:= "No cadastro do Fornecedor alguns dos seguintes campos estao vazios: Cod CBO, Data nasc., Ocorrencia, Categ. SEFIP, Num Insc Aut ou Cat eSocial!"
                cTitulo	:= "Validacao Campos RPA"
                u_MSGLOG(cMsg, cTitulo, 1, .F.)
            EndIf
        EndIf
    EndIf
Return lRet
