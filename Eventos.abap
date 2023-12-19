*$*$ -------------------------------------------------------------- *$*$
*$*$ Autor      : André Luiz Guilhermini Junior                     *$*$
*$*$ Data       : 20/09/2023                                        *$*$
*$*$ -------------------------------------------------------------- *$*$
*$*$ Objetivo: Fazer o desenvolvimento da EF Recobrança Portofer    *$*$
*$*$ Melhorias:                                                     *$*$
*$*$ -------------------------------------------------------------- *$*$

*$*$ -------------------------------------------------------------- *$*$
*$*$ Include           Z_ALGJ_02_EVE                                *$*$
*$*$ -------------------------------------------------------------- *$*$

INITIALIZATION.

  CREATE OBJECT o_alv.

START-OF-SELECTION.

  o_alv->validacao_inicial( ).
  IF v_resp = '2'.
    LEAVE TO LIST-PROCESSING.
  ELSE.
    o_alv->seleciona_dados( ).
    o_alv->processa_dados( ).
    o_alv->monta_alv( ).
    o_alv->exibe_alv( ).
  ENDIF.

END-OF-SELECTION.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2023. Sap Release 740
