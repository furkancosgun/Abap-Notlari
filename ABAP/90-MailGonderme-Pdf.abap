
FORM send_teklif_mail USING ls_ekko TYPE ekko
                            lv_sender type adr6-smtp_addr
                            p_lt_rows       TYPE lvc_t_row.
TYPES:BEGIN OF lt_y,
          lifnr TYPE lifnr,
          spras TYPE spras,
        END OF lt_y.

      DATA: lo_send_request   TYPE REF TO cl_bcs VALUE IS INITIAL,
          lt_message_body   TYPE bcsy_text VALUE IS INITIAL,
          lo_document       TYPE REF TO cl_document_bcs VALUE IS INITIAL,
          lv_sent_to_all(1) TYPE c VALUE IS INITIAL,
          lx_document_bcs   TYPE REF TO cx_document_bcs VALUE IS INITIAL,
          lo_sender         TYPE REF TO if_sender_bcs VALUE IS INITIAL,
          lo_recipient      TYPE REF TO if_recipient_bcs VALUE IS INITIAL.

    DATA: ls_fm_name         TYPE rs38l_fnam,
*          ls_formname        TYPE fpname VALUE 'ZMM_AF_SAS',
          ls_formname        TYPE fpname,
          ls_fp_docparams    TYPE sfpdocparams,
          ls_fp_formoutput   TYPE fpformoutput,
          ls_fp_outputparams TYPE sfpoutputparams,
          lt_att_content_hex TYPE solix_tab,
          lp_pdf_size        TYPE so_obj_len.

  DATA: lt_item TYPE TABLE OF lt_y.

  SELECT
    ekko~lifnr
    lfa1~spras
  FROM lfa1
  INNER JOIN ekko ON ekko~lifnr =  lfa1~lifnr
  INTO CORRESPONDING FIELDS OF TABLE lt_item
  WHERE ekko~ebeln = ls_ekko-ebeln.

  READ TABLE lt_item INTO DATA(ls_temp) WITH KEY spras = 'TR'.

  IF sy-subrc EQ 0.
   ls_formname = 'ZMM_AF_TEKLIF'.

  ELSE.
   ls_formname = 'ZMM_AF_TEKLIF_EN'.

  ENDIF.

            CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
              EXPORTING
                i_name     = ls_formname
              IMPORTING
                e_funcname = ls_fm_name.

            ls_fp_outputparams-nodialog = 'X'.
            ls_fp_outputparams-getpdf   = 'X'.

            CALL FUNCTION 'FP_JOB_OPEN'
              CHANGING
                ie_outputparams = ls_fp_outputparams
              EXCEPTIONS
                cancel          = 1
                usage_error     = 2
                system_error    = 3
                internal_error  = 4
                OTHERS          = 5.

.

            CALL FUNCTION ls_fm_name
              EXPORTING
                /1bcdwb/docparams  = ls_fp_docparams
*               IT_TEXT            = IT_TEXT
                it_item            = lt_teklifitem
                is_header          = ls_teklif
              IMPORTING
                /1bcdwb/formoutput = ls_fp_formoutput
              EXCEPTIONS
                usage_error        = 1
                system_error       = 2
                internal_error     = 3
                OTHERS             = 4.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ENDIF.

            CALL FUNCTION 'FP_JOB_CLOSE'
              EXCEPTIONS
                usage_error    = 1
                system_error   = 2
                internal_error = 3
                OTHERS         = 4.

