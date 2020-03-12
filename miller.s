.data
STDOUT = 1
SYSWRITE = 1
SYSEXIT = 60
EXIT_SUCCESS = 0
format_long: .asciz "%lld"
format_int: .asciz "%d"
kom_pierwsza: .asciz "Liczba prawdopodobnie pierwsza \n"
kom_pierwsza_len= .-kom_pierwsza
kom_zlozona: .asciz "Liczba zlozona \n"
kom_zlozona_len= .-kom_zlozona

.bss
.comm liczba, 8
.comm k,4

.text
.global main
main:

mov $0, %rax        # Przesyłamy 0 parametrów zmiennoprzecinkowych
mov $format_long, %rdi # Pierwszy parametr całkowity dla scanf
                    # - format w jakim ma zostać zapisany
                    # wynik w buforze
mov $liczba, %rsi  # Drugi parametr całkowity dla scanf
                    # - adres bufora do które zapisany
                    # ma zostać wynik
call scanf


mov $0, %rax        # Przesyłamy 0 parametrów zmiennoprzecinkowych
mov $format_int, %rdi # Pierwszy parametr całkowity dla scanf
                    # - format w jakim ma zostać zapisany
                    # wynik w buforze
mov $k, %rsi  # Drugi parametr całkowity dla scanf
                    # - adres bufora do które zapisany
                    # ma zostać wynik
call scanf

call start # inicjacja losowania

movq $0, %r15  # s- wykladnik potegi 2 w dzielniku p-1
movq liczba(,%r15,1), %r14  # p- liczba do sprawdzenia
movq k(,%r15,1), %r12   # n - liczba powtorzen
movq %r14, %r8
dec %r8   # d- mnoznik potegi 2 w dzielniku p-1

cmp $4, %r14  # jezeli mniejsza od 4
jl pierwsza

movq $0, %rdx
movq $2, %rcx
movq %r14, %rax
div %rcx  # czy liczba jest parzysta
cmp $0, %rdx
je zlozona

usun_dzielniki_2:

shr %r8 # d=d/2
inc %r15 # s++

movq $0, %rdx
movq %r8, %rax
movq $2, %rbx
div %rbx
cmp $0, %rdx
je usun_dzielniki_2


movq $0, %r13  # i - licznik petli

test:    # wykonaj n- testow millera-rabina


# wywolanie funkcji losujacej dla zakresu 0-p-2, zabezpieczam wczesniej rejestry na stosie
push %r15
push %r14
push %r12
push %r8
movq $0, %rax
movq %r14, %rdi
call losuj
# wynik w rax
pop %r8
pop %r12
pop %r14
pop %r15


# wywolanie funkcji szybkiego potegowania modularnego
push %r14
push %r8
push %rax
call mod # wynik w rax
pop %rdx # przywracam konieczne rejestry
pop %r8
pop %r14

cmp $1, %rax # x==1
je sprawdzaj_warunki_petli

movq %r14, %rdx
dec %rdx
cmp %rax, %rdx  # x=p-1
je sprawdzaj_warunki_petli


movq $1, %r8  # licznik petli- obliczanie wyrazow ciagu millera

ciag:

push %r14
push $2
push %rax
call mod  # rax=rax*rax mod p

cmp $1, %rax  # jezeli x==1, liczba nie jest pierwsza
je zlozona

inc %r8  # zwieksz licznik
cmp %r15, %r8  # jezeli licznik>s koniec
jge sprawdzaj_warunki_petli

movq %r14, %rdx
dec %rdx
cmp %rax, %rdx  # x=p-1
je sprawdzaj_warunki_petli  # jezeli x=p-1 koniec

jmp ciag

movq %r14, %rdx
dec %rdx
cmp %rax, %rdx  # x=p-1
je zlozona  # jezeli ostatni wyraz ciagu nie jest jedynka- liczba zlozona

sprawdzaj_warunki_petli:
inc %r13
cmp %r12, %r13
jne test

jmp pierwsza  # jezeli liczba przeszla pomyslnie wszystkie testy

zlozona:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $kom_zlozona, %rsi
movq $kom_zlozona_len, %rdx
syscall
jmp koniec

pierwsza:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $kom_pierwsza, %rsi
movq $kom_pierwsza_len, %rdx
syscall


koniec:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall


# funckja szybkiego potegowania modularnego
mod:
push %rbp # umieszczenie poprzedniego rejesteru bazowego na sotsie
movq %rsp, %rbp # Pobranie zawartości rejestru RSP (zawierającego
                # wskaźnik na ostatni element umieszczony
                # na stosie) do rejestru bazowego.
sub $8, %rsp # zwiekszenie wskazinika sotsu o 1
movq 16(%rbp), %rax # 1 argument do rax
movq 24(%rbp), %rbx  # 2 do rbx
movq 32(%rbp), %rcx  # 3 do rcx

movq $1, %r8  # licznik
movq $1, %r9  # wynik
movq $0, %rdx  # do dzielenia
div %rcx  # dziele rdx:rax/rcx, wynik modulo do rdx
movq %rdx, %r10  # przenosze wynik modulo

mod_petla:
movq $0, %rdx
movq %r10, %rax
div %rcx
movq %rdx, %r10   # zapisuje wynik modulo

movq %rbx, %rdi
and %r8,%rdi  # czy bit jest 1?
cmp $0, %rdi
je bit0
movq $0, %rdx
movq  %r9, %rax
mul %r10  # rax=rax*r10
div %rcx # rax mod rcx
movq %rdx, %r9 # zapisuje wynik

bit0:
movq %r10, %rax
movq $0, %rdx
mul %rax  #rax=rax*rax
movq %rax, %r10

# warunki petli
shl %r8 # przesun licznik petli
cmp %rbx, %r8
jle mod_petla

movq %r9, %rax # zwracam wynik
movq %rbp, %rsp
pop %rbp
ret # koniec fukcji
