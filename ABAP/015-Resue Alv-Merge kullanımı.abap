*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_REUSE_KULLANIM_TOP
*&---------------------------------------------------------------------*

" Veri yapıları ve field catalog için gerekli değişkenler tanımlanır
TYPES: BEGIN OF gty_list,
       ebeln TYPE ebeln,  " Satın alma belgesi numarası
       ebelp TYPE ebelp,  " Kalem numarası
       bstyp TYPE ebstyp, " Belge tipi
       bsart TYPE bsart,  " Belge türü
       matnr TYPE matnr,  " Malzeme numarası
       menge TYPE menge,  " Malzeme miktarı
       meins TYPE meins,  " Miktar birimi
       statu TYPE statu,  " Sipariş durumu
  END OF gty_list.

" Tablo ve yapı tanımlamaları
DATA: gt_list TYPE TABLE OF gty_list, " İç tablo
      gs_list TYPE gty_list. " Yapı

DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv, " Field catalog tablosu
      gs_fieldcatalog TYPE slis_fieldcat_alv, " Field catalog yapısı

DATA: gs_layout TYPE slis_layout_alv. " Layout yapısı

FORM get_data.
  " Tabloyu doldurma
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
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name   = sy-repid
      i_structure_name = 'ZFC_EGT_ALV_S'
      i_inclname       = sy-repid
    CHANGING
      ct_fieldcat      = gt_fieldcatalog.
ENDFORM.

FORM set_layout.
  gs_layout-window_titlebar = 'Reuse ALV Kullanımı'.
  gs_layout-zebra = 'X'.  " Zebra desenli satırlar
  gs_layout-colwidth_optimize = abap_true. " Kolon genişliklerini optimize et
ENDFORM.

FORM display_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout   = gs_layout
      it_fieldcat = gt_fieldcatalog
    TABLES
      t_outtab    = gt_list
    EXCEPTIONS
      program_error = 1
      others        = 2.
  IF sy-subrc <> 0.
    " Hata yönetimi burada yapılır
  ENDIF.
ENDFORM.

START-OF-SELECTION.

PERFORM get_data.
PERFORM set_fieldcatalog.
PERFORM set_layout.
PERFORM display_alv.
