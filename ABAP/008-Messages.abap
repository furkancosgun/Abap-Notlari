* Mesajların tanımlanması ve kullanılması

* Mesaj türlerinin kullanımı
* 'S' success (başarı), 'I' info (bilgi), 'W' warning (uyarı), 'E' error (hata), 'A' abort (acil durdurma), 'X' exit (çökme)
MESSAGE 'Bu bir başarı mesajı' TYPE 'S'. " Başarıyı temsil eder, sol altta gösterilir
MESSAGE 'Bu bir bilgi mesajı' TYPE 'I'. " Bilgiyi temsil eder, popup ile gösterilir
MESSAGE 'Bu bir uyarı mesajı' TYPE 'W'. " Uyarıyı temsil eder, sol altta gösterilir, program akışını durdurur
MESSAGE 'Bu bir hata mesajı' TYPE 'E'. " Hata mesajı, sol altta gösterilir, program akışını durdurur
MESSAGE 'Bu bir acil durum mesajı' TYPE 'A'. " Acil durumu temsil eder, popup ile gösterilir, program akışını durdurur ve ana ekrana gönderir
MESSAGE 'Bu bir çökme mesajı' TYPE 'X'. " Çökme ekranı verir, program akışını durdurur ve ana ekrana gönderir

* Mesaj görünümünü değiştirme
* Mesaj türü 'S' olarak tanımlanmışsa bile 'I' gibi bilgi olarak görüntülenebilir
MESSAGE 'Bu bir bilgi mesajı' TYPE 'S' DISPLAY LIKE 'I'. " Sol altta mesaj verir ama bilgiyi temsil eder

* Text Symbol ekleme
* Text Symbol, mesaj metinleri için dinamik içerik eklemeye olanak sağlar
* Text Symbol tanımlamaları SE80 veya SE38 üzerinden yapılabilir

* Text Symbol ekleme: Go -> Text Symbols kısmından ID verilerek metin ifadesi eklenir
* Kullanım: Text Symbol ID kullanarak mesaj metni tanımlanır
MESSAGE text-id TYPE 'I'. " Verilen ID'ye ait metin bilgi olarak gösterilir

* Message Class oluşturma ve kullanma
* Message Class, SE91 kullanılarak oluşturulabilir

* Message Class ile mesaj kullanımı
* Mesaj sınıfı ve mesaj numarası kullanılarak mesaj gösterilir
MESSAGE messageType MessageClassId(messageClassName). " Mesaj sınıfı ile mesaj gösterimi
MESSAGE i000(msg). " Mesaj sınıfı ile mesaj numarası

* Mesaj sınıfı adı vermeden mesaj kullanma
* Mesaj ID ve sınıf adı verilerek kullanılabilir
REPORT <program_name> MESSAGE-ID MsgClassName. " Mesaj sınıfı adı ile kullanım
MESSAGE i000. " Sadece ID verilerek kullanım

* Mesaj sınıfında dinamik değer kullanma
* Mesaj sınıfı metinlerinde '&' işareti kullanılarak dinamik değerler eklenir

* Dinamik değerler ile mesaj kullanımı
MESSAGE i000 WITH 'parametre'. " Parametre değeri mesaj metnine dinamik olarak eklenir

* Birden fazla dinamik değer içeren mesaj sınıfı kullanımı
* Mesaj metni oluşturulurken istenen kısımlara '&' işareti konulur

* Birden fazla dinamik değer ile mesaj kullanımı
MESSAGE i000 WITH 'ilk' 'ikinci'. " Sırasıyla değerler mesaj metnine eklenir

