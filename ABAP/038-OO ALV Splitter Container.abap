*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME
*&---------------------------------------------------------------------*

" ALV nesneleri ve container'lar için tanımlar
DATA: go_alv TYPE REF TO cl_gui_alv_grid, " İlk ALV nesnesi
      go_alv2 TYPE REF TO cl_gui_alv_grid, " İkinci ALV nesnesi
      go_alv3 TYPE REF TO cl_gui_alv_grid, " Üçüncü ALV nesnesi
      go_alv4 TYPE REF TO cl_gui_alv_grid. " Dördüncü ALV nesnesi

DATA: gt_fcat TYPE lvc_t_fcat, " İlk ALV için field catalog
      gt_fcat2 TYPE lvc_t_fcat, " İkinci ALV için field catalog
      gt_fcat3 TYPE lvc_t_fcat, " Üçüncü ALV için field catalog
      gt_fcat4 TYPE lvc_t_fcat, " Dördüncü ALV için field catalog
      gs_layout TYPE lvc_s_layo. " Layout yapılandırması

DATA: gt_scarr TYPE TABLE OF scarr, " SCARR tablosundan veri
      gt_sflight TYPE TABLE OF sflight, " SFLIGHT tablosundan veri
      gt_ekko TYPE TABLE OF ekko, " EKKO tablosundan veri
      gt_ekpo TYPE TABLE OF ekpo. " EKPO tablosundan veri

" Ekranı bölen container'lar için tanımlar
DATA: go_splitter TYPE REF TO cl_gui_splitter_container,
      go_sub1 TYPE REF TO cl_gui_container, " İlk parça
      go_sub2 TYPE REF TO cl_gui_container, " İkinci parça
      go_sub3 TYPE REF TO cl_gui_container, " Üçüncü parça
      go_sub4 TYPE REF TO cl_gui_container. " Dördüncü parça

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Ekranda ALV tablolarını gösterir
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM dispaly_alv .

  " Splitter container'ı oluşturur ve ekranı dört parçaya böler
  CREATE OBJECT go_splitter
    EXPORTING
      parent = cl_gui_container=>screen0
      rows = 2
      columns = 2.

  " Her bir parça için container'lar oluşturur
  CALL METHOD go_splitter->get_container
    EXPORTING
      row = 1
      column = 1
    RECEIVING
      container = go_sub1.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row = 2
      column = 1
    RECEIVING
      container = go_sub2.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row = 1
      column = 2
    RECEIVING
      container = go_sub3.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row = 2
      column = 2
    RECEIVING
      container = go_sub4.

  " İlk ALV nesnesini oluşturur ve ilk container'a yerleştirir
  CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_sub1.

  " İkinci ALV nesnesini oluşturur ve ikinci container'a yerleştirir
  CREATE OBJECT go_alv2
    EXPORTING
      i_parent = go_sub2.

  " Üçüncü ALV nesnesini oluşturur ve üçüncü container'a yerleştirir
  CREATE OBJECT go_alv3
    EXPORTING
      i_parent = go_sub3.

  " Dördüncü ALV nesnesini oluşturur ve dördüncü container'a yerleştirir
  CREATE OBJECT go_alv4
    EXPORTING
      i_parent = go_sub4.

  " İlk ALV'yi veri ve layout ile gösterir
  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING
      is_layout = gs_layout
    CHANGING
      it_outtab = gt_scarr
      it_fieldcatalog = gt_fcat.

  " İkinci ALV'yi veri ve layout ile gösterir
  CALL METHOD go_alv2->set_table_for_first_display
    EXPORTING
      is_layout = gs_layout
    CHANGING
      it_outtab = gt_sflight
      it_fieldcatalog = gt_fcat2.

  " Üçüncü ALV'yi veri ve layout ile gösterir
  CALL METHOD go_alv3->set_table_for_first_display
    EXPORTING
      is_layout = gs_layout
    CHANGING
      it_outtab = gt_ekko
      it_fieldcatalog = gt_fcat3.

  " Dördüncü ALV'yi veri ve layout ile gösterir
  CALL METHOD go_alv4->set_table_for_first_display
    EXPORTING
      is_layout = gs_layout
    CHANGING
      it_outtab = gt_ekpo
      it_fieldcatalog = gt_fcat4.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Veriyi alır ve tabloları doldurur
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  " SCARR tablosundan veriyi alır
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  " SFLIGHT tablosundan ilk 20 satırı alır
  SELECT * FROM sflight UP TO 20 ROWS INTO CORRESPONDING FIELDS OF TABLE gt_sflight.

  " EKKO tablosundan ilk 20 satırı alır
  SELECT * FROM ekko UP TO 20 ROWS INTO CORRESPONDING FIELDS OF TABLE gt_ekko.

  " EKPO tablosundan ilk 20 satırı alır
  SELECT * FROM ekpo UP TO 20 ROWS INTO CORRESPONDING FIELDS OF TABLE gt_ekpo.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field catalog ayarlarını yapar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fcat .

  " SCARR tablosu için field catalog oluşturur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat = gt_fcat.

  " SFLIGHT tablosu için field catalog oluşturur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SFLIGHT'
    CHANGING
      ct_fieldcat = gt_fcat2.

  " EKKO tablosu için field catalog oluşturur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'EKKO'
    CHANGING
      ct_fieldcat = gt_fcat3.

  " EKPO tablosu için field catalog oluşturur
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'EKPO'
    CHANGING
      ct_fieldcat = gt_fcat4.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       ALV'nin layout ayarlarını yapar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_layout .

  CLEAR gs_layout.

  gs_layout-cwidth_opt = 'X'. " Kolon genişliklerini otomatik ayarla
  gs_layout-zebra = 'X'. " Zebra desenini uygula

ENDFORM.
