*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_KULLANIM_TOP
*&---------------------------------------------------------------------*

" ALV (ABAP List Viewer)
DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV nesnesini tanımladık
      go_container TYPE REF TO cl_gui_custom_container. " ALV'yi tutacak konteyneri tanımladık

" Tablo verisi
"DATA gt_scarr TYPE TABLE OF scarr.

" Alan Kataloğu
DATA: gt_fcat TYPE lvc_t_fcat, " Field Catalog için iç tablo
      gs_fcat TYPE lvc_s_fcat. " Field Catalog yapısı

" Yerleşim işlemleri
DATA gs_layout TYPE lvc_s_layo. " Yerleşim yapısı

" Görünüm üzerinde değişiklik yapmak için Field Symbol
FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat. " Kolon üzerinde değişiklik yapmak için

" Tablo yapısı ve renk değişimi için tanımlamalar
" Buraya eklenecek tüm dataların field catalog içine eklenmesi gerekir
TYPES: BEGIN OF gty_scarr,
  icon TYPE icon_d, " İkon kolonu için domain
  carrid TYPE s_carr_id,
  carrname TYPE s_carrname,
  currcode TYPE s_currcode,
  url TYPE s_carrurl,
  cost TYPE i,
  location TYPE char10, " Dropdown için
  sinif TYPE char10, " Dinamik dropdown için
  dd_sinif TYPE char1, " Dinamik dropdown için
  END OF gty_scarr.

DATA: gs_cell_color TYPE lvc_s_scol. " Hücre rengi yapısı

DATA: gt_scarr TYPE TABLE OF gty_scarr,
      gs_scarr TYPE gty_scarr.

FIELD-SYMBOLS <gfs_scarr> TYPE gty_scarr. " Satır rengini vermek için

///////FRM////////


*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_KULLANIM_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       Bu form ALV ekranını oluşturur
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  IF go_alv IS INITIAL.

  " ALV için konteyneri oluşturuyoruz
    CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV'. " Ekranda oluşturduğumuz custom container ID'si

  " ALV nesnesini oluşturuyoruz
    CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_container. " Konteyner ID'si verilecek, ama önce oluşturulmalı

  " Dropdown içeriğini dolduruyoruz
    PERFORM set_dropdown.

  " ALV ekranına veriyi bastırmak için methodu çağırıyoruz
    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT = gs_layout
    CHANGING
      IT_OUTTAB = gt_scarr " Veri basacağımız tablo
      IT_FIELDCATALOG = GT_FCAT " Kolon bazında düzenleme yapmamızı sağlar
.

  " Değerlerin yakalanabilmesi için edit event ekliyoruz
    CALL METHOD go_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified. " Satırdan çıkınca event tetiklenecek

    CALL METHOD go_alv->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter. " Satırda Enter yapınca işlemler yakalanabilir

  ELSE.

  " ALV ekranını yenilemek için fonksiyonu çağırıyoruz
    CALL METHOD go_alv->refresh_table_display. " ALV daha önce oluşturulduysa ekranı yenile

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Bu form veriyi seçip işler
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.

    CASE <gfs_scarr>-currcode.
      WHEN 'EUR'.
        <gfs_scarr>-dd_sinif = '2'.
      WHEN 'USD'.
        <gfs_scarr>-dd_sinif = '3'.
      WHEN OTHERS.
        <gfs_scarr>-dd_sinif = '4'.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field Catalog ayarlarını yapar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fcat .

  PERFORM create_fcat USING 'ICON' 'icon' 'icon' 'icon' 0 '' '' '' 0 ''. " İkon kolonu için
  PERFORM create_fcat USING 'CARRID' 'Air c.' 'Airline c.' 'Airline code' 1 '' 'X' '' 0 ''.
  PERFORM create_fcat USING 'CARRNAME' 'A. Name' 'Air Name' 'Airline Name' 2 '' '' '' 0 ''.
  PERFORM create_fcat USING 'CURRCODE' 'Curr' 'Local Curr' 'Local currency of airline' 3 '' '' '' 0 ''.
  PERFORM create_fcat USING 'URL' 'A. Url' 'Air Url' 'Airline Url' 4 'X' '' '' 0 ''.
  PERFORM create_fcat USING 'COST' 'Cost' 'Cost' 'Cost' 5 'X' '' 'X' 0 ''.
  PERFORM create_fcat USING 'LOCATION' 'Lokasyon' 'Lokasyon' 'Lokasyon' 6 'X' '' 'X' 1 ''.
  PERFORM create_fcat USING 'SINIF' 'Ucus s.' 'Ucus s' 'Ucus sınıfı' 7 'X' '' 'X' 0 'DD_SINIF'.

