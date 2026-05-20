#include <stdio.h>
#include "system.h"
#include "io.h"
#include "alt_types.h"

#define SWAP_BASE       SWAP_OCTETS_COMPONENT_0_BASE
#define SELECT_BASE     select_0_BASE
#define REG_OFFSET(x)   ((x)*4)

// Fonctions pour accéder au swap
static void swap_write(alt_u32 value) {
    IOWR_32DIRECT(SWAP_BASE, 0, value);
}

static alt_u32 swap_read() {
    return IORD_32DIRECT(SWAP_BASE, 0);
}

// Fonctions pour piloter le PIO select
static void select_write(alt_u16 mode) {
    IOWR_16DIRECT(SELECT_BASE, 0, mode);
}

int main(void) {
    alt_u32 input = 0x12345678;
    alt_u32 output;

    printf("==== TEST SWAP OCTETS COMPONENT ====\n");

    // Mode 0 : [O0|O1|O2|O3]
    select_write(0); // écrire 0 dans le PIO pour mode 0
    swap_write(input);
    output = swap_read();
    printf("Mode 0:\n");
    printf("Entrée  : 0x%08X\n", (unsigned int)input);
    printf("Sortie  : 0x%08X\n", (unsigned int)output);

    // Mode 1 : [O1|O0|O3|O2]
    select_write(1); // écrire 1 dans le PIO pour mode 1
    swap_write(input);
    output = swap_read();
    printf("Mode 1:\n");
    printf("Entrée  : 0x%08X\n", (unsigned int)input);
    printf("Sortie  : 0x%08X\n", (unsigned int)output);

    return 0;
}