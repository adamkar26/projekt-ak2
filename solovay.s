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


cmp $4, %r14  # jezeli mniejsza od 4
jl pierwsza

movq $0, %rdx
movq $2, %rcx
movq %r14, %rax
div %rcx  # czy liczba jest parzysta
cmp $0, %rdx
je zlozona

movq $0, %r11
iteracje:
push %r11
movq %r14, %rdi
call losuj_s # wynik losowania- a w rax
pop %r11

movq %rax, %r15   #  a w r15
push %r14
push %rax
call symboljacobiego  # wynik w rax
add %r14, %rax    # rax+r14
movq $0, %rdx
div %r14   # rax/n
movq %rdx, %r13  # x w r13
movq %r14, %rcx
dec %rcx   # n-1
shr %rcx   # (n-1)/2

push %r14
push %rcx
push %r15
call mod
cmp %rax, %r13
jne zlozona
cmp $0, %r13
je zlozona

inc %r11
cmp %r12, %r11
jl iteracje
jmp pierwsza

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


# ------------------------------------------------------------------
# funckja obliczajaca symbol jacobiego, (a, n)- paramtry przez stos
symboljacobiego:
push %rbp # umieszczenie poprzedniego rejesteru bazowego na sotsie
movq %rsp, %rbp # Pobranie zawartości rejestru RSP (zawierającego
                # wskaźnik na ostatni element umieszczony
                # na stosie) do rejestru bazowego.
sub $8, %rsp # zwiekszenie wskazinika sotsu o 1
movq 16(%rbp), %rcx # 1 argument do rcx - a
movq 24(%rbp), %rbx  # 2 do rbx  - n

movq $0, %rax
cmp $0, %rcx  # a==0
je koniec_funkcji

movq $1, %rax  # temp=1

cmp $0, %rcx  # a<0
jge czy1
neg %rcx # a=-a
movq $0, %rdx
movq %rax, %r9
movq %rbx, %rax
movq $4, %r8
div %r8   # n%4
cmp $3, %rdx
jne czy1_a
neg %r9  # temp = -temp
movq %r9, %rax

czy1_a:
movq %r9, %rax
czy1:
cmp $1, %rcx  # a==1, return temp-rax
je koniec_funkcji

petla:
cmp $0, %rcx   # while(a!=0)
je koniec_petli

cmp $0, %rcx
jge kolejna_petla
neg %rcx  # a= -a

movq $0, %rdx
movq %rax, %r9
movq %rbx, %rax
movq $4, %r8
div %r8   # n%4
cmp $3, %rdx
jne niemodulo3
neg %r9  # temp=-temp

niemodulo3:
movq %r9, %rax

kolejna_petla:
movq %rcx, %r9
and $1, %r9
cmp $0, %r9
jne koniec_petli_wewnetrznej
shr %rcx # a=a/2

movq %rax, %r9
movq $0, %rdx
movq %rbx, %rax
movq $8, %r8
div %r8
cmp $3, %rdx # n %8= 3 || n%8=5
je przeciwna
cmp $5, %rdx
jne dalej_petla
przeciwna:
neg %r9
dalej_petla:
movq %r9, %rax
jmp kolejna_petla

koniec_petli_wewnetrznej:
# zamien kolejnoscia a, n
movq %rcx, %r9
movq %rbx, %rcx
movq %r9, %rbx

# if(a%4==3 || n%4==3)
movq %rcx, %r9
and $3, %r9
cmp $3, %r9
jne dalej
movq %rbx, %r9
and $3, %r9
cmp $3, %r9
jne dalej

neg %rax
dalej:
movq %rax, %r9
movq $0, %rdx
movq %rcx, %rax
div %rbx # a=a%n
movq %r9, %rax
movq %rdx, %rcx

movq %rbx, %r9
shr %r9
cmp %rcx, %r9  # a>n/2
jge w_gore
sub %rbx,%rcx # a=a-n

w_gore:
jmp petla

koniec_petli:
cmp $1, %rbx
je koniec_funkcji  # return temp

movq $0, %rax  # return 0

koniec_funkcji:   # wynik w rax
movq %rbp, %rsp
pop %rbp
ret # koniec fukcji


# ----------------------------------------------
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
