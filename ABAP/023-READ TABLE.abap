*&---------------------------------------------------------------------*
*& Report ZFC_SQL_YAPILARI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_SQL_YAPILARI.

" İşlemlerde SCARR tablosu kullanılmaktadır

" Veri tanımlamaları
DATA: gt_table TYPE TABLE OF scarr, " SCARR tablosuna ait verileri tutacak iç tablo
      gs_table TYPE scarr,         " SCARR tablosundaki bir satırı tutacak yapı
      gv_currcode TYPE S_CURRCODE. " Tablodaki currcode kolonunun değerini saklayacak değişken

START-OF-SELECTION.

" SCARR tablosundaki tüm verileri gt_table iç tablosuna alır
SELECT * FROM scarr INTO TABLE gt_table.

" Belirli bir şart ile iç tablodan veri okuma
" Aşağıdaki yorumlanmış kod örnekleri, `READ TABLE` kullanılarak nasıl filtreleme yapılabileceğini gösterir.

" Aşağıdaki kod, `carrid` değeri 'AZ' olan satırı iç tablodan okur
*"READ TABLE gt_table INTO gs_table WITH KEY carrid = 'AZ'.
" Eğer `sy-subrc` ile kontrol edilmek istenirse, `sy-subrc` 1 dönerse şartı sağlayan kayıt bulunamamıştır.
" Eğer şartı sağlayan birden fazla kayıt varsa, `sy-subrc` 1 dönebilir.

" Aşağıdaki kod, `carrname` değeri 'Air Canada' olan satırı iç tablodan okur
*"READ TABLE gt_table INTO gs_table WITH KEY carrname = 'Air Canada'.

" Birden fazla şart ekleme
" Şartlar arasında otomatik olarak AND ilişkilendirmesi yapılır, bu yüzden tüm şartlar sağlanmalıdır.
*"READ TABLE gt_table INTO gs_table WITH KEY carrname = 'Air Canada' "carrname değerinin 'Air Canada' olması
*                                  currcode = 'EUR'. "currcode değerinin 'EUR' olması

" `READ TABLE` yalnızca `EQ` (eşit) mantığını destekler. Küçükten büyüğe veya büyükten küçüğe sıralama yapılmaz.

" `currcode` değeri 'EUR' olan tüm satırlar üzerinde gezinir ve yazdırır
LOOP AT gt_table INTO gs_table WHERE currcode = 'EUR'.
  WRITE gs_table.
ENDLOOP.
