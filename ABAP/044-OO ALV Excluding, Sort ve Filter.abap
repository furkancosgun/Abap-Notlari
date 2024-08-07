*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_DENEME_TOP
*&---------------------------------------------------------------------*

DATA: go_alv TYPE REF TO cl_gui_alv_grid, " ALV Grid nesnesi için referans
      go_container TYPE REF TO cl_gui_custom_container. " ALV Grid'in bulunduğu container için referans

DATA: gt_scarr TYPE TABLE OF scarr, " SCARR tablosuna benzeyen internal table
      gs_scarr TYPE scarr. " SCARR tablosu için work area

DATA: gt_fcat TYPE lvc_t_fcat, " Field catalog (alan katalogu) için internal table
      gs_fcat TYPE lvc_s_fcat. " Field catalog (alan katalogu) için structure

DATA: gs_layout TYPE lvc_s_layo. " ALV Grid'in layout (düzen) ayarları

" Top of page kullanımı için veri tanımlamaları
DATA: go_split_container TYPE REF TO cl_gui_splitter_container, " Container'ı parçalamak için referans
      go_sub1 TYPE REF TO cl_gui_container, " Container'ın bir parçası için referans
      go_sub2 TYPE REF TO cl_gui_container. " Container'ın diğer parçası için referans

DATA: go_docu TYPE REF TO cl_dd_document. " Top of Page için document nesnesi

FIELD-SYMBOLS: <gfs_fcat> TYPE lvc_s_fcat, " Field catalog için field symbol
               <gfs_scarr> TYPE scarr. " SCARR tablosu için field symbol

DATA: gt_excluding TYPE ui_functions, " Excluding işlemleri için internal table
      gv_excluding TYPE ui_func, " Toolbar butonlarını hariç tutmak için değişken
      gt_sort TYPE lvc_t_sort, " Sıralama işlemleri için internal table
      gs_sort TYPE lvc_s_sort, " Sıralama için structure
      gt_filter TYPE lvc_t_filt, " Filtreleme işlemleri için internal table
      gs_filter TYPE lvc_s_filt. " Filtreleme için structure

FORM display_alv.
* Create container and ALV Grid objects
  CREATE OBJECT go_container
  EXPORTING
    container_name = 'CC_ALV'.

  CREATE OBJECT go_alv
  EXPORTING
    i_parent = go_container.

* Initialize configurations
  PERFORM set_excluding.
  PERFORM set_sort.
  PERFORM set_filter.

* Display the ALV Grid with the configured settings
  go_alv->set_table_for_first_display(
  EXPORTING
    is_layout = gs_layout " Layout settings
    it_toolbar_excluding = gt_excluding " Excluded Toolbar Functions
  CHANGING
    it_outtab = gt_scarr " Output Table
    it_fieldcatalog = gt_fcat " Field Catalog
    it_sort = gt_sort " Sort Criteria
    it_filter = gt_filter " Filter Criteria
).
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       Retrieve data from SCARR table
*----------------------------------------------------------------------*
FORM get_data.
  SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_scarr.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_FCAT
*&---------------------------------------------------------------------*
*       Generate field catalog for ALV
*----------------------------------------------------------------------*
FORM get_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'SCARR'
    CHANGING
      ct_fieldcat = gt_fcat.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       Set layout options for ALV
*----------------------------------------------------------------------*
FORM set_layout.
  gs_layout-cwidth_opt = 'X'. " Column width optimization
  gs_layout-zebra = 'X'. " Zebra pattern for rows
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_EXCLUDING
*&---------------------------------------------------------------------*
*       Exclude certain toolbar buttons
*----------------------------------------------------------------------*
FORM set_excluding.
  CLEAR gv_excluding.
  gv_excluding = cl_gui_alv_grid=>mc_fc_detail. " Exclude Detail button
  APPEND gv_excluding TO gt_excluding.

  CLEAR gv_excluding.
  gv_excluding = cl_gui_alv_grid=>mc_fc_sort_asc. " Exclude Sort Ascending button
  APPEND gv_excluding TO gt_excluding.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_SORT
*&---------------------------------------------------------------------*
*       Set sorting criteria for ALV
*----------------------------------------------------------------------*
FORM set_sort.
  CLEAR gs_sort.
  gs_sort-apos = 1. " Sort position
  gs_sort-fieldname = 'CURRCODE'. " Field to sort
  gs_sort-down = 'X'. " Sort descending
  APPEND gs_sort TO gt_sort.

  CLEAR gs_sort.
  gs_sort-apos = 2. " Sort position
  gs_sort-fieldname = 'CARRNAME'. " Field to sort
  gs_sort-up = 'X'. " Sort ascending
  APPEND gs_sort TO gt_sort.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FILTER
*&---------------------------------------------------------------------*
*       Set filter criteria for ALV
*----------------------------------------------------------------------*
FORM set_filter.
  CLEAR gs_filter.
  gs_filter-tabname = 'GT_SCARR'.
  gs_filter-fieldname = 'CURRCODE'.
  gs_filter-sign = 'I'. " Include
  gs_filter-option = 'EQ'. " Equals
  gs_filter-low = 'USD'. " Filter value
  APPEND gs_filter TO gt_filter.
ENDFORM.
