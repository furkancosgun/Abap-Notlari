*&---------------------------------------------------------------------*
*& Report ZFC_EXAMPLE_8
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_EXAMPLE_8.

*" FOR ALL ENTRIES, JOIN yapamayacağımız tablolar için kullanılır.
*" Örneğin BSEG (FI Belge Kalemi Tablosu) bir cluster tablo yapısına sahip olduğundan dolayı bu tabloya JOIN işlemi gerçekleştirilemez.
*" Bu nedenle bu tablo ile ilgili bir işlem yapılırken, FOR ALL ENTRIES kuralı kullanılır.
*" FOR ALL ENTRIES kullanırken, anahtar tablonun boş olup olmadığını kontrol etmek önemlidir.

DATA: gv_budat TYPE ekbe-budat,              " Kullanıcıdan alınacak tarih
      gt_ekbe TYPE TABLE OF ekbe WITH HEADER LINE, " EKBE tablosunun internal tablo
      gt_mseg TYPE TABLE OF mseg WITH HEADER LINE, " MSEG tablosunun internal tablo
      gt_rseg TYPE TABLE OF rseg WITH HEADER LINE. " RSEG tablosunun internal tablo

DATA: BEGIN OF s_key,
        gjahr  LIKE ekbe-gjahr,   " Yıl
        belnr  LIKE ekbe-belnr,   " Belge Numarası
        buzei  LIKE rseg-buzei,   " Kalem Numarası
      END OF s_key,
      gt_key1 LIKE TABLE OF s_key WITH HEADER LINE, " Mal Girişleri için anahtar tablosu
      gt_key2 LIKE TABLE OF s_key WITH HEADER LINE. " Fatura Girişleri için anahtar tablosu

SELECT-OPTIONS s_budat FOR gv_budat.  " Kullanıcıdan tarih aralığı al

*" EKBE tablosundan veri çekiyoruz
SELECT * FROM ekbe INTO TABLE gt_ekbe
    WHERE budat IN s_budat.

*" Anahtar Tabloları Dolduruluyor
LOOP AT gt_ekbe.
  IF gt_ekbe-vgabe EQ '1'. " Mal Girişi
    MOVE-CORRESPONDING gt_ekbe TO gt_key1.
    COLLECT gt_key1.  " Mal Girişleri için anahtar tablosuna veri ekle
  ELSEIF gt_ekbe-vgabe EQ '2'. " Fatura Girişi
    MOVE-CORRESPONDING gt_ekbe TO gt_key2.
    COLLECT gt_key2.  " Fatura Girişleri için anahtar tablosuna veri ekle
  ENDIF.
ENDLOOP.

*" Anahtar Tablo Boş mu diye kontrol ediyoruz
IF gt_key1[] IS NOT INITIAL.
  " Tüm Mal Girişleri tek bir seferde okunur
  SELECT * INTO TABLE gt_mseg FROM mseg
    FOR ALL ENTRIES IN gt_key1
    WHERE gjahr = gt_key1-gjahr
    AND mblnr = gt_key1-belnr
    AND zeile = gt_key1-buzei(4).  " Zeile uzunluğunun ilk 4 karakterini al
ENDIF.

*" Anahtar Tablo Boş mu diye kontrol ediyoruz
IF gt_key2[] IS NOT INITIAL.
  " Tüm Fatura Girişleri tek bir seferde okunur
  SELECT * INTO TABLE gt_rseg FROM rseg
    FOR ALL ENTRIES IN gt_key2
    WHERE gjahr = gt_key2-gjahr
    AND belnr = gt_key2-belnr
    AND buzei = gt_key2-buzei.
ENDIF.
