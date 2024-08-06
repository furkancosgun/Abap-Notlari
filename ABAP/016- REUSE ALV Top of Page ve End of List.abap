*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_REUSE_KULLANIM_TOP
*&---------------------------------------------------------------------*

" Veri yapıları
TYPES: BEGIN OF gty_list,
       ebeln TYPE ebeln,  " Satın alma belgesi numarası
       ebelp TYPE ebelp,  " Kalem numarası
       bstyp TYPE ebstyp, " Belge tipi
       bsart TYPE bsart,  " Belge türü
       matnr TYPE matnr,  " Malzeme numarası
       menge TYPE bstmg,  " Malzeme miktarı
       meins TYPE meins,  " Miktar birimi
       statu TYPE statu,  " Sipariş durumu
  END OF gty_list.

" İç tablo ve yapı tanımlamaları
DATA: gt_list TYPE TABLE OF gty_list, " İç tablo
      gs_list TYPE gty_list. " Yapı

" Field catalog oluşturma
DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv, " Field catalog tablosu
      gs_fieldcatalog TYPE slis_fieldcat_alv. " Field catalog yapısı

" Layout oluşturma
DATA gs_layout TYPE slis_layout_alv.

" Event yapılandırması
DATA: gt_events TYPE slis_t_event, " Event iç tablosu
      gs_event TYPE slis_alv_event. " Event yapısı

FORM get_data.
  " EKKO ve EKPO tablolarını birleştirerek veriyi alır
  SELECT
    ekko~ebeln,
    ekpo~ebelp,
    ekko~bstyp,
    ekko~bsart,
    ekpo~matnr,
    ekpo~menge,
    ekpo~meins
  FROM ekko
  INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
  INTO TABLE gt_list.
ENDFORM.

FORM set_fieldcatalog.
  " Field catalogu oluşturur
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name   = sy-repid
      i_structure_name = 'ZFC_EGT_ALV_S'
      i_inclname       = sy-repid
    CHANGING
      ct_fieldcat      = gt_fieldcatalog.
ENDFORM.

FORM set_layout.
  " Layout üzerinde değişiklik yapar
  gs_layout-window_titlebar = 'Reuse ALV Kullanımı'. " Başlık metni
  gs_layout-zebra = 'X'. " Zebra desenli satırlar
  gs_layout-colwidth_optimize = abap_true. " Kolon genişliklerini optimize et
ENDFORM.

FORM display_alv.
  " Etkinliklerin yapılandırılması
  gs_event-name = slis_ev_top_of_page.
  gs_event-form = 'TOP_OF_PAGE'.
  APPEND gs_event TO gt_events.
  CLEAR gs_event.
  gs_event-name = slis_ev_end_of_list.
  gs_event-form = 'END_OF_LIST'.
  APPEND gs_event TO gt_events.

  " ALV ekranını görüntüler
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcatalog
      it_events          = gt_events
    TABLES
      t_outtab           = gt_list
    EXCEPTIONS
      program_error      = 1
      others             = 2.
  IF sy-subrc <> 0.
    " Hata yönetimi burada yapılır
  ENDIF.
ENDFORM.

FORM TOP_OF_PAGE.
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.
  DATA lv_date TYPE char10.

  CLEAR ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Satın Alma Sipariş Raporu'.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Tarih:'.
  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO lv_date.
  ls_header-info = lv_date.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

FORM END_OF_LIST.
  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.
  DATA: lv_lines TYPE i,
        lv_lines_c TYPE char5.

  DESCRIBE TABLE gt_list LINES lv_lines.
  lv_lines_c = lv_lines.
  CLEAR ls_header.
  ls_header-typ = 'A'.
  CONCATENATE 'Bu raporda' lv_lines_c 'adet kalem vardır' INTO ls_header-info SEPARATED BY space.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.
ENDFORM.

START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fieldcatalog.
PERFORM set_layout.
PERFORM display_alv.
