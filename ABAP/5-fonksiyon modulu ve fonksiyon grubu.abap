" Function Module: Belli bir amaca hizmet eden yapıyı, bir alanda toplayıp istenildiği zaman erişilen yapı
" Function Group: Fonksiyonların gruplanıp bir başlık altında toplanması

" Fonksiyon grubu oluşturmak için SE80 t-kodu ile function group oluşturulup ad verilip aktif edilir

" Function Module oluşturmak:
" SE37: Fonksiyon modülü oluşturma t-kodu
" Fonksiyon adı verilir
" Create ile oluşturulur
" Tanım ve fonksiyon grubu değerleri verilir

" Fonksiyon modülünü tanımak:
" Attributes: Özellikler
" Import: Fonksiyona verilecek parametreler
" Export: Fonksiyonun bize döndüreceği parametreler
" Changing: Bir değer alıp o değeri değiştirip veren yapılar
" Tables: Fonksiyona verilecek tablolar
" Exceptions: Hata alınan veya öngörülen durumlar
" Source code: Fonksiyonun ne yapacağını gireceğimiz alan

" Örnek Fonksiyon
" İki input alır, int birini diğerine böler ve return eder

" 1- Import kısmından parametreler verilir
" iv_num1 TYPE i4 -> Import kısmına sırasıyla yapılır
" iv_num2 TYPE i4 -> Import kısmına sırasıyla yapılır

" 2- Export kısmı
" ev_result TYPE i4 -> Export kısmına aynı şekilde yapılır

" 3- Changing
" cv_message TYPE c LENGTH 20 -> Mesaj eklemek için ekledik

" 4- Source code kısmına gelinir

FUNCTION func_name.

  ev_result = iv_num1 / iv_num2.

ENDFUNCTION.

" Pass by value alanları kapalıysa fonksiyon parametrelerinin gelen değeri fonksiyon içinde değiştirilmesine izin vermez

" Optional = Eklenmesi zorunlu olmayan parametre

" Eğer exception kullanmak istersek:
" Exception kısmına hata adı girilir ve açıklaması yazılır

" Source code kısmına tekrar gelinir
FUNCTION func_name.

* if iv_num1 eq 0. "0'a eşitse *
IF iv_num1 IS INITIAL. " Eğer herhangi bir değer ataması yapılmadıysa
  RAISE exception_name. " Exception çağırma
ENDIF.

ENDFUNCTION.

" Fonksiyon modülünü kullanmak

" START-OF-SELECTION: Her zaman kullanılması tavsiye edilir. Öncesinde değişken atamaları, sonrasında değer atamaları vs. yapılabilir

REPORT reportName.

DATA: gv_num1 TYPE i4,
      gv_num2 TYPE i4,
      gv_result TYPE i4,
      gv_message TYPE c LENGTH 20.

START-OF-SELECTION.
  gv_num1 = 20.
  gv_num2 = 5.
  gv_message = 'Message1'.

  CALL FUNCTION 'functionName' " SAP ekrandan örnek (pattern) kısmından fonksiyon modülü adı eklenir ve 
                               " OK denir, fonksiyon parametreleri ve exception'lar otomatik doldurulması için gelir
    EXPORTING
      iv_num1 = gv_num1
      iv_num2 = gv_num2
    IMPORTING
      ev_result = gv_result
    CHANGING
      cv_message = gv_message
    EXCEPTIONS
      divided_by_zero = 1
      others = 2.

  IF sy-subrc = 0. " Değer sıfıra eşitse hata yok demektir
    WRITE: / 'Result: ', gv_result.
    WRITE: / 'Message: ', gv_message.
  ELSEIF sy-subrc = 1.
    WRITE: 'Cannot divide by zero'.
  ENDIF.
