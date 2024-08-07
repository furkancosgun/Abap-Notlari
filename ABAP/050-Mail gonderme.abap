*&---------------------------------------------------------------------*
*& Report ZSEND_EMAIL
*&---------------------------------------------------------------------*
REPORT zsend_email.

TYPES: BEGIN OF ty_alicibilgileri,
         receiver TYPE so_recipient,
         rec_type  TYPE so_rec_type,
       END OF ty_alicibilgileri.

TYPES: BEGIN OF ty_mailozellikleri,
         obj_langu TYPE so_obj_langu,
         obj_name  TYPE so_obj_name,
         obj_descr TYPE so_obj_descr,
       END OF ty_mailozellikleri.

TYPES: BEGIN OF ty_mailicerigi,
         line TYPE string,
       END OF ty_mailicerigi.

DATA: gt_alicibilgileri TYPE TABLE OF ty_alicibilgileri,
      gs_alicibilgileri TYPE ty_alicibilgileri,
      gt_mailozellikleri TYPE TABLE OF ty_mailozellikleri,
      gs_mailozellikleri TYPE ty_mailozellikleri,
      gt_mailicerigi TYPE TABLE OF ty_mailicerigi,
      gs_mailicerigi TYPE ty_mailicerigi,
      gt_icerikbilgileri TYPE TABLE OF soli,
      gs_icerikbilgileri TYPE soli,
      gv_gonderen TYPE so_recipient VALUE 'sender@example.com', "Gönderen adres
      gv_text TYPE string VALUE 'Bu bir test e-postasıdır.', "Mail içeriği
      gv_subject TYPE string VALUE 'Test E-Postası', "Mail konusu
      gv_receiver TYPE so_recipient VALUE 'receiver@example.com'. "Alıcı adresi

*&---------------------------------------------------------------------*
*&      Form  SET_RECEIVER
*&---------------------------------------------------------------------*
FORM set_receiver USING p_receiver_mail.

  CLEAR gs_alicibilgileri.
  gs_alicibilgileri-receiver = p_receiver_mail.
  gs_alicibilgileri-rec_type = 'U'.
  APPEND gs_alicibilgileri TO gt_alicibilgileri.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_SUBJECT
*&---------------------------------------------------------------------*
FORM set_subject USING p_subjectname.

  CLEAR gs_mailozellikleri.
  gs_mailozellikleri-obj_langu = 'T'.
  gs_mailozellikleri-obj_name = p_subjectname.
  gs_mailozellikleri-obj_descr = p_subjectname.
  APPEND gs_mailozellikleri TO gt_mailozellikleri.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SET_BODY
*&---------------------------------------------------------------------*
FORM set_body USING p_text.

  CLEAR gs_mailicerigi.
  gs_mailicerigi-line = p_text.
  APPEND gs_mailicerigi TO gt_mailicerigi.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SEND_MAIL
*&---------------------------------------------------------------------*
FORM send_mail.

  CLEAR gs_icerikbilgileri.
  gs_icerikbilgileri-transf_bin = SPACE.
  gs_icerikbilgileri-head_start = 1.
  gs_icerikbilgileri-head_num   = 0.
  gs_icerikbilgileri-body_start = 1.

  DESCRIBE TABLE gt_mailicerigi LINES gs_icerikbilgileri-body_num.

  gs_icerikbilgileri-doc_type = 'HTM'.
  APPEND gs_icerikbilgileri TO gt_icerikbilgileri.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data                    = gs_mailozellikleri
      sender_address                   = gv_gonderen
      sender_address_type              = 'INT'
      commit_work                      = 'X'
    TABLES
      packing_list                     = gt_icerikbilgileri
      contents_txt                     = gt_mailicerigi
      receivers                        = gt_alicibilgileri
    EXCEPTIONS
      too_many_receivers               = 1
      document_not_sent                = 2
      document_type_not_exist          = 3
      operation_no_authorization       = 4
      parameter_error                  = 5
      x_error                          = 6
      enqueue_error                    = 7
      others                           = 8.

  IF sy-subrc = 0.
    WRITE: / 'Başarılı'.
  ELSE.
    WRITE: / 'Başarısız'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Start of selection
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM set_receiver USING gv_receiver.
  PERFORM set_subject USING gv_subject.
  PERFORM set_body USING gv_text.
  PERFORM send_mail.
