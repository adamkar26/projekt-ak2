.data
SYSREAD = 0
STDIN = 0
SYSWRITE = 1
STDOUT = 1
SYSOPEN = 2
SYSCLOSE = 3
SYSEXIT = 60
EXIT_SUCCESS = 0

start_comment: .ascii "Sito Eratostenesa. Wpisz koniec przedzialu liczbowego. Przedzial musi miec przynajmniej 10 liczb. Maks 2560 liczb.\n"
start_length = .-start_comment

fail_comment: .ascii "FAIL\n"
fail_length = .-fail_comment

good_comment: .ascii "Wynik zapisano do pliku.\n"
good_length = .-good_comment

fo: .ascii "sito.txt\0"

.bss
.comm in, 10
.comm numbers, 10240
.comm out, 5120

.text
.global main

main:
# wyświetlenie początkowego komunikatu
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $start_comment, %rsi
movq $start_length, %rdx
syscall

# wczytanie końca przedziału liczbowego
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $in, %rsi
movq $10, %rdx
syscall

movq %rax, %r8 # R8 - długość wczytanych danych
subq $2, %r8
movq $0, %r9 # R9 - jako licznik

# sprawdzenie, czy wprowadzono liczbę
check1:
movb in(, %r9, 1), %al
cmpb $48, %al
jl fail
cmpb $57, %al
jg fail
cmpq %r9, %r8
je ascii1
incq %r9
jmp check1

# zamiana wprowadzonych danych na wartość liczbową, która zostanie wpisana do rejestru
ascii1:
movq $10, %r10
movq $0, %r11
movq $0, %r12

ascii2:
movq %r12, %rax
mulq %r10
movq %rax, %r12
movq $0, %rax
movb in(, %r11, 1), %al
subb $48, %al
addq %rax, %r12
cmpq %r11, %r8
je check2
incq %r11
jmp ascii2

# sprawdzenie -> przedział ma mieć co najmniej 10 liczb, co najwyżej 2560 liczb
check2:
cmpq $11, %r12
jl fail
cmpq $2561, %r12
jg fail
jmp use_c

# obliczenie pierwiastka za pomocą funkcji w języku C
use_c:
movq $0, %rax
movq %r12, %rdi
call element

# wrzucenie na stos, wywołanie funkcji, zdjęcie ze stosu
function:
movq $numbers, %r8
movq $out, %r9
pushq %rax
pushq %r12
pushq %r9
pushq %r8
call sito
popq %r8
popq %r9
popq %r12 # R12 - do wypisania liczb pozostałych z sita do pliku
popq %rax

file:
# otworzenie pliku w celu zapisania wyniku
movq $SYSOPEN, %rax
movq $fo, %rdi
movq $1, %rsi
movq $0, %rdx
syscall

movq %rax, %r8 # R8 - identyfikator otwartego pliku

# zapis do pliku
movq $SYSWRITE, %rax
movq %r8, %rdi
movq $out, %rsi
movq %r12, %rdx
syscall

# zamknięcie pliku
movq $SYSCLOSE, %rax
movq %r8, %rdi
movq $1, %rsi
movq $0, %rdx
syscall
jmp end1

# wyświetlenie komunikatu o błędzie
fail:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $fail_comment, %rsi
movq $fail_length, %rdx
syscall
jmp end2

# komunikat o zapisaniu wyniku do pliku
end1:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $good_comment, %rsi
movq $good_length, %rdx
syscall

# zakończenie pracy programu
end2:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

# --------------------------------------------------
# SITO ERATOSTENESA
# --------------------------------------------------

sito:
# rozpoczęcie funkcji, pobranie danych ze stosu
push %rbp
movq %rsp, %rbp
movq 16(%rsp), %r14
movq 24(%rsp), %r15
movq 32(%rsp), %r8
movq 40(%rsp), %r9

movq $2, %rax # RAX - pierwsza liczba w sicie Eratostenesa
movq $0, %rcx # RCX - jako licznik

# wypełnianie sita
add_to_numbers:
movq %rax, (%r14, %rcx, 4)
cmpq %rax, %r8
je make1
incq %rax
incq %rcx
jmp add_to_numbers

# przygotowanie rejestrów
make1:
movq $0, %rax
movq %r8, %rbx
subq $1, %rbx # N-1
movq %r9, %rcx
subq $1, %rcx # ceil(sqrt(N))-1
movq $0, %rdx
movq $2, %r10 # do kolejnych wielokrotności
movq $0, %r11

# zastępywanie zerami wielokrotności liczb
make2:
movl (%r14, %r11, 4), %eax
mulq %r10
movq %rax, %r12
movq $0, %rax
subq $2, %r12
movl %edx, (%r14, %r12, 4)
cmpq %r12, %rbx
jle make3
incq %r10
jmp make2

make3:
movq $2, %r10

make4:
incq %r11
cmpq %r11, %rcx
je save1
movl (%r14, %r11, 4), %eax
cmpl $0, %eax
je make4
jmp make2

# przygotowanie rejestrów
save1:
movq $0, %rcx
movq $0, %rdx
movq $10, %r8
movq $0, %r10
movq $0, %r11
movq $0, %r12

# liczba, która nie jest zerem -> skok save3
save2:
movl (%r14, %rcx, 4), %edx
cmpl $0, %edx
jne save3
jmp save8

save3:
movq %rdx, %r9

# zapisanie liczby, która nie jest zerem do rejestru w odwrotnej kolejności cyfr
save4:
movq %r10, %rax
mulq %r8
movq %rax, %r10
movq %r9, %rax
divq %r8
movq %rax, %r9
addq %rdx, %r10
incq %r11
cmpq $0, %r9
je save5
jmp save4

save5:
movq %r10, %rax
subq $1, %r11
movq $0, %rdx

# zapisywanie cyfry/cyfr do bufora (w kodzie ascii), kiedy koniec cyfry/cyfr -> skok save7
save6:
divq %r8
addq $48, %rdx
movq %rdx, (%r15, %r12, 1)
cmpq %r12, %r11
je save7
incq %r12
movq $0, %rdx
jmp save6

# dodawanie do bufora znaku spacji
save7:
cmpq %rcx, %rbx
je endf
incq %rcx
movq $' ', %rdx
addq $2, %r11
incq %r12
movq %rdx, (%r15, %r12, 1)
incq %r12
movq $0, %rdx
movq $0, %r10
jmp save2

save8:
cmpq %rcx, %rbx
je endf
incq %rcx
jmp save2

# dodanie do bufora znaku przejścia do nowej linii, R12 - do wypisania liczb pozostałych z sita do pliku (uwaga na dodawanie do R12, inkrementację R12!)
endf:
addq $2, %r12
movq $'\n', %rax
movq %rax, (%r15, %r12, 1)
incq %r12

# skopiowanie danych do stosu, zakończenie funkcji
movq %r12, 32(%rsp)
movq %rbp, %rsp
pop %rbp
ret
