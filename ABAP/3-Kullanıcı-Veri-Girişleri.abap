" Parameters: p_num1 - integer type, input accepts 10 digits
PARAMETERS: p_num1 TYPE i. " int türünde 10 basamaklı input istedim

" Git->metin_sembolleri->selection_text: Inputtaki yazıyı değiştirebiliriz

PARAMETERS: p_num2 TYPE i,
            p_num3 TYPE c. " Data element türünde veri alacak şekilde ayarlanır

" Select-options: iki değer arasında/dışında seçim hakkı verir
SELECT-OPTIONS: s_person FOR data. " İki değer arasında veya dışında seçim hakkı verir

" Tables: Raporun tabloyu tanımadığı durumlarda rapora tabloyu tanıtma işlemi yapılır
TABLES: databaseTableName. " Raporun tabloyu tanımadığı zamanlarda rapora tanıtma işlemi yapılır

" Select-options: Tablonun belirli bir kolonunu referans alır
SELECT-OPTIONS: s_col FOR tableName-columnName. " Bu tablonun bu kolonunu referans al demek oluyor

" Checkbox
PARAMETERS: p_chk AS CHECKBOX. " Checkbox tanımlama

" RadioButton
PARAMETERS: p_rad1 AS RADIOBUTTON GROUP grp1,
            p_rad2 AS RADIOBUTTON GROUP grp1. " Radio buttonlar aynı grup içinde

" SelectionScreen: Bir panel oluşturup içine parametreler veya selection screen ekleyebiliriz, tasarım açısından daha hoş durması için
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.

" Parameters or texts all views
SELECTION-SCREEN: END OF BLOCK b1.

" Panele başlık verme
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE 'Başlık'.

PARAMETERS: lv_name TYPE string.

SELECTION-SCREEN: END OF BLOCK b1.
