  METHOD if_ex_me_process_po_cust~check.

    DATA: lt_list       TYPE TABLE OF zmm_blg_tur,
          ls_list       LIKE LINE OF lt_list,
          ls_header     TYPE mepoheader,
          lt_items      TYPE purchase_order_items,
          ls_items      LIKE LINE OF lt_items,
          ls_items_data TYPE mepoitem,
          lv_banfn      TYPE ekpo-banfn.

    ls_header = im_header->get_data( ).�Ba�l�k verilerini al�r
    lt_items = im_header->get_items( ).�Kalem verilerini al�r obje doner

    SELECT * FROM zmm_blg_tur INTO TABLE lt_list.�Bak�m tablosuna select at�l�r

    READ TABLE lt_list INTO ls_list WITH KEY bsart = ls_header-bsart.
�Bak�m tablosu okunarak bsart de�eri girilen ba�l�k verilerinin i�inde ki bsarta e�itse
 
    IF sy-subrc EQ 0.�loopa girer
�Kalem verilerinin i�inde d�nerek her objeyi ls_items i�ine atar
      LOOP AT lt_items INTO ls_items.
�ls_items objesinin item alan�n�n get data methodu kullan�larak
�Kalem verileri ls_items_data strcutrr�na at�l�r

        CALL METHOD ls_items-item->get_data
          RECEIVING
            re_data = ls_items_data.

�Kalem verileri i�inde banfn alan�(SAT) bo� ise
        IF ls_items_data-banfn IS INITIAL.
�mesaj olarak sat referans� olmadan sipari� a��lmaz mesajo bastr�l�r
          MESSAGE e002(zmm).
          "SAT referans� olmadan sipari� a��lamaz!
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.


  ENDMETHOD.
