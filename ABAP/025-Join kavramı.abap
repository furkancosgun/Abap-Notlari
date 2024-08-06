*&---------------------------------------------------------------------*
*& Report ZFC_SQL_YAPILARI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_SQL_YAPILARI.

*" İşlemlerde scarr tablosu kullanılmaktadır
*" Aşağıda farklı SQL işlemlerinin örnekleri gösterilmektedir.

DATA: gt_table     TYPE TABLE OF scarr,     " scarr tablosuna ait veri tutacak internal tablo
      gs_table     TYPE scarr,              " scarr tablosuna ait bir satırı tutacak yapı
      gv_currcode  TYPE S_CURRCODE.        " scarr tablosundan sadece currcode değerini tutacak değişken

*" Kendi oluşturacağımız tip üzerinde deneyelim
TYPES: BEGIN OF gty_table,
         currcode TYPE s_currcode, " scarr tablosundaki currcode alanı
         url      TYPE s_carrurl,  " scarr tablosundaki url alanı
       END OF gty_table.

DATA: gt_table2 TYPE TABLE OF gty_table.  " Oluşturduğumuz tipten bir tablo

START-OF-SELECTION.

*" 1. INNER JOIN Örneği
  " Bu sorguda, scarr ve spfli tabloları birleştirilir ve her iki tablodaki eşleşen kayıtlar getirilir.
  SELECT * 
  FROM scarr AS t1
  INNER JOIN spfli AS t2
  ON t1.carrid = t2.carrid
  INTO TABLE @DATA(inner_join_result).

*" 2. LEFT JOIN Örneği
  " Bu sorguda, scarr tablosundaki tüm kayıtlar ve spfli tablosundaki eşleşen kayıtlar getirilir.
  " Eşleşmeyen kayıtlar NULL olarak döner.
  SELECT * 
  FROM scarr AS t1
  LEFT JOIN spfli AS t2
  ON t1.carrid = t2.carrid
  INTO TABLE @DATA(left_join_result).

*" 3. RIGHT JOIN Örneği
  " Bu sorguda, spfli tablosundaki tüm kayıtlar ve scarr tablosundaki eşleşen kayıtlar getirilir.
  " Eşleşmeyen kayıtlar NULL olarak döner.
  SELECT * 
  FROM scarr AS t1
  RIGHT JOIN spfli AS t2
  ON t1.carrid = t2.carrid
  INTO TABLE @DATA(right_join_result).
  

*" 4. FULL OUTER JOIN (ABAP'ta doğrudan desteklenmiyor, alternatif yöntem)
  " Bu örnekte FULL OUTER JOIN simüle edilir. Sol ve sağ tablo sonuçları birleştirilir.
  SELECT * 
  FROM scarr AS t1
  LEFT JOIN spfli AS t2
  ON t1.carrid = t2.carrid
  INTO TABLE @DATA(left_join_temp).

  SELECT * 
  FROM scarr AS t1
  RIGHT JOIN spfli AS t2
  ON t1.carrid = t2.carrid
  INTO TABLE @DATA(right_join_temp).

  APPEND LINES OF left_join_temp TO right_join_temp.
  

*" 5. SELECT SINGLE Örneği
  " Tek bir kayıt getirir. Genellikle belirli bir koşula göre tek bir satırı almak için kullanılır.
  SELECT SINGLE currcode 
  FROM scarr 
  INTO @gv_currcode 
  WHERE carrid = 'AC'.
  
  WRITE: / 'SELECT SINGLE Result:', 
         / 'CURRCODE'.
  WRITE: / gv_currcode.

*" 6. SELECT WITH UP TO ROWS Örneği
  " Belirtilen sayıda kayıt getirir. Genellikle ilk birkaç kayıt için kullanılır.
  SELECT * 
  FROM scarr 
  INTO TABLE @DATA(up_to_rows_result) 
  UP TO 5 ROWS.

*" 7. MOVE-CORRESPONDING Kullanımı
  " Bir yapıdaki değerleri, kolon adlarına göre başka bir yapıya taşır, sıraya göre değil.
  TYPES: BEGIN OF gty_type1,
           col1 TYPE char10,
           col2 TYPE char10,
           col3 TYPE char10,
           col4 TYPE char10,
         END OF gty_type1.

  TYPES: BEGIN OF gty_type2,
           col2 TYPE char10,
           col3 TYPE char10,
         END OF gty_type2.

  DATA: gs_typ1 TYPE gty_type1,
        gs_typ2 TYPE gty_type2.

  gs_typ1-col1 = 'aaaa'.
  gs_typ1-col2 = 'bbbb'.
  gs_typ1-col3 = 'cccc'.
  gs_typ1-col4 = 'dddd'.

  MOVE-CORRESPONDING gs_typ1 TO gs_typ2.

