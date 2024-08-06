*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_REUSE_KULLANIM
*&---------------------------------------------------------------------*

* Bu dosya, ALV Grid Display kullanarak veri görüntülemek için kullanılır.
* Kullanıcı etkileşimlerini yönetmek amacıyla callback fonksiyonları ve 
* event yapıları kullanılmıştır.

* Global veri tipi ve yapı tanımlamaları
TYPES: BEGIN OF gty_list, " ALV grid için veri yapısı
       chkbox TYPE char1, " Satır seçimleri için checkbox
       EBELN TYPE EBELN, " Satın alma belge numarası (ekko tablosu)
       ebelp TYPE ebelp, " Kalem numarası (ekpo tablosu)
       bstyp TYPE ebstyp, " Belge tipi (ekko tablosu)
       bsart TYPE esart, " Belge türü (ekko tablosu)
       matnr TYPE matnr, " Malzeme numarası (ekpo tablosu)
       menge TYPE bstmg, " Malzeme miktarı (ekpo tablosu)
       meins TYPE meins, " Miktar türü (ekpo tablosu)
       statu TYPE statu, " Sipariş durumu (ekpo tablosu)
  END OF gty_list.

* İç tablolara ve yapılarına ait tanımlamalar
DATA: gt_list TYPE TABLE OF gty_list, " İç tablo
      gs_list TYPE gty_list. " İç tablo satırı

DATA: gt_fieldcalatog TYPE SLIS_T_FIELDCAT_ALV, " Field catalog için iç tablo
      gs_fieldcalatog TYPE slis_fieldcat_alv. " Field catalog yapısı

DATA gs_layout TYPE SLIS_LAYOUT_ALV. " ALV ekran yerleşim yapısı

DATA: gt_events TYPE SLIS_T_EVENT, " Event iç tablosu
      gs_event TYPE slis_alv_event. " Event yapısı

*--------------------------------------------------------------*
* FORM GET_DATA
*--------------------------------------------------------------*
* Tabloyu verilerle doldurur
FORM get_data.
  SELECT " Veri seçiminde kullanılacak alanlar
    ekko~ebeln
    ekpo~ebelp
    ekko~bstyp
    ekko~bsart
    ekpo~matnr
    ekpo~menge
    ekpo~meins
  FROM ekko
  INNER JOIN ekpo ON ekpo~EBELN = ekko~EBELN " İki tabloyu birleştir
  INTO TABLE gt_list. " İç tabloyu doldur
ENDFORM.

*--------------------------------------------------------------*
* FORM SET_FIELDCATALOG
*--------------------------------------------------------------*
* Field catalog oluşturur
FORM set_fieldcatalog.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME   = sy-repid
      I_STRUCTURE_NAME = 'ZFC_EGT_ALV_S' " İç yapı adı
      I_INCLNAME       = SY-REPID
    CHANGING
      CT_FIELDCAT      = gt_fieldcalatog. " Field catalog iç tablosu
ENDFORM.

*--------------------------------------------------------------*
* FORM SET_LAYOUT
*--------------------------------------------------------------*
* ALV ekran yerleşimini ayarlar
FORM set_layout.
  gs_layout-WINDOW_TITLEBAR = 'Reuse ALV Kullanımı'. " Başlık metni
  gs_layout-ZEBRA = 'X'. " Zebra deseni
  gs_layout-COLWIDTH_OPTIMIZE = abap_true. " Sütun genişliklerini optimize et
  " gs_layout-EDIT = 'X'. " Tabloyu düzenlenebilir yapar
ENDFORM.

