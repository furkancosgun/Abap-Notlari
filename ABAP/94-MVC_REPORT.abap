"MODEL INTERFACE
INTERFACE zif_report_model
  PUBLIC .
  METHODS get_data .
  METHODS get_output_data RETURNING VALUE(rr_data) TYPE REF TO data .
ENDINTERFACE.

"VIEW INTERFACE
INTERFACE zif_report_view
  PUBLIC .
  METHODS :set_model IMPORTING VALUE(io_model) TYPE REF TO zif_report_model.
  METHODS :display.
  METHODS :set_controller IMPORTING VALUE(io_controller) TYPE REF TO zif_report_controller .
  METHODS :prepare_display.
  METHODS :refresh_table_display.
ENDINTERFACE.

"CONTROLLER INTERFACE
INTERFACE zif_report_controller
  PUBLIC .
  METHODS: set_model IMPORTING VALUE(io_model) TYPE REF TO zif_report_model .
  METHODS: set_view IMPORTING VALUE(io_view) TYPE REF TO zif_report_view .
  METHODS: handle_top_of_page FOR EVENT top_of_page OF cl_gui_alv_grid IMPORTING e_dyndoc_id table_index.
  METHODS: handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid IMPORTING e_row_id e_column_id.
  METHODS: handle_double_click FOR EVENT double_click OF cl_gui_alv_grid IMPORTING e_row e_column es_row_no.
  METHODS: handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid IMPORTING er_data_changed e_onf4 e_onf4_before e_onf4_after e_ucomm.
  METHODS: handle_button_click FOR EVENT button_click OF cl_gui_alv_grid IMPORTING es_col_id es_row_no.
  METHODS: handle_onf4 FOR EVENT onf4 OF cl_gui_alv_grid IMPORTING e_fieldname e_fieldvalue es_row_no er_event_data et_bad_cells e_display.
  METHODS: handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive.
  METHODS: handle_user_command FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm.
ENDINTERFACE.

"APP INTERFACE
INTERFACE zif_report_app
  PUBLIC .
  METHODS:initialization.
  METHODS:start_of_selection.
  METHODS:end_of_selection.
ENDINTERFACE.

"""EXAMPLE REPORT"""

"MODEL
*&---------------------------------------------------------------------*
*&  Include           ZFC_REPORT_MVC_MODEL
*&---------------------------------------------------------------------*
CLASS cls_model DEFINITION.
  PUBLIC SECTION.
    INTERFACES  zif_report_model.
  PRIVATE SECTION.
    DATA :mt_table TYPE TABLE OF scarr.
ENDCLASS.
CLASS cls_model IMPLEMENTATION .
  METHOD:zif_report_model~get_data.
    SELECT * FROM scarr INTO CORRESPONDING FIELDS OF TABLE mt_table.
  ENDMETHOD.
  METHOD zif_report_model~get_output_data.
    rr_data = REF #( mt_table ).
  ENDMETHOD.
ENDCLASS.

"VIEW
*&---------------------------------------------------------------------*
*&  Include           ZFC_REPORT_MVC_VIEW
*&---------------------------------------------------------------------*
CLASS cls_view DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_report_view.
  PRIVATE SECTION.
    CONSTANTS:mc_alv_structre TYPE dd02l-tabname VALUE 'SCARR'.
    DATA :mo_controller TYPE REF TO zif_report_controller,
          mo_model      TYPE REF TO zif_report_model,
          mo_alv_grid   TYPE REF TO cl_gui_alv_grid,
          ms_layout     TYPE lvc_s_layo,
          mt_fieldcat   TYPE lvc_t_fcat,
          ms_variant    TYPE disvariant.
