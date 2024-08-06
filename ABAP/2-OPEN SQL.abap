" Domain nedir: Teknik yapısal özellikler bulunur
" Data element nedir: Daha anlamsal özellikler bulunur, veri tipi vs.

" Variable oluşturma
DATA: gv_person_id TYPE int4,    " ID veri elemanı
      gv_person_name TYPE char30,  " Ad veri elemanı
      gv_person_surname TYPE char30, " Soyad veri elemanı
      gv_person_gender TYPE char1,  " Cinsiyet veri elemanı
      gs_person TYPE TableName,           " Structure tanımlama (n kolonu referans alır)
      gt_person TYPE TABLE OF TableName. " Tablo tanımlama

" Verileri tabloya seçme
SELECT * FROM tableName INTO TABLE gt_person.

" Structure: Tabloların tek bir satırını tutan yapı
" Structure verilerini tutma
SELECT SINGLE * FROM tableName INTO gs_person.

" Tek bir sütunu almak
SELECT SINGLE tableColumnName FROM tableName INTO columnValue.

" Where yapısı ile veri seçme
SELECT SINGLE * FROM tableName INTO gs_person WHERE columnName EQ value.

" Structure veri eklemek
gs_person-columnName = 3.
gs_person-columnName = 'furkan'.

" Veriyi tabloya ekleme
INSERT tableName FROM gs_person.

" Update ve delete komutları normal SQL komutları ile aynıdır
" Modify komutu: Eğer structure içindeki key'e sahip bir değer varsa update yapar, yoksa insert işlemi yapar
MODIFY tableName FROM gs_person.
