#include <math.h>
// funkcja do obliczenia pierwiastka
int function (int num)
{
    double num2 = num;
    num2 = floor(sqrt(num2));
    num = num2;
    return num;
}
