#include <stdint.h>

#define PWM_BASE  0x00000020u
#define MOTOR_R   (*(volatile uint16_t *)(PWM_BASE + 0x0u))
#define MOTOR_L   (*(volatile uint16_t *)(PWM_BASE + 0x2u))

uint16_t speeds[] = {0x0280, 0x038B, 0x04C4, 0x05FC, 0x0835};
uint8_t speed_index = 0;

void set_motor_speed(uint16_t speed)
{
    uint16_t cmd = 0x2000u | (speed & 0x0FFFu);
    MOTOR_R = cmd;
    MOTOR_L = cmd;
}

void stop_motors(void)
{
    MOTOR_R = 0x0000u;
    MOTOR_L = 0x0000u;
}

int main(void)
{
    while (1) {
        set_motor_speed(speeds[speed_index]);
        stop_motors();

        speed_index++;
        if (speed_index >= sizeof(speeds) / sizeof(speeds[0])) {
            speed_index = 0;
        }
    }

    return 0;
}
