*&---------------------------------------------------------------------*
*& Report ZFC_RADIOBUTTON_DEMO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_RADIOBUTTON_DEMO.

* Parametreler
PARAMETERS: p_file1 TYPE c RADIOBUTTON GROUP a DEFAULT 'X',
            p_date  TYPE c RADIOBUTTON GROUP a,
            p_pres  TYPE c RADIOBUTTON GROUP b MODIF ID 001,
            p_appl  TYPE c RADIOBUTTON GROUP b MODIF ID 001.

* Ekran çıktısı işlemleri
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    * Ekran elemanlarını kontrol et
    IF screen-group1 = '001'.
      * Eğer p_file1 seçilmişse, p_pres ve p_appl ekran elemanlarını etkinleştir
      IF p_file1 = 'X'.
        screen-active = '1'.
      ELSE.
        screen-active = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

  " İşlem yapabileceğiniz yer

