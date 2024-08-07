*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME_TOP
*&---------------------------------------------------------------------*

DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV Grid nesnesi
      go_container TYPE REF TO cl_gui_custom_container, " ALV Grid'in bulunduğu container
      go_event_receiver TYPE REF TO cl_event_receiver, " Event işleyici nesnesi
      go_split_container TYPE REF TO cl_gui_splitter_container, " Container'ı bölmek için
      go_sub1 TYPE REF TO cl_gui_container, " Bir alt container
      go_sub2 TYPE REF TO cl_gui_container, " Diğer alt container
      go_docu TYPE REF TO cl_dd_document. " Top of page için document nesnesi

DATA: gt_scarr TYPE TABLE OF scarr, " SCARR tablosuna benzeyen internal table
      gs_scarr TYPE scarr. " SCARR tablosuna benzeyen work area

DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog
      gs_fcat TYPE lvc_s_fcat. " Field catalog için structure

DATA: gs_layout TYPE lvc_s_layo. " Layout ayarları

FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat, " Field catalog field symbol
               <gfs_scarr> TYPE scarr. " SCARR tablosuna benzeyen field symbol

CLASS cl_event_receiver DEFINITION DEFERRED. " Event işleyici sınıfı tanımı ertelenir

CLASS cl_event_receiver DEFINITION. " Event işleyici sınıfı tanımı
  PUBLIC SECTION.
    METHODS handle_onf4 " Search field
      FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING
        e_fieldname
        e_fieldvalue
        es_row_no
        er_event_data
        et_bad_cells
        e_display.
ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.
  METHOD handle_onf4.
    TYPES: BEGIN OF lty_value_tab, " Value tab alanı için bir tek kolonlu tablo
             carrname TYPE s_carrname,
             carrdeff TYPE char20,
           END OF lty_value_tab.

    DATA: lt_value_tab TYPE TABLE OF lty_value_tab, " Tek kolonlu tabloyu referans alan internal table
          ls_value_tab TYPE lty_value_tab. " Structure için work area

    " Search help pop-up'ında gösterilecek değerler
    CLEAR ls_value_tab.
    ls_value_tab-carrname = 'Uçuş 1'.
    ls_value_tab-carrdeff = 'Birinci uçuş'.
    APPEND ls_value_tab TO lt_value_tab.

    CLEAR ls_value_tab.
    ls_value_tab-carrname = 'Uçuş 2'.
    ls_value_tab-carrdeff = 'İkinci uçuş'.
    APPEND ls_value_tab TO lt_value_tab.

    CLEAR ls_value_tab.
    ls_value_tab-carrname = 'Uçuş 3'.
    ls_value_tab-carrdeff = 'Üçüncü uçuş'.
    APPEND ls_value_tab TO lt_value_tab.

    DATA: lt_return_tab TYPE TABLE OF ddshretval, " Return tab için internal table
          ls_return_tab TYPE ddshretval. " Return tab için work area

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST' " Search help pop-up'ını gösterir
      EXPORTING
        retfield              = 'CARRNAME'  " Value tab'daki hangi kolonu referans alacağız
        window_title           = 'carrname F4'    " Pop-up başlığı
        value_org              = 'S'   " Default olarak 'S' seçili
      TABLES
        value_tab             = lt_value_tab " Ekranda görünecek internal table
        return_tab             = lt_return_tab. " Kullanıcının seçtiği değerler

    " Seçilen değeri return tab'dan al
    READ TABLE lt_return_tab INTO ls_return_tab WITH KEY fieldname = 'F0001'.
    IF sy-subrc EQ 0.

      " Seçilen değeri tablodaki ilgili alana yaz
      READ TABLE gt_scarr ASSIGNING <gfs_scarr> INDEX es_row_no-row_id.
      IF sy-subrc EQ 0.
        <gfs_scarr>-carrname = ls_return_tab-fieldval.
        go_alv->refresh_table_display( ). " ALV Grid'i güncelle
      ENDIF.
    ENDIF.

    " Event'in tamamlandığını belirt
    er_event_data->m_event_handled = 'X'.
  ENDMETHOD.
ENDCLASS.

FORM display_alv.
  IF go_alv IS INITIAL.

    " Event işleyici nesnesini oluştur
    CREATE OBJECT go_event_receiver.

    " Container nesnesini oluştur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    " ALV Grid nesnesini oluştur
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

    " Button click eventini ayarla
    SET HANDLER go_event_receiver->handle_onf4 FOR go_alv. " Search help alanını ALV'ye ekle

    PERFORM register_f4. " Search help alanını kaydet

    " ALV Grid'i ilk görüntüleme için ayarla
    go_alv->set_table_for_first_display(
      EXPORTING
        is_layout = gs_layout
      CHANGING
        it_outtab = gt_scarr
        it_fieldcatalog = gt_fcat
    ).

    CALL METHOD go_alv->register_edit_event " Edit eventini kaydet
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  ELSE.
    " Eğer ALV nesnesi zaten varsa, tabloyu yenile
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.
ENDFORM.

FORM get_data.
  " SCARR tablosundaki verileri internal table'a çeker
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.
ENDFORM.

FORM get_fcat.
  " Field catalog'u dinamik olarak oluştur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat = gt_fcat.

  LOOP AT gt_fcat ASSIGNING <gfs_fcat>. " Field catalog tablosu üzerinde döner
    IF <gfs_fcat>-fieldname EQ 'CARRNAME'.
      <gfs_fcat>-edit = 'X'. " Edit mode
      <gfs_fcat>-style = cl_gui_alv_grid=>mc_style_f4. " Search help alanını aktif et
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM set_layout.
  " ALV Grid'in layout ayarlarını yap
  gs_layout-cwidth_opt = 'X'.
  gs_layout-zebra = 'X'.
ENDFORM.

FORM register_f4.
  DATA: lt_f4 TYPE lvc_t_f4, " Birden çok alana search help eklemek için internal table
        ls_f4 TYPE lvc_s_f4. " Internal table için structure

  CLEAR ls_f4.

  ls_f4-fieldname = 'CARRNAME'. " Hangi kolona search help ekleyeceğiz
  ls_f4-register = 'X'. " Register, yani search help alanı olarak belirt
  APPEND ls_f4 TO lt_f4. " Seçilen kolonu tabloya ekle

  CALL METHOD go_alv->register_f4_for_fields " Search help alanını hangi kolonda olacağını belirt
    EXPORTING
      it_f4 = lt_f4.
ENDFORM.
