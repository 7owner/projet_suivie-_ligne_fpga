# README — IPCore Acquisition Avalon-MM pour Capteurs Sol LTC2308

# 1. Présentation du projet

Ce projet consiste à développer un **IPCore Avalon-MM** permettant au processeur **NIOS II** de communiquer avec les capteurs sol du robot CuteCar via le convertisseur analogique-numérique :

```text
LTC2308
```

Le système permet :

* l’acquisition des capteurs infrarouges,
* la lecture des valeurs ADC depuis le logiciel HAL,
* l’intégration dans Qsys Platform Designer,
* l’export des signaux vers les LEDs,
* la création d’un périphérique mémoire-mappé Avalon.

---

# 2. Architecture générale

Architecture globale :

```text
                +------------------+
                |     NIOS II      |
                +------------------+
                         |
                         |
                    Avalon-MM
                         |
                         v
        +--------------------------------+
        | acquisition_avalon_interface   |
        +--------------------------------+
              |                  |
              |                  |
              v                  v
        pll_2freqs         capteurs_sol
                                  |
                                  |
                                  v
                              LTC2308
                                  |
                                  v
                         Capteurs infrarouges
```

---

# 3. Fichiers principaux

| Fichier                            | Rôle                  |
| ---------------------------------- | --------------------- |
| `acquisition_avalon_interface.vhd` | IPCore Avalon-MM      |
| `capteurs_sol.vhd`                 | Acquisition brute ADC |
| `capteurs_sol_seuil.vhd`           | Détection noir/blanc  |
| `pll_2freqs.vhd`                   | Génération horloges   |
| `lights.vhd`                       | Top-level Quartus     |
| `nios_system.qsys`                 | Système NIOS II       |
| `acquisition_test_soc.c`           | Programme HAL         |

---

# 4. Fonctionnement du système

Le système effectue les opérations suivantes :

1. génération des horloges via PLL,
2. pilotage SPI du LTC2308,
3. acquisition des 7 capteurs,
4. stockage des données dans des registres Avalon,
5. lecture par le NIOS II,
6. affichage des données via UART et LEDs.

---

# 5. PLL et horloges

Le composant :

```vhdl
pll_2freqs
```

génère :

| Horloge | Usage                     |
| ------- | ------------------------- |
| 40 MHz  | Horloge SPI ADC           |
| 2 kHz   | Déclenchement acquisition |

Connexion :

```vhdl
U_PLL : pll_2freqs
```

---

# 6. Communication SPI avec le LTC2308

Le LTC2308 utilise :

| Signal        | Fonction             |
| ------------- | -------------------- |
| `ADC_CONVSTr` | lancement conversion |
| `ADC_SCK`     | horloge SPI          |
| `ADC_SDIr`    | configuration ADC    |
| `ADC_SDO`     | données ADC          |

Ces signaux sont exportés depuis Qsys vers le top-level.

---

# 7. Intégration Qsys / Platform Designer

L’IPCore a été intégré dans :

```text
nios_system.qsys
```

via une interface :

```text
Avalon Memory-Mapped Slave
```

Interfaces utilisées :

| Interface | Type            |
| --------- | --------------- |
| `clock`   | Clock Sink      |
| `resetn`  | Reset Sink      |
| `s0`      | Avalon-MM Slave |
| `conduit` | Export ADC      |

---

# 8. Mapping mémoire Avalon

L’IPCore expose plusieurs registres mémoire :

| Offset | Fonction |
| ------ | -------- |
| 0      | READY    |
| 1      | CAPT0    |
| 2      | CAPT1    |
| 3      | CAPT2    |
| 4      | CAPT3    |
| 5      | CAPT4    |
| 6      | CAPT5    |
| 7      | CAPT6    |

Lecture via :

```c
IORD_16DIRECT()
```

Écriture via :

```c
IOWR_16DIRECT()
```

---

# 9. Particularité Avalon : offsets ×4

Le bus Avalon du NIOS II utilise un adressage 32 bits.

Les offsets doivent donc être multipliés par 4 :

```c
#define REG_OFFSET(x) ((x) * 4)
```

Exemple :

| Registre | Adresse réelle |
| -------- | -------------- |
| offset 0 | 0x00           |
| offset 1 | 0x04           |
| offset 2 | 0x08           |

---

# 10. Acquisition ADC brute

Le composant :

```text
capteurs_sol.vhd
```

retourne les vraies valeurs ADC des capteurs.

