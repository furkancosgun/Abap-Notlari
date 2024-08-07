DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV grid nesnesi
      go_container TYPE REF TO cl_gui_custom_container, " ALV'yi tutacak container
      gt_scarr TYPE TABLE OF scarr, " SCARR tablosundan veri
      gs_scarr TYPE scarr, " SCARR tablosu için tekil veri
      gt_fcat TYPE lvc_t_fcat, " Field catalog tablosu
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

    " Event receiver nesnesini oluşturur
    CREATE OBJECT go_event_receiver.

    " Container nesnesini oluşturur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    " ALV grid nesnesini oluşturur ve container'a yerleştirir
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container.

    " Double-click event'ini ayarlar
    SET HANDLER go_event_receiver->handle_double_click FOR go_alv.

    " ALV grid'ini veri ve layout ile ilk kez görüntüler
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

  " Field catalog ayarlarını yapar
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

  " ALV grid'inin layout ayarlarını yapar
  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Kolon genişliklerini otomatik ayarla
  gs_layout-zebra = 'X'. " Zebra desenini uygula

ENDFORM.

CLASS cl_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS handle_double_click " Hücreye çift tıklama event'ini işler
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.

ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_double_click.

    DATA lv_mess TYPE char200. " Mesaj değişkeni

    " İlgili satırı alır
    READ TABLE gt_scarr INTO gs_scarr INDEX es_row_no-row_id.
    IF sy-subrc EQ 0.
      " Çift tıklama olayında, tıklanan kolonun bilgilerini mesaj olarak basar
      CONCATENATE 'Tıklanan kolon'
                  e_column-fieldname
                  'Değeri'
                  gs_scarr
                  INTO lv_mess
                  SEPARATED BY space.
      MESSAGE lv_mess TYPE 'I'. " Mesajı ekrana basar
    ENDIF.

  ENDMETHOD.

ENDCLASS.
