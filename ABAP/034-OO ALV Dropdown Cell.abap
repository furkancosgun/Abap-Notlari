
*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_USE_TOP
*&---------------------------------------------------------------------*

" ALV
DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV Grid nesnesi
      go_container TYPE REF TO cl_gui_custom_container. " ALV'yi tutacak container

" Tablo verisi
DATA: gt_scarr TYPE TABLE OF gty_scarr. " Veri tablosu

" Field catalog
DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog iç tablosu
      gs_fcat TYPE lvc_s_fcat. " Field catalog yapısı

" Layout işlemleri
DATA: gs_layout TYPE lvc_s_layo. " Layout yapısı

" Field symbol ile görünümde değişiklik yapma
FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat. " Kolon üzerinde değişiklik yapmak için

" Tablo renk değişimleri için
TYPES: BEGIN OF gty_scarr,
  icon TYPE icon_d, " İkon kolonu için domain
  carrid TYPE s_carr_id,
  carrname TYPE s_carrname,
  currcode TYPE s_currcode,
  url TYPE s_carrurl,
  cost TYPE i,
  location TYPE char10, " Dropdown için
  END OF gty_scarr.

DATA: gs_cell_color TYPE lvc_s_scol. " Hücre renk yapısı

DATA: gt_scarr TYPE TABLE OF gty_scarr,
      gs_scarr TYPE gty_scarr.

FIELD-SYMBOLS: <gfs_scarr> TYPE gty_scarr. " Satır renklerini belirlemek için


*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_USE_FRM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       ALV Grid ekranını oluşturur ve verileri gösterir.
*----------------------------------------------------------------------*
FORM display_alv .

  IF go_alv IS INITIAL.

    " Custom container'ı oluşturur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'. " Custom container adı

    " ALV nesnesini oluşturur
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container. " Container ID

    " Tabloyu ekrana basar
    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout = gs_layout
      CHANGING
        it_outtab = gt_scarr
        it_fieldcatalog = gt_fcat
      EXCEPTIONS
        OTHERS = 1.

    " Editable modda değer yakalamak için event ekler
    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified. " Satır değiştirildiğinde event tetiklenecek

    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter. " Satıra enter yapıldığında event tetiklenecek
  ELSE.
    " Ekranın yenilenmesini sağlar
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Verileri veritabanından çeker.
*----------------------------------------------------------------------*
FORM get_data .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field catalog'u ayarlar.
*----------------------------------------------------------------------*
FORM set_fcat .

  PERFORM create_fcat USING 'ICON' 'Icon' 'Icon' 'Icon' 0 '' '' '' 0. " İkon kolonu için
  PERFORM create_fcat USING 'CARRID' 'Air c.' 'Airline c.' 'Airline code' 1 '' 'X' '' 0.
  PERFORM create_fcat USING 'CARRNAME' 'A. Name' 'Air Name' 'Airline Name' 2 '' '' '' 0.
  PERFORM create_fcat USING 'CURRCODE' 'Curr' 'Local Curr' 'Local currency of airline' 3 '' '' '' 0.
  PERFORM create_fcat USING 'URL' 'A. Url' 'Air Url' 'Airline Url' 4 'X' '' '' 0.
  PERFORM create_fcat USING 'COST' 'Cost' 'Cost' 'Cost' 5 'X' '' 'X' 0.
  PERFORM create_fcat USING 'LOCATION' 'Location' 'Location' 'Location' 6 'X' '' 'X' 1.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  CREATE_FCAT
