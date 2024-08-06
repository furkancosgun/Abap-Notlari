*&---------------------------------------------------------------------*
*& Report ZFC_SQL_YAPILARI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_SQL_YAPILARI.

" işlemlerde scarr tablosu kullanılmaktadır

" İç tablo ve değişken tanımlamaları
DATA: gt_table TYPE TABLE OF scarr,  " scarr tablosuna ait verileri tutacak iç tablo
      gs_table TYPE scarr,          " scarr tablosundaki tek bir satırı tutacak yapı
      gv_currcode TYPE S_CURRCODE. " currcode kolonunun değerini saklayacak değişken

START-OF-SELECTION.

" Tüm satırları al ve iç tabloya ata
* SELECT * FROM scarr INTO TABLE gt_table WHERE CARRID = 'AC'.
* scarr tablosundan CARRID = 'AC' olan tüm satırları gt_table iç tablosuna alır

" İlk satırı oku ve yazdır
* READ TABLE gt_table INTO gs_table INDEX 1.
* gt_table iç tablosundaki ilk satırı gs_table yapısına okur
* WRITE gs_table.
* gs_table yapısındaki veriyi ekrana yazar

" İlk 5 satırı al ve iç tabloya ata
* SELECT * UP TO 5 ROWS FROM scarr INTO TABLE gt_table.
* scarr tablosundan ilk 5 satırı gt_table iç tablosuna alır

" Tek bir satırı oku ve yazdır
* READ TABLE gt_table INTO gs_table INDEX 1.
* gt_table iç tablosundaki ilk satırı gs_table yapısına okur

" Tek bir satır verisi al
* SELECT SINGLE * FROM scarr INTO gs_table.
* scarr tablosundan sadece bir satırı gs_table yapısına alır

" Tek bir kolon değeri al
* SELECT SINGLE currcode FROM scarr INTO gv_currcode.
* scarr tablosundan sadece currcode kolonunun değerini gv_currcode değişkenine alır

" Alınan değeri ekrana yazdır
WRITE gv_currcode.
