DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV Grid nesnesi
      go_container TYPE REF TO cl_gui_custom_container, " ALV Grid'in bulunduğu container
      go_event_receiver TYPE REF TO cl_event_receiver, " Event işleyici nesnesi
      go_split_container TYPE REF TO cl_gui_splitter_container, " Container'ı bölmek için
      go_sub1 TYPE REF TO cl_gui_container, " Bir alt container
      go_sub2 TYPE REF TO cl_gui_container, " Diğer alt container
      go_docu TYPE REF TO cl_dd_document. " Top of page için document nesnesi

DATA: gt_scarr TYPE TABLE OF scarr, " SCARR tablosu için internal table
      gs_scarr TYPE scarr. " SCARR tablosu için work area

DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog
      gs_fcat TYPE lvc_s_fcat. " Field catalog için structure

DATA: gs_layout TYPE lvc_s_layo. " Layout ayarları

FIELD-SYMBOLS: <gfs_fcatt> TYPE lvc_s_fcat, " Field catalog field symbol
               <gfs_fscarr> TYPE scarr. " SCARR tablosu field symbol

CLASS cl_event_receiver DEFINITION DEFERRED. " Sınıf tanımı ertelenir

CLASS cl_event_receiver DEFINITION. " Event işleyici sınıfı tanımı
  PUBLIC SECTION.
    METHODS handle_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        er_data_changed
        e_onf4
        e_onf4_before
        e_onf4_after
        e_ucomm.
ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.
  METHOD handle_data_changed.
    DATA: lv_mess TYPE char200, " Mesaj değişkeni
          ls_modi TYPE lvc_s_modi. " Değişiklik bilgilerini tutan değişken

    LOOP AT er_data_changed->mt_good_cells INTO ls_modi. " Değişiklikleri kontrol et
      READ TABLE gt_scarr INTO gs_scarr INDEX ls_modi-row_id. " İlgili satırı oku
      IF sy-subrc EQ 0. " Okuma başarılı ise
        CONCATENATE gs_scarr-carrname " Kolon adı
                    'Kolonunun,'
                    'Eski değeri =>'
                    ls_modi-fieldname " Eski değer
                    'Yeni değeri =>'
                    ls_modi-value " Yeni değer
                    INTO lv_mess
                    SEPARATED BY space.
        MESSAGE lv_mess TYPE 'I'. " Mesajı ekrana bas
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

FORM display_alv.

  IF go_alv IS INITIAL.

    " Event işleyici nesnesini oluşturur
    CREATE OBJECT go_event_receiver.

    " Container nesnesini oluşturur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    " ALV grid nesnesini oluşturur
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

    " Data change eventini ayarlar
    SET HANDLER go_event_receiver->handle_data_changed FOR go_alv.

    " ALV Grid'in verilerini ve layout ayarlarını ayarlar
    go_alv->set_table_for_first_display(
      EXPORTING
        is_layout = gs_layout
      CHANGING
        it_outtab = gt_scarr
        it_fieldcatalog = gt_fcat
    ).

    " Edit eventini kaydeder
    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  ELSE.
    " Eğer ALV nesnesi zaten varsa, tabloyu yeniler
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.

ENDFORM.

FORM get_data.

  " SCARR tablosundaki verileri internal table'a çeker
  SELECT * FROM scarr INTO TABLE gt_scarr.

ENDFORM.

FORM set_fcat USING p_fieldname.

  " Field catalog ayarlarını yapar
  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname.
  gs_fcat-ref_table = 'SCARR'.
  gs_fcat-ref_field = p_fieldname.
  APPEND gs_fcat TO gt_fcat.

ENDFORM.

FORM get_fcat.

  " Field catalog'u dinamik olarak oluşturur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat = gt_fcat.

  LOOP AT gt_fcat ASSIGNING <gfs_fcatt>.
    IF <gfs_fcatt>-fieldname EQ 'CARRNAME'.
      <gfs_fcatt>-edit = abap_true.
    ELSEIF <gfs_fcatt>-fieldname EQ 'CARRID'.
      <gfs_fcatt>-key = 'X'.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM set_layout.

  " ALV Grid'in layout ayarlarını yapar
  gs_layout-cwidth_opt = 'X'.
  gs_layout-zebra = 'X'.

ENDFORM.
