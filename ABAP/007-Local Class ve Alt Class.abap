CLASS math_op DEFINITION. " Kullanılacak veri veya metodlar tanımlanır.

  PUBLIC SECTION. " Erişilebilirlik türü
    DATA: lv_num1 TYPE i,
          lv_num2 TYPE i,
          rv_result TYPE i.
  
    METHODS: sum_numbers. " Methodlar

ENDCLASS.

CLASS math_op IMPLEMENTATION. " Veri ve metod kodlaması yapılır

  METHOD sum_numbers.
    rv_result = lv_num1 + lv_num2. " Public olarak erişilen parametreler
  ENDMETHOD.

ENDCLASS.

" Alt class oluşturma
" Kalıtım alma işlemi yapılır
" CLASS class_name DEFINITION INHERITING FROM parent_class_name
CLASS math_op_diff DEFINITION INHERITING FROM math_op.

  PUBLIC SECTION.
    METHODS: numb_diff. " Kalıtım aldığımız için tekrar veri oluşturmaya gerek yoktur, önceki class'ın verilerini kullanabiliriz

ENDCLASS.

CLASS math_op_diff IMPLEMENTATION. " Class'ı işlevsel hale getirmek için implementasyon yapılır

  METHOD numb_diff.
    rv_result = lv_num1 - lv_num2. " Kalıtım aldığımız verileri kullanır
  ENDMETHOD.

ENDCLASS.

" Oluşturulan class'ı kullanma

" İki adet değişken ve iki class'ı referans verdik
DATA: go_math_op TYPE REF TO math_op,
      go_math_op_diff TYPE REF TO math_op_diff.

START-OF-SELECTION. " Programın başlamasıyla
  CREATE OBJECT go_math_op. " Objeleri yaratıyoruz
  CREATE OBJECT go_math_op_diff.

  go_math_op->lv_num1 = 10. " İlk değişkeni, yani class'ımızın parametrelerini verdik
  go_math_op->lv_num2 = 30.
  go_math_op->sum_numbers( ). " Methodumuzu çalıştırdık

  WRITE: go_math_op->rv_result. " Write komutu ile class içindeki public sonuç değişkenini yazdırdık

  go_math_op_diff->lv_num1 = 10. " Aynı işlemleri ikinci class içinde gerçekleştirdik
  go_math_op_diff->lv_num2 = 90.
  go_math_op_diff->numb_diff( ).
  WRITE: go_math_op_diff->rv_result.

" Encapsulation: Erişilebilirlik sınırlama

CLASS enc_op DEFINITION.

  PUBLIC SECTION. " Her yerden erişilebilir
    DATA: lv_ad TYPE string,
          lv_soyad TYPE string.
  
  PROTECTED SECTION. " Sadece kalıtım alan ve bu class'ta kullanılabilir
    DATA: lv_baba_ad TYPE string.
  
  PRIVATE SECTION. " Sadece bu class'ta kullanılabilir
    DATA: lv_yas TYPE i.

ENDCLASS.
