#include "io.h"
#include "system.h"
int main() {
    while (1) {
        IOWR(TO_HEX_BASE, 0, 0x1234);
    }
}
