" SE24: Class veya Interface oluşturma t-kodu

" Class içinde methods kısmı, fonksiyon modülü anlamına gelir
" Methods kısmından methodlar oluşturulur; parametreleri vs. her şeyi aynı panel üzerinden verip değiştirebiliriz

" Oluşturulan class'ı kullanma

DATA: gv_class TYPE REF TO className. " Class'ı referans alan değişken

START-OF-SELECTION.
  CREATE OBJECT gv_class. " Değişkene class'ın tipine referans verdiğimiz için create object diyerek
                          " obje oluşturulur ve işlemler bunun içinden yapılır
  
  gv_class->class_methods( ). " Ctrl + Space yapıldığında kod tamamlanır

" Eğer metodumuz static ise class'ı oluşturmadan ve create etmeden sadece className=>static_method şeklinde erişebiliriz

" Types alanı ile de class'lar için değişken tipi oluşturduğumuz alan
" Attributes: Class için değişken oluşturma alanıdır
" Friends: Başka bir class'ın fonksiyonlarını kullanabileceğimiz alan
" Hangi class'ın fonksiyonlarını başka class'ta kullanacaksak o class'ın adını friends alanına yazmamız gerekir
" Tekrar fonksiyon oluşturur ve parametrelerini veririz ama source code kısmında diğer class'ın kodunu çağırarak kendi parametrelerimizi veririz

" Events: Parametreler tanımlayıp source code yazmadan methods kısmında kullanmamızı sağlar
" Events'i kullanmak için methods kısmında tekrar method oluşturup goto_properties kısmından event handler for kısmına
" hangi class'ın hangi event'ini kullanacaksak o yazılır

" Aliases: Interface'in fonksiyon adlarını kısaltarak programda kullanmamızı sağlayan yapı
