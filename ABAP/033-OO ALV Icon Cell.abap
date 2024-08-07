
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
  END OF gty_scarr.

DATA: gs_cell_color TYPE lvc_s_scol. " Hücre renk yapısı

DATA: gt_scarr TYPE TABLE OF gty_scarr,
      gs_scarr TYPE gty_scarr.

FIELD-SYMBOLS: <gfs_scarr> TYPE gty_scarr. " Satır renklerini belirlemek için

/////////FRM///////////

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
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'. " Custom container adı

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_container. " Container ID

    CALL METHOD go_alv->set_table_for_first_display
      EXPORTING
        is_layout = gs_layout
      CHANGING
        it_outtab = gt_scarr
        it_fieldcatalog = gt_fcat
      EXCEPTIONS
        OTHERS = 1.

    " Editable modda değer yakalamak için event ekleyin
    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified. " Satır değiştirildiğinde event tetiklenecek

    CALL METHOD go_alv->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_enter. " Satıra enter yapıldığında event tetiklenecek
  ELSE.
    CALL METHOD go_alv->refresh_table_display. " Ekranın yenilenmesini sağlar
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Verileri veritabanından çeker.
*----------------------------------------------------------------------*
FORM get_data .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  " Kolona ikon vermek için ve modify işlemleriyle uğraşmamak için field symbol kullandık
  LOOP AT gt_scarr ASSIGNING <gfs_scarr>.
    <gfs_scarr>-icon = '@01@'. " İkon ID'si
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field catalog'u ayarlar.
*----------------------------------------------------------------------*
FORM set_fcat .

  PERFORM create_fcat USING 'ICON' 'Icon' 'Icon' 'Icon' 0 '' '' ''.
  PERFORM create_fcat USING 'CARRID' 'Air c.' 'Airline c.' 'Airline code' 1 '' 'X' ''.
  PERFORM create_fcat USING 'CARRNAME' 'A. Name' 'Air Name' 'Airline Name' 2 '' '' ''.
  PERFORM create_fcat USING 'CURRCODE' 'Curr' 'Local Curr' 'Local currency of airline' 3 '' '' ''.
  PERFORM create_fcat USING 'URL' 'A. Url' 'Air Url' 'Airline Url' 4 'X' '' ''.
  PERFORM create_fcat USING 'COST' 'Cost' 'Cost' 'Cost' 5 'X' '' 'X'.

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
                       p_edit.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname.
  gs_fcat-scrtext_s = p_scrtext_s.
  gs_fcat-scrtext_m = p_scrtext_m.
  gs_fcat-scrtext_l = p_scrtext_l.
  gs_fcat-col_pos = p_col_pos.
  gs_fcat-col_opt = p_col_opt.
  gs_fcat-key = p_key.
  gs_fcat-edit = p_edit.

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
*&  Include           ZFC_ALV_OO_ALV_USE_PBO
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       ALV ekranını hazırlar.
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.

  PERFORM display_alv. " ALV'yi ekrana basma

ENDMODULE.


*&---------------------------------------------------------------------*
*& Report ZFC_ALV_OO_ALV_USE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfc_alv_oo_alv_use.

INCLUDE zfc_alv_oo_alv_use_top.
INCLUDE zfc_alv_oo_alv_use_pbo.
INCLUDE zfc_alv_oo_alv_use_pai.
INCLUDE zfc_alv_oo_alv_use_frm.

START-OF-SELECTION.

  PERFORM get_data. " Verileri çekme
  PERFORM set_fcat. " Field catalog'u doldurma
  PERFORM set_layout. " ALV layout özelleştirme

  CALL SCREEN 0100. " Ekranı çağır
