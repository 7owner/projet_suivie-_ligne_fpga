# TP1_v3 - Commande PWM des moteurs

Cette version ajoute la generation PWM pour commander les deux moteurs du robot.

## Points principaux

- `PWM_generation.vhd` genere les signaux PWM moteur droit et gauche.
- Les bits de commande sont organises avec `GO`, `DIR` et une consigne de vitesse sur 12 bits.
- `app_software/pwm.c` et `app_software/pwmv2.c` testent plusieurs vitesses depuis Nios II.
- `lights.vhd`, `lights_sdram.vhd` et `nios_system.qsys` integrent l'evolution materielle.

Cette etape permet de valider la commande bas niveau des moteurs avant d'ajouter la perception par capteurs.
