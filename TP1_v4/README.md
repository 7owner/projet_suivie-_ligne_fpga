# TP1_v4 - Lecture des capteurs de sol

Cette version introduit la lecture des capteurs de sol et la validation logicielle des valeurs seuillees.

## Points principaux

- `app_software/seuils.c` lit le peripherique capteur via une adresse memoire-mappee et affiche le vecteur obtenu.
- `Ip_Module/` contient les modules IP ajoutes au systeme.
- `nios_system.qsys` decrit l'integration Qsys/Platform Designer.
- `lights.vhd` et `lights_sdram.vhd` restent les top-levels de reference pour l'integration Quartus.

Le but de cette etape est de verifier que les capteurs remontent une information exploitable avant la logique de suivi de ligne complete.
