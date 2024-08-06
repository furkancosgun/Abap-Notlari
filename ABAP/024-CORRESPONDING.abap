*&---------------------------------------------------------------------*
*& Report ZFC_SQL_YAPILARI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_SQL_YAPILARI.

*" İşlemlerde SCARR tablosu kullanılmaktadır

" Veri tanımlamaları
DATA: gt_table TYPE TABLE OF scarr, " SCARR tablosuna ait verileri tutacak iç tablo
      gs_table TYPE scarr.         " SCARR tablosundaki bir satırı tutacak yapı

*" Kendi oluşturduğumuz tipler
TYPES: BEGIN OF gty_table,
         currcode TYPE s_currcode,
         url      TYPE s_carrurl,
       END OF gty_table.

DATA: gt_table2 TYPE TABLE OF gty_table. " Oluşturduğumuz tipten bir iç tablo

START-OF-SELECTION.

" SCARR tablosundan tüm verileri gt_table iç tablosuna alır
SELECT * FROM scarr INTO TABLE gt_table.

" Eğer kolon sırası farklı ise SELECT ile veri çekme işlemi hata verebilir.
" Kolon sıralamaları uymadığında aşağıdaki kod hata verebilir.
*" SELECT currcode url FROM scarr INTO TABLE gt_table.
*" BREAK-POINT. " Kolon sıralamaları uymazsa hata verir

" Bu yapıyı düzeltmek için CORRESPONDING kullanmalıyız:
" Kolon adlarına göre veri aktarımı yapar, sıralama önemli değildir.
SELECT currcode url FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_table2.

" Kısmi seçilen kolonlar ve tam tablo seçimi arasındaki farkları görebilmek için aşağıdaki kodları kullanabilirsiniz
" SELECT * FROM scarr INTO TABLE gt_table2. " Kolon sayısı ve sırası farklı olduğu için bu hata verir
" SELECT currcode url FROM scarr INTO CORRESPONDING FIELDS OF TABLE gt_table2.
" BREAK-POINT. " Doğru veri aktarımı sağlar

" STRUCTURE'larda KULLANIM

" 2 adet yeni tip oluşturalım
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

" Oluşturduğumuz tiplerden 2 adet yapı tanımlayalım
DATA: gs_typ1 TYPE gty_type1,
      gs_typ2 TYPE gty_type2.

" gs_typ1 yapı değerlerini dolduralım
GS_TYP1-COL1 = 'aaaa'.
GS_TYP1-COL2 = 'bbbb'.
GS_TYP1-COL3 = 'cccc'.
GS_TYP1-COL4 = 'dddd'.

" gs_typ2 yapısına gs_typ1'den veri aktarma
" Bu işlem tipler arasındaki kolon sıralamaları uyumlu olmadığı için doğru çalışmaz.
*" gs_typ2 = GS_TYP1. " Yanlış atama, kolon sıralamaları uymuyor
" BREAK-POINT.

" Bu hatayı düzeltmek için MOVE-CORRESPONDING kullanmalıyız
" MOVE-CORRESPONDING kullanımı kolon adlarına göre veri aktarımı yapar, sıraya göre değil
MOVE-CORRESPONDING GS_TYP1 TO GS_TYP2.
" BREAK-POINT. " Doğru veri aktarımı sağlar

