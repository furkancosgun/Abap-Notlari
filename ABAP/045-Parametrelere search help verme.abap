PARAMETERS p_carrid TYPE scarr-carrid. " Kullanıcıdan Carrier ID alacak bir parametre oluşturma

DATA: gt_list       TYPE TABLE OF scarr, " Search help için veri tablosu
      gs_list       TYPE scarr, " Search help'de gösterilecek satır
      gt_return_tab TYPE TABLE OF ddshretval, " Kullanıcının seçtiği değerleri döndüren tablonun veri türü
      gs_return_tab TYPE dselc, " Kullanıcının seçtiği değerin veri türü
      gs_mapping    TYPE dselc. " Mapping (eşleme) için veri türü

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_carrid. " p_carrid alanında arama yardımı tetiklenince çalışır

  SELECT * FROM scarr INTO TABLE gt_list. " SCARR tablosundaki tüm verileri gt_list tablosuna al

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST' " Arama yardımcısını başlatma
    EXPORTING
      retfield     = 'CARRID' " Arama sonucunda dönecek alan, bu örnekte 'CARRID'
      dynpprog     = sy-repid " Programın adı (geçerli programın ID'si)
      dynpnr       = sy-dynnr " Ekran numarası (geçerli ekranın numarası)
      dynprofield  = 'P_CARRID' " Parametre adı (arama yardımcısının hangi alanda gösterileceği)
      window_title = 'Search help' " Arama yardımcısının başlığı
      value_org    = 'S' " Verinin yapısı (S: structure, C: cell)
    TABLES
      value_tab    = gt_list " Arama yardımcısında görünecek değerler
      return_tab   = gt_return_tab. " Kullanıcının seçtiği değerler

  " Kodun devamında seçilen değeri işlemek için gereken kod eklenebilir

