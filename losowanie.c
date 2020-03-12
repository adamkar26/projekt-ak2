#include <stdio.h>
#include <time.h>
#include <stdlib.h>

void start()
{
    srand(time(NULL));
}


 long long int losuj (long long int n )
 {
   long long int a;
   a=2+rand()%(n-2);
   return a;
 }

 long long int losuj_s(long long int n)
 {
   long long int a;
   a=rand()%(n-1)+1;
   return a;
 }
