.data
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
SYSEXIT = 60
EXIT_SUCCESS = 0
STDOUT = 1
STDIN = 0

plik: .ascii "sito.txt\0"

info: .ascii "Podaj liczbe...[2, 6538249]\n"
info_length = .-info

yes: .ascii "Liczba jest pierwsza.\n"
yes_length = .-yes

no: .ascii "Liczba nie jest pierwsza.\n"
no_length = .-no

fail: .ascii "Blad!\n"
fail_length = .-fail

.bss
.comm txt, 5120
.comm sito, 375
.comm data, 10

.text
.global main

main:
# otworzenie pliku
movq $SYSOPEN, %rax
movq $plik, %rdi
movq $0, %rsi
movq $0, %rdx
syscall

# przeniesienie do R8 identyfikatora otwartego pliku, do R9 rozmiaru w bajtach bufora sito
movq %rax, %r8
movq $5120, %r9

# wczytanie danych z pliku
movq $SYSREAD, %rax
movq %r8, %rdi
movq $txt, %rsi
movq %r9, %rdx
syscall

# zamknięcie pliku
movq $SYSCLOSE, %rax
movq %r8, %rdi
movq $0, %rsi
movq $0, %rdx
syscall

# przygotowanie rejestrów
movq $0, %rax
movq $0, %rbx
movq $0, %rcx
movq $10, %r10
movq $0, %r11

# odczytywanie danych z bufora txt, uzyskiwanie wartości liczby w rejestrze, przepisywanie zawartości rejestru do bufora sito
make_1:
cmpq %rcx, %r9
je make_4
movb txt(, %rcx, 1), %bl
cmpb $' ', %bl
je make_3

make_2:
subb $'0', %bl
mulq %r10
addq %rbx, %rax
incq %rcx
jmp make_1

make_3:
movw %ax, sito(, %r11, 2)
movq $0, %rax
incq %rcx
incq %r11
jmp make_1

# wczytanie danych od użytkownika programu
make_4:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $info, %rsi
movq $info_length, %rdx
syscall

movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $data, %rsi
movq $10, %rdx
syscall

# przygotowanie rejestrów
make_5:
movq %rax, %r8
subq $1, %r8
movq $0, %rax
movq $0, %rbx
movq $0, %rcx

# uzyskiwanie wartości liczby wprowadzonej przez użytkownika, sprawdzanie, czy wprowadzono odpowiednie dane
make_6:
cmpq %rcx, %r8
je check
movb data(, %rcx, 1), %bl
cmpb $'0', %bl
jl blad
cmpb $'9', %bl
jg blad
subb $'0', %bl
mulq %r10
addq %rbx, %rax
incq %rcx
jmp make_6

# sprawdzanie danych wprowadzonych przez użytkownika, jeśli 2 -> liczba jest pierwsza
check:
cmpq $2, %rax
jl blad
je jest_pierwsza
cmpq $6538249, %rax
jg blad

# skopiowanie wartości liczby wprowadzonej przez użytkownika do R8, wykorzystanie funkcji z języka C do obliczenia pierwiastka, przygotowanie rejestrów
make_7:
movq %rax, %rbx
movq %rax, %rdi
movq $0, %rax
call function
movq %rbx, %r8
movq %rax, %r9
decq %r9
movq $0, %r10
movq $0, %rbx

# sprawdzanie, czy liczba pierwsza -> dzielenie przez liczby pierwsze
make_8:
movq $0, %rdx
movq %r8, %rax
movw sito(, %r10, 2), %bx
divq %rbx
cmpq $0, %rdx
je nie_jest_pierwsza
cmpq %r10, %r9
je jest_pierwsza
incq %r10
jmp make_8

# komunikat o bledzie
blad:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $fail, %rsi
movq $fail_length, %rdx
syscall
jmp end

# komunikat, że liczba jest pierwsza
jest_pierwsza:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $yes, %rsi
movq $yes_length, %rdx
syscall
jmp end

# komunikat, że liczba nie jest pierwsza
nie_jest_pierwsza:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $no, %rsi
movq $no_length, %rdx
syscall

# zakończenie pracy programu
end:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