Exemple :

```text
CAPT0 = 52
CAPT1 = 65
CAPT2 = 48
```

Ce composant a été utilisé pour :

* déboguer le SPI,
* vérifier les acquisitions ADC,
* valider le LTC2308.

---

# 11. Utilisation de capteurs_sol_seuil

Le composant :

```text
capteurs_sol_seuil.vhd
```

ajoute :

* une comparaison avec un seuil,
* la génération de :

```text
vect_capt
```

Architecture :

```text
ADC -> capteurs_sol_seuil -> vect_capt
```

---

# 12. Pourquoi nous avons basculé vers capteurs_sol

Pendant le debug, les valeurs retournées étaient :

```text
0
1
0
1
```

car :

```text
capteurs_sol_seuil
```

retourne déjà des données logiques seuillées.

Il devenait impossible de savoir si :

* le problème venait du SPI,
* du LTC2308,
* du seuil,
* ou des comparateurs.

Nous avons donc temporairement utilisé :

```text
capteurs_sol.vhd
```

seul pour :

* observer les vraies valeurs ADC,
* valider le matériel,
* isoler les problèmes.

Architecture debug :

```text
ADC -> capteurs_sol -> Avalon
```

Une fois l’acquisition validée, il sera possible de réintroduire :

```text
capteurs_sol_seuil
```

pour :

* recréer `vect_capt`,
* réaliser le suivi de ligne,
* piloter le robot CuteCar.

---

# 13. Snapshot des données

Un système de snapshot a été ajouté :

```vhdl
snap_data0 <= data0_s;
```

Objectif :

* stabiliser les données lues par Avalon,
* éviter les incohérences multi-horloges.

Le snapshot est réalisé sur front montant de :

```vhdl
data_ready_s
```

---

# 14. Synchronisation multi-domaines

Deux domaines d’horloge existent :

| Domaine       | Horloge |
| ------------- | ------- |
| ADC           | 40 MHz  |
| Avalon / NIOS | 50 MHz  |

Pour éviter la métastabilité :

```vhdl
ready_meta
ready_sync
ready_old
```

ont été utilisés.

---

# 15. Top-level Quartus

Le fichier :

```text
lights.vhd
```

connecte :

* SDRAM,
* moteurs,
* acquisition ADC,
* LEDs.

Connexion ADC :

```vhdl
adc_convstr_export => LTC_ADC_CONVST,
adc_sck_export     => LTC_ADC_SCK,
adc_sdir_export    => LTC_ADC_SDI,
adc_sdo_export     => LTC_ADC_SDO
```

---

# 16. Debug via LEDs

Les LEDs ont été utilisées pour :

* visualiser READY,
* afficher les bits ADC,
* vérifier les acquisitions.

Exemple :

```vhdl
LED <= data_ready_s & vect_capt_s;
```

ou :

```vhdl
vect_capt_export <= snap_data0(6 downto 0);
```

---

# 17. Programme HAL C

Le programme HAL :

* lit les registres Avalon,
* affiche les capteurs,
* vérifie READY.

Lecture :

```c
capt0 = acq_read(CAPT0_OFFSET);
```

Affichage :

```c
printf("CAPT0 = %u\n", capt0);
```

---

# 18. Difficultés rencontrées

## 18.1 Offsets Avalon

Erreur initiale :

```c
(x) * 2
```

Correction :

```c
(x) * 4
```

---

## 18.2 data_capture

Le composant attendait une impulsion et non une clock continue.

---

## 18.3 capteurs_sol_seuil

Le composant masquait les valeurs ADC réelles.

---

## 18.4 Synchronisation horloges

Problèmes entre :

* 40 MHz,
* 50 MHz.

Résolus via synchronisation Avalon.

---

# 19. Procédure de compilation

Après chaque modification :

```text
1. Analyze Synthesis Files
2. Generate Qsys
3. Compile Quartus
4. Programmer FPGA
5. Regenerate BSP
6. Clean Project
7. Build HAL
```

---

# 20. Résultat obtenu

Le projet permet maintenant :

* communication NIOS ↔ Avalon ↔ ADC,
* acquisition capteurs,
* lecture via HAL,
* export LEDs,
* intégration Qsys complète,
* base fonctionnelle pour le suivi de ligne du CuteCar.

Le système constitue désormais une base robuste pour :

* robot autonome,
* suivi de ligne,
* contrôle moteur intelligent,
* traitement embarqué FPGA + NIOS II.
