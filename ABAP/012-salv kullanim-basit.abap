*&---------------------------------------------------------------------*
*& Report ZFC_ALV_SALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_ALV_SALV_KULLANIM.

" Veri tanımları
DATA: gt_sbook TYPE TABLE OF sbook, " İç tablo (intern table) veri tutar
      go_salv TYPE REF TO cl_salv_table. " SALV nesne referansı

START-OF-SELECTION.

  " Veriyi seçme
  SELECT * UP TO 20 ROWS FROM sbook
    INTO TABLE gt_sbook. " Verileri iç tabloya al

  " SALV fonksiyonu oluşturma
  cl_salv_table=>factory(
    IMPORTING
      r_salv_table = go_salv " SALV nesnesini oluşturur
    CHANGING
      t_table      = gt_sbook " İç tabloyu SALV nesnesine bağlar
  ).

  " SALV görüntüleme
  go_salv->display( ). " SALV ekranında görüntüler
