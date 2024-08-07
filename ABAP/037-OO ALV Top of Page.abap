*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME_TOP
*&---------------------------------------------------------------------*

" ALV nesnesi ve container tanımlamaları
DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV nesnesi için referans
      go_container TYPE REF TO cl_gui_custom_container. " ALV'yi barındıracak container

" Veritabanı tablosu ve yapı
DATA gt_scarr TYPE TABLE OF scarr. " SCARR tablosunun veri tablosu

DATA: gt_fcat TYPE lvc_t_fcat, " Field Catalog iç tablosu
      gs_fcat TYPE lvc_s_fcat, " Field Catalog yapısı
      gs_layout TYPE lvc_s_layo. " ALV düzen yapısı

" Event'lar için class tanımlaması
CLASS cl_event_receiver DEFINITION DEFERRED. " Event'lar için class tanımlaması

" Event handler nesnesi
DATA go_event_receiver TYPE REF TO cl_event_receiver. " Event handler nesnesi için referans

" Top of Page işlemleri için container ve document nesneleri
DATA: go_split_container TYPE REF TO cl_gui_splitter_container, " Container'ı bölmek için
      go_sub1 TYPE REF TO cl_gui_container, " Bir parçası için container
      go_sub2 TYPE REF TO cl_gui_container, " Diğer parçası için container
      go_docu TYPE REF TO cl_dd_document. " Top of Page yapılandırması için document nesnesi

*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       ALV ekranını gösterir
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  IF go_alv IS INITIAL.

    " Event handler nesnesini oluşturur
    CREATE OBJECT go_event_receiver.

    " ALV'nin yer alacağı container'ı oluşturur
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC_ALV'.

    " Container'ı iki parçaya böler
    CREATE OBJECT go_split_container
      EXPORTING
        parent = go_container " Ana container
        rows = 2 " İki satır
        columns = 1. " Tek kolon

    " Top of Page yapılandırması için document nesnesini oluşturur
    CREATE OBJECT go_docu
      EXPORTING
        style = 'ALV_GRID'. " ALV Grid stilinde

    " Top of Page alanını yönetecek sub container'ı alır
    CALL METHOD go_split_container->get_container
      EXPORTING
        row = 1 " Birinci satır
        column = 1 " Birinci kolon
      RECEIVING
        container = go_sub1. " Sub1 container'ı

    " ALV'nin yer alacağı sub container'ı alır
    CALL METHOD go_split_container->get_container
      EXPORTING
        row = 2 " İkinci satır
        column = 1 " Birinci kolon
      RECEIVING
        container = go_sub2. " Sub2 container'ı

    " Birinci satırın yüksekliğini ayarlar
    CALL METHOD go_split_container->set_row_height
      EXPORTING
        id = 1 " Satır ID'si
        height = 15. " Yükseklik

    " ALV nesnesini oluşturur ve sub2 container'ına atar
    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_sub2. " ALV'nin yer alacağı container

    " Event handler'ı ALV nesnesine bağlar
    SET HANDLER go_event_receiver->handle_top_of_page FOR go_alv.

    " ALV ekranını ilk kez veri ve layout ile gösterir
    go_alv->set_table_for_first_display(
      EXPORTING
        is_layout = gs_layout " Layout ayarları
      CHANGING
        it_outtab = gt_scarr " Görüntülenecek veri tablosu
        it_fieldcatalog = gt_fcat " Field Catalog
    ).

    " Top of Page yapılandırmasını ekrana basar
    go_alv->list_processing_events(
      EXPORTING
        i_event_name = 'TOP_OF_PAGE' " Event adı
        i_dyndoc_id = go_docu " Dinamik document
    ).

  ELSE.
    " ALV ekranını yeniler
    CALL METHOD go_alv->refresh_table_display.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Veriyi alır ve tabloya ekler
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  " SCARR tablosundan verileri alır
  SELECT * FROM scarr INTO TABLE gt_scarr.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       Field Catalog ayarlarını yapar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fcat USING p_fieldname.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Kolon adı

  " Referans tablonun ve kolonun ayarlarını yapar
  gs_fcat-ref_table = 'SCARR'.
  gs_fcat-ref_field = p_fieldname.

  APPEND gs_fcat TO gt_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_FCAT
*&---------------------------------------------------------------------*
*       Field Catalog ayarlarını yapar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_fcat .
  " Field Catalog ayarlarını yapar
  PERFORM set_fcat USING 'CARRID'.
  PERFORM set_fcat USING 'CARRNAME'.
  PERFORM set_fcat USING 'CURRCODE'.
  PERFORM set_fcat USING 'URL'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       Layout ayarlarını yapar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_layout .
  gs_layout-cwidth_opt = 'X'. " Kolon genişliklerini otomatik ayarla
  gs_layout-zebra = 'X'. " Zebra desenini uygula
ENDFORM.

////////////CLS///////////////

*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME_CLS
*&---------------------------------------------------------------------*
CLASS cl_event_receiver DEFINITION. " Event işleyici sınıfı
  PUBLIC SECTION. " Erişim bölümünü tanımlar
    METHODS handle_top_of_page " Top of Page event işleyicisi
      FOR EVENT top_of_page OF cl_gui_alv_grid
    IMPORTING
      e_dyndoc_id
      table_index.

ENDCLASS.

CLASS cl_event_receiver IMPLEMENTATION.

  METHOD handle_top_of_page. " Top of Page işleyicisi
    DATA: lv_text TYPE sdydo_text_element. " Başlık metnini tutar

    lv_text = 'Flight Details'.

    " Text ekleme metodunu çağırır
    CALL METHOD go_docu->add_text
      EXPORTING
        text = lv_text " Metin
        sap_style = cl_dd_document=>heading. " Metin stili

    CALL METHOD go_docu->new_line. " Yeni satır ekler

    CLEAR lv_text.

    " Kullanıcı adını ekler
    CONCATENATE 'USER: ' sy-uname INTO lv_text SEPARATED BY space.

    CALL METHOD go_docu->add_text
      EXPORTING
        text = lv_text " Metin
        sap_color = cl_dd_document=>list_positive. " Metin rengi
        "sap_fontsize = CL_DD_DOCUMENT=>MEDIUM. " Metin font büyüklüğü (Yorum satırına alınmış)

    CALL METHOD go_docu->display_document
      EXPORTING
        parent = go_sub1. " Metin görüntülenecek alan

  ENDMETHOD.

ENDCLASS.
