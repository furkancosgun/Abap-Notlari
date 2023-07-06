"MODEL INTERFACE
interface ZIF_REPORT_MODEL
  public .


  methods GET_DATA .
  methods GET_OUTPUT_DATA
    returning
      value(RR_DATA) type ref to DATA .
endinterface.

"VIEW INTERFACE
interface ZIF_REPORT_VIEW
  public .


  methods SET_MODEL
    importing
      value(IO_MODEL) type ref to ZIF_REPORT_MODEL .
  methods SHOW_DATA .
  methods SET_CONTROLLER
    importing
      value(IO_CONTROLLER) type ref to ZIF_REPORT_CONTROLLER .
  methods PREPARE_DISPLAY .
  methods REFRESH_TABLE_DISPLAY .
endinterface.

"CONTROLLER INTERFACE
interface ZIF_REPORT_CONTROLLER
  public .


  methods SET_MODEL
    importing
      value(IO_MODEL) type ref to ZIF_REPORT_MODEL .
  methods SET_VIEW
    importing
      value(IO_VIEW) type ref to ZIF_REPORT_VIEW .
  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW
      !E_COLUMN
      !ES_ROW_NO .
endinterface.

"REPORT
*&---------------------------------------------------------------------*
*& Report ZFC_EXP_MVC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfc_exp_mvc.

CLASS cls_model DEFINITION.
  PUBLIC SECTION.
    INTERFACES  zif_report_model.
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

CLASS cls_view DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_report_view.
    CONSTANTS:mc_alv_structre TYPE dd02l-tabname VALUE 'SCARR'.
    DATA :mo_controller TYPE REF TO zif_report_controller,
          mo_model      TYPE REF TO zif_report_model,
          mo_alv_grid   TYPE REF TO cl_gui_alv_grid,
          ms_layout     TYPE lvc_s_layo,
          mt_fieldcat   TYPE lvc_t_fcat,
          ms_variant    TYPE disvariant..
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
  ENDMETHOD.
  METHOD zif_report_view~show_data.
    zif_report_view~prepare_display( ).
    DATA(mr_table) = mo_model->get_output_data( ).
    ASSIGN mr_table->* TO FIELD-SYMBOL(<fs_table>).
    CREATE OBJECT mo_alv_grid
      EXPORTING
        i_parent = cl_gui_custom_container=>default_screen
      EXCEPTIONS
        OTHERS   = 0.
    SET HANDLER mo_controller->handle_double_click FOR mo_alv_grid.
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

CLASS cls_controller DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_report_controller.
    DATA mo_model TYPE REF TO zif_report_model.
    DATA mo_view TYPE REF TO zif_report_view.
ENDCLASS.
CLASS cls_controller IMPLEMENTATION.
  METHOD zif_report_controller~set_model.
    mo_model = io_model.
  ENDMETHOD.
  METHOD zif_report_controller~handle_double_click.
    DATA(mr_table) = mo_model->get_output_data( ).
    FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE.
    ASSIGN mr_table->* TO <fs_table>.
    DELETE <fs_table> INDEX 1.
    mo_view->refresh_table_display( ).
  ENDMETHOD.
  METHOD zif_report_controller~set_view.
    mo_view = io_view.
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  DATA(lo_model) = NEW cls_model( ).
  DATA(lo_view) = NEW cls_view( ).
  DATA(lo_controller) = NEW cls_controller( ).

  lo_model->zif_report_model~get_data( ).

  lo_view->zif_report_view~set_model( io_model = lo_model ).
  lo_view->zif_report_view~set_controller( io_controller = lo_controller ).

  lo_controller->zif_report_controller~set_model( io_model = lo_model ).
  lo_controller->zif_report_controller~set_view( io_view = lo_view ).

  lo_view->zif_report_view~show_data( ).