************ Mail G??nderimi
            APPEND 'Merhaba,' TO lt_message_body.
            APPEND ' ' TO lt_message_body.
            APPEND |{ ls_ekko-ebeln } numaral?? sat??nalma sipari??i olu??turulmu??tur. Sipari??in size ula??t??????na dair teyidinizi rica ederiz.| TO lt_message_body.
            APPEND ' ' TO lt_message_body.
            APPEND ' ' TO lt_message_body.
            APPEND 'Genel Ko??ullar:' TO lt_message_body.
            APPEND '1. Taraflarca aksine ve resmi bir karar al??nmad?????? s??rece al??mlar??m??z burada belirtilen ??artlara tabi olacakt??r.' &&
                   ' ??hlal nedeniyle ortaya ????kabilecek herhangi bir hasardan mal?? veya hizmeti tedarik eden sat??c??lar??, sorumlu tutma hakk??m??z mahfuzdur.' TO lt_message_body.
            APPEND '2. Herbir sipari??in al??nd??????na dair yaz??l?? teyit, tebli??i m??teakip 3 (????) i?? g??n??d??r. Aksi takdirde sipari??imizde belirtilen ??artlar ge??erlidir.' TO lt_message_body.
            APPEND '3. Bir sipari??in kabul??, sat??c??y?? teslim tarihleri a????s??ndan gayrikabilir??cu ??ekilde ba??lar. S??zkonusu teslim' &&
                   ' tarihlerine ili??kin ??artlar sadece mal??n istenildi??i ??ekilde, istenen yerde tesliminden ve i??in ??stenildi??i ??ekilde tesliminden ibaret olmay??p; ' TO lt_message_body.
            APPEND ' sipari?? ve ekinde belirtilen t??m teknik, idari ve mali vesaikin teslimini de i??erir.' TO lt_message_body.
            APPEND '4. Bu formda belirtilen fiyatlar kesin olarak m??talaa edilecektir.' TO lt_message_body.
            APPEND '5. Mallar??n uygun bi??imde korunmas?? ??artt??r. Yetersiz ambalajlama ve uygunsuz y??kleme nedeniyle olu??abilecek hasarlardan sat??c??y?? sorumlu tutma hakk??m??z mahfuzdur.' TO lt_message_body.
            APPEND '6. Mal??n var??????n?? m??teakip en k??sa zamanda kontrol edildi??i ger??e??ini g??z??n??nde bulundurarak; ??ikayetlerimizi bildirmek' &&
                   ' konusunda belirli bir tarih s??zkonusu olamaz. ??irketimizin yaz??l?? onay??na kadar, sat??c??n??n garantisi ge??erlili??ini korur.' TO lt_message_body.
            APPEND '7. Kullan??m esnas??nda hatal?? oldu??u anla????lan mallar??n yerine, ??cretsiz olarak ve en k??sa zaman i??erisinde yenilerinin g??nderilmesini ' &&
                   'talep etme keyfiyetini veya teslim tarihi ile hatan??n anla????ld?????? tarih aras??ndaki s??renin uzunlu??una bak??lmaks??z??n' TO lt_message_body.
            APPEND ' fatura miktarlar??n??n hesab??m??za alacak kaydedilmesini isteme hakk??m??z sakl??d??r.' TO lt_message_body.
            APPEND '8. Fatura ve irsaliye ??zerine bu formda belirtilen Sat??nalma Sipari?? Numaras??n??n yaz??lmas?? zorunludur. Sat??nalma Sipari?? numaras?? yaz??l??' &&
                   'olmayan faturalar kabul edilmeyip, faturan??n nevine g??re ya reddedilecek ya da iade faturas?? kesilecektir.' TO lt_message_body.

            DATA(lv_ebeln_t) = |{ ls_ekko-ebeln } Numaral?? Sipari?? Hk./ ABC Deterjan |.
            DATA(lv_ebeln_t1) = |{ ls_ekko-ebeln } Numaral?? Sipari?? Mektubu |.
            DATA: lv_sood_objdes TYPE sood-objdes,
                  lv_so_obj_des  TYPE so_obj_des.
            lv_sood_objdes = lv_ebeln_t1.
            lv_so_obj_des = lv_ebeln_t.

            lo_document = cl_document_bcs=>create_document(
              i_type    = 'RAW'
              i_text    = lt_message_body
              i_subject = lv_so_obj_des ).

            CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
              EXPORTING
                buffer     = ls_fp_formoutput-pdf
              TABLES
                binary_tab = lt_att_content_hex.

            lo_document->add_attachment(
              EXPORTING
                i_attachment_type    = 'pdf'
                i_attachment_subject = lv_sood_objdes
                i_att_content_hex    = lt_att_content_hex ).

            lo_send_request = cl_bcs=>create_persistent( ).
            lo_send_request->set_document( lo_document ).
*          lo_sender = cl_cam_address_bcs=>create_internet_address( 'sap@abc.com.tr' ).
            lo_sender = cl_cam_address_bcs=>create_internet_address( lv_sender ).
            lo_send_request->set_sender(
              EXPORTING
                i_sender = lo_sender ).

            LOOP AT p_lt_rows INTO DATA(ls_rows).
              READ TABLE gt_mail INTO DATA(ls_mail) INDEX ls_rows.
              lo_recipient = cl_cam_address_bcs=>create_internet_address( ls_mail-smtp_addr ).
              lo_send_request->add_recipient(
                EXPORTING
                  i_recipient = lo_recipient
                  i_express   = 'X' ).
            ENDLOOP.

            " CC mail adresleri
            SELECT smtp_addr FROM zmm_t_mail_bakim
              INTO TABLE @DATA(lt_cc)
              WHERE ekgrp EQ @ls_ekko-ekgrp
                AND zzsas EQ 'X'.

            IF ls_ekko-ekorg EQ 'S002'.
              APPEND INITIAL LINE TO lt_cc ASSIGNING FIELD-SYMBOL(<lfs_cc>).
*            <lfs_cc>-smtp_addr = 'abcoperations@abc.com.tr'.
              <lfs_cc>-smtp_addr = lv_sender.
            ENDIF.

            LOOP AT lt_cc INTO DATA(ls_cc).
              lo_recipient = cl_cam_address_bcs=>create_internet_address( ls_cc-smtp_addr ).
              lo_send_request->add_recipient(
                EXPORTING
                  i_recipient = lo_recipient
                  i_copy      = 'X'
                  i_express   = 'X' ).
            ENDLOOP.

            lo_send_request->set_send_immediately( 'X' ).
            lo_send_request->send( ).
            COMMIT WORK.
            MESSAGE 'Sat??nalma sipari??i formu ekli olarak ilgili adreslere g??nderilmi??tir' TYPE 'I'.
ENDFORM.