*&---------------------------------------------------------------------*
*       Manuel field catalog oluşturur.
*----------------------------------------------------------------------*
FORM create_fcat USING p_fieldname
                       p_scrtext_s
                       p_scrtext_m
                       p_scrtext_l
                       p_col_pos
                       p_col_opt
                       p_key
                       p_edit
                       p_drdn.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Kolon adı (verilmezse o kolon ALV'de görünmez)
  gs_fcat-scrtext_s = p_scrtext_s. " Kolon adı kısa
  gs_fcat-scrtext_m = p_scrtext_m. " Kolon adı orta
  gs_fcat-scrtext_l = p_scrtext_l. " Kolon adı uzun
  gs_fcat-col_pos = p_col_pos.   " Kolon sırası
  gs_fcat-col_opt = p_col_opt.   " Kolon optimizasyonu (en uzun metne kadar kolon genişliği ayarlanır)
  gs_fcat-key = p_key.           " Key alanı (kolon rengi diğerlerinden daha farklı olur)
  gs_fcat-edit = p_edit.         " Editlenebilir olsun mu olmasın mı
  gs_fcat-drdn_hdl = p_drdn.     " Dropdown handle ID (birden fazla dropdown olabilir, bu yüzden ID verilir)

  APPEND gs_fcat TO gt_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       ALV Layout ayarlarını yapar.
*----------------------------------------------------------------------*
FORM set_layout .

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Tüm kolonların genişlik optimizasyonu yapılır
  gs_layout-zebra = 'X'. " Zebra desenini uygular

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SUM
*&---------------------------------------------------------------------*
*       Toplam ve ortalama hesaplar, ikonları günceller.
*----------------------------------------------------------------------*
FORM get_sum .

  DATA: lv_sum TYPE i,
        lv_avg TYPE i,
        lv_lines TYPE i.

  LOOP AT gt_scarr INTO gs_scarr.
    lv_sum = lv_sum + gs_scarr-cost. " Toplam cost hesaplama
  ENDLOOP.

  DESCRIBE TABLE gt_scarr LINES lv_lines. " Satır sayısını alır

  IF lv_lines > 0.
    lv_avg = lv_sum / lv_lines. " Ortalama hesaplama
  ELSE.
    lv_avg = 0. " Satır yoksa ortalama sıfır
  ENDIF.

  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
    IF <gfs_scarr>-cost > lv_avg.
      <gfs_scarr>-icon = '@0A@'. " Yeşil trafik lambası
    ELSEIF <gfs_scarr>-cost < lv_avg.
      <gfs_scarr>-icon = '@08@'. " Kırmızı trafik lambası
    ELSE.
      <gfs_scarr>-icon = '@09@'. " Turuncu trafik lambası
    ENDIF.
  ENDLOOP.

  " ALV ekranını günceller
  PERFORM display_alv.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_DROPDOWN
*&---------------------------------------------------------------------*
*       Dropdown içeriğini doldurur.
*----------------------------------------------------------------------*
FORM set_dropdown .

  DATA: lt_dropdown TYPE lvc_t_drop, " İç tablo
        ls_dropdown TYPE lvc_s_drop. " Yapı

  CLEAR ls_dropdown.

  ls_dropdown-handle = 1. " Dropdown oluştururken kullanılan ID
  ls_dropdown-value = 'Yurt içi'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  ls_dropdown-handle = 1. " Dropdown oluştururken kullanılan ID
  ls_dropdown-value = 'Yurt Dışı'. " Dropdown verisi
  APPEND ls_dropdown TO lt_dropdown.

  " Dropdown tablosunu ALV'ye ayarlar
  go_alv->set_drop_down_table(
    EXPORTING
      it_drop_down = lt_dropdown " Oluşturduğumuz dropdown tablosu
  ).

ENDFORM.


*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_USE_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       ALV için ekran durumunu ayarlar.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  PERFORM set_fcat. " Field catalog'u ayarla
  PERFORM set_layout. " Layout ayarlarını yap

  PERFORM get_data. " Verileri al
  PERFORM get_sum. " Toplam ve ortalamayı hesapla
  PERFORM set_dropdown. " Dropdown içeriğini ayarla
  PERFORM display_alv. " ALV ekranını oluştur

ENDMODULE.

