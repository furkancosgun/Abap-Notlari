parameters: p_num1 type i. //int turunde 10 basamaklı input istedim

git->metin_sembolleri->selection_text-> inputtaki yazıyı değiştirebiliriz

parameters: p_num1 type i,
			p_num2 type DATAELEMENT.///verirsek o deger uzunlugunda veri alcak durumda kendini ayarlar
	
//////////////
select-options: s_per_soy for data.//iki deger arasında/dışında secim hakkı verir 


Tables: veritabanıTabloAdı.

select-options: s_per_ad for tableAd-kolonAdı.//bu tablonun bu kolonunu referans al demek oluyor

//CHECHBOX
parameters: p_cbox1 as checkbox.
			
//RadioButton
parameters: p_radi as radiobutton group grp1,
	p_radi2 radiobutton group grp1.

//selectionScreen //Panele oturtma
selection-Screen begin of block bl1 with frame.

parameters or texts all views

selection-Screen end of block bl1.

///TEXT verme
selection-Screen begin of block bl1 with frame title text-id.


SELECTION-SCREEN: BEGIN OF BLOCK b1  WITH FRAME TITLE Başlik .

PARAMETERS: lv_ad type string.

SELECTION-SCREEN : END OF BLOCK b1.


