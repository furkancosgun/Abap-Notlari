" Event blocks: Program akışını düzenlemek için kullanılan keywordlerdir.
" İlk açılış, kullanıcı girişinden önce çalışacak kodlar gibi yaşam döngüsü bloklarıdır.

" 1. Initialization: User input parametrelerinden önce çalışmasını istediğimiz kodlar
" 2. At selection-screen: Input parametrelerini özelleştiren yapı
" 3. Start-of-selection: Program çalıştığında çalışan kod
" 4. End-of-selection: Formları kullanacağımız yapı

PARAMETERS: p_num TYPE i. " Parametre alan yapı oluşturur

INITIALIZATION.
  " Input parametresi gelmeden önce çalışır, input içine değer atar
  p_num = 12.

AT SELECTION-SCREEN.
  " Input parametresine her girildiğinde çalışır
  p_num = p_num + 1.

START-OF-SELECTION.
  " Rapor çalıştırıldığında hemen çalışır
  WRITE: 'Start of selection'.

END-OF-SELECTION.
  " Uygulama çalışma işlemi bitince çalışır
  WRITE: 'End of selection'.

" Form: Fonksiyon anlamına gelir
DATA: gv_num1 TYPE i.

INITIALIZATION.

AT SELECTION-SCREEN.

START-OF-SELECTION.
  PERFORM increment_number. " Daha sonra forma (fonksiyona) erişmek için perform keyword'ü kullanılır
  WRITE: gv_num1.
  PERFORM multiply_two_numbers USING 5 5.
END-OF-SELECTION.

" Form oluşturma
" Form {form_name} USING {parameters} şeklinde devam eder
FORM increment_number.
  gv_num1 = gv_num1 + 1.
ENDFORM.

" Parametre alan form (Fonksiyon)
FORM multiply_two_numbers USING p_num1 p_num2.
  DATA: lv_result TYPE i.

  lv_result = p_num1 * p_num2.

  WRITE: lv_result.
ENDFORM.
