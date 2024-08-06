*&---------------------------------------------------------------------*
*& Report ZFC_ALV_REUSE_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

* Bu rapor, ALV Grid Display kullanarak çeşitli işlemler yapar.
* Ayrıca, ALV variant işlemlerini de içerir.

*--------------------------------------------------------------*
* Global veri tanımlamaları
*--------------------------------------------------------------*
DATA: gs_variant TYPE DISVARIANT, " Variant işlemleri için yapı
      gs_exit    TYPE char1.      " Çıkış kodu

* Kullanıcıdan variant seçimi almak için parameter
PARAMETERS p_vari TYPE DISVARIANT-VARIANT.

*--------------------------------------------------------------*
* Raporun başlangıç kısmı
*--------------------------------------------------------------*
INITIALIZATION.

  * Varsayılan kaydedilen variantı almak için fonksiyon çağırılır
  gs_variant-REPORT = sy-repid. " Variantın hangi raporda kullanılacağını belirler

  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    CHANGING
      CS_VARIANT = gs_variant
    EXCEPTIONS
      WRONG_INPUT = 1
      NOT_FOUND   = 2
      PROGRAM_ERROR = 3
      OTHERS      = 4.
  
  IF SY-SUBRC = 0.
    p_vari = gs_variant-VARIANT. " Varsayılan variantı parametreye atar
  ENDIF.

*--------------------------------------------------------------*
* Kullanıcıdan variant seçimi almak için seçim ekranında fonksiyon çağırılır
*--------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  gs_variant-REPORT = sy-repid. " Variantın hangi raporda kullanılacağını belirler

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT = gs_variant
    IMPORTING
      E_EXIT     = gs_exit
      ES_VARIANT = gs_variant
    EXCEPTIONS
      NOT_FOUND  = 1
      PROGRAM_ERROR = 2
      OTHERS     = 3.

  IF SY-SUBRC IS INITIAL.
    p_vari = gs_variant-VARIANT. " Seçilen variantı parametreye atar
  ENDIF.

*--------------------------------------------------------------*
* Raporun ana seçimi
*--------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_data.    " Veri alma fonksiyonu
  PERFORM set_fieldcatalog. " Field catalog ayarları
  PERFORM set_layout. " Layout ayarları
  PERFORM display_alv. " ALV Grid Display çağrısı

*--------------------------------------------------------------*
* FORM tanımlamaları
*--------------------------------------------------------------*

FORM display_alv.

  " Variant işlemleri: Kullanıcıdan seçilen variantı ayarlama
  gs_variant-VARIANT = p_vari. " Kaydedilen variantın ID'sini belirler

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = sy-repid " Callback fonksiyonlarının bulunduğu program
      IS_LAYOUT = gs_layout " Layout ayarları
      IT_FIELDCAT = gt_fieldcalatog " Field catalog (Tablo kolonları)
      IT_EXCLUDING = gt_exclude " Status bardan çıkarılacak işlemler
      * IT_SPECIAL_GROUPS = ' '
      IT_SORT = gt_sort " Sıralama bilgileri
      IT_FILTER = gt_filter " Filtreleme bilgileri
      * IS_SEL_HIDE = ' '
      I_DEFAULT = 'X' " Varsayılan variantların etkilenip etkilenmeyeceği
      I_SAVE = 'A' " Variantları kaydetme ayarı: 'X' -> Genel değişim, 'U' -> Kullanıcıya özel değişim, 'A' -> Hem genel hem kullanıcıya özel
      IS_VARIANT = gs_variant " Variant işlemleri için yapı
      IT_EVENTS = gt_events " Event yapılandırması
    TABLES
      T_OUTTAB = gt_list " İç tablo
    EXCEPTIONS
      PROGRAM_ERROR = 1 " Program hatası
      OTHERS = 2 " Diğer hatalar
      .

  IF SY-SUBRC <> 0.
    " Hata işleme burada yapılabilir
  ENDIF.

ENDFORM.
