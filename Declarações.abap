*$*$ -------------------------------------------------------------- *$*$
*$*$ Autor      : Andr� Luiz Guilhermini Junior                     *$*$
*$*$ Data       : 20/09/2023                                        *$*$
*$*$ -------------------------------------------------------------- *$*$
*$*$ Objetivo: Fazer o desenvolvimento da EF Recobran�a Portofer    *$*$
*$*$ Melhorias:                                                     *$*$
*$*$ -------------------------------------------------------------- *$*$

*$*$ -------------------------------------------------------------- *$*$
*$*$ Include           Z_ALGJ_02_TOP                                *$*$
*$*$ -------------------------------------------------------------- *$*$

*$*$ -------------------------------------------------------------- *$*$
*$*$                         TABELAS DO ECC                         *$*$
*$*$ -------------------------------------------------------------- *$*$

TABLES: anla,
        anek.

*$*$ -------------------------------------------------------------- *$*$
*$*$                            TYPES                               *$*$
*$*$ -------------------------------------------------------------- *$*$

TYPES:
  BEGIN OF y_saida,
    bukrs  TYPE anep-bukrs,
    anln1  TYPE anep-anln1,
    anln2  TYPE anep-anln2,
    budat  TYPE anek-budat,
    bwasl  TYPE anep-bwasl,
    anbtr  TYPE anep-anbtr,
    txt50  TYPE char50,
    txk50  TYPE ankt-txk50,
    lnran  TYPE anep-lnran,
    anlkl  TYPE anla-anlkl,
    bldat  TYPE anek-bldat,
    bwatxt TYPE tabwt-bwatxt,
    mark   TYPE c,
  END OF y_saida,

  BEGIN OF y_log,
    status TYPE char5,
    bukrs  TYPE anep-bukrs,
    anln1  TYPE anep-anln1,
    anln2  TYPE anep-anln2,
    budat  TYPE anek-budat,
    bwasl  TYPE anep-bwasl,
    anbtr  TYPE anep-anbtr,
    txt50  TYPE char50,
  END OF y_log,

  BEGIN OF y_csv,
    one TYPE char600,
  END OF y_csv,

  BEGIN OF y_anlp,
    bukrs TYPE anlp-bukrs,
    gjahr TYPE anlp-gjahr,
    peraf TYPE anlp-peraf,
  END OF y_anlp,

  BEGIN OF y_anek,
    bukrs TYPE anek-bukrs,
    anln1 TYPE anek-anln1,
    anln2 TYPE anek-anln2,
    budat TYPE anek-budat,
    lnran TYPE anek-lnran,
    gjahr TYPE anek-gjahr,
    bldat TYPE anek-bldat,
    belnr TYPE anek-belnr,
    sgtxt TYPE anek-sgtxt,
  END OF y_anek,

  BEGIN OF y_anla,
    bukrs TYPE anla-bukrs,
    anln1 TYPE anla-anln1,
    anln2 TYPE anla-anln2,
    anlkl TYPE anla-anlkl,
    txt50 TYPE anla-txt50,
  END OF y_anla,

  BEGIN OF y_anep,
    bukrs TYPE anep-bukrs,
    anln1 TYPE anep-anln1,
    anln2 TYPE anep-anln2,
    gjahr TYPE anep-gjahr,
    lnran TYPE anep-lnran,
    afabe TYPE anep-afabe,
    anbtr TYPE anep-anbtr,
    bwasl TYPE anep-bwasl,
  END OF y_anep,

  BEGIN OF y_ankt,
    spras TYPE ankt-spras,
    anlkl TYPE ankt-anlkl,
    txk50 TYPE ankt-txk50,
  END OF y_ankt,

  BEGIN OF y_tabw,
    bwasl  TYPE tabw-bwasl,
    bwagrp TYPE tabw-bwagrp,
    anshkz TYPE tabw-anshkz,
  END OF y_tabw,

  BEGIN OF y_tabwt,
    bwasl  TYPE tabwt-bwasl,
    bwatxt TYPE tabwt-bwatxt,
  END OF y_tabwt.



*$*$ -------------------------------------------------------------- *$*$
*$*$                           CONSTANTES                           *$*$
*$*$ -------------------------------------------------------------- *$*$

DATA: c_b10  TYPE bwagrp VALUE '10',
      c_a224 TYPE anlkl VALUE '00000224',
      cr_br  TYPE RANGE OF bwasl.

*$*$ -------------------------------------------------------------- *$*$
*$*$                           VARI�VEIS                            *$*$
*$*$ -------------------------------------------------------------- *$*$

DATA: v_help    TYPE string,
      v_resp    TYPE c,
      v_gjahr_i TYPE bkpf-gjahr,
      v_monat_i TYPE bkpf-monat,
      v_poper_i TYPE t009b-poper,
      v_gjahr_f TYPE bkpf-gjahr,
      v_monat_f TYPE bkpf-monat,
      v_poper_f TYPE t009b-poper.

*$*$ -------------------------------------------------------------- *$*$
*$*$                           ESTRUTURAS                           *$*$
*$*$ -------------------------------------------------------------- *$*$

DATA: wa_saida    TYPE y_saida,
      wa_fieldcat TYPE slis_fieldcat_alv,
      wa_csv      TYPE y_csv,
      wa_anlp     TYPE y_anlp,
      wa_anek     TYPE y_anek,
      wa_anla     TYPE y_anla,
      wa_ankt     TYPE y_ankt,
      wa_tabwt    TYPE y_tabwt,
      wa_tabw     TYPE y_tabw,
      wa_tabw2    TYPE y_tabw,
      wa_anep     TYPE y_anep,
      wa_controle TYPE zbj_treino_contr,
      wa_log      TYPE y_log.

*$*$ -------------------------------------------------------------- *$*$
*$*$                        TABELAS INTERNAS                        *$*$
*$*$ -------------------------------------------------------------- *$*$

DATA: ti_saida    TYPE TABLE OF y_saida,
      ti_fieldcat TYPE TABLE OF slis_fieldcat_alv,
      ti_csv      TYPE TABLE OF y_csv,
      ti_anlp     TYPE TABLE OF y_anlp,
      ti_anek     TYPE TABLE OF y_anek,
      ti_anla     TYPE TABLE OF y_anla,
      ti_anep     TYPE TABLE OF y_anep,
      ti_ankt     TYPE TABLE OF y_ankt,
      ti_tabw     TYPE TABLE OF y_tabw,
      ti_tabwt    TYPE TABLE OF y_tabwt,
      ti_tabw_2   TYPE TABLE OF y_tabw,
      ti_controle TYPE TABLE OF zbj_treino_contr,
      ti_log      TYPE TABLE OF y_log,
      ti_fieldlog TYPE TABLE OF slis_fieldcat_alv.

*$*$ -------------------------------------------------------------- *$*$
*$*$                        CLASSES E OBJETOS                        *$*$
*$*$ -------------------------------------------------------------- *$*$

CLASS cla_alv DEFINITION DEFERRED.

DATA:
  o_alv         TYPE REF TO cla_alv,
  lo_table      TYPE REF TO cl_salv_table,
  lo_functions  TYPE REF TO cl_salv_functions_list,
  lo_selections TYPE REF TO cl_salv_selections.

