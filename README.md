# Projet suivi de ligne FPGA - CUTECAR

Ce depot regroupe les differentes etapes du TP de conception FPGA autour d'une carte Altera/Intel FPGA, d'un systeme Nios II/Qsys et du robot CUTECAR. L'objectif final est de commander le robot pour detecter une ligne au sol, calculer sa position et adapter les moteurs avec des modules materiels VHDL.

## Objectifs du projet

- Mettre en place un projet Quartus avec un systeme Nios II/Qsys.
- Valider les entrees/sorties de base avec les interrupteurs et les LED.
- Ajouter une commande PWM pour les moteurs droit et gauche.
- Lire les capteurs de sol via l'ADC et appliquer un seuil de detection.
- Calculer la position de la ligne a partir d'un vecteur de capteurs.
- Commander le suivi de ligne et la rotation du robot avec des blocs VHDL dedies.

## Organisation du depot

| Dossier | Role |
| --- | --- |
| `TP1_v1/` | Premiere base Quartus/Qsys : lecture des interrupteurs et recopie sur les LED avec un programme C minimal. |
| `TP1_v2/` | Separation plus claire entre la partie materielle (`app_hardware`) et logicielle (`app_software`) autour du meme principe LED/switches. |
| `TP1_v3/` | Ajout de la generation PWM pour commander les deux moteurs et premiers programmes de test des vitesses. |
| `TP1_v4/` | Integration des capteurs de sol et lecture des valeurs seuillees depuis le processeur Nios II. |
| `TP1_v4_bis/` | Passage sur l'architecture CUTECAR : top-level robot, modules IP reutilisables et documentation du TP. |
| `TP1_v5/` | Ajout du calcul de position de ligne (`POS.vhd`) et du module de suivi de ligne (`suivi_ligne.vhd`). |
| `TP1_v6/` | Version la plus avancee : controle de suivi de ligne (`CTL_SL.vhd`) et controle de rotation (`CTL_Rot.vhd`) avec synchronisation sur `data_ready`. |

## Fichiers importants

- `*.qpf`, `*.qsf` : fichiers de projet et d'affectation Quartus.
- `*.qsys` : description du systeme Qsys/Platform Designer.
- `*.vhd` : modules materiels VHDL.
- `app_software/*.c` : programmes C executes sur Nios II.
- `TP_DOC/*.pdf` : documents de reference du TP.
- `seuil.xlsx` : notes/valeurs de seuil utilisees pour les capteurs de sol.

## Evolution technique

### TP1_v1 et TP1_v2

Les premieres versions valident la chaine Quartus/Qsys et les acces memoire-mappes depuis Nios II. Le programme `lights.c` lit l'adresse des interrupteurs et ecrit directement la valeur vers les LED. Cette etape sert de test de communication entre le processeur embarque, les peripheriques et le top-level VHDL.

### TP1_v3

Cette version ajoute le module `PWM_generation.vhd`. Il genere une PWM a partir d'un mot de commande contenant :

- bit 13 : activation `GO` ;
- bit 12 : direction ;
- bits 11 a 0 : rapport cyclique/vitesse.

Les programmes `pwm.c` et `pwmv2.c` testent plusieurs vitesses sur les moteurs gauche et droit via des adresses memoire-mappees.

### TP1_v4 et TP1_v4_bis

Ces versions introduisent la lecture des capteurs de sol et leur seuillage. Le module `capteurs_sol_seuil.vhd` pilote l'ADC, recupere les canaux capteurs et produit un vecteur compact de detection. Le programme `seuils.c` lit ce vecteur cote Nios II pour valider les valeurs.

### TP1_v5

La version `TP1_v5` ajoute la logique de suivi de ligne :

- `POS.vhd` convertit le vecteur de capteurs en position signee de la ligne ;
- `suivi_ligne.vhd` ajuste les PWM gauche/droite en fonction de l'erreur de position ;
- `Top_CUTECAR.vhd` integre les modules au niveau robot.

### TP1_v6

La version `TP1_v6` structure davantage le controle :

- `CTL_SL.vhd` calcule les commandes moteurs de suivi de ligne uniquement lors d'une nouvelle donnee ADC valide (`data_ready`) ;
- `CTL_Rot.vhd` gere une rotation jusqu'a retrouver le capteur central, avec etat interne `IDLE`, `ROTATE`, `DONE` ;
- les commandes moteurs sont empaquetees avec les bits `GO`, `DIR` et `duty`.

## Utilisation

1. Ouvrir la version souhaitee dans Quartus avec le fichier `.qpf` correspondant.
2. Verifier les affectations dans le fichier `.qsf`.
3. Ouvrir le systeme `.qsys` dans Platform Designer si une regeneration est necessaire.
4. Compiler le projet Quartus.
5. Charger le bitstream sur la carte FPGA.
6. Compiler et televerser le programme C Nios II lorsque la version utilise une application logicielle.

## Remarques Git

Les dossiers generes par Quartus et les artefacts de compilation sont ignores pour garder un depot lisible et exploitable. Les sources VHDL, C, fichiers de projet Quartus, fichiers Qsys, documents de TP et fichiers de seuil sont conserves.
