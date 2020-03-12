.data
STDOUT = 1
SYSWRITE = 1
SYSEXIT = 60
EXIT_SUCCESS = 0
format_long: .asciz "%lld"
kom_pierwsza: .asciz "Liczba pierwsza lub liczba pseudopierwsza przy podstawie 2 \n"
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


movq $0, %rax
movq liczba(,%rax,1), %r11  # sprawdzana liczba w r10
cmp $4,%r11
jl pierwsza

movq $2, %rax
push %r11
push %r11
push %rax
call mod # 2^p mod 2

cmp $2, %rax
jne zlozona

pierwsza:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $kom_pierwsza, %rsi
movq $kom_pierwsza_len, %rdx
syscall
jmp exit


zlozona:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $kom_zlozona, %rsi
movq $kom_zlozona_len, %rdx
syscall


exit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall


# ----------------------------------------------------------------
# funkcja szybkiego potęgowania modularnego
# oblicz a^b mod m a-rax, b-rbx, m-rcx


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
