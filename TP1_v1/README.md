# TP1_v1 - Base Nios II LED/switches

Cette version valide le premier systeme Quartus/Qsys. Le programme `app_software/lights.c` lit les interrupteurs en memoire-mappee et recopie leur valeur sur les LED.

## Points principaux

- Projet Quartus : `lights.qpf` et `lights.qsf`.
- Systeme Qsys : `nios_system.qsys`.
- Top-level VHDL : `lights.vhd` et variante SDRAM `lights_sdram.vhd`.
- Logiciel Nios II : `app_software/lights.c`.

Cette etape sert de test minimal pour verifier que le processeur Nios II, les peripheriques LED/switches et le top-level VHDL communiquent correctement.
