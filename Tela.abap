*$*$ -------------------------------------------------------------- *$*$
*$*$ Autor      : André Luiz Guilhermini Junior                     *$*$
*$*$ Data       : 20/09/2023                                        *$*$
*$*$ -------------------------------------------------------------- *$*$
*$*$ Objetivo: Fazer o desenvolvimento da EF Recobrança Portofer    *$*$
*$*$ Melhorias:                                                     *$*$
*$*$ -------------------------------------------------------------- *$*$

*$*$ -------------------------------------------------------------- *$*$
*$*$ Include           Z_ALGJ_02_SCR                                *$*$
*$*$ -------------------------------------------------------------- *$*$

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.

PARAMETERS      p_bukrs TYPE anla-bukrs OBLIGATORY.
SELECT-OPTIONS: s_budat FOR  anek-budat OBLIGATORY,
                s_anln1 FOR  anla-anln1,
                s_anln2 FOR  anla-anln2.

SELECTION-SCREEN: END OF BLOCK b2.

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2023. Sap Release 740
