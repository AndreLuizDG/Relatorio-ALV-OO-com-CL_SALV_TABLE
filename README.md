# Relatorio ALV OO, ultilização de bapi e CL_SALV_TABLE

## Descrição
Este repositório contém um código ABAP que implementa um relatório orientado a objetos (OO) no SAP, utilizando a classe `CL_SALV_TABLE` para exibição de dados tabulares. Além disso, o relatório interage com uma BAPI para recuperar dados relevantes.

## Conteúdo
1. [**Pré-requisitos**](#pré-requisitos)
2. [**Instruções de Uso**](#instruções-de-uso)
3. [**Detalhes Técnicos**](#detalhes-técnicos)
4. [**Autor**](#Autor)



## Pré-requisitos
- Sistema SAP com suporte a ABAP.
- Acesso às transações de desenvolvimento no SAP.

## Instruções de Uso
1. Faça o download do código-fonte.
2. Importe o código-fonte para o sistema SAP utilizando a transação `SE80` ou `SE38`.
3. Execute o relatório utilizando a transação `SE38` ou `SA38`.

## Detalhes Técnicos
O relatório é implementado no arquivo `relatorio_oo.abap` e utiliza includes separados para melhor modularização (`Declarações.abap`, `Classes.abap`). A classe `CL_SALV_TABLE` é empregada para facilitar a exibição de dados tabulares. A BAPI é chamada para obter dados relevantes.

## Autor
Este projeto foi desenvolvido primaria mente por André Luiz G.J.
