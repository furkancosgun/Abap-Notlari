Event blocks:program akışını duzene oturtmak için kullanılan keywordlerdir"İlk açılış vs. "Bir nevi yaşam dongusudur

1-initialization, //user input parametrelerinden once çalışmasını istediğimz kodlar
2-at selection-screen,//input parametrelerini ozelleşitren yapı
3-start-of-selection,//program run oldugunda çalışan kod
4-end-of-selection,//formları kullancagımı yapı


parameters: p_num type int4.//parametre alan yapı oluşturur

initialization:  
	"input parametresi gelmeden çalışır input içine degeri atar
	p_num=12.
	
at selection-screen:	"input parametresine her girildiğinde çalışır
	p_num = p_num + 1.
	
start-of-selection:	"rapor run edildigi gibi çalışır
	write 'start of-selection'.

end-of-selection: 	"uygulama çalışma işlemi bitince çalışır
	write 'end-of-selection'.
	
" Form	"Fonksiyon anlamına gelir
data: gv_num1 type i.
initialization.

at selection-screen.

start-of-selection.
	perform sayiya_bir_ekle. "daha sona forma(Fonksiona) erişmek isterek perform keywordu kullanılır
	write gv_num1.
	perform iki_sayiyi_carp usin 5
								 5.
end-of-selection.


"form oluşturma
"form {formad} using {parametreler}vs. devam eder.
form sayiya_bir_ekle.
	gv_num1 = gv_num1 + 1.
endform.


"Parametre alan form(Fonksiyon)
form iki_sayiyi_carp using p_num1,p_num2.
	data lv_sonuc type i.
	
	lv_sonuc = P_num1 * p_num2.
	
	write lv_sonuc.