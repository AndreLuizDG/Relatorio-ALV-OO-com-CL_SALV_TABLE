*$*$ -------------------------------------------------------------- *$*$
*$*$ Autor      : André Luiz Guilhermini Junior                     *$*$
*$*$ Data       : 20/09/2023                                        *$*$
*$*$ -------------------------------------------------------------- *$*$
*$*$ Objetivo: Fazer o desenvolvimento da EF Recobrança Portofer    *$*$
*$*$ Melhorias: Implementar a classe que faz o botão de gerar CSV   *$*$
*$*$ tá com problema pq o metodo é privado                          *$*$
*$*$ -------------------------------------------------------------- *$*$

*$*$ -------------------------------------------------------------- *$*$
*$*$ Include           Z_ALGJ_02_CLA                                *$*$
*$*$ -------------------------------------------------------------- *$*$

CLASS cla_alv DEFINITION.

  PUBLIC SECTION.
    METHODS:
      validacao_inicial,
*     ler_constantes,
      seleciona_dados,
      filtro_anek,
      processa_dados,
      monta_alv,
*      criar_barra_status,
      monta_fieldcat IMPORTING field     TYPE string
                               tab       TYPE string
                               ref_field TYPE string
                               ref_tab   TYPE string
                               hotspot   TYPE string
                               sum       TYPE string,
      exibe_alv.
*      user_comand.

ENDCLASS.

CLASS cla_alv IMPLEMENTATION.

  METHOD validacao_inicial.

    CALL FUNCTION 'FI_PERIOD_DETERMINE'
      EXPORTING
        i_budat        = s_budat-low "Data inicial da minha tela de seleção
        i_bukrs        = p_bukrs     "Empresa da minha tela de seleção
      IMPORTING
        e_gjahr        = v_gjahr_i "Exercício
        e_monat        = v_monat_i "Mês do exercício
        e_poper        = v_poper_i "Periodo contabil (ano)
      EXCEPTIONS
        fiscal_year    = 1
        period         = 2
        period_version = 3
        posting_period = 4
        special_period = 5
        version        = 6
        posting_date   = 7
        OTHERS         = 8.

    IF sy-subrc <> 0.
      CLEAR: v_gjahr_i,
             v_monat_i,
             v_poper_i.
    ENDIF.

    CALL FUNCTION 'FI_PERIOD_DETERMINE'
      EXPORTING
        i_budat        = s_budat-high "Data inicial da minha tela de seleção
        i_bukrs        = p_bukrs      "Empresa da minha tela de seleção
      IMPORTING
        e_gjahr        = v_gjahr_f "Exercício
        e_monat        = v_monat_f "Mês do exercício
        e_poper        = v_poper_f "Periodo contabil (ano)
      EXCEPTIONS
        fiscal_year    = 1
        period         = 2
        period_version = 3
        posting_period = 4
        special_period = 5
        version        = 6
        posting_date   = 7
        OTHERS         = 8.

    IF sy-subrc <> 0.
      CLEAR: v_gjahr_f,
             v_monat_f,
             v_poper_f.
    ENDIF.

    SELECT bukrs
           gjahr
           peraf
      FROM anlp
      INTO TABLE ti_anlp
     WHERE bukrs =  p_bukrs
       AND gjahr >= v_gjahr_i
       AND gjahr <= v_gjahr_f
       AND peraf >= v_poper_i
       AND peraf <= v_poper_f.

    IF ti_anlp IS NOT INITIAL.
      CLEAR: v_help,
             v_resp.

      CONCATENATE
      'Para a empresa' p_bukrs 'já foi lançada depreciação para o período informado.'
      'Será necessário executar transação afab  com a opção “repetição”.'
      'Deseja prosseguir?'
      INTO v_help
       SEPARATED BY space.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          text_question  = v_help
        IMPORTING
          answer         = v_resp
        EXCEPTIONS
          text_not_found = 1
          OTHERS         = 2.

      IF sy-subrc <> 0.
        CLEAR: v_help,
               v_resp.
      ENDIF.
    ENDIF.

*    Fazer a validação na hora de chamar os metodos

  ENDMETHOD.

  METHOD seleciona_dados.

