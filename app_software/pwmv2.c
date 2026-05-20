#include <stdint.h>

#define MOTOR_R   (*(volatile unsigned int*) 0x00000010)
#define MOTOR_L   (*(volatile unsigned int*) 0x00000000)

// Liste des vitesses
uint16_t speeds[] = {0x2800, 0x288B, 0x29C4, 0x2AFC, 0x2C35};
uint8_t speed_index = 0;

// Petit délai
void delay(volatile uint32_t t)
{
    while(t--) ;
}

// Applique une vitesse
void set_motor_speed(uint16_t speed)
{
    uint16_t cmd = 0x2000 | (speed & 0x0FFF);  // GO=1, DIR=0
    MOTOR_R = cmd;
    MOTOR_L = cmd;
}

// Stoppe les moteurs
void stop_motors()
{
    MOTOR_R = 0x0000;
    MOTOR_L = 0x0000;
}

int main()
{
    while (1)
    {
        // 1) Applique la vitesse actuelle
        set_motor_speed(speeds[speed_index]);

        // 2) Laisse tourner un moment
        delay(500000);

        // 3) Stoppe les moteurs
        stop_motors();

        // 4) Pause avant la vitesse suivante
        delay(300000);

        // 5) Passe à la vitesse suivante
        speed_index++;

        if (speed_index >= sizeof(speeds) / sizeof(speeds[0]))
        {
            speed_index = 0;
        }
    }

    return 0;
}
