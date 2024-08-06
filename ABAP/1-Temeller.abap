" Data type definitions
DATA gv_decimal TYPE p DECIMALS 3.   " Ondalık veri tipi, 3 ondalık basamak
DATA gv_integer TYPE i.             " Tam sayı veri tipi (int4)
DATA gv_numeric TYPE n LENGTH 3.   " Numerik veri tipi, 3 basamak
DATA gv_char TYPE c LENGTH 1.      " Karakter veri tipi (1 karakter uzunluğunda)
DATA gv_string TYPE string.        " String veri tipi

" Assigning values to variables
gv_decimal = '12,123'.   " Virgül ve 3 ondalık basamağı olan sayı
gv_integer = 123.        " Tam sayı
gv_numeric = '654'.      " Numerik veri tipi, 3 basamaklı
gv_char = 'A'.          " Karakter veri tipi
gv_string = 'selam furkan'. " String veri tipi

DATA gv_numeric10 TYPE n LENGTH 10. " 10 basamaklı sayıyı temsil eder

" Defining multiple data variables
DATA: gv_var1 TYPE i,
      gv_var2 TYPE n,
      gv_var3 TYPE string.

" Comment lines
" selam
* selam *

" Printing output
WRITE: / 'Text to print'. " Yeni satıra geçerek yazdırır

" Using IF statements
IF gv_numeric > 5.
  WRITE: / 'Variable is greater than 5', gv_numeric.
ENDIF.

DATA gv_variable TYPE i VALUE 10.

IF gv_variable < 10.
  WRITE: / 'Variable is less than 10'.
ELSEIF gv_variable > 10.
  WRITE: / 'Variable is greater than 10'.
ELSE.
  WRITE: / 'Variable is 10'.
ENDIF.

DATA: gv_num1 TYPE i VALUE 2,
      gv_num2 TYPE i VALUE 2.

IF gv_num1 = 1. " Eşittir
  WRITE: / 'Your value is 1'.
ELSEIF gv_num1 = gv_num2.
  WRITE: / 'Your value is 2'.
ELSE.
  WRITE: / 'Your value is neither 1 nor 2'.
ENDIF.

" CASE WHEN structure
DATA gv_case TYPE i VALUE 1.

CASE gv_case.
  WHEN 1.
    WRITE: / 'Number 1'.
  WHEN 2.
    WRITE: / 'Number 2'.
  WHEN 3.
    WRITE: / 'Number 3'.
  WHEN OTHERS.
    WRITE: / 'Number is neither 1, 2, nor 3'.
ENDCASE.

" DO loop
DATA: gv_name TYPE string VALUE 'Furkan',
     gv_length TYPE i.

gv_length = strlen(gv_name).

DO gv_length TIMES.
  WRITE: / 'Furkan'.
ENDDO.

DATA gv_counter TYPE i VALUE 0.

DO 20 TIMES.
  WRITE: / 'Current number: ', gv_counter.  " Yeni satıra geçer
  gv_counter = gv_counter + 1.
ENDDO.

" WHILE loop

WHILE gv_counter > 0. " Şart sağlandığı sürece çalışır
  WRITE: / 'NUMBER: ', gv_counter.
  gv_counter = gv_counter - 1.
ENDWHILE.

" Comparison operators
" < LT  : Less than
" > GT  : Greater than
" <= LE : Less than or equal to
" >= GE : Greater than or equal to
" = EQ  : Equal to
