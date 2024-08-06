*&---------------------------------------------------------------------*
*& Report ZFC_FLIGHT_QUERY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFC_FLIGHT_QUERY.

* Veri yapısı tanımlama
DATA: gs_sflight TYPE sflight. " SFLIGHT tablosu için veri yapısı

* Kullanıcıdan parametre alma
PARAMETERS: p_carrid TYPE s_carr_id, " Taşıyıcı ID'si
            p_connid TYPE s_conn_id, " Bağlantı ID'si
            p_fldate TYPE s_date.   " Uçuş tarihi

START-OF-SELECTION.
  " Sorgu yapma ve sonuçları alacak veri yapısına atama
  SELECT SINGLE * 
    FROM sflight 
    INTO gs_sflight 
    WHERE carrid = p_carrid
      AND connid = p_connid
      AND fldate = p_fldate.

  " Sonuçların işlenmesi veya ekrana yazdırılması gibi işlemler burada yapılabilir
  IF sy-subrc = 0. " Eğer sorgudan sonuç dönerse
    WRITE: / 'Uçuş Bilgileri:',
           / 'Taşıyıcı ID: ', gs_sflight-carrid,
           / 'Bağlantı ID: ', gs_sflight-connid,
           / 'Uçuş Tarihi: ', gs_sflight-fldate,
           / 'Kalkış Yeri: ', gs_sflight-departure_airport,
           / 'Varış Yeri: ', gs_sflight-arrival_airport,
           / 'Yolcu Sayısı: ', gs_sflight-passengers.
  ELSE.
    WRITE: / 'Belirtilen kriterlere uygun uçuş bulunamadı.'.
  ENDIF.
