#include <stdio.h>
#include <stdint.h>
#include "io.h"

#define INPOSSENSOR_BASE 0x20   // Adresse exacte dans Qsys

int main()
{
    printf("=== Lecture des capteurs seuils ===\n");

    uint8_t v;
    int i;   // déclaration ici pour compatibilité C89

    while (1)
    {
        v = IORD_8DIRECT(INPOSSENSOR_BASE, 0);

        printf("Capteurs = 0x%02X\n", v);

        // pause
        for (i = 0; i < 500000; i++)
        {
            // rien
        }
    }

    return 0;
}
