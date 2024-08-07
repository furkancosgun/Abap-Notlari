*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_KULLANIM_TOP
*&---------------------------------------------------------------------*

" ALV (ABAP List Viewer) için nesne referansları
DATA: go_alv TYPE REF TO CL_GUI_ALV_GRID, " ALV nesnesi
      go_container TYPE REF TO CL_GUI_CUSTOM_CONTAINER. " ALV'yi içerecek konteyner

" Field Catalog ve Layout tanımlamaları
DATA: gt_fcat TYPE lvc_t_fcat, " Field Catalog için iç tablo
      gs_fcat TYPE lvc_s_fcat, " Field Catalog için yapı
      gs_layout TYPE LVC_S_LAYO. " ALV ekran düzeni için yapı

" Veritabanı tablosu ve hücre stili için tip tanımlamaları
TYPES: BEGIN OF gty_scarr,
  CARRID TYPE S_CARR_ID,       " Havayolu kodu
  CARRNAME TYPE S_CARRNAME,   " Havayolu ismi
  CURRCODE TYPE S_CURRCODE,   " Para birimi kodu
  URL TYPE S_CARRURL,         " URL adresi
  STYLE TYPE LVC_T_STYL,      " Hücre stili için tablo (bu sadece verinin stili için değil, aynı zamanda layouta da bildirilmelidir)
  styleC TYPE char8,          " Hücre stili kodu
  END OF gty_scarr.

" Hücre stili yapısı
DATA gs_style TYPE LVC_S_STYL. " Hücre stili için yapı

" Veriler için iç tablo ve yapılar
DATA: gt_scarr TYPE TABLE OF gty_scarr,
      gs_scarr TYPE gty_scarr.

FIELD-SYMBOLS: <gfs_scarr> TYPE gty_scarr. " Satır rengini ayarlamak için field-symbol

//////////FRM///////////

*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_KULLANIM_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       ALV ekranını gösterir
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_ALV .

  IF GO_ALV IS INITIAL.
    " ALV nesnesini oluşturur
    CREATE OBJECT GO_ALV
      EXPORTING
        I_PARENT = CL_GUI_CONTAINER=>SCREEN0. " Konteyner ID'si verilmelidir, önce oluşturulmalıdır

    " ALV ekranına veri eklemek için methodu çağırır
    CALL METHOD GO_ALV->SET_TABLE_FOR_FIRST_DISPLAY
      EXPORTING
        IS_LAYOUT = gs_layout
      CHANGING
        IT_OUTTAB = gt_scarr " Ekranda gösterilecek veri
        IT_FIELDCATALOG = GT_FCAT " Kolon düzenlemeleri için

    " Editable modda veri yakalamak için eventleri kaydeder
    CALL METHOD GO_ALV->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED. " Satırdan çıkıldığında event tetiklenir

    CALL METHOD GO_ALV->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER. " Satırda enter yapıldığında event tetiklenir

  ELSE.
    " ALV ekranını yeniler
    CALL METHOD GO_ALV->REFRESH_TABLE_DISPLAY. " Ekranı yeniler
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Veri alır ve işler
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_DATA .

  " SCARR tablosundaki tüm verileri alır
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.

  " Geçici tabloyu oluşturur ve veri ekler
  DATA: lv_style TYPE n LENGTH 8,
        lv_style_c TYPE char8.

  DATA(gt_scarr_tmp) = gt_scarr. " Tabloyu geçici bir tabloya kopyalar

  DO 30 TIMES.
    APPEND LINES OF gt_scarr_tmp TO gt_scarr. " Geçici tablodaki satırları ana tabloya ekler
  ENDDO.

  LOOP AT GT_SCARR ASSIGNING <GFS_SCARR>. " Tabloyu döngüye alır

    LV_STYLE = LV_STYLE + 1. " Her döngüde stil değerini artırır
    LV_STYLE_C = LV_STYLE. " Stil değerini karakter tipine dönüştürür
    <GFS_SCARR>-STYLEC = LV_STYLE_C. " Stil kodunu veriye yazar

    CLEAR gs_style. " Stil yapısını temizler
    GS_STYLE-FIELDNAME = 'URL'. " Stil uygulanacak kolon
    GS_STYLE-STYLE = LV_STYLE_C. " Stil kodunu ayarlar

    APPEND GS_STYLE TO <GFS_SCARR>-STYLE. " Hücre stilini ilgili tabloya ekler

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
FORM SET_FCAT .

  " Kolonların Field Catalog ayarlarını yapar
  PERFORM CREATE_FCAT USING 'CARRID' 'Air c.' 'Airline c.' 'Airline code' ''.
  PERFORM CREATE_FCAT USING 'CARRNAME' 'A. Name' 'Air Name' 'Airline Name' ''.
  PERFORM CREATE_FCAT USING 'CURRCODE' 'Curr' 'Local Curr' 'Local currency of airline' ''.
  PERFORM CREATE_FCAT USING 'URL' 'A. Url' 'Air Url' 'Airline Url' 'X'.
  PERFORM CREATE_FCAT USING 'STYLEC' 'S. C.' 'Style c' 'Style code' ''.

ENDFORM.

" Manuel Field Catalog oluşturma
FORM CREATE_FCAT USING p_fieldname
                       p_scrtext_s
                       p_scrtext_m
                       p_scrtext_l
                       p_edit.

  CLEAR GS_FCAT.
  GS_FCAT-FIELDNAME = p_fieldname. " Kolon adı, eğer verilmezse görünmez
  GS_FCAT-SCRTEXT_S = p_scrtext_s. " Kolon adı kısa
  GS_FCAT-SCRTEXT_M = p_scrtext_m. " Kolon adı orta
  GS_FCAT-SCRTEXT_L = p_scrtext_l. " Kolon adı uzun
  GS_FCAT-EDIT = p_edit. " Düzenlenebilir mi
  APPEND GS_FCAT TO GT_FCAT.

ENDFORM.

FORM SET_LAYOUT .

  CLEAR GS_LAYOUT.
  GS_LAYOUT-CWIDTH_OPT = 'X'. " Tüm kolonların genişliği otomatik olarak ayarlanır
  GS_LAYOUT-ZEBRA = 'X'. " Satırları zebra deseninde gösterir
  GS_LAYOUT-STYLEFNAME = 'STYLE'. " Hücre stili için layout ayarlarını yapar

ENDFORM.