*--------------------------------------------------------------*
* FORM DISPLAY_ALV
*--------------------------------------------------------------*
* ALV ekranını görüntüler ve event yapılandırmasını ekler
FORM display_alv.
  " Event yapılandırması
  gs_event-NAME = SLIS_EV_TOP_OF_PAGE. " Event ID
  gs_event-FORM = 'TOP_OF_PAGE'. " Event form adı
  APPEND gs_event TO gt_events. " Event iç tablosuna ekle

  CLEAR gs_event.
  gs_event-NAME = SLIS_EV_END_OF_LIST. " Event ID
  gs_event-FORM = 'END_OF_LIST'. " Event form adı
  APPEND gs_event TO gt_events. " Event iç tablosuna ekle

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM    = sy-repid " Callback fonksiyonlarının bulunduğu program
      I_CALLBACK_USER_COMMAND = 'USER_COMMAND' " User command fonksiyon adı
      IS_LAYOUT             = gs_layout
      IT_FIELDCAT           = gt_fieldcalatog
      IT_EVENTS             = gt_events " Event yapılandırması
    TABLES
      T_OUTTAB              = gt_list " İç tablo
  IF sy-subrc <> 0.
    " Hata işleme burada yapılabilir
  ENDIF.
ENDFORM.

*--------------------------------------------------------------*
* FORM USER_COMMAND
*--------------------------------------------------------------*
* Kullanıcı komutlarını işler
FORM user_command USING p_ucomm TYPE sy-ucomm
                        ps_selfield TYPE SLIS_SELFIELD.
  DATA: lv_mes TYPE char200,
        lv_index TYPE numc2. " Satır sayacı

  CASE p_ucomm.
    WHEN '&MSG'. " Mesaj komutu
      LOOP AT gt_list INTO gs_list WHERE chkbox = 'X'.
        lv_index = lv_index + 1.
      ENDLOOP.
      CONCATENATE lv_index
                'Adet Satır Seçildi'
                INTO lv_mes
                SEPARATED BY space.
      MESSAGE lv_mes TYPE 'I'.
    WHEN '&IC1'. " Alan tıklama komutu
      CASE ps_selfield-fieldname.
        WHEN 'EBELN'.
          CONCATENATE ps_selfield-value
                      'numaralı SAS tıklanmıştır'
                      INTO lv_mes
                      SEPARATED BY space.
          MESSAGE lv_mes TYPE 'I'.
        WHEN 'MATNR'.
          CONCATENATE ps_selfield-value
                      'numaralı malzemeye tıklanmıştır'
                      INTO lv_mes
                      SEPARATED BY space.
          MESSAGE lv_mes TYPE 'I'.
      ENDCASE.
  ENDCASE.
ENDFORM.

*--------------------------------------------------------------*
* FORM TOP_OF_PAGE
*--------------------------------------------------------------*
* Sayfanın üst kısmına başlık ve bilgi ekler
FORM top_of_page.
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.
  DATA lv_date TYPE char10.

  CLEAR ls_header.
  ls_header-TYP = 'H'. " Header
  ls_header-INFO = 'SAS Tablosu'.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-TYP = 'S'. " Seçim
  ls_header-KEY = 'Tarih:'.
  CONCATENATE sy-datum+6(2) " Tarihi formatla
              '.'
              sy-datum+4(2)
              '.'
              sy-datum+0(4)
              INTO lv_date.
  ls_header-INFO = lv_date.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-TYP = 'A'. " Aksiyon
  ls_header-INFO = 'Satın alma sipariş raporu'.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = lt_header.
ENDFORM.

*--------------------------------------------------------------*
* FORM END_OF_LIST
*--------------------------------------------------------------*
* Liste sonuna toplam satır sayısını ekler
FORM end_of_list.
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  DATA: lv_lines TYPE i,
        lv_lines_c TYPE char5.

  DESCRIBE TABLE gt_list LINES lv_lines. " Satır sayısını al
  lv_lines_c = lv_lines.
  CLEAR ls_header.
  ls_header-TYP = 'A'. " Aksiyon
  CONCATENATE 'Bu raporda'
              lv_lines_c
              'adet kalem vardır'
              INTO ls_header-INFO
              SEPARATED BY space.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      IT_LIST_COMMENTARY = lt_header.
ENDFORM.


START-OF-SELECTION.
  PERFORM get_data.
  PERFORM set_fieldcatalog.
  PERFORM set_layout.
  PERFORM display_alv.