*   Cabeçalho de documento do lançamento de imobilizado
    FREE   ti_anek.
    SELECT bukrs
           anln1
           anln2
           budat
           lnran
           gjahr
           bldat
           belnr
           sgtxt
      FROM anek
      INTO TABLE  ti_anek.
*     (ESTÁ COMENTANDO PQ NÃO TEM DADOS PARA ESSE CENARIO)
*     WHERE bukrs  = p_bukrs   "Empresa
*       AND anln1  = s_anln1   "Imobilizado
*       AND anln2  = s_anln2   "Subnúmero
*       AND budat  = s_budat.    "Data de Lançamento
*      AND LNSAN  = space     "Documento de Estorno

    IF sy-subrc <> 0.
      FREE ti_anek.
    ENDIF.

*   Dados Mestres do Ativo Imobilizado
    IF ti_anek IS  NOT INITIAL.
      FREE ti_anla.
      SELECT bukrs
             anln1
             anln2
             anlkl
             txt50
        FROM anla
        INTO TABLE ti_anla
     FOR ALL ENTRIES IN ti_anek
       WHERE bukrs  =  ti_anek-bukrs  "Empresa
         AND anln1  =  ti_anek-anln1  "Imobilizado
         AND anln2  =  ti_anek-anln2. "Subnúmero
*        AND anlkl  IN s_anlkl.       "Classe do Imobilizado (ESTÁ COMENTANDO PQ NÃO TEM DADOS PARA ESSE CENARIO)

      IF sy-subrc <> 0.
        FREE ti_anla.
      ENDIF.
    ENDIF.

    me->filtro_anek( ).

*   Partidas individuais do imobilizado
    IF ti_anek IS NOT INITIAL.

      FREE ti_anep.
      SELECT bukrs
             anln1
             anln2
             gjahr
             lnran
             afabe
             anbtr
             bwasl
      FROM anep
      INTO TABLE ti_anep
      FOR ALL ENTRIES IN ti_anek
      WHERE bukrs = ti_anek-bukrs
        AND anln1 = ti_anek-anln1
        AND anln2 = ti_anek-anln2
        AND gjahr = ti_anek-gjahr
        AND lnran = ti_anek-lnran
        AND afabe = '01'.

      IF sy-subrc <> 0.
        FREE ti_anep.
      ENDIF.

    ENDIF.

    FREE   ti_ankt.
    SELECT spras
           anlkl
           txk50
      FROM ankt
      INTO TABLE ti_ankt
     WHERE spras = 'P'. "Idioma

    IF sy-subrc <> 0.
      FREE ti_ankt.
    ENDIF.

*   Tipos de movimento da contabilidade do imobilizado
    FREE   ti_tabw.
    SELECT bwasl
           bwagrp
           anshkz
      FROM tabw
      INTO TABLE ti_tabw.
*     WHERE bwagrp = s_bwagrp.

    IF sy-subrc <> 0.
      FREE ti_tabw.
    ENDIF.

*     Textos dos tipos de movimento da contabilidade do imob.
    FREE ti_tabwt.
    SELECT bwasl
           bwatxt
      FROM tabwt
      INTO TABLE ti_tabwt
       FOR ALL ENTRIES IN ti_tabw
     WHERE bwasl 	= ti_tabw-bwasl "Tipo de Movimento
       AND spras  = 'P'.          "Idioma

    IF sy-subrc <> 0.
      FREE ti_tabwt.
    ENDIF.

*     Tipos de movimento da contabilidade do imobilizado
    FREE ti_tabw_2.
    SELECT bwasl
           bwagrp
           anshkz
      FROM tabw
      INTO TABLE ti_tabw_2.

    IF sy-subrc <> 0.
      FREE ti_tabw_2.
    ENDIF.

