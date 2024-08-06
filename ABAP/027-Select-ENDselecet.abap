*&---------------------------------------------------------------------*
*& Report ZFC_SQL_EXAMPLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfc_sql_example.

DATA: gs_scarr TYPE scarr. " scarr adında bir yapı (structure) tanımlanır

START-OF-SELECTION.

*" scarr tablosundan veri çekme
*" Bu örnekte, tüm verileri bir döngüde işlemek için ENDSELECT yapısını kullanacağız.

SELECT * FROM scarr INTO gs_scarr.

  " Burada SELECT ENDSELECT yapısı bir döngü gibi davranır
  WRITE: / gs_scarr-carrid, gs_scarr-carrname, gs_scarr-currcode.

ENDSELECT.

*" Belirli bir şartla veri çekme
*" Örneğin, 'currcode' alanı 'EUR' olan kayıtları çekebiliriz.

SELECT * FROM scarr INTO TABLE @DATA(gt_scarr)
  WHERE currcode = 'EUR'.

  " Kayıtları işlemek için LOOP kullanılabilir
  LOOP AT gt_scarr INTO gs_scarr.
    WRITE: / gs_scarr-carrid, gs_scarr-carrname, gs_scarr-currcode.
  ENDLOOP.

*END-OF-SELECTION.
