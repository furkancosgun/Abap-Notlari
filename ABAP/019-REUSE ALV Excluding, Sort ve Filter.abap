*&---------------------------------------------------------------------*
*&  Include           ZFC_ALV_EXCLUDE_SORT_FILTER
*&---------------------------------------------------------------------*

* Bu dosya, ALV Grid Display'de sıralama, filtreleme ve işlem hariç tutma işlemlerini yapar.

*--------------------------------------------------------------*
* Global veri tanımlamaları
*--------------------------------------------------------------*
DATA: gt_exclude TYPE SLIS_T_EXTAB, " Status bardan çıkarılacak işlemler için iç tablo
      gs_exclude TYPE slis_extab. " Status bardan çıkarılacak işlemler için yapı

DATA: gt_sort TYPE SLIS_T_SORTINFO_ALV, " Sıralama bilgileri için iç tablo
      gs_sort TYPE slis_sortinfo_alv. " Sıralama bilgileri için yapı

DATA: gt_filter TYPE SLIS_T_FILTER_ALV, " Filtreleme bilgileri için iç tablo
      gs_filter TYPE SLIS_FILTER_ALV. " Filtreleme bilgileri için yapı

*--------------------------------------------------------------*
* FORM Uygulama: Exclude, Sort ve Filter işlemleri
*--------------------------------------------------------------*
FORM apply_exclude_sort_filter.

  * Excluding (hariç tutma) - Status bardan işlem kaldırma
  gs_exclude-FCODE = '&ABC'. " Status bardan çıkarılacak işlem kodu
  APPEND gs_exclude TO gt_exclude. " Hariç tutulacak işlemleri iç tabloya ekler

  * Sıralama işlemleri
  gs_sort-SPOS = 1. " Sıralama sırası (Birden fazla sıralama yapılırsa, bu numaraya göre sıralanır)
  gs_sort-TABNAME = 'GT_LIST'. " Tablo adı
  gs_sort-FIELDNAME = 'MENGE'. " Sıralanacak kolon adı
  gs_sort-UP = 'X'. " Küçükten büyüğe sıralama
  * gs_sort-DOWN = abap_true. " Büyükten küçüğe sıralama (isteğe bağlı)
  APPEND gs_sort TO gt_sort. " Sıralama bilgilerini iç tabloya ekler

  * Filtreleme işlemleri
  * gs_filter-TABNAME = 'GT_LIST'. " Tablo adı
  * gs_filter-FIELDNAME = 'MEINS'. " Filtrelenecek kolon adı
  * gs_filter-SIGN0 = 'I'. " Include (dahil) / Exclude (hariç) 
  * gs_filter-OPTION = 'EQ'. " Eşit (Equal) / Aralık (Between) 
  * gs_filter-VALUE = 'KG'. " Filtreleme değeri
  * APPEND gs_filter TO gt_filter. " Filtreleme bilgilerini iç tabloya ekler

  * ALV Grid Display fonksiyonunu çağırma
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = sy-repid " Callback fonksiyonlarının bulunduğu program
      IS_LAYOUT = gs_layout " Layout ayarları
      IT_FIELDCAT = gt_fieldcalatog " Field catalog (Tablo kolonları)
      IT_EXCLUDING = gt_exclude " Status bardan çıkarılacak işlemler
      IT_SORT = gt_sort " Sıralama bilgileri
      IT_FILTER = gt_filter " Filtreleme bilgileri
      IT_EVENTS = gt_events " Event yapılandırması
    TABLES
      T_OUTTAB = gt_list " İç tablo
    EXCEPTIONS
      PROGRAM_ERROR = 1 " Program hatası
      OTHERS = 2 " Diğer hatalar
      .

  IF SY-SUBRC <> 0.
    " Hata işleme burada yapılabilir
  ENDIF.

ENDFORM.
