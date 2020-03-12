.data
SYSWRITE = 1
STDOUT = 1
SYSREAD = 0
STDIN = 0
SYSEXIT = 60
EXIT_SUCCESS = 0

info: .ascii "[2, ... <- ?] (maksymalna liczba - 1000000)\n"
info_length = .-info

fail: .ascii "Blad. :<\n"
fail_length = .-fail

.bss
.comm from_user, 10
.comm sito, 4000000
.comm number, 8
.comm number2, 8

.text
.global main

main:
# komunikat dla użytkownika
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $info, %rsi
movq $info_length, %rdx
syscall

# pobranie danych od użytkownika
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $from_user, %rsi
movq $10, %rdx
syscall

# przygotowanie rejestrów
movq %rax, %r8
decq %r8
movq $0, %rax
movq $0, %rbx
movq $0, %rcx
movq $10, %r9

# kontrola danych, uzyskiwanie wartości liczby wprowadzonej przez użytkownika
sprawdzanie_1:
cmpq %rcx, %r8
je sprawdzanie_2
movb from_user(, %rcx, 1), %bl
cmpb $'0', %bl
jl blad
cmpb $'9', %bl
jg blad
subb $'0', %bl
mulq %r9
addq %rbx, %rax
incq %rcx
jmp sprawdzanie_1

# kontrola danych - czy przedział liczbowy jest poprawny? + przygotowanie rejestrów
sprawdzanie_2:
cmpq $2, %rax
jl blad
cmpq $1000000, %rax
jg blad

# obliczenie pierwiastka, przygotowanie rejestrów
pierwiastek:
movq %rax, %rbx
movq %rax, %rdi
movq $0, %rax
call function
movq %rax, %r8
movq $1, %r9
movq $1, %r10
movq $4, %r13
movq $3, %r14
movq $12, %r15
movq $0, %rcx

# dodanie 2 i 3 do bufora
przed:
movl $2, %edx
movl %edx, sito(, %rcx, 4)
incq %rcx
movl $3, %edx
movl %edx, sito(, %rcx, 4)

# ---| ALGORYTM |---
# określanie x^2
sito_1:
cmpq %r9, %r8
jl usuwanie_wielokrotnosci_1
movq %r9, %rax
mulq %rax # x * x
movq %rax, %r11

# określanie pierwszego równania
sito_2:
cmpq %r10, %r8
jl sito_12
movq %r10, %rax
mulq %rax # y * y
movq %rax, %r12
movq %r11, %rax
mulq %r13 # 4x^2
addq %r12, %rax # 4x^2 + y^2

# dzielenie wyniku równania przez 12, czy reszta z dzielenia to 1 lub 5?
sito_3:
cmpq %rax, %rbx
jl sito_5
movq $0, %rdx
movq %rax, %rsi
divq %r15
cmpq $1, %rdx
je sito_4
cmpq $5, %rdx
je sito_4
jmp sito_5

# jeśli reszta z dzielenia to 1 lub 5 -> zapisywanie wyniku równania do bufora
sito_4:
movq $0, %rdx
movq %rsi, %rcx
subq $2, %rcx
movl sito(, %rcx, 4), %edx
cmpl $0, %edx
jne zmiana_1
movl %esi, sito(, %rcx, 4)
jmp sito_5

zmiana_1:
movq $0, %rsi
movl %esi, sito(, %rcx, 4)

# określanie drugiego równania
sito_5:
movq %r11, %rax
mulq %r14 # 3x^2
addq %r12, %rax # 3x^2 + y^2

# dzielenie wyniku równania przez 12, czy reszta z dzielenia to 7?
sito_6:
cmpq %rax, %rbx
jl sito_8
movq $0, %rdx
movq %rax, %rsi
divq %r15
cmpq $7, %rdx
je sito_7
jmp sito_8

# jeśli reszta z dzielenia to 7 -> zapisywanie wyniku równania do bufora
sito_7:
movq $0, %rdx
movq %rsi, %rcx
subq $2, %rcx
movl sito(, %rcx, 4), %edx
cmpl $0, %edx
jne zmiana_2
movl %esi, sito(, %rcx, 4)
jmp sito_8

