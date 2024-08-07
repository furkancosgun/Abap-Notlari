--------TOP-------

*&---------------------------------------------------------------------*
*&  Include           ZFC_TEXT_TO_TABLE_TOP
*&---------------------------------------------------------------------*

DATA: it_itab TYPE STANDARD TABLE OF zfc_table WITH HEADER LINE. " Kendi oluşturduğunuz tablo için internal tablo
DATA: lv_file TYPE string. " Dosya adını tutacak değişken

-------FRM--------

*&---------------------------------------------------------------------*
*&  Include           ZFC_TEXT_TO_TABLE_FRM
*&---------------------------------------------------------------------*

FORM get_data USING p_file TYPE string. " Dosya adını form parametresi olarak alır

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                      = p_file " Dosya adı
      has_field_separator           = '#' " Alan ayracı
      codepage                      = '4110' " Dosya kodlama sayfası
    TABLES
      data_tab                      = it_itab[]. " Text'ten tabloya dönüştürülmüş veriler

  LOOP AT it_itab[] ASSIGNING FIELD-SYMBOL(<ifs_itab>). " Text içinden alınan tabloyu döneriz

    " Kolon adları: EBELN, BSART, AEDAT, AEDAT2, ERNAM, TXZ01

    IF <ifs_itab>-aedat EQ 0 OR <ifs_itab>-aedat2 EQ 0. " Eğer kolonlar boşsa (0) ise
      SHIFT <ifs_itab>-aedat LEFT DELETING LEADING '0'. " Kolon değerlerini temizleriz
      SHIFT <ifs_itab>-aedat2 LEFT DELETING LEADING '0'.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Görüntüleme işlemi için ALV kullanımı
*----------------------------------------------------------------------*
FORM display_alv. " Reuse ALV kullanarak ekranı basma işlemi yapacağız

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program                = sy-repid " Rapor ismini sistemden alır
      i_structure_name                  = 'ZFC_TABLE' " Tablo yapısını belirtir
    TABLES
      t_outtab                          = it_itab[] " Text'ten dönen tabloyu yazdırır
    EXCEPTIONS
      program_error                     = 1
      OTHERS                            = 2.

ENDFORM.

--------Main--------

*&---------------------------------------------------------------------*
*& Report ZFC_TEXT_TO_TABLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfc_text_to_table.
INCLUDE zfc_text_to_table_top.
INCLUDE zfc_text_to_table_frm.

PARAMETERS: p_file LIKE rlgrap-filename DEFAULT 'C:\'. " Varsayılan dosya yolu 'C:\' olarak belirlenmiş

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file. " Parametrenin arama yardımcısına tıklanınca çalışır

  CALL FUNCTION 'WS_FILENAME_GET' " Dosya seçim penceresini açar
    EXPORTING
      def_path = p_file " Varsayılan dosya yolu
      mask     = '*.*' " Tüm dosyalar için filtre
      mode     = '0' " Dosya seçme modu
      title    = 'Choose File' " Pencere başlığı
    IMPORTING
      filename = p_file " Seçilen dosyanın adı
    EXCEPTIONS
      inv_winsys       = 1 " Windows sistemi hatası
      no_batch         = 2 " Batch işlem yapılamazsa
      selection_cancel = 3 " Kullanıcı seçim yapmadan pencereyi kapatırsa
      selection_error  = 4 " Seçim hatası
      others           = 5. " Diğer beklenmeyen hatalar

START-OF-SELECTION. " Rapor çalıştırıldığında başlar
  lv_file = p_file. " Parametreden dönen değeri değişkene atar
  PERFORM get_data USING lv_file. " Veri alma işlemini başlatır
  PERFORM display_alv. " ALV'yi görüntüler
