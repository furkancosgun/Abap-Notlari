*&---------------------------------------------------------------------*
*&  Include           ZFC_EXCEL_TO_ALV_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF gty_tab, " SCARR tablosunu kullanarak istediğimiz kolonlar için tip oluşturma
         carrid   TYPE scarr-carrid,
         carrname TYPE scarr-carrname,
         currcode TYPE scarr-currcode,
         url      TYPE scarr-url,
       END OF gty_tab.

DATA: gt_fcat TYPE slis_t_fieldcat_alv, " Field catalog tablomuz
      gs_fcat TYPE slis_fieldcat_alv,   " Field catalog'u dolduracağımız yapı
      it_tab TYPE TABLE OF gty_tab WITH HEADER LINE, " Oluşturduğumuz tablo
      it_raw TYPE truxs_t_text_data. " Ham halde gelen Excel verisini tutacak tablo

*&---------------------------------------------------------------------*
*&  Include           ZFC_EXCEL_TO_ALV_FRM
*&---------------------------------------------------------------------*

FORM set_fcat USING p_colid TYPE string
                        p_tabname TYPE string.
  CLEAR gs_fcat.
  gs_fcat-fieldname = p_colid.
  gs_fcat-ref_fieldname = p_colid.
  gs_fcat-ref_tabname = p_tabname.
  APPEND gs_fcat TO gt_fcat.
ENDFORM.

FORM get_fcat.
  PERFORM set_fcat USING 'CARRID'   'SCARR'.
  PERFORM set_fcat USING 'CARRNAME' 'SCARR'.
  PERFORM set_fcat USING 'CURRCODE' 'SCARR'.
  PERFORM set_fcat USING 'URL'      'SCARR'.
ENDFORM.

FORM display_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = gt_fcat
    TABLES
      t_outtab           = it_tab
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    " Hata işleme kodu buraya eklenecek
  ENDIF.
ENDFORM.

FORM get_data USING p_file TYPE string.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_line_header        = 'X' " Excel içinde kolon adları var mı?
      i_tab_raw_data       = it_raw " Ham halde gelen verileri tutacak tablo
      i_filename           = p_file " Dosya adını verir
    TABLES
      i_tab_converted_data = it_tab[] " Verileri iç tabloya aktarır
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Report ZFC_EXCEL_TO_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfc_excel_to_alv.
INCLUDE zfc_excel_to_alv_top.
INCLUDE zfc_excel_to_alv_frm.

PARAMETERS: p_file TYPE rlgrap-filename. " Dosya yolu için parametre

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME' " Dosya seçme fonksiyonu
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name = p_file.

START-OF-SELECTION.
  PERFORM get_data USING p_file. " Dosya adını get_data formuna aktarır
  PERFORM get_fcat. " Field catalog'u oluşturur
  PERFORM display_alv. " ALV ekranında görüntüler
