CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' " ALV Grid Display fonksiyon modülünü çağırır
 EXPORTING
   I_CALLBACK_PROGRAM                = sy-repid " Callback fonksiyonlarının bulunduğu programın ID'si (bu fonksiyonun hangi programda tanımlandığını belirtir)
   IS_LAYOUT                         = GS_LAYOUT " Layout işlemleri, tablo görünümünü belirler
   IT_FIELDCAT                       = GT_FIELDCALATOG " Field catalog, tablo kolonlarını ve özelliklerini tanımlar
   IT_EXCLUDING                      = gt_exclude " Status bardan istenmeyen işlemleri çıkarır
   IT_SORT                           = gt_sort " Sıralama işlemleri, tablo sıralama bilgilerini belirtir
   IT_FILTER                         = gt_filter " Filtreleme işlemleri, tablo filtreleme bilgilerini belirtir
   I_SAVE                            = 'A' " Kaydetme işlemleri: 'X' -> Genel değişim, 'U' -> Kullanıcıya özel değişim, 'A' -> Hem genel hem kullanıcıya özel değişim
   IS_VARIANT                        = gs_variant " Variant işlemleri için yapı, kaydedilen variant bilgilerini içerir
   IT_EVENTS                         = gt_events " Event yapılandırması, tablo olaylarını yönetir
   I_SCREEN_START_COLUMN             = 20 " Ekranın başlangıç kolonunu belirler, popup penceresinin başlangıç konumu
   I_SCREEN_START_LINE               = 2 " Ekranın başlangıç satırını belirler, popup penceresinin başlangıç konumu
   I_SCREEN_END_COLUMN               = 100 " Ekranın bitiş kolonunu belirler, popup penceresinin bitiş konumu
   I_SCREEN_END_LINE                 = 20 " Ekranın bitiş satırını belirler, popup penceresinin bitiş konumu
TABLES
    T_OUTTAB = gt_list " Tablo, ALV Grid Display için kullanılan tablo
          .

  * Hata kontrolü
  IF SY-SUBRC <> 0.
    * Hata işleme kodu burada eklenmelidir
  ENDIF.
