*&---------------------------------------------------------------------*
*& Report ZFC_ALV_OO_ALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT ZFC_ALV_OO_ALV_KULLANIM.

" ALV ve Container tanımlamaları
DATA: go_alv TYPE REF TO CL_GUI_ALV_GRID, " ALV nesnesini tanımlar
      go_container TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " ALV için container tanımlar

" Tablo verileri için tanımlar
DATA: gt_scarr TYPE TABLE OF gty_scarr. " Tablo verilerini tutacak iç tablo

" Field catalog tanımlamaları
DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog için iç tablo
      gs_fcat TYPE lvc_s_fcat. " Field catalog için yapı

" Layout ayarları için yapı
DATA: gs_layout TYPE LVC_S_LAYO. " Layout yapılandırması için yapı

" Field symbol ile field catalog üzerinde değişiklik yapmak için
FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat.

" Satır ve hücre renklendirmesi için tanımlar
TYPES: BEGIN OF gty_scarr,
  CARRID TYPE S_CARR_ID,
  CARRNAME TYPE S_CARRNAME,
  CURRCODE TYPE S_CURRCODE,
  URL TYPE S_CARRURL,
  linecolor TYPE CHAR4, " Satır renklendirme
  cell_color TYPE LVC_T_SCOL, " Hücre renklendirme tablosu
  END OF gty_scarr.

DATA: gs_cell_color TYPE LVC_S_SCOL. " Hücre renk yapısı

FIELD-SYMBOLS: <gfs_scarr> TYPE gty_scarr. " Satır renklendirme için field symbol

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Verileri çeker ve renklendirme işlemleri yapar
*----------------------------------------------------------------------*
FORM GET_DATA.

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  " Gelen veriyi işleyip renklendirme işlemleri yapar
  LOOP AT gt_scarr ASSIGNING <GFS_SCARR>.
    CASE <GFS_SCARR>-CURRCODE.
      WHEN 'USD'.
        <GFS_SCARR>-LINECOLOR = 'C610'. " Satır rengini kırmızı yapar
      WHEN 'JPY'.
        <GFS_SCARR>-LINECOLOR = 'C710'.
      WHEN 'EUR'.
        CLEAR: gs_cell_color.
        GS_CELL_COLOR-FNAME = 'CURRCODE'.
        GS_CELL_COLOR-COLOR-COL = '3'.
        GS_CELL_COLOR-COLOR-int = '1'.
        GS_CELL_COLOR-COLOR-inv = '0'.
        APPEND GS_CELL_COLOR TO <GFS_SCARR>-CELL_COLOR.
    ENDCASE.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       Layout ayarlarını yapılandırır
*----------------------------------------------------------------------*
FORM SET_LAYOUT.

  CLEAR GS_LAYOUT.
  GS_LAYOUT-CWIDTH_OPT = 'X'. " Kolon genişliklerini optimize eder
  "GS_LAYOUT-EDIT = ABAP_TRUE. " Kolonları düzenlenebilir yapar
  "GS_LAYOUT-NO_TOOLBAR = 'X'. " Toolbar'ı gizler
  GS_LAYOUT-ZEBRA = 'X'. " Zebra desenini uygular
  GS_LAYOUT-INFO_FNAME = 'LINECOLOR'. " Kolonun veri tutmadığını belirtir
  GS_LAYOUT-CTAB_FNAME = 'CELL_COLOR'. " Hücre renklendirmesi için

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       ALV grid'i ekrana basar
*----------------------------------------------------------------------*
FORM DISPLAY_ALV.

  CREATE OBJECT go_container " ALV için container oluşturur
    EXPORTING
      container_name = 'CC_ALV'. " Layout üzerindeki custom container ID'si

  CREATE OBJECT go_alv " ALV nesnesi oluşturur
    EXPORTING
      i_parent = go_container. " Container ID'sini belirtir

  CALL METHOD go_alv->SET_TABLE_FOR_FIRST_DISPLAY " ALV'yi ekrana basar
    EXPORTING
      IS_LAYOUT = gs_layout
    CHANGING
      IT_OUTTAB = gt_scarr " Veriyi ekranda gösterecek tablo
      IT_FIELDCATALOG = gt_fcat " Field catalog ile kolon düzenlemesi
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR = 2
      TOO_MANY_LINES = 3
      OTHERS = 4.

  IF SY-SUBRC <> 0.
    " Uygun hata işleme burada yapılabilir
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field catalog oluşturur
*----------------------------------------------------------------------*
FORM SET_FCAT.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE' " Otomatik field catalog oluşturma
    EXPORTING
      I_STRUCTURE_NAME = 'SCARR'
    CHANGING
      CT_FIELDCAT = gt_fcat " Field catalog için iç tabloyu oluşturur
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR = 2
      OTHERS = 3.

  IF SY-SUBRC <> 0.
    " Uygun hata işleme burada yapılabilir
  ENDIF.

  " Manuel field catalog oluşturma
  READ TABLE gt_fcat ASSIGNING <gfs_fcat> WITH KEY fieldname = 'CARRID'.
  IF sy-subrc = 0.
    <gfs_fcat>-KEY = 'X'. " Key alanını ayarlar
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Start-of-Selection
*&---------------------------------------------------------------------*
*       Programın ana çalıştırma bölümü
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_data. " Verileri çeker
  PERFORM set_fcat. " Field catalog'u doldurur
  PERFORM set_layout. " ALV layout ayarlarını yapar
  PERFORM display_alv. " ALV'yi ekrana basar

  CALL SCREEN 0100. " Ekranı çağırır
