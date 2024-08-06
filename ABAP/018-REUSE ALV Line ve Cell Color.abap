*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_COLOR_CUSTOMIZATION
*&---------------------------------------------------------------------*

* Bu dosya, ALV Grid Display'de satır ve hücre renklerini değiştirmek için kullanılır.

* Global veri tipi ve yapı tanımlamaları
TYPES: BEGIN OF gty_list, " Global veri yapısı
       chkbox TYPE char1, " Satır seçimini aktif etmek için checkbox
       EBELN TYPE EBELN, " Satın alma belge numarası (ekko tablosu)
       ebelp TYPE ebelp, " Kalem numarası (ekpo tablosu)
       bstyp TYPE ebstyp, " Belge tipi (ekko tablosu)
       bsart TYPE esart, " Belge türü (ekko tablosu)
       matnr TYPE matnr, " Malzeme numarası (ekpo tablosu)
       menge TYPE bstmg, " Malzeme miktarı (ekpo tablosu)
       meins TYPE meins, " Miktar türü (ekpo tablosu)
       statu TYPE statu, " Sipariş durumu (ekpo tablosu)
       line_color TYPE char4, " Satır rengi
       cell_color TYPE SLIS_T_SPECIALCOL_ALV, " Hücre rengi, tablonun tüm hücreleri için farklı renkler tanımlanabilir
  END OF gty_list.

* Hücre rengi için yapı
DATA: gs_cell_color TYPE slis_specialcol_alv. " Hücre rengi için yapı

* Tabloyu oluşturma
DATA: gt_list TYPE TABLE OF gty_list, " İç tablo
      gs_list TYPE gty_list. " İç tablo satırı

* Field catalog oluşturma
DATA: gt_fieldcalatog TYPE SLIS_T_FIELDCAT_ALV, " Field catalog iç tablosu
      gs_fieldcalatog TYPE slis_fieldcat_alv. " Field catalog yapısı

* Layout yapılandırma
DATA gs_layout TYPE SLIS_LAYOUT_ALV. " ALV ekran yerleşim yapısı

* Event yapılandırması
DATA: gt_events TYPE SLIS_T_EVENT, " Event iç tablosu
      gs_event TYPE slis_alv_event. " Event yapısı

*--------------------------------------------------------------*
* FORM SET_LAYOUT
*--------------------------------------------------------------*
* Layout ayarlarını yapar
FORM set_layout.
  " Layout üzerinde değişiklik yapar
  gs_layout-WINDOW_TITLEBAR = 'Reuse ALV Kullanımı'. " Başlık metni
  gs_layout-ZEBRA = 'X'. " Zebra deseni
  gs_layout-COLWIDTH_OPTIMIZE = abap_true. " Sütun genişliklerini optimize eder
  gs_layout-BOX_FIELDNAME = 'CHKBOX'. " Seçim kutusu için alan adı
  gs_layout-INFO_FIELDNAME = 'LINE_COLOR'. " Satır renklerini belirtmek için alan adı
  gs_layout-COLTAB_FIELDNAME = 'CELL_COLOR'. " Hücre renklendirmesi için oluşturduğumuz tabloyu ekler
  " gs_layout-EDIT = 'X'. " Tabloyu düzenlenebilir yapar (isteğe bağlı)
ENDFORM.

*--------------------------------------------------------------*
* FORM GET_DATA
*--------------------------------------------------------------*
* Verileri tablodan çeker ve tabloyu doldurur
FORM get_data.
  " Tabloyu doldurur
  SELECT " Kolonları alır
    ekko~ebeln
    ekpo~ebelp
    ekko~bstyp
    ekko~bsart
    ekpo~matnr
    ekpo~menge
    ekpo~meins
    ekpo~statu
  FROM ekko
  INNER JOIN ekpo ON ekpo~EBELN = ekko~EBELN " İki tabloyu birleştirir
  INTO CORRESPONDING FIELDS OF TABLE gt_list. " İç tabloyu doldur

  " Satır rengini ayarlama ve hücre renklendirme işlemleri
  LOOP AT gt_list INTO gs_list. " Tüm satırlar üzerinde döner
    IF gs_list-ebelp = '10'. " Eğer kalem numarası 10 ise
      CLEAR gs_cell_color. " Hücre rengini temizler
      gs_cell_color-FIELDNAME = 'MATNR'. " Malzeme numarası kolonunu renklendir
      gs_cell_color-COLOR-COL = 4. " Renk kodu (ana renk)
      gs_cell_color-COLOR-INT = 1. " Koyuluk derecesi
      gs_cell_color-COLOR-INV = 0. " Arka plan mı, ön plan mı
      APPEND gs_cell_color TO gs_list-cell_color. " Hücre rengini tabloya ekler

      CLEAR gs_cell_color. " Hücre rengini temizler
      gs_cell_color-FIELDNAME = 'BSART'. " Belge türü kolonunu renklendir
      gs_cell_color-COLOR-COL = 7. " Renk kodu (ana renk)
      gs_cell_color-COLOR-INT = 1. " Koyuluk derecesi
      gs_cell_color-COLOR-INV = 0. " Arka plan mı, ön plan mı
      APPEND gs_cell_color TO gs_list-cell_color. " Hücre rengini tabloya ekler
    ENDIF.
    MODIFY gt_list FROM gs_list. " İç tabloyu günceller
  ENDLOOP.

  " Renk değerleri
  " Renk kodları C ile başlar
  " 0 - Beyaz, 1 - Mavi, 2 - Gri, 3 - Sarı, 4 - Turkuaz, 5 - Yeşil, 6 - Kırmızı, 7 - Turuncu
  " İkinci karakter renk seçer
  " 0 - 1 Koyuluk derecesi
  " 0 - 1 Arka plan veya ön plan rengi
  " Örnek: C500 açık yeşil
ENDFORM.

*--------------------------------------------------------------*
* FORM DISPLAY_ALV
*--------------------------------------------------------------*
* ALV ekranını görüntüler
FORM display_alv.
  " Event yapılandırması
  gs_event-NAME = SLIS_EV_TOP_OF_PAGE. " Event ID
  gs_event-FORM = 'TOP_OF_PAGE'. " Event form adı
  APPEND gs_event TO gt_events. " Event iç tablosuna ekle

  CLEAR gs_event.
  gs_event-NAME = SLIS_EV_END_OF_LIST. " Event ID
  gs_event-FORM = 'END_OF_LIST'. " Event form adı
  APPEND gs_event TO gt_events. " Event iç tablosuna ekle

  gs_event-NAME = SLIS_EV_PF_STATUS_SET. " Event ID
  gs_event-FORM = 'PF_STATUS_SET'. " Event form adı
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
