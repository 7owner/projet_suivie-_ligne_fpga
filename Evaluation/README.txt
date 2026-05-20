# Création d’un IP Core PWM sous Qsys / Nios II

Le but de ce projet était de créer un IP Core personnalisé permettant de piloter les moteurs de la plateforme CuteCar à l’aide d’un processeur Nios II et du bus Avalon sous Quartus II et Qsys (Platform Designer).

Pour cela, nous sommes partis d’un composant spécialisé déjà existant nommé `PWM_generation.vhd`. Ce composant permet de générer des signaux PWM afin de contrôler la vitesse des moteurs, leur sens de rotation ainsi que leur activation.

Cependant, ce composant ne pouvait pas être utilisé directement par le processeur Nios II. Nous avons donc développé une interface Avalon appelée `PWM_avalon_interface.vhd`. Cette interface agit comme un intermédiaire entre le processeur et le composant PWM. Elle permet au processeur Nios II d’envoyer des commandes via le bus Avalon grâce à des écritures mémoire.

Le composant a ensuite été importé dans Qsys à l’aide du Component Editor afin de créer un véritable IP Core personnalisé compatible Avalon-MM.

Le système Qsys réalisé contient :
- un processeur Nios II,
- une mémoire SDRAM,
- un JTAG UART,
- des PIO pour les LEDs et les switches,
- ainsi que notre IP Core PWM personnalisé.

Le top-level utilisé dans le projet est `lights.vhd`. Ce fichier permet de connecter :
- la clock FPGA,
- la SDRAM,
- les LEDs,
- les switches,
- et les sorties PWM vers les moteurs du CuteCar.

Les sorties moteurs utilisées sont :
- `MTRR_P`
- `MTRR_N`
- `MTRL_P`
- `MTRL_N`

Le driver moteur est activé grâce au signal :

```vhdl
MTR_Sleep_n <= '1';