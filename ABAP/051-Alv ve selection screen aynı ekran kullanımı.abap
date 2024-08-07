*&---------------------------------------------------------------------*
*& Report ZFC_EXAMPLE_11
*&---------------------------------------------------------------------*
REPORT zfc_example_11.

*&---------------------------------------------------------------------*
*&  Include           ZFC_EXAMPLE_11_TOP
*&---------------------------------------------------------------------*
TYPES: BEGIN OF zfc_satis,
         aciklama TYPE string,        " Açıklama
         miktar TYPE i,              " Miktar
         birim_fiyat TYPE p DECIMALS 2, " Birim fiyat
         toplam TYPE p DECIMALS 2,  " Toplam (Birim fiyat * Miktar)
       END OF zfc_satis.

DATA: gv_text  TYPE string,
      gt_table TYPE TABLE OF zfc_satis WITH HEADER LINE.

" ALV nesneleri
DATA: dockingbottom TYPE REF TO cl_gui_docking_container,
      alv_bottom    TYPE REF TO cl_gui_alv_grid.

" Layout
DATA gs_layout TYPE lvc_s_layo.

*&---------------------------------------------------------------------*
*&  Include           ZFC_EXAMPLE_11_FRM
*&---------------------------------------------------------------------*
FORM get_adobe USING p_table TYPE zfc_satis_tt
                     p_adres TYPE string.
  DATA: fm_name           TYPE rs38l_fnam,
        fp_docparams      TYPE sfpdocparams,
        fp_outputparams   TYPE sfpoutputparams.

  " Çıktı parametrelerini ayarla ve spool job'u aç
  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    " Hata işleme
  ENDIF.

  " Oluşturulan fonksiyon modülünün adını al
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = 'ZFC_EXAMPLE_EFATURA' " Adobe form adı
    IMPORTING
      e_funcname = fm_name.

  " Adobe formu çağır
  CALL FUNCTION fm_name
    EXPORTING
      it_satis                 = p_table
      iv_musteri_adres         = p_adres
    EXCEPTIONS
      usage_error              = 1
      system_error             = 2
      internal_error           = 3
      OTHERS                   = 4.
  IF sy-subrc <> 0.
    " Hata işleme
  ENDIF.

  " Spool job'u kapat
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error           = 1
      system_error          = 2
      internal_error        = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    " Hata işleme
  ENDIF.
ENDFORM.

FORM add_table USING p_acklma TYPE string
                        p_miktar TYPE i
                        p_bfiyat TYPE p DECIMALS 2.
  " Tabloya yeni satır ekler
  gt_table-aciklama = p_acklma.
  gt_table-miktar = p_miktar.
  gt_table-birim_fiyat = p_bfiyat.
  gt_table-toplam = p_bfiyat * p_miktar.
  APPEND gt_table.
  MESSAGE 'Satış başarıyla eklendi' TYPE 'S'.
ENDFORM.

FORM display_alv.
  IF dockingbottom IS INITIAL.
    CREATE OBJECT dockingbottom
      EXPORTING
        repid     = sy-repid
        dynnr     = sy-dynnr
        side      = dockingbottom->dock_at_bottom
        extension = 170.

    CREATE OBJECT alv_bottom
      EXPORTING
        i_parent = dockingbottom.

    CALL METHOD alv_bottom->set_table_for_first_display
      EXPORTING
        is_layout        = gs_layout       " Layout
        i_structure_name = 'ZFC_SATIS'
      CHANGING
        it_outtab        = gt_table[].
  ELSE.
    alv_bottom->refresh_table_display( ).
  ENDIF.
ENDFORM.

FORM set_layout.
  CLEAR gs_layout.
  gs_layout-zebra = 'X'.       " Zebra çizgili satırlar
  gs_layout-cwidth_opt = 'X'.  " Kolon genişliğini otomatik ayarla
ENDFORM.

*&---------------------------------------------------------------------*
*&      Selection Screen
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK sel_screen_1 WITH FRAME TITLE TEXT-000.
PARAMETERS: acklma TYPE zfc_satis-aciklama,
            miktar TYPE zfc_satis-miktar,
            bfiyat TYPE zfc_satis-birim_fiyat.

SELECTION-SCREEN: PUSHBUTTON /1(20) btnadd USER-COMMAND btnadd, " Ekle butonu
                  PUSHBUTTON 21(20) btnpdf USER-COMMAND btnpdf. " PDF butonu
SELECTION-SCREEN END OF BLOCK sel_screen_1.

INITIALIZATION.
  PERFORM set_layout.
  btnadd = 'Ekle'.  " Ekle butonunun etiketi
  btnpdf = 'PDF Yazdır'. " PDF butonunun etiketi

AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'BTNADD'.
      PERFORM add_table USING acklma miktar bfiyat.
      CLEAR: acklma, miktar, bfiyat.

    WHEN 'BTNPDF'.
      CALL FUNCTION 'CC_POPUP_STRING_INPUT'
        EXPORTING
          property_name = 'Müşteri adres bilgisi'
        CHANGING
          string_value  = gv_text.
      PERFORM get_adobe USING gt_table[] gv_text.

  ENDCASE.

  PERFORM display_alv.
