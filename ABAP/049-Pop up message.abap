*&---------------------------------------------------------------------*
*& Report ZPOPUP_EXAMPLES
*&---------------------------------------------------------------------*
REPORT zpopup_examples.

DATA: lv_answer TYPE c LENGTH 1, " İki seçenekli pop-up yanıtı
      lv_result TYPE c LENGTH 1, " Radyo butonlu pop-up yanıtı
      lv_mind   TYPE c LENGTH 1, " Onay pop-up yanıtı
      gv_text   TYPE string.     " String değer girilen pop-up yanıtı

*&---------------------------------------------------------------------*
*&  Include           ZPOPUP_EXAMPLES_FM
*&---------------------------------------------------------------------*

* İki seçenekli pop-up penceresi: "SMART FORM" veya "ADOBE FORM"
CALL FUNCTION 'POPUP_WITH_2_BUTTONS_TO_CHOOSE'
  EXPORTING
    diagnosetext1 = 'Lütfen İstenilen Form Türünü Seçiniz...'
    textline1     = space
    textline2     = space
    text_option1  = 'SMART FORM'
    text_option2  = 'ADOBE FORM'
    titel         = 'Seçim Yap'
  IMPORTING
    answer        = lv_answer.

* Radyo butonlu pop-up penceresi: İki seçenek sunar
CALL FUNCTION 'K_KKB_POPUP_RADIO2'
  EXPORTING
    i_title   = 'Form Türünü Seçin'
    i_text1   = 'SMARTFORM'
    i_text2   = 'ADOBE FORM'
    i_default = 'DEFAULT'
  IMPORTING
    i_result  = lv_result
  EXCEPTIONS
    cancel    = 1
    OTHERS    = 2.
IF sy-subrc <> 0.
  " Hata işleme burada yapılabilir
  WRITE: / 'Radyo butonlu pop-up işlemi başarısız oldu.'.
ENDIF.

* Onay pop-up penceresi: Seçilen kayıtların silinmesini onaylar
CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    text_question         = 'Seçilen kayıtlar silinecek. Devam etmek istiyor musunuz?'
    text_button_1         = 'Evet'
    icon_button_1         = 'ICON_OKAY'
    text_button_2         = 'Hayır'
    icon_button_2         = 'ICON_CANCEL'
    display_cancel_button = ' '
    popup_type            = 'ICON_MESSAGE_QUESTION'
  IMPORTING
    answer                = lv_mind
  EXCEPTIONS
    text_not_found        = 1
    OTHERS                = 2.

* String değer girişi için pop-up penceresi
CALL FUNCTION 'CC_POPUP_STRING_INPUT'
  EXPORTING
    property_name = 'Müşteri adres bilgisi'
  CHANGING
    string_value  = gv_text.

*&---------------------------------------------------------------------*
*& END OF REPORT
*&---------------------------------------------------------------------*
