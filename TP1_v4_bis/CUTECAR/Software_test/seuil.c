#include "alt_types.h"
#include "io.h"
#include <stdio.h>

// Adresses Qsys des capteurs (à confirmer)
#define POS_DATA0R_BASE 0x0030
#define POS_DATA1R_BASE 0x0040
#define POS_DATA2R_BASE 0x0050
#define POS_DATA3R_BASE 0x0060
#define POS_DATA4R_BASE 0x0070
#define POS_DATA5R_BASE 0x0080
#define POS_DATA6R_BASE 0x0090

int main() {
    alt_u32 capteur_base[7] = {
        POS_DATA0R_BASE, POS_DATA1R_BASE, POS_DATA2R_BASE,
        POS_DATA3R_BASE, POS_DATA4R_BASE, POS_DATA5R_BASE, POS_DATA6R_BASE
    };
    int i;
    alt_u8 val;

    while(1) {
       // printf("Capteurs: ");
        for(i=0; i<7; i++) {
            val = IORD_8DIRECT(capteur_base[i], 0);  // Lecture directe
            printf("%u;",val);           // Affichage immédiat
        }
        printf("\n");

        // Petite pause pour ne pas saturer l'UART
        volatile int j;
        for(j=0;j<500000;j++);
    }

    return 0;
}