*       Cabeçalho de documento do lançamento de imobilizado
    IF ti_anek IS NOT INITIAL.
      SELECT bukrs
             anln1
             anln2
             lnran
        FROM zbj_treino_contr "Tabela criada
        INTO  TABLE ti_controle
         FOR ALL ENTRIES IN ti_anek
       WHERE  bukrs   = ti_anek-bukrs  "Empresa
         AND  anln1   = ti_anek-anln1  "Imobilizado
         AND  anln2   = ti_anek-anln2  "Subnúmero
         AND  lnran  	= ti_anek-lnran. "Sequencial

      IF sy-subrc <> 0.
        FREE ti_controle.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD filtro_anek.

    DATA: v_tabix.

    SORT: ti_anek BY bukrs
                    anln1
                    anln2,
          ti_anla BY bukrs
                    anln1
                    anln2.

    LOOP AT ti_anek INTO wa_anek.

      v_tabix = sy-tabix.

      READ TABLE ti_anla INTO wa_anla WITH KEY
                                      bukrs = wa_anek-bukrs
                                      anln1 = wa_anek-anln1
                                      anln2 = wa_anek-anln2
                                      BINARY SEARCH.

      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
        DELETE ti_anek INDEX v_tabix.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD processa_dados.

    SORT: ti_anep BY  bukrs
                      anln1
                      anln2
                      lnran
                      bwasl,

          ti_controle BY bukrs
                         anln1
                         anln2
                         lnran,

          ti_tabw BY  bwasl.

    LOOP AT ti_anep INTO wa_anep.

      READ TABLE ti_controle INTO wa_controle WITH KEY
                                              bukrs = wa_anep-bukrs
                                              anln1 = wa_anep-anln1
                                              anln2 = wa_anep-anln2
                                              lnran = wa_anep-lnran
                                              BINARY SEARCH.

      IF sy-subrc = 0.
        CONTINUE.
      ELSE.
        READ TABLE ti_tabw INTO wa_tabw WITH KEY
                                        bwasl = wa_anep-bwasl.

        IF sy-subrc <> 0.
          CONTINUE.
        ELSE.

          wa_saida-bukrs = wa_anep-bukrs. "Empresa
          wa_saida-anln1 = wa_anep-anln1. "Imobilizado
          wa_saida-anln2 = wa_anep-anln2. "“Subnúmero

          READ TABLE ti_anla INTO wa_anla WITH KEY
                                          bukrs = wa_anep-bukrs "Empresa
                                          anln1 = wa_anep-anln1 "Imobilizado
                                          anln2 = wa_anep-anln2 "Subnúmero
                                          BINARY SEARCH.
          IF sy-subrc = 0.
            wa_saida-txt50 = wa_anla-txt50. "Texto Descritivo
            wa_saida-anlkl = wa_anla-anlkl. "Classe do Imobilizado
          ENDIF.

          READ TABLE ti_ankt INTO wa_ankt WITH KEY
                                          anlkl = wa_anla-anlkl
                                          BINARY SEARCH.
          IF sy-subrc = 0.
            wa_saida-txk50 = wa_ankt-txk50.
          ENDIF.

          wa_saida-lnran = wa_anep-lnran. "N° sequencial da partida
          wa_saida-bwasl = wa_anep-bwasl. "Tipo de movimento do imobilizado

          READ TABLE ti_tabwt INTO wa_tabwt WITH KEY
                                            bwasl = wa_anep-bwasl
                                            BINARY SEARCH.
          IF sy-subrc = 0.
            wa_saida-bwatxt = wa_tabwt-bwatxt. "Descrição do tipo de movimento
          ENDIF.

          READ TABLE ti_anek INTO wa_anek WITH KEY
                                          bukrs = wa_anep-bukrs
                                          anln1 = wa_anep-anln1
                                          anln2 = wa_anep-anln2
                                          gjahr = wa_anep-gjahr
                                          lnran = wa_anep-lnran
                                          BINARY SEARCH.
          IF sy-subrc = 0.
            wa_saida-bldat = wa_anek-bldat. "Data do documento
            wa_saida-budat = wa_anek-budat. "Data do documento
          ENDIF.

          wa_saida-anbtr = wa_anep-anbtr.
          APPEND wa_saida TO ti_saida.


        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD monta_alv.

    FREE ti_fieldcat.
    CLEAR wa_fieldcat.

    me->monta_fieldcat( field     = 'BUKRS'
                        tab       = 'TI_SAIDA'
                        ref_field = 'BUKRS'
                        ref_tab   = 'ANEP'
                        hotspot   = ''
                        sum       = '' ).

    me->monta_fieldcat( field     = 'ANLN1'
                        tab       = 'TI_SAIDA'
                        ref_field = 'ANLN1'
                        ref_tab   = 'ANEP'
                        hotspot   = ''
                        sum       = '').

    me->monta_fieldcat( field = 'ANLN2'
                        tab = 'TI_SAIDA'
                        ref_field = 'ANLN2'
                        ref_tab = 'ANEP'
                        hotspot = ''
                        sum = '').

    me->monta_fieldcat( field = 'BUDAT'
                        tab = 'TI_SAIDA'
                        ref_field = 'BUDAT'
                        ref_tab = 'ANEK'
                        hotspot = '' sum = '').

    me->monta_fieldcat( field = 'BWASL'
                        tab = 'TI_SAIDA'
                        ref_field = 'BWASL'
                        ref_tab = 'ANEP'
                        hotspot = ''
                        sum = '').

    me->monta_fieldcat( field = 'ANBTR'
                        tab = 'TI_SAIDA'
                        ref_field = 'ANBTR'
                        ref_tab = 'ANEP'
                        hotspot = ''
                        sum = '').

    CLEAR wa_fieldcat.
    wa_fieldcat-fieldname = 'TXT50'.
    wa_fieldcat-tabname = 'TI_SAIDA'.
    wa_fieldcat-reptext_ddic = 'MONTANTE LANÇADO'.
    wa_fieldcat-inttype = 'C'.
    wa_fieldcat-outputlen = 50.
    APPEND wa_fieldcat TO ti_fieldcat.

    me->monta_fieldcat( field = 'TXK50'
                        tab = 'TI_SAIDA'
                        ref_field = 'TXK50'
                        ref_tab = 'ANKT'
                        hotspot =  '' sum = '').

    me->monta_fieldcat( field = 'LNRAN'
                        tab = 'TI_SAIDA'
                        ref_field = 'LNRAN'
                        ref_tab = 'ANEP'
                        hotspot = ''
                        sum = '').

    me->monta_fieldcat( field = 'ANLKL'
                        tab = 'TI_SAIDA'
                        ref_field = 'ANLKL'
                        ref_tab = 'ANLA'
                        hotspot = ''
                        sum = '').

    me->monta_fieldcat( field = 'BLDAT'
                        tab = 'TI_SAIDA'
                        ref_field = 'BLDAT'
                        ref_tab = 'ANEK'
                        hotspot = ''
                        sum = '').

    me->monta_fieldcat( field = 'BWASL'
                        tab = 'TI_SAIDA'
                        ref_field = 'BWASL'
                        ref_tab = 'ANEP'
                        hotspot = ''
                        sum = '').

    me->monta_fieldcat( field = 'BWATXT'
                        tab = 'TI_SAIDA'
                        ref_field = 'BWATXT'
                        ref_tab = 'TABWT'
                        hotspot = ''
                        sum = '').
  ENDMETHOD.

  METHOD monta_fieldcat.

    CLEAR wa_fieldcat.
    wa_fieldcat-fieldname     = field.
    wa_fieldcat-tabname       = tab.
    wa_fieldcat-ref_fieldname = ref_field.
    wa_fieldcat-ref_tabname   = ref_tab.
    wa_fieldcat-hotspot       = hotspot.
    wa_fieldcat-do_sum        = sum.

    APPEND wa_fieldcat TO ti_fieldcat.

  ENDMETHOD.

  METHOD exibe_alv.

    DATA: lo_events     TYPE REF TO cl_salv_events_table,
*          event_handler TYPE REF TO zcl_handle_events,
          lv_text       TYPE string,
          lv_icon       TYPE string.

*   "Criando" o ALV
    cl_salv_table=>factory(
    IMPORTING r_salv_table = lo_table
    CHANGING  t_table = ti_saida ).

*   Abilitando as funcionalidades
    lo_functions = lo_table->get_functions( ).
    lo_functions->set_all( abap_true ).

    TRY.
        lv_text = 'Exportar para arquivo .CSV'.
        lv_icon = 'ICON_XLS'.
        lo_functions->add_function(
          name = 'Z_EXCEL'
          icon = lv_icon
          text = lv_text
          tooltip = lv_text
                position = if_salv_c_function_position=>right_of_salv_functions ).
      CATCH cx_salv_wrong_call cx_salv_existing.
    ENDTRY.

*   Exibindo o ALV
    lo_table->display( ).

  ENDMETHOD. "z_exibe

ENDCLASS. "zcl_report

----------------------------------------------------------------------------------
Extracted by Mass Download version 1.5.5 - E.G.Mellodew. 1998-2023. Sap Release 740