zmiana_2:
movq $0, %rsi
movl %esi, sito(, %rcx, 4)

# określanie trzeciego równania
sito_8:
cmpq %r9, %r10
jge sito_11
movq %r11, %rax
mulq %r14 # 3x^2
subq %r12, %rax # 3x^2 - y^2

# dzielenie wyniku równania przez 12, czy reszta z dzielenia to 11?
sito_9:
cmpq %rax, %rbx
jl sito_11
movq $0, %rdx
movq %rax, %rsi
divq %r15
cmpq $11, %rdx
je sito_10
jmp sito_11

# jeśli reszta z dzielenia to 11 -> zapisywanie wyniku równania do bufora
sito_10:
movq $0, %rdx
movq %rsi, %rcx
subq $2, %rcx
movl sito(, %rcx, 4), %edx
cmpl $0, %edx
jne zmiana_3
movl %esi, sito(, %rcx, 4)
jmp sito_11

zmiana_3:
movq $0, %rsi
movl %esi, sito(, %rcx, 4)

# zwiększenie y
sito_11:
incq %r10
jmp sito_2

# zwiększenie x, a y = 1
sito_12:
movq $1, %r10
incq %r9
jmp sito_1

# pozbywanie się wielokrotności liczb pierwszych z sita
usuwanie_wielokrotnosci_1:
movq $5, %rax
movq $0, %rsi

usuwanie_wielokrotnosci_2:
cmpq %rax, %r8
jl zapis_1
mulq %rax
movq %rax, %r9
movq %rax, %rdi

usuwanie_wielokrotnosci_3:
cmpq %rdi, %rbx
jl usuwanie_wielokrotnosci_4
movq %rdi, %rcx
subq $2, %rcx
movl %esi, sito(, %rcx, 4)
addq %rax, %rdi
jmp usuwanie_wielokrotnosci_3

usuwanie_wielokrotnosci_4:
movq %r9, %rax
incq %rax
jmp usuwanie_wielokrotnosci_2

# przygotowanie rejestrów
zapis_1:
movq $0, %rax
decq %rbx
movq $0, %r8
movq $10, %r9
movq $0, %r10
movq $0, %r11
movq $0, %r12
movq $0, %r13

# pobieranie danych z bufora, które nie są 0
zapis_2:
movl sito(, %r12, 4), %eax
cmpl $0, %eax
jne zapis_3
jmp zapis_7

# zapisywanie cyfr do bufora w odwrotnej kolejności
zapis_3:
movq $0, %rdx
divq %r9
movb %dl, number(, %r10, 1)
cmpq $0, %rax
je zapis_4
incq %r10
jmp zapis_3

# przywracanie poprawnej kolejności cyfr, dodawanie do bufora cyfr w kodzie ascii
zapis_4:
movb number(, %r10, 1), %dl
addb $'0', %dl
movb %dl, number2(, %r11, 1)
cmpq $0, %r10
je zapis_5
decq %r10
incq %r11
jmp zapis_4

# dodawanie do bufora znaku spacji, wyświetlanie liczby pierwszej na ekranie ze spacją
zapis_5:
incq %r11
movb $' ', %dl
movb %dl, number2(, %r11, 1)
incq %r11
movq %r11, %r13
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $number2, %rsi
movq %r11, %rdx
syscall
movb $0, %dl
movq $0, %rax
movq $0, %r10
movq $0, %r11

# czyszczenie bufora
zapis_6:
movb %dl, number2(, %r13, 1)
cmpq $0, %r13
je zapis_7
decq %r13
jmp zapis_6

# jak w R12 liczba równa końcowi przedziału liczbowego -> skok do koniec
zapis_7:
cmpq %r12, %rbx
je koniec
incq %r12
jmp zapis_2

blad:
# komunikat o błędzie
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $fail, %rsi
movq $fail_length, %rdx
syscall

koniec:
# zakończenie pracy programu
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
