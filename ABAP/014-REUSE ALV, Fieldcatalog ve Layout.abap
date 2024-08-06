*&---------------------------------------------------------------------*
*& Report ZFC_ALV_REUSE_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_ALV_REUSE_KULLANIM.

" Reuse yapısını çağırmak için fonksiyon modülü kullanılır
" REUSE_ALV_GRID_DISPLAY fonksiyonu ile ALV ekranı oluşturulur

" Tablolardan kullanacağımız kolonları tanımlamak için global bir yapı oluşturulur
TYPES: BEGIN OF gty_list,
       ebeln TYPE ebeln,  " Satın alma belgesi numarası (EKKO)
       ebelp TYPE ebelp,  " Kalem numarası (EKPO)
       bstyp TYPE ebstyp, " Belge tipi (EKKO)
       bsart TYPE bsart,  " Belge türü (EKKO)
       matnr TYPE matnr,  " Malzeme numarası (EKPO)
       menge TYPE menge,  " Malzeme miktarı (EKPO)
  END OF gty_list.

" Veri tablosu ve yapı tanımlamaları
DATA: gt_list TYPE TABLE OF gty_list, " İç tablo
      gs_list TYPE gty_list. " Yapı

" Field catalog ve layout için değişkenler tanımlanır
DATA: gt_fieldcatalog TYPE slis_t_fieldcat_alv, " Field catalog tablosu
      gs_fieldcatalog TYPE slis_fieldcat_alv, " Field catalog yapısı
      gs_layout TYPE slis_layout_alv. " Layout yapısı

" Field catalog verilerini eklemek için bir form oluşturulur
FORM add_fieldcatalog USING p_fieldname p_seltext_s p_seltext_m p_seltext_l.

  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = p_fieldname.
  gs_fieldcatalog-seltext_s = p_seltext_s.
  gs_fieldcatalog-seltext_m = p_seltext_m.
  gs_fieldcatalog-seltext_l = p_seltext_l.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

ENDFORM.

START-OF-SELECTION.

  " Tabloyu doldurma
  SELECT
    ekko~ebeln,
    ekpo~ebelp,
    ekko~bstyp,
    ekko~bsart,
    ekpo~matnr,
    ekpo~menge
  FROM ekko
  INNER JOIN ekpo ON ekpo~ebeln = ekko~ebeln
  INTO TABLE gt_list.

  " Field catalog oluşturma
  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'ebeln'.
  gs_fieldcatalog-seltext_s = 'Sas no'.
  gs_fieldcatalog-seltext_m = 'Sas numarasi'.
  gs_fieldcatalog-seltext_l = 'Satın alma numarası'.
  gs_fieldcatalog-key = 'X'.
  gs_fieldcatalog-col_pos = 0.
  gs_fieldcatalog-outputlen = 30.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'ebelp'.
  gs_fieldcatalog-seltext_s = 'Kalem no'.
  gs_fieldcatalog-seltext_m = 'Kalem Numarası'.
  gs_fieldcatalog-seltext_l = 'Kalem numarası'.
  gs_fieldcatalog-key = 'X'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'bstyp'.
  gs_fieldcatalog-seltext_s = 'Belge t.'.
  gs_fieldcatalog-seltext_m = 'Belge tipi'.
  gs_fieldcatalog-seltext_l = 'Belge tipi'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'bsart'.
  gs_fieldcatalog-seltext_s = 'Belge tur.'.
  gs_fieldcatalog-seltext_m = 'Belge türü'.
  gs_fieldcatalog-seltext_l = 'Belge türü'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  CLEAR: gs_fieldcatalog.
  gs_fieldcatalog-fieldname = 'matnr'.
  gs_fieldcatalog-seltext_s = 'Malzeme n'.
  gs_fieldcatalog-seltext_m = 'Malzeme num'.
  gs_fieldcatalog-seltext_l = 'Malzeme numarası'.
  APPEND gs_fieldcatalog TO gt_fieldcatalog.

  " Miktar kolonu eklemek için form kullanımı
  PERFORM add_fieldcatalog USING 'menge' 'Mal mik' 'Malzeme mik' 'Malzeme miktarı'.

  " Layout üzerinde değişiklik yapmak
  gs_layout-window_titlebar = 'Reuse ALV Kullanımı'.
  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = abap_true.

  " REUSE_ALV_GRID_DISPLAY fonksiyon modülü ile ALV ekranını oluşturma
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      is_layout = gs_layout
      it_fieldcat = gt_fieldcatalog
    TABLES
      t_outtab = gt_list
    EXCEPTIONS
      program_error = 1
      others = 2.

  IF sy-subrc <> 0.
    " Hata yönetimi burada yapılır
  ENDIF.
