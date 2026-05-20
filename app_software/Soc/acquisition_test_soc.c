#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "io.h"
#include "alt_types.h"

#ifndef ACQUISITION_AVALON_INTERFACE_0_BASE
#error "ACQUISITION_AVALON_INTERFACE_0_BASE introuvable : verifie le nom exact dans system.h"
#endif

#define ACQ_BASE ACQUISITION_AVALON_INTERFACE_0_BASE

#define CAPT0_OFFSET      0
#define CAPT1_OFFSET      1
#define CAPT2_OFFSET      2
#define CAPT3_OFFSET      3
#define CAPT4_OFFSET      4
#define CAPT5_OFFSET      5
#define CAPT6_OFFSET      6

#define VECT_OFFSET       7
#define READY_OFFSET      8
#define NIVEAU_OFFSET     9

#define REG16_OFFSET(x)   ((x) * 4)

static alt_u16 acq_read(alt_u16 reg)
{
    return IORD_16DIRECT(ACQ_BASE, REG16_OFFSET(reg));
}

static void acq_write(alt_u16 reg, alt_u16 value)
{
    IOWR_16DIRECT(ACQ_BASE, REG16_OFFSET(reg), value);
}

int main(void)
{
    alt_u16 capt0;
    alt_u16 capt1;
    alt_u16 capt2;
    alt_u16 capt3;
    alt_u16 capt4;
    alt_u16 capt5;
    alt_u16 capt6;

    alt_u16 vect;
    alt_u16 ready;
    int i;

    printf("====================================\n");
    printf(" TEST ACQUISITION CAPTEURS SOL\n");
    printf("====================================\n");

    printf("ACQ BASE = 0x%08lX\n", (unsigned long)ACQ_BASE);

    /*
     * Reglage seuil detection
     * plus faible = plus sensible
     */
    acq_write(NIVEAU_OFFSET, 40);

    while (1)
    {
        ready = acq_read(READY_OFFSET);

        capt0 = acq_read(CAPT0_OFFSET);
        capt1 = acq_read(CAPT1_OFFSET);
        capt2 = acq_read(CAPT2_OFFSET);
        capt3 = acq_read(CAPT3_OFFSET);
        capt4 = acq_read(CAPT4_OFFSET);
        capt5 = acq_read(CAPT5_OFFSET);
        capt6 = acq_read(CAPT6_OFFSET);

        vect = acq_read(VECT_OFFSET) & 0x007F;

        printf("\n----------------------------------\n");
        printf("READY = %u\n", (unsigned int)(ready & 0x0001));

        printf("CAPT0 = %4u\n", (unsigned int)capt0);
        printf("CAPT1 = %4u\n", (unsigned int)capt1);
        printf("CAPT2 = %4u\n", (unsigned int)capt2);
        printf("CAPT3 = %4u\n", (unsigned int)capt3);
        printf("CAPT4 = %4u\n", (unsigned int)capt4);
        printf("CAPT5 = %4u\n", (unsigned int)capt5);
        printf("CAPT6 = %4u\n", (unsigned int)capt6);

        printf("VECT_CAPT = 0x%02X\n", (unsigned int)vect);

        printf("BINAIRE   = ");
        for (i = 6; i >= 0; i--)
        {
            printf("%u", (unsigned int)((vect >> i) & 0x1));
        }
        printf("\n");

        usleep(200000);
    }

    return 0;
}