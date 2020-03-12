#include <math.h>

int element (int value_from_register) // value_from_register -> wartość z rejestru RDI
{
    double el = value_from_register;
    el = sqrt(el); // obliczenie pierwiastka
    el = ceil(el); // zaokrąglenie w górę
    value_from_register = el;
    return value_from_register; // wynik działania funkcji będzie w rejestrze RAX
}