ENDCLASS.
CLASS cls_view IMPLEMENTATION .
  METHOD zif_report_view~set_model.
    mo_model = io_model.
  ENDMETHOD.
  METHOD zif_report_view~prepare_display.
    CLEAR ms_layout.
    ms_layout-zebra      = 'X'.
    ms_layout-col_opt    = 'X'.
    ms_layout-cwidth_opt = 'X'.
    ms_variant-report = sy-repid.
    REFRESH  mt_fieldcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = mc_alv_structre
      CHANGING
        ct_fieldcat      = mt_fieldcat
      EXCEPTIONS
        OTHERS           = 0.
    LOOP AT mt_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>).
      <fs_fcat>-edit = 'X'.
    ENDLOOP.
  ENDMETHOD.
  METHOD zif_report_view~display.

    zif_report_view~prepare_display( ).

    DATA(mr_table) = mo_model->get_output_data( ).
    ASSIGN mr_table->* TO FIELD-SYMBOL(<fs_table>).

    CREATE OBJECT mo_alv_grid
      EXPORTING
        i_parent = cl_gui_custom_container=>default_screen
      EXCEPTIONS
        OTHERS   = 0.

    SET HANDLER mo_controller->handle_double_click FOR mo_alv_grid."IF NEED

    CALL METHOD mo_alv_grid->set_table_for_first_display
      EXPORTING
        is_layout                     = ms_layout
        i_save                        = 'A'
        i_default                     = 'X'
        is_variant                    = ms_variant
      CHANGING
        it_outtab                     = <fs_table>
        it_fieldcatalog               = mt_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc IS INITIAL.
      CALL METHOD mo_alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.

      CALL METHOD mo_alv_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_enter
        EXCEPTIONS
          error      = 1
          OTHERS     = 2.
    ENDIF.
    WRITE ''.
  ENDMETHOD.
  METHOD zif_report_view~set_controller.
    mo_controller = io_controller.
  ENDMETHOD.
  METHOD zif_report_view~refresh_table_display.
    mo_alv_grid->refresh_table_display( ).
  ENDMETHOD.
ENDCLASS.

"CONTROLLER
*&---------------------------------------------------------------------*
*&  Include           ZFC_REPORT_MVC_CONTROLLER
*&---------------------------------------------------------------------*
CLASS cls_controller DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_report_controller.
  PRIVATE SECTION.
    DATA mo_model TYPE REF TO zif_report_model.
    DATA mo_view TYPE REF TO zif_report_view.
ENDCLASS.
CLASS cls_controller IMPLEMENTATION.
  METHOD zif_report_controller~set_model.
    mo_model = io_model.
  ENDMETHOD.
  METHOD zif_report_controller~handle_double_click.
    mo_view->refresh_table_display( ).
  ENDMETHOD.
  METHOD zif_report_controller~set_view.
    mo_view = io_view.
  ENDMETHOD.
ENDCLASS.

"APP
*&---------------------------------------------------------------------*
*&  Include           ZFC_REPORT_MVC_APP
*&---------------------------------------------------------------------*
CLASS cls_app DEFINITION.
  PUBLIC SECTION.
    INTERFACES:zif_report_app.
  PRIVATE SECTION.
    DATA :mo_model      TYPE REF TO zif_report_model.
    DATA :mo_view       TYPE REF TO zif_report_view.
    DATA :mo_controller TYPE REF TO zif_report_controller.
ENDCLASS.
CLASS cls_app IMPLEMENTATION.
  METHOD:zif_report_app~initialization.
    mo_model      = NEW cls_model( ).
    mo_view       = NEW cls_view( ).
    mo_controller = NEW cls_controller( ).
  ENDMETHOD.
  METHOD:zif_report_app~start_of_selection.
    mo_model->get_data( ).
  ENDMETHOD.
  METHOD:zif_report_app~end_of_selection.
    mo_view->set_model( io_model = mo_model ).
    mo_view->set_controller( io_controller = mo_controller ).

    mo_controller->set_model( io_model = mo_model ).
    mo_controller->set_view( io_view = mo_view ).

    mo_view->prepare_display( ).
    mo_view->display( ).
  ENDMETHOD.
ENDCLASS.

"BASE
*&---------------------------------------------------------------------*
*& Report ZFC_REPORT_MVC
*&---------------------------------------------------------------------*
*& CREATED BY FURKAN COSGUN
*&---------------------------------------------------------------------*
REPORT zfc_report_mvc.
INCLUDE  zfc_report_mvc_model.
INCLUDE  zfc_report_mvc_view.
INCLUDE  zfc_report_mvc_controller.
INCLUDE  zfc_report_mvc_app.

DATA app TYPE REF TO zif_report_app.

LOAD-OF-PROGRAM.
  app = NEW cls_app( ).

INITIALIZATION.
  app->initialization( ).

START-OF-SELECTION.
  app->start_of_selection( ).

END-OF-SELECTION.
  app->end_of_selection( ).
