# TP1_v2 - Organisation hardware/software

Cette version reprend le test LED/switches en separant mieux les sources materielles et logicielles.

## Points principaux

- Sources hardware dans `app_hardware/`.
- Sources software dans `app_software/`.
- Systeme Platform Designer dans `nios_system.qsys`.
- Projet Quartus conserve dans `lights.qpf` et `lights.qsf`.

Le fonctionnement reste volontairement simple : lire les interrupteurs et afficher la valeur sur les LED, afin de stabiliser l'organisation du projet avant l'ajout des moteurs.
