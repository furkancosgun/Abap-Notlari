*&---------------------------------------------------------------------*
*& Include           ZFC_ALV_OO_ALV_KULLANIM_TOP
*&---------------------------------------------------------------------*

" ALV nesnesi ve konteyner için referanslar
DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV nesnesi
      go_container TYPE REF TO cl_gui_custom_container. " ALV'yi tutacak konteyner

" Tablo verisi
DATA: gt_scarr TYPE TABLE OF scarr.

*&---------------------------------------------------------------------*
*& Include           ZFC_ALV_OO_ALV_KULLANIM_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'.  " Ekran statusunu ayarlar
  SET TITLEBAR '0100'.  " Ekran başlığını ayarlar

  PERFORM dispaly_alv.  " ALV'yi ekrana basma
ENDMODULE.

*&---------------------------------------------------------------------*
*& Include           ZFC_ALV_OO_ALV_KULLANIM_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

CASE sy-ucomm.
  WHEN '&BACK'.
    SET SCREEN 0.  " Ekranı kapatır ve önceki ekrana döner
ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Include           ZFC_ALV_OO_ALV_KULLANIM_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPALY_ALV
*&---------------------------------------------------------------------*
FORM dispaly_alv.

  " ALV için bir konteyner oluşturur
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV'.  " Ekranda gösterilecek custom container ID'si

  " ALV nesnesini oluşturur
  CREATE OBJECT go_alv
    EXPORTING
      i_parent = go_container.  " Konteynerin referansı

  " ALV nesnesinin ekran için ilk verileri ayarlaması
  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING
      i_structure_name = 'SCARR'  " Tablo yapısının adı
    CHANGING
      it_outtab = gt_scarr.  " Gösterilecek veri tablosu

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.

  " scarr tablosundan veriyi iç tabloya çeker
  SELECT * FROM scarr INTO TABLE gt_scarr.

ENDFORM.

*&---------------------------------------------------------------------*
*& Report ZFC_ALV_OO_ALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_ALV_OO_ALV_KULLANIM.

INCLUDE ZFC_ALV_OO_ALV_KULLANIM_TOP.
INCLUDE ZFC_ALV_OO_ALV_KULLANIM_PBO.
INCLUDE ZFC_ALV_OO_ALV_KULLANIM_PAI.
INCLUDE ZFC_ALV_OO_ALV_KULLANIM_FRM.

START-OF-SELECTION.

  PERFORM get_data.  " Veriyi çekmek için GET_DATA formunu çağırır

  CALL SCREEN 0100.  " Ekranı çağırır
