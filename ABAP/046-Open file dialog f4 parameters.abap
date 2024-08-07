PARAMETERS: p_file LIKE rlgrap-filename DEFAULT 'C:\'. " Varsayılan dosya yolu 'C:' olarak belirlenmiş

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file. " p_file parametresinde değer arama yardımcısına tıklanınca çalışır

  CALL FUNCTION 'WS_FILENAME_GET' " Dosya seçme penceresini açar
    EXPORTING
      def_path = p_file " Varsayılan dosya yolu
      mask     = '*.txt' " Dosya uzantısı filtresi (örneğin, sadece .txt dosyaları)
      mode     = '0' " Dosya seçme modu
      title    = 'Choose File' " Pencere başlığı
    IMPORTING
      filename = p_file " Seçilen dosyanın adı
    EXCEPTIONS
      inv_winsys       = 1 " Windows sistemi ile ilgili bir hata
      no_batch         = 2 " Batch işleme yapılması gerekiyorsa ancak yapılamıyorsa
      selection_cancel = 3 " Kullanıcı seçim yapmadan pencereyi kapattığında
      selection_error  = 4 " Seçim yapılırken bir hata oluştuğunda
      others           = 5. " Diğer hatalar

  IF sy-subrc <> 0. " Eğer işlem sırasında hata oluşmuşsa
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno. " Hata mesajını göster
  ENDIF.
