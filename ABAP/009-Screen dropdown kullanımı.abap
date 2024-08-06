*&---------------------------------------------------------------------*
*& Report ZFC_SCREEN_EXAMPLE_APP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_SCREEN_EXAMPLE_APP.

* Değişkenler
DATA: gv_name TYPE char30,         " Kullanıcı adı
      gv_surname TYPE char30,      " Kullanıcı soyadı
      gv_gender_M TYPE char1,      " Erkek cinsiyeti için flag
      gv_gender_F TYPE char1,      " Kadın cinsiyeti için flag, xfeld kullanılabilir
      gv_chkBox TYPE xfeld,        " Checkbox için flag
      gv_salary TYPE i.            " Maaş bilgisi

* Dropdown verileri
DATA: gv_id TYPE vrm_id,           " Veri tablosu ID'si
      gt_values TYPE vrm_values,   " Dropdown değerleri tablosu
      gs_value TYPE vrm_value,     " Dropdown değerlerini tutan yapı
      gv_index TYPE i.             " Döngüde kullanılacak indeks

START-OF-SELECTION.

  " Dropdown veri hazırlığı
  gv_index = 18.                 " Başlangıç indeksi
  DO 40 TIMES.                  " 40 kez döngü
    gs_value-key = gv_index.    " Dropdown verisi için key değeri
    gs_value-text = gv_index.   " Dropdown verisi için metin değeri
    APPEND gs_value TO gt_values. " Dropdown değerler tablosuna ekle
    gv_index = gv_index + 1.    " İndeksi bir artır
  ENDDO.

  gv_chkBox = abap_true.        " Checkbox varsayılan olarak işaretli
  CALL SCREEN 0100.            " Ekranı yüklemeden önce veri hazırlığı yapılmalı

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Bu modül ekran çıktısı hazırlandığında tetiklenir
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100_STATUS'.  " Ekran için PF-STATUS ayarla
*  SET TITLEBAR 'xxx'.         " Başlık çubuğunu ayarla, opsiyonel

  " Dropdown verilerini ayarla
  gv_id = 'GV_SALARY'.          " Dropdown için ID
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID     = gv_id,           " Dropdown ID
      VALUES = gt_values.      " Dropdown değerleri

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       Kullanıcı komutlarını işlemek için bu modül kullanılır
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE sy-ucomm.
    WHEN '&BCK'.               " Geri butonuna basıldığında
      IF gv_gender_M EQ abap_true. " Erkek cinsiyeti seçilmişse
        MESSAGE 'Cinsiyetiniz erkek' TYPE 'I'. " Bilgi mesajı
      ELSE. 
        MESSAGE 'Cinsiyetiniz kadın' TYPE 'I'. " Bilgi mesajı
      ENDIF.

      IF gv_chkBox EQ 'X'.     " Checkbox işaretlenmişse
         MESSAGE 'Sözleşme kabul edildi' TYPE 'I'. " Bilgi mesajı
         LEAVE TO SCREEN 0.  " Ekranı kapat ve ana ekrana dön
      ELSE.
        MESSAGE 'Sözleşme kabul edilmek zorundadır' TYPE 'I'. " Bilgi mesajı
      ENDIF.
  ENDCASE.

ENDMODULE.
