* Internal tablonun tanımlanması
TYPES: BEGIN OF ty_example,
         field1 TYPE c LENGTH 10,
         field2 TYPE i,
       END OF ty_example.

* Standart iç tablo tanımlaması
DATA: lt_standard TYPE TABLE OF ty_example WITH EMPTY KEY.

* Sıralı iç tablo tanımlaması
DATA: lt_sorted TYPE SORTED TABLE OF ty_example
               WITH UNIQUE KEY field1.

* Karışık iç tablo tanımlaması
DATA: lt_hashed TYPE HASHED TABLE OF ty_example
               WITH UNIQUE KEY field1.

* İç tabloya veri ekleme
DATA: ls_example TYPE ty_example.

* Standart tabloya veri ekleme
ls_example-field1 = 'Data1'.
ls_example-field2 = 10.
INSERT ls_example INTO TABLE lt_standard.

* Sıralı tabloya veri ekleme
ls_example-field1 = 'Data2'.
ls_example-field2 = 20.
INSERT ls_example INTO TABLE lt_sorted.

* Karışık tabloya veri ekleme
ls_example-field1 = 'Data3'.
ls_example-field2 = 30.
INSERT ls_example INTO TABLE lt_hashed.

* İç tablodan veri okuma (READ TABLE)
DATA: lv_field2 TYPE i.

READ TABLE lt_standard INTO ls_example WITH KEY field1 = 'Data1'.
IF sy-subrc = 0.
  lv_field2 = ls_example-field2.
ENDIF.

* İç tablodan veri döngüsü (LOOP AT)
LOOP AT lt_sorted INTO ls_example.
  WRITE: / ls_example-field1, ls_example-field2.
ENDLOOP.

* İç tablodan veri arama (FIND IN TABLE)
DATA: lv_index TYPE sy-tabix.

FIND FIRST OCCURRENCE OF 'Data2'
  IN TABLE lt_standard
  MODE CHARACTER
  RESULT INDEX lv_index.

* İç tablodan veri değiştirme (MODIFY)
READ TABLE lt_sorted INTO ls_example WITH KEY field1 = 'Data2'.
IF sy-subrc = 0.
  ls_example-field2 = 99.
  MODIFY lt_sorted INDEX sy-tabix OF ls_example.
ENDIF.

* İç tablodan veri silme (DELETE)
DELETE lt_hashed WHERE field1 = 'Data3'.

* İç tabloyu sıralama (SORT)
SORT lt_sorted BY field1 ASCENDING.

* İç tabloyu temizleme (CLEAR)
CLEAR lt_standard.  " Sadece başlık satırı temizlenir

* İç tabloyu tamamen boşaltma (REFRESH)
REFRESH lt_standard.  " İçerik temizlenir

* İç tablonun hafızasını serbest bırakma (FREE)
FREE lt_standard.  " Hafıza serbest bırakılır

* İç tablodaki bilgi alma (DESCRIBE TABLE)
DATA: lv_lines TYPE i,
      lv_width TYPE i.

DESCRIBE TABLE lt_standard LINES lv_lines.
DESCRIBE TABLE lt_standard LINES lv_lines WIDTH lv_width.

* Aynı değerli ardışık kayıtları silme (DELETE ADJACENT DUPLICATE ENTRIES)
DELETE ADJACENT DUPLICATE ENTRIES FROM lt_standard COMPARING ALL FIELDS.

