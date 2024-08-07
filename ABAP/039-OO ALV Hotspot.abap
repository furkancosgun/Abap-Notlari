DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV grid nesnesi
      go_container TYPE REF TO cl_gui_custom_container, " ALV'yi tutacak container
      gt_scarr TYPE TABLE OF scarr, " SCARR tablosundan veri
      gs_scarr TYPE scarr, " SCARR tablosu için tekil veri
      gt_fcat TYPE lvc_t_fcat, " Field catalog
      gs_fcat TYPE lvc_s_fcat, " Field catalog için yapı
      gs_layout TYPE lvc_s_layo, " Layout ayarları
      go_event_receiver TYPE REF TO cl_event_receiver. " Event işleyici sınıf

" Ekranı bölmek için kullanılacak container ve alt container'lar
DATA: go_split_container TYPE REF TO cl_gui_splitter_container,
      go_sub1 TYPE REF TO cl_gui_container,
      go_sub2 TYPE REF TO cl_gui_container.

FIELD-SYMBOLS: <gfs_fcatt> TYPE lvc_s_fcat. " Field catalog için field-symbol

FORM display_alv .

  IF go_alv IS INITIAL.

    " Event receiver'ı oluşturur
    CREATE OBJECT go_event_receiver.

    " Container nesnesini oluşturur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    " ALV grid nesnesini oluşturur ve container'a yerleştirir
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

    " Hotspot click event'ini ayarlar
    SET HANDLER go_event_receiver->handle_hotspot_click FOR go_alv.

    " ALV grid'ini veri ve layout ile görüntüler
    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout = gs_layout
      CHANGING
        it_outtab = gt_scarr
        it_fieldcatalog = gt_fcat.

  ELSE.
    " ALV grid'ini günceller
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.

ENDFORM.

FORM get_data .

  " SCARR tablosundan veriyi alır
  SELECT * FROM scarr INTO TABLE gt_scarr.

ENDFORM.

FORM set_fcat USING p_fieldname.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Kolon adı
  gs_fcat-ref_table = 'SCARR'. " Referans tablo
  gs_fcat-ref_field = p_fieldname. " Referans alan

  APPEND gs_fcat TO gt_fcat.

ENDFORM.

FORM get_fcat .

  " Field catalog'u oluşturur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat = gt_fcat.

  " Field catalog'daki alanları döner ve hotspot ayarlarını yapar
  LOOP AT gt_fcat ASSIGNING <gfs_fcatt>.
    IF <gfs_fcatt>-fieldname EQ 'CARRID' OR <gfs_fcatt>-fieldname EQ 'CARRNAME'.
      <gfs_fcatt>-hotspot = abap_true. " Hotspot özelliğini aktif eder
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM set_layout .

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Kolon genişliklerini otomatik ayarla
  gs_layout-zebra = 'X'. " Zebra desenini uygula

ENDFORM.

CLASS cl_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS handle_hotspot_click " Hotspot click olayını işler
      FOR EVENT hotspot_click OF cl_gui_alv_grid
    IMPORTING
      e_row_id
      e_column_id.

ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_hotspot_click.

    DATA lv_mess TYPE char200. " Mesaj değişkeni

    " İlgili satırı alır
    READ TABLE gt_scarr INTO gs_scarr INDEX e_row_id-index.
    IF sy-subrc EQ 0.
      CASE e_column_id.
        WHEN 'CARRID'.
          CONCATENATE 'Tıklanan kolon'
                      e_column_id
                      'Değeri'
                      gs_scarr-carrid
                      INTO lv_mess
                      SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'. " Mesajı ekrana basar
        WHEN 'CARRNAME'.
          CONCATENATE 'Tıklanan kolon'
                      e_column_id
                      'Değeri'
                      gs_scarr-carrname
                      INTO lv_mess
                      SEPARATED BY space.
          MESSAGE lv_mess TYPE 'I'. " Mesajı ekrana basar
      ENDCASE.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
