*&---------------------------------------------------------------------*
*& Report ZFC_ALV_OO_ALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT ZFC_ALV_OO_ALV_KULLANIM.

" ALV ve Container tanımlamaları
DATA: go_alv TYPE REF TO CL_GUI_ALV_GRID, " ALV nesnesini tanımlar
      go_container TYPE REF TO CL_GUI_CUSTOM_CONTAINER. " ALV için container tanımlar

" Tablo verileri için tanımlar
DATA: gt_scarr TYPE TABLE OF gty_scarr, " Tablo verilerini tutacak iç tablo
      gs_scarr TYPE gty_scarr. " Tek bir kayıt için yapı

" Field catalog tanımlamaları
DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog için iç tablo
      gs_fcat TYPE lvc_s_fcat. " Field catalog için yapı

" Layout ayarları için yapı
DATA: gs_layout TYPE LVC_S_LAYO. " Layout yapılandırması için yapı

" Field symbol ile field catalog üzerinde değişiklik yapmak için
FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat.

" Satır ve hücre renklendirmesi için tanımlar
TYPES: BEGIN OF gty_scarr,
  CARRID TYPE S_CARR_ID,
  CARRNAME TYPE S_CARRNAME,
  CURRCODE TYPE S_CURRCODE,
  URL TYPE S_CARRURL,
  COST TYPE i, " Maliyet alanı
  END OF gty_scarr.

DATA: gs_cell_color TYPE LVC_S_SCOL. " Hücre renk yapısı
FIELD-SYMBOLS: <gfs_scarr> TYPE gty_scarr. " Satır renklendirme için field symbol

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       Ekran durumunu ayarlar
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.
  SET TITLEBAR '0100'.

  PERFORM display_alv. " ALV'yi ekrana basar

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       Kullanıcı komutlarını işler
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE sy-ucomm.
    WHEN '&BACK'.
      SET SCREEN 0.
    WHEN '&SAVE'.
      PERFORM get_sum. " Toplam maliyeti hesaplar
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       ALV'yi ekrana basar
*----------------------------------------------------------------------*
FORM DISPLAY_ALV .

  CREATE OBJECT go_container " ALV için container oluşturur
    EXPORTING
      container_name = 'CC_ALV'. " Layout üzerindeki custom container ID'si

  CREATE OBJECT go_alv " ALV nesnesi oluşturur
    EXPORTING
      i_parent = go_container. " Container ID'sini belirtir

  CALL METHOD go_alv->SET_TABLE_FOR_FIRST_DISPLAY " ALV'yi ekrana basar
    EXPORTING
      is_layout = gs_layout " Layout ayarlarını gönderir
    CHANGING
      it_outtab = gt_scarr " Veriyi ekranda gösterecek tablo
      it_fieldcatalog = gt_fcat " Field catalog ile kolon düzenlemesi
    EXCEPTIONS
      INVALID_PARAMETER_COMBINATION = 1
      PROGRAM_ERROR = 2
      TOO_MANY_LINES = 3
      OTHERS = 4.

  IF sy-subrc <> 0.
    " Hata işleme yapılabilir
  ENDIF.

  " Düzenlenebilir modda değer yakalamak için event ekler
  CALL METHOD go_alv->REGISTER_EDIT_EVENT
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified. " Satırdan çıkınca event tetiklenir

  CALL METHOD go_alv->REGISTER_EDIT_EVENT
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter. " Satırda Enter yapılınca işlemler yakalanabilir

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Verileri alır
*----------------------------------------------------------------------*
FORM GET_DATA .

  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field catalog oluşturur
*----------------------------------------------------------------------*
FORM SET_FCAT .

  PERFORM create_fcat USING 'CARRID' 'Air c.' 'Airline c.' 'Airline code' 1 '' 'X' ''.
  PERFORM create_fcat USING 'CARRNAME' 'A. Name' 'Air Name' 'Airline Name' 2 '' '' ''.
  PERFORM create_fcat USING 'CURRCODE' 'Curr' 'Local Curr' 'Local currency of airline' 3 '' '' ''.
  PERFORM create_fcat USING 'URL' 'A. Url' 'Air Url' 'Airline Url' 4 'X' '' ''.
  PERFORM create_fcat USING 'COST' 'Cost' 'Cost' 'Cost' 5 'X' '' 'X'.

ENDFORM.

" Manuel field catalog oluşturma
FORM CREATE_FCAT USING p_fieldname
                       p_scrtext_s
                       p_scrtext_m
                       p_scrtext_l
                       p_col_pos
                       p_col_opt
                       p_key
                       p_edit.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Kolon adı
  gs_fcat-scrtext_s = p_scrtext_s. " Kolon adı kısa
  gs_fcat-scrtext_m = p_scrtext_m. " Kolon adı orta
  gs_fcat-scrtext_l = p_scrtext_l. " Kolon adı uzun
  gs_fcat-col_pos = p_col_pos. " Kolon sırası
  gs_fcat-col_opt = p_col_opt. " Kolon optimizasyonu
  gs_fcat-key = p_key. " Key alanı
  gs_fcat-edit = p_edit. " Düzenlenebilir mi?

  APPEND gs_fcat TO gt_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       Layout ayarlarını yapılandırır
*----------------------------------------------------------------------*
FORM SET_LAYOUT .

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Kolon genişliklerini optimize eder
  gs_layout-zebra = 'X'. " Zebra desenini uygular

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_SUM
*&---------------------------------------------------------------------*
*       Edit modunda girilen değerleri toplar
*----------------------------------------------------------------------*
FORM GET_SUM .

  DATA: lv_sum TYPE i,
        lv_sumc TYPE char10,
        lv_message TYPE char50.

  LOOP AT gt_scarr INTO gs_scarr.
    lv_sum = lv_sum + gs_scarr-cost.
  ENDLOOP.

  lv_sumc = lv_sum.
  CONCATENATE 'Toplam' lv_sumc INTO lv_message SEPARATED BY space.
  MESSAGE lv_message TYPE 'I'.

ENDFORM.

START-OF-SELECTION.

  PERFORM get_data. " Verileri alır
  PERFORM set_fcat. " Field catalog oluşturur
  PERFORM set_layout. " Layout ayarlarını yapar
  PERFORM display_alv. " ALV'yi ekrana basar

  CALL SCREEN 0100. " Ekranı çağırır
