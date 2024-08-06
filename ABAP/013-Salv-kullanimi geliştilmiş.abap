*&---------------------------------------------------------------------*
*& Report ZFC_ALV_SALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_ALV_SALV_KULLANIM.

" Veri tanımları
DATA: gt_sbook TYPE TABLE OF sbook, " İç tablo (intern table) veri tutar
      go_salv TYPE REF TO cl_salv_table. " SALV nesnesinin referansı

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

  " Ekran işlemleri
  " SALV nesnesinin ekran ayarlarını tutan değişken oluşturulur
  DATA: lo_display TYPE REF TO cl_salv_display_settings.

  " Oluşturulan objeye SALV nesnesinin ekran ayarları atanır
  lo_display = go_salv->get_display_settings( ).

  " Ekran üzerindeki liste başlığını değiştirme
  lo_display->set_list_header( VALUE = 'SALV Kullanımı' ).

  " Listenin satırlarının zebra desenli olmasını sağlar
  lo_display->set_striped_pattern( VALUE = 'X' ).

  " Genel Kolon işlemleri
  " Kolonlara erişmek için SALV sınıfından obje üretilir
  DATA: lo_cols TYPE REF TO cl_salv_columns.

  " Üretilen değişkene SALV nesnesinin kolonları atanır
  lo_cols = go_salv->get_columns( ).

  " Kolonlar arası boşluğu optimize etme
  lo_cols->set_optimize( VALUE = 'X' ).

  " Tekli Kolon İşlemleri
  " Kolona erişmek için SALV kütüphanesinden kolon değişkeni üretilir
  DATA: lo_col TYPE REF TO cl_salv_column.

  " Kolonun kapladığı alanı değiştirme
  " Değişkene kolonlara eriştiğimiz değişkenin get_column fonksiyonu ile bir kolon atanır
  lo_col = lo_cols->get_column( COLUMNNAME = 'INVOICE' ).

  lo_col->set_long_text( 'Changed column' ).
  lo_col->set_medium_text( 'Changed cln' ).
  lo_col->set_short_text( 'CHNGD CLN' ).

  " İstenilen kolonu kaldırma
  lo_col = lo_cols->get_column( COLUMNNAME = 'MANDT' ).
  lo_col->set_visible( VALUE = '' ).

  " Olası kolon bulunamama hatalarını engellemek için TRY-CATCH kullanılır
  TRY.
    lo_col = lo_cols->get_column( COLUMNNAME = 'herhangi bir kolon' ). " Kolon adı doğru girilmezse dump ekranına düşer, biz bunu TRY-CATCH ile engelliyoruz
    lo_col->set_visible( VALUE = '' ).
  CATCH cx_salv_not_found.
    " Kolon bulunamadığında mesaj gösterilir
    MESSAGE 'Column Not Found' TYPE 'I'.
  ENDTRY.

  " Toolbar Eklemek / Functions
  " Toolbar'a erişmek için değişken oluşturulur
  DATA: lo_toolbar TYPE REF TO cl_salv_functions.

  " Değişkene SALV nesnesinden gelen toolbar/functions değerlerini almak için fonksiyon çağırılır
  lo_toolbar = go_salv->get_functions( ).

  " Toolbar aktif edilir
  lo_toolbar->set_all( VALUE = abap_true ).

  " Başlık ve açıklama ekleme
  " Başlık ve açıklamaları birleştirmek için değişkenler oluşturulur
  DATA: lo_header TYPE REF TO cl_salv_form_layout_grid,
        lo_h_label TYPE REF TO cl_salv_form_label,
        lo_h_flow TYPE REF TO cl_salv_form_layout_flow.

  CREATE OBJECT lo_header. " Başlık objesi oluşturulur

  " Başlık oluşturmak için label konumu belirlenir
  lo_h_label = lo_header->create_label(
    ROW    = 1
    COLUMN = 1
  ).
  lo_h_label->set_text( VALUE = 'Oluşturulmuş başlık' ). " Başlık metni atanır

  " Açıklama metnini konumu ayarlanır
  lo_h_flow = lo_header->create_flow(
    ROW    = 2
    COLUMN = 1
  ).

  lo_h_flow->create_text(
    EXPORTING
      TEXT = 'Bu bir açıklama'
  ).

  " Oluşturduğumuz başlık objesi SALV yapısına eklenir
  go_salv->set_top_of_list( VALUE = lo_header ).

  " ALV yapısını bir popup şekline çevirme
  go_salv->set_screen_popup(
    EXPORTING
      start_column = 1 " Başlangıç kolonu
      end_column   = 80 " Bitiş kolonu
      start_line   = 1 " Başlangıç satırı
      end_line     = 20 " Bitiş satırı
  ).

  " SALV görüntülenir
  go_salv->display( ).
