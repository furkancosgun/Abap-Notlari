*&---------------------------------------------------------------------*
*& Report ZFC_ALV_OO_ALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_ALV_OO_ALV_KULLANIM.

* TOP KISMI
DATA: go_alv TYPE REF TO CL_GUI_ALV_GRID, " ALV nesnesini tanımlar
      go_container TYPE REF TO CL_GUI_CUSTOM_CONTAINER, " ALV için container tanımlar
      gt_scarr TYPE TABLE OF scarr, " Tablo verilerini tutacak iç tablo
      gt_fcat TYPE lvc_t_fcat, " Field catalog için iç tablo
      gs_fcat TYPE lvc_s_fcat, " Field catalog için yapı
      gs_layout TYPE LVC_S_LAYO. " Layout için yapı

FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat. " Field catalog üzerinde değişiklik yapmak için field symbol

* PBO (Process Before Output) MODÜLÜ
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'. " SAP GUI durumunu ayarlar
  SET TITLEBAR '0100'. " Ekran başlığını ayarlar

  PERFORM display_alv. " ALV grid'i ekrana getirir

ENDMODULE.

* PAI (Process After Input) MODÜLÜ
MODULE USER_COMMAND_0100 INPUT.

CASE sy-ucomm.
  WHEN '&BACK'.
    SET SCREEN 0. " Önceki ekrana döner
ENDCASE.

ENDMODULE.

* FORM - ALV'yi Görüntüle
FORM display_alv.

  CREATE OBJECT go_container " ALV için container oluşturur
    EXPORTING
      CONTAINER_NAME = 'CC_ALV'. " Layout üzerinde oluşturduğumuz custom container ID

  CREATE OBJECT go_alv " ALV nesnesini oluşturur
    EXPORTING
      i_parent = go_container. " Önce oluşturulan container ID

  CALL METHOD go_alv->SET_TABLE_FOR_FIRST_DISPLAY " ALV'yi ekrana getirir
    EXPORTING
      i_default = 'X' " Varsayılan ayarları kullanır
      is_layout = gs_layout " Layout ayarları
    CHANGING
      it_outtab = gt_scarr " Görüntülenecek veri
      it_fieldcatalog = gt_fcat " Kolon ayarları için field catalog
    EXCEPTIONS
      OTHERS = 1. " Tüm istisnaları genel olarak işler

ENDFORM.

* FORM - Verileri Çek
FORM get_data.

  SELECT * FROM scarr INTO TABLE gt_scarr. " SCARR tablosundan verileri çeker

ENDFORM.

* FORM - Field Catalog Ayarları
FORM set_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE' " Otomatik field catalog oluşturur
    EXPORTING
      i_structure_name = 'SCARR' " Yapı veya tablo adı
    CHANGING
      ct_fieldcat = gt_fcat " Field catalog için iç tablo
    EXCEPTIONS
      inconsistent_interface = 1
      program_error = 2
      others = 3.

  IF sy-subrc <> 0.
    " Uygun hata işleme kodunu buraya ekleyin
  ENDIF.

  " Field catalog'u manuel olarak ayarlama
  READ TABLE gt_fcat ASSIGNING <gfs_fcat> WITH KEY fieldname = 'CARRID'.
  IF sy-subrc = 0.
    <gfs_fcat>-key = 'X'. " Key alanını işaretler
  ENDIF.

ENDFORM.

* FORM - Manuel Field Catalog Oluştur
FORM create_fcat USING p_fieldname
                       p_scrtext_s
                       p_scrtext_m
                       p_scrtext_l
                       p_col_pos
                       p_col_opt
                       p_key.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Kolon adı
  gs_fcat-scrtext_s = p_scrtext_s. " Kısa metin
  gs_fcat-scrtext_m = p_scrtext_m. " Orta metin
  gs_fcat-scrtext_l = p_scrtext_l. " Uzun metin
  gs_fcat-col_pos = p_col_pos. " Kolon pozisyonu
  gs_fcat-col_opt = p_col_opt. " Kolon genişlik optimizasyonu
  gs_fcat-key = p_key. " Key alanı

  APPEND gs_fcat TO gt_fcat. " Field catalog tablosuna ekler

ENDFORM.

* FORM - Layout Ayarları
FORM set_layout.

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Kolon genişliklerini optimize eder
  gs_layout-zebra = 'X'. " Satırlara zebra desenini uygular

ENDFORM.

* RAPORUN BAŞLANGICI
START-OF-SELECTION.

  PERFORM get_data. " Verileri çeker
  PERFORM set_fcat. " Field catalog'u ayarlar
  PERFORM set_layout. " Layout ayarlarını yapar

  CALL SCREEN 0100. " ALV ekranını çağırır
