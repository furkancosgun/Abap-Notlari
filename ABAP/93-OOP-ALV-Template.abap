*&---------------------------------------------------------------------*
*&  Include           ZFC_EXAMPLE_TOP
*&---------------------------------------------------------------------*

CLASS cls_report DEFINITION DEFERRED.
TABLES:scarr.
DATA: go_report  TYPE REF TO cls_report,
      gt_alv_tab TYPE TABLE OF scarr.
"///////////////////////////////////////////////////////////////////////
*&---------------------------------------------------------------------*
*&  Include           ZFC_EXAMPLE_SLC
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.
PARAMETERS p_carrid TYPE scarr-carrid.
SELECTION-SCREEN END OF BLOCK b1.
"///////////////////////////////////////////////////////////////////////
*&---------------------------------------------------------------------*
*&  Include           ZFC_EXAMPLE_CLS
*&---------------------------------------------------------------------**&---------------------------------------------------------------------*
*&  Include           ZFC_DEMO_REPORT_TEMPLATE_CLS
*&---------------------------------------------------------------------*
CLASS cls_report DEFINITION INHERITING FROM cls_events.
  PUBLIC SECTION.
    METHODS :get_data,prepare_display,display_alv.

  PRIVATE SECTION.
    CONSTANTS: lc_alv_structre TYPE dd02l-tabname VALUE 'SCARR'.
    DATA: alv_grid TYPE REF TO cl_gui_alv_grid,
          layout   TYPE lvc_s_layo,
          fieldcat TYPE lvc_t_fcat,
          variant  TYPE disvariant.

ENDCLASS.

*----------------------------------------------------------------------*
*       CLASS CLS_LOCAL IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cls_report IMPLEMENTATION.
  METHOD get_data.
    SELECT * FROM scarr INTO TABLE gt_alv_tab.
    CHECK sy-subrc IS INITIAL.
    cl_progress_indicator=>progress_indicate( i_text = |Processing..|
                                      i_processed = sy-tabix
                                      i_total = lines( gt_alv_tab )
                                      i_output_immediately = 'X' ).
  ENDMETHOD.

  METHOD prepare_display.
    CREATE OBJECT alv_grid
      EXPORTING
        i_parent = cl_gui_custom_container=>screen0
      EXCEPTIONS
        OTHERS   = 0.

    CLEAR layout.
    layout-zebra      = 'X'.
    layout-col_opt    = 'X'.
    layout-cwidth_opt = 'X'.
    variant-report = sy-repid.

    REFRESH  fieldcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = lc_alv_structre
      CHANGING
        ct_fieldcat      = fieldcat
      EXCEPTIONS
        OTHERS           = 0.

  ENDMETHOD.

  METHOD display_alv.
    SET HANDLER me->handle_double_click FOR alv_grid.
    CALL METHOD alv_grid->set_table_for_first_display
      EXPORTING
        is_layout                     = layout
        i_save                        = 'A'
        i_default                     = 'X'
        is_variant                    = variant
      CHANGING
        it_outtab                     = gt_alv_tab
        it_fieldcatalog               = fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc IS INITIAL.
      CALL METHOD alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.

      CALL METHOD alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_enter
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*&  Include           ZFC_DEMO_REPORT_TEMPLATE_EVT
*&---------------------------------------------------------------------*
CLASS cls_events DEFINITION .
  PROTECTED SECTION.
    METHODS  handle_top_of_page
        FOR EVENT top_of_page OF cl_gui_alv_grid
      IMPORTING
        e_dyndoc_id
        table_index.


    METHODS handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING
        e_row_id
        e_column_id.

    METHODS handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.

    METHODS handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
        er_data_changed
        e_onf4
        e_onf4_before
        e_onf4_after
        e_ucomm.

    METHODS handle_button_click
        FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING
        es_col_id
        es_row_no.

    METHODS handle_onf4
        FOR EVENT onf4 OF cl_gui_alv_grid
      IMPORTING
        e_fieldname
        e_fieldvalue
        es_row_no
        er_event_data
        et_bad_cells
        e_display.

    METHODS: handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
        e_object
        e_interactive.

    METHODS: handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
        e_ucomm.

ENDCLASS.

CLASS cls_events IMPLEMENTATION.
  METHOD handle_top_of_page.
  ENDMETHOD.

  METHOD handle_hotspot_click.
  ENDMETHOD.

  METHOD handle_double_click.
  ENDMETHOD.

  METHOD handle_data_changed.
  ENDMETHOD.

  METHOD handle_button_click.
  ENDMETHOD.

  METHOD handle_onf4.
  ENDMETHOD.

  METHOD handle_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
  ENDMETHOD.
ENDCLASS.
"///////////////////////////////////////////////////////////////////////
*&---------------------------------------------------------------------*
*&  Include           ZFC_EXAMPLE_SRC
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100S'.
*  SET TITLEBAR 'ZTITLE'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module user_command_0100 input.
  CASE sy-ucomm.
    WHEN '&F03' or '&F12' or '&F15'.
      SET SCREEN 0.
  ENDCASE.

endmodule.
"///////////////////////////////////////////////////////////////////////
*&---------------------------------------------------------------------*
*& Report ZFC_EXAMPLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfc_demo_report_template.
INCLUDE zfc_demo_report_template_top.
INCLUDE zfc_demo_report_template_slc.
INCLUDE zfc_demo_report_template_evt.
INCLUDE zfc_demo_report_template_cls.
INCLUDE zfc_demo_report_template_src.


INITIALIZATION.
  CREATE OBJECT go_report.

START-OF-SELECTION.
  go_report->get_data( ).
  go_report->prepare_display( ).
  go_report->display_alv( ).
  CALL SCREEN 0100.
