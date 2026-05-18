#include <stdint.h>

#define MOTOR_R   (*(volatile unsigned int*) 0x00000010)  // Contrôle moteur droit
#define MOTOR_L   (*(volatile unsigned int*) 0x00000000)  // Contrôle moteur gauche

// Liste des vitesses (en hexadécimal)
uint16_t speeds[] = {0x2800, 0x288B, 0x29C4, 0x2AFC, 0x2C35};
uint8_t speed_index = 0;  // Indice pour parcourir les vitesses

// Fonction de commande des moteurs avec une vitesse spécifique
void set_motor_speed(uint16_t speed)
{
    uint16_t cmd = 0x2000 | (speed & 0x0FFF);  // GO=1, DIR=0 (forward)
    MOTOR_R = cmd;
    MOTOR_L = cmd;
}

// Fonction pour arrêter les moteurs
void stop_motors()
{
    MOTOR_R = 0x2000;   
    MOTOR_L = 0x2000;
}

int main()
{
    while (1)
    {
        // 1) Applique la vitesse actuelle
        set_motor_speed(speeds[speed_index]);

        // 2) Stoppe les moteurs avant de changer de vitesse
        stop_motors();

        // 3) Passe à la vitesse suivante
        speed_index++;

        // 4) Si on dépasse la dernière vitesse → retour à la première
        if (speed_index >= sizeof(speeds) / sizeof(speeds[0]))
        {
            speed_index = 0;
        }
    }

    return 0;
}
