*&---------------------------------------------------------------------*
*& Report ZFC_ALV_OO_ALV_KULLANIM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_ALV_OO_ALV_KULLANIM.

DATA: go_alv TYPE REF TO CL_GUI_ALV_GRID, " Define the ALV object
      go_container TYPE REF TO CL_GUI_CUSTOM_CONTAINER. " Define the container object for ALV

" Table Data
DATA gt_scarr TYPE TABLE OF scarr. " Internal table to hold data of type SCARR

" Field Catalog
DATA: gt_fcat TYPE lvc_t_fcat, " Internal table for field catalog
      gs_fcat TYPE lvc_s_fcat. " Structure for field catalog

" Layout Settings
DATA gs_layout TYPE LVC_S_LAYO. " Structure for layout settings

* Process Before Output (PBO)
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS '0100'. " Set the SAP GUI status
  SET TITLEBAR '0100'. " Set the title bar of the screen

  PERFORM display_alv. " Call the form to display ALV

ENDMODULE.

* Process After Input (PAI)
MODULE USER_COMMAND_0100 INPUT.

CASE sy-ucomm.
  WHEN '&BACK'.
    SET SCREEN 0. " Return to the previous screen
ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_OO_ALV_KULLANIM_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       This form sets up and displays the ALV grid.
*----------------------------------------------------------------------*
FORM display_alv.

  CREATE OBJECT go_container " Create the container for ALV
    EXPORTING
      CONTAINER_NAME = 'CC_ALV'. " Container ID for the custom container

  CREATE OBJECT go_alv " Create the ALV object
    EXPORTING
      i_parent = go_container. " Parent container ID

  CALL METHOD go_alv->SET_TABLE_FOR_FIRST_DISPLAY " Method to display the ALV grid
    EXPORTING
      i_default = 'X' " Use default settings
      is_layout = gs_layout " Layout settings
    CHANGING
      it_outtab = gt_scarr " Data to be displayed
      it_fieldcatalog = gt_fcat " Field catalog for column settings
    EXCEPTIONS
      OTHERS = 1. " Handle all exceptions generically

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       This form retrieves data from the database.
*----------------------------------------------------------------------*
FORM get_data.

  SELECT * FROM scarr INTO TABLE gt_scarr. " Select data into internal table

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_FCAT
*&---------------------------------------------------------------------*
*       This form sets the field catalog for ALV.
*----------------------------------------------------------------------*
FORM set_fcat.

  PERFORM create_fcat USING 'CARRID' 'Air c.' 'Airline c.' 'Airline code' 1 '' 'X'.
  PERFORM create_fcat USING 'CARRNAME' 'A. Name' 'Air Name' 'Airline Name' 2 '' ''.
  PERFORM create_fcat USING 'CURRCODE' 'Curr' 'Local Curr' 'Local currency of airline' 3 '' ''.
  PERFORM create_fcat USING 'URL' 'A. Url' 'Air Url' 'Airline Url' 4 'X' ''.

ENDFORM.

FORM create_fcat USING p_fieldname
                       p_scrtext_s
                       p_scrtext_m
                       p_scrtext_l
                       p_col_pos
                       p_col_opt
                       p_key.

  CLEAR gs_fcat.
  gs_fcat-fieldname = p_fieldname. " Column name
  gs_fcat-scrtext_s = p_scrtext_s. " Short text for the column
  gs_fcat-scrtext_m = p_scrtext_m. " Medium text for the column
  gs_fcat-scrtext_l = p_scrtext_l. " Long text for the column
  gs_fcat-col_pos = p_col_pos. " Column position
  gs_fcat-col_opt = p_col_opt. " Column width optimization
  gs_fcat-key = p_key. " Key field

  APPEND gs_fcat TO gt_fcat. " Append the field catalog to the internal table

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       This form sets the layout for the ALV grid.
*----------------------------------------------------------------------*
FORM set_layout.

  CLEAR gs_layout.
  gs_layout-cwidth_opt = 'X'. " Optimize column widths
  gs_layout-zebra = 'X'. " Apply zebra striping to rows

ENDFORM.

START-OF-SELECTION.

  PERFORM get_data. " Retrieve data
  PERFORM set_fcat. " Set field catalog
  PERFORM set_layout. " Set layout options

  CALL SCREEN 0100. " Call the screen for ALV display
