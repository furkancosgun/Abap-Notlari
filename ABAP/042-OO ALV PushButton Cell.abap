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

TYPES: BEGIN OF gty_scarr, " SCARR tablosuna benzeyen bir tip
  delete TYPE char10,
  mandt TYPE s_mandt,
  carrid TYPE s_carr_id,
  carrname TYPE s_carrname,
  currcode TYPE s_currcode,
  url TYPE s_carrurl,
END OF gty_scarr.

DATA: gt_scarr TYPE TABLE OF gty_scarr, " SCARR tablosuna benzeyen internal table
      gs_scarr TYPE gty_scarr. " SCARR tablosuna benzeyen work area

DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog
      gs_fcat TYPE lvc_s_fcat. " Field catalog için structure

DATA: gs_layout TYPE lvc_s_layo. " Layout ayarları

FIELD-SYMBOLS: <gfs_fcatt> TYPE lvc_s_fcat, " Field catalog field symbol
               <gfs_scarr> TYPE gty_scarr. " SCARR tablosuna benzeyen field symbol

CLASS cl_event_receiver DEFINITION DEFERRED. " Event işleyici sınıfı tanımı ertelenir

CLASS cl_event_receiver DEFINITION. " Event işleyici sınıfı tanımı
  PUBLIC SECTION.
    METHODS handle_button_click
      FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING
        es_col_id
        es_row_no.
ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.
  METHOD handle_button_click.
    DATA: lv_mess TYPE char200. " Mesaj değişkeni

    READ TABLE gt_scarr INTO gs_scarr INDEX es_row_no-row_id. " Seçili satırı oku
    IF sy-subrc EQ 0. " İşlem başarılı ise
      CASE es_col_id-fieldname. " Kolon adı eşitse
        WHEN 'DELETE'. " Delete butonuna tıklanmışsa
          CONCATENATE es_col_id-fieldname " Kolon adı
                      'Buttonuna bastın Bu indexteki =>'
                      gs_scarr " Seçili satırdaki veri
                      INTO lv_mess " Mesaj değişkenine at
                      SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'. " Mesajı ekrana bas
      ENDCASE.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME_FRM
*&---------------------------------------------------------------------*

FORM display_alv.
  IF go_alv IS INITIAL.

    " Event işleyici nesnesini oluştur
    CREATE OBJECT go_event_receiver.

    " Container nesnesini oluştur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    " ALV grid nesnesini oluştur
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

    " Button click eventini ayarla
    SET HANDLER go_event_receiver->handle_button_click FOR go_alv.

    " ALV Grid'in verilerini ve layout ayarlarını yap
    go_alv->set_table_for_first_display(
      EXPORTING
        is_layout = gs_layout
      CHANGING
        it_outtab = gt_scarr
        it_fieldcatalog = gt_fcat
    ).

  ELSE.
    " Eğer ALV nesnesi zaten varsa, tabloyu yenile
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.
ENDFORM.

FORM get_data.
  " SCARR tablosundaki verileri internal table'a çeker
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
    " Satırlara buton ikonunu ekle
    <gfs_scarr>-delete = '@11@'.
  ENDLOOP.
ENDFORM.

FORM get_fcat.
  " Field catalog'u dinamik olarak oluştur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat = gt_fcat.

  CLEAR gs_fcat. " Field catalog structure'ını temizle
  gs_fcat-fieldname = 'DELETE'. " Delete butonu ekle
  gs_fcat-scrtext_s = 'SIL'.
  gs_fcat-scrtext_m = 'SIL'.
  gs_fcat-scrtext_l = 'SIL'.
  gs_fcat-style     = cl_gui_alv_grid=>mc_style_button. " Buton stili
  gs_fcat-icon      = 'X'. " Kolonun icon alabilme özelliğini aktif et
  APPEND gs_fcat TO gt_fcat.
ENDFORM.

FORM set_layout.
  " ALV Grid'in layout ayarlarını yap
  gs_layout-cwidth_opt = 'X'.
  gs_layout-zebra = 'X'.
ENDFORM.
