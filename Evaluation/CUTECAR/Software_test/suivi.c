#include <stdio.h>
#include <io.h>

#define SWITCHES_OUT  0x00003000
#define VECT_POS      0x00000100
#define NIVEAU        0x00000110

#define POS0          0x00000030
#define POS1          0x00000040
#define POS2          0x00000050
#define POS3          0x00000060
#define POS4          0x00000070
#define POS5          0x00000080
#define POS6          0x00000090

static void delay_loop(volatile unsigned int count)
{
    while (count--) { }
}

static void print_bits7(unsigned int v)
{
    int i;
    for (i = 6; i >= 0; i--)
    {
        printf("%u", (v >> i) & 1u);
    }
}

int main(void)
{
    unsigned int sw;
    unsigned int vect;
    unsigned int niv;
    unsigned int d0, d1, d2, d3, d4, d5, d6;

    printf("=== Lecture capteurs CUTECAR ===\n");

    /* seuil initial */
    IOWR_32DIRECT(NIVEAU, 0, 10);

    /* start suivi de ligne */
    IOWR_32DIRECT(SWITCHES_OUT, 0, 1);

    while (1)
    {
        sw   = IORD_32DIRECT(SWITCHES_OUT, 0);
        vect = IORD_32DIRECT(VECT_POS, 0);
        niv  = IORD_32DIRECT(NIVEAU, 0);

        d0 = IORD_32DIRECT(POS0, 0);
        d1 = IORD_32DIRECT(POS1, 0);
        d2 = IORD_32DIRECT(POS2, 0);
        d3 = IORD_32DIRECT(POS3, 0);
        d4 = IORD_32DIRECT(POS4, 0);
        d5 = IORD_32DIRECT(POS5, 0);
        d6 = IORD_32DIRECT(POS6, 0);

        printf("SW=0x%08X | NIVEAU=%3u | VECT=0x%02X | bits=",
               sw, niv, vect & 0x7F);
        print_bits7(vect & 0x7F);

        printf(" | D0=%3u D1=%3u D2=%3u D3=%3u D4=%3u D5=%3u D6=%3u\n",
               d0, d1, d2, d3, d4, d5, d6);

        delay_loop(3000000);
    }

    return 0;
}