ENDFORM.

" Manuel Field Catalog oluşturma
FORM create_fcat USING p_fieldname
                       p_scrtext_s
                       p_scrtext_m
                       p_scrtext_l
                       p_col_pos
                       p_col_opt
                       p_key
                       p_edit
                       p_drdn
                       p_drdn_f.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Kolon adı, eğer verilmezse kolon ALV'de gözükmez
  gs_fcat-scrtext_s = p_scrtext_s. " Kolon adı kısa
  gs_fcat-scrtext_m = p_scrtext_m. " Kolon adı orta
  gs_fcat-scrtext_l = p_scrtext_l. " Kolon adı uzun
  gs_fcat-col_pos   = p_col_pos.   " Kolon sırası
  gs_fcat-col_opt   = p_col_opt.   " Kolon genişliği optimizasyonu
  gs_fcat-key       = p_key.       " Key alanı, kolon rengi diğerlerinden farklı olur
  gs_fcat-edit      = p_edit.      " Düzenlenebilir mi olmasın mı
  gs_fcat-drdn_hndl = p_drdn.      " Dropdown handle ID, birden fazla dropdown olabilir
  gs_fcat-drdn_field = p_drdn_f.   " Dropdown handle ID, birden fazla dropdown olabilir

  APPEND gs_fcat TO gt_fcat.

ENDFORM.

FORM set_layout .

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Tüm kolonların genişliği optimizasyonu yapılır
  gs_layout-zebra = 'X'. " Satırları zebra desenine çevirir

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SUM
*&---------------------------------------------------------------------*
*       Bu form editable modda girilen değerleri işler
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_sum. " Ortalama hesaplama ve ikon ekleme

  DATA: lv_sum TYPE i,
        lv_avg TYPE i,
        lv_lines TYPE i.

  LOOP AT gt_scarr INTO gs_scarr.
    lv_sum = lv_sum + gs_scarr-cost. " Cost değerlerini topluyor
  ENDLOOP.

  DESCRIBE TABLE gt_scarr LINES lv_lines. " Tablo satır sayısını verir

  lv_avg = lv_sum / lv_lines. " Ortalama hesaplama

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>. " Ortalama hesaplandıktan sonra ikon ekleme

    IF <gfs_scarr>-cost > lv_avg. " Ortalama değerler karşılaştırması
      <gfs_scarr>-icon = '@0A@'. " Yeşil trafik lambası
    ELSEIF <gfs_scarr>-cost < lv_avg.
      <gfs_scarr>-icon = '@08@'. " Kırmızı trafik lambası
    ELSE.
      <gfs_scarr>-icon = '@09@'. " Turuncu trafik lambası
    ENDIF.
  ENDLOOP.

  " ALV ekranını yenilemek için gerekli
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_DROPDOWN
*&---------------------------------------------------------------------*
*       Dropdown içeriğini ayarlar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_dropdown.

  DATA: lt_dropdown TYPE lvc_t_drop, " İç tablo
        ls_dropdown TYPE lvc_s_drop. " Yapı

  CLEAR ls_dropdown.

  ls_dropdown-handle = 1. " Dropdown ID
  ls_dropdown-value = 'Yurt içi'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 1. " Dropdown ID
  ls_dropdown-value = 'Yurt Dışı'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 2. " Dropdown ID
  ls_dropdown-value = 'Ekonomi'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 2. " Dropdown ID
  ls_dropdown-value = 'Business'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 2. " Dropdown ID
  ls_dropdown-value = 'Middle'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 3. " Dropdown ID
  ls_dropdown-value = 'Ekonomi'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 3. " Dropdown ID
  ls_dropdown-value = 'Business'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 4. " Dropdown ID
  ls_dropdown-value = 'Middle'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  go_alv->set_drop_down_table(
    EXPORTING
      it_drop_down = lt_dropdown " Oluşturduğumuz dropdown tablosu
  ).

ENDFORM.
