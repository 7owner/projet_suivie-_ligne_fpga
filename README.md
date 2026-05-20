# README - IPCore Acquisition Capteurs Sol Avalon-MM

## 1. Objectif du projet

L'objectif du projet est de creer un **IPCore Avalon-MM** permettant au processeur **NIOS II** de :

* piloter les capteurs sol du robot CuteCar,
* lire les donnees du convertisseur ADC LTC2308,
* acceder aux valeurs des capteurs depuis un programme C/HAL,
* exporter des signaux de debug vers les LEDs.

Le systeme repose sur :

```text
NIOS II <-> Bus Avalon-MM <-> IPCore Acquisition <-> LTC2308 <-> Capteurs IR
```

---

# 2. Architecture globale

Le projet contient plusieurs blocs :

| Bloc | Role |
| ---------------------------------- | ----------------------------------- |
| `nios_system.qsys` | Systeme Qsys contenant NIOS II |
| `acquisition_avalon_interface.vhd` | IPCore Avalon-MM acquisition |
| `capteurs_sol.vhd` | Gestion brute ADC LTC2308 |
| `capteurs_sol_seuil.vhd` | Comparaison seuil / vecteur logique |
| `pll_2freqs.vhd` | Generation horloges 40 MHz + 2 kHz |
| `lights.vhd` | Top-level Quartus |

---

# 3. Fonctionnement general

## 3.1 Acquisition ADC

Le module :

```text
capteurs_sol.vhd
```

pilote le convertisseur :

```text
LTC2308
```

via les signaux SPI :

| Signal | Role |
| ------------- | -------------------- |
| `ADC_CONVSTr` | lancement conversion |
| `ADC_SCK` | horloge SPI |
| `ADC_SDIr` | configuration ADC |
| `ADC_SDO` | donnees ADC |

---

## 3.2 Horloges utilisees

La PLL genere :

| Horloge | Usage |
| ------- | ------------------------- |
| 40 MHz | SPI ADC |
| 2 kHz | declenchement acquisition |

Le composant :

```vhdl
pll_2freqs
```

est utilise dans l'IPCore.

---

# 4. Interface Avalon-MM

L'IPCore expose plusieurs registres accessibles par le NIOS II.

## Mapping memoire

| Offset | Fonction |
| ------ | -------- |
| 0 | READY |
| 1 | CAPT0 |
| 2 | CAPT1 |
| 3 | CAPT2 |
| 4 | CAPT3 |
| 5 | CAPT4 |
| 6 | CAPT5 |
| 7 | CAPT6 |

Les offsets sont accedes en HAL avec :

```c
#define REG_OFFSET(x) ((x) * 4)
```

car Avalon utilise un adressage 32 bits.

Le composant `acquisition_avalon_interface.vhd` est le point central du projet. Il encapsule la logique d'acquisition, expose les registres au NIOS II, gere les exports Qsys et transforme l'acquisition ADC en peripherique memoire directement exploitable en logiciel.

---

# 5. Export des signaux Qsys

Dans Qsys, plusieurs signaux ont ete exportes :

| Export | Description |
| -------------------- | ----------------- |
| `adc_convstr_export` | ADC CONVST |
| `adc_sck_export` | ADC SCK |
| `adc_sdir_export` | ADC SDI |
| `adc_sdo_export` | ADC SDO |
| `vect_capt_export` | debug LEDs |
| `data_ready_export` | acquisition prete |

---

# 6. Top-level Quartus

Le fichier :

```text
lights.vhd
```

connecte :

* SDRAM,
* moteurs,
* acquisition ADC,
* LEDs de debug.

Connexion ADC :

```vhdl
adc_convstr_export => LTC_ADC_CONVST,
adc_sck_export     => LTC_ADC_SCK,
adc_sdir_export    => LTC_ADC_SDI,
adc_sdo_export     => LTC_ADC_SDO
```

---

# 7. Debug LEDs

Les LEDs ont ete utilisees pour verifier :

* l'activite acquisition,
* les donnees capteurs,
* le signal READY.

Exemple :

```vhdl
LED <= data_ready_s & vect_capt_s;
```

ou :

```vhdl
vect_capt_export <= snap_data0(6 downto 0);
```

pour afficher directement les bits ADC.

---

# 8. Snapshot des donnees

Un mecanisme de snapshot a ete ajoute :

```vhdl
snap_data0 <= data0_s;
```

afin de :

* stabiliser les donnees ADC,
* eviter les lectures incoherentes Avalon.

Le snapshot est effectue sur front montant de :

```vhdl
data_ready_s
```

---

# 9. Synchronisation multi-horloge

Une synchronisation a ete ajoutee entre :

| Domaine | Horloge |
| ------------- | ------- |
| ADC | 40 MHz |
| Avalon / NIOS | 50 MHz |

avec :

```vhdl
ready_meta
ready_sync
ready_old
```

pour eviter les problemes de metastabilite.

---

# 10. Programme HAL C

Le logiciel HAL :

* lit les registres Avalon,
* affiche les valeurs ADC,
* affiche le signal READY.

Exemple :

```c
capt0 = acq_read(CAPT0_OFFSET);
```

Lecture Avalon :

```c
IORD_16DIRECT(ACQ_BASE, REG_OFFSET(reg));
```

---

# 11. Difficultes rencontrees

## 11.1 Offsets Avalon

Erreur initiale :

```c
(x) * 2
```

Correction :

```c
(x) * 4
```

a cause du bus Avalon 32 bits.

---

## 11.2 data_capture

Le composant attendait une impulsion.

Une version utilisant une clock continue bloquait la FSM acquisition.

---

## 11.3 capteurs_sol vs capteurs_sol_seuil

Deux approches ont ete testees :

| Module | Usage |
| -------------------- | ---------------------------- |
| `capteurs_sol` | donnees ADC brutes |
| `capteurs_sol_seuil` | detection logique noir/blanc |

---

# 12. Procedure compilation

Apres chaque modification :

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

# 13. Resultat obtenu

Le systeme permet :

* acquisition ADC depuis le NIOS II,
* lecture des capteurs via Avalon-MM,
* export des signaux vers LEDs,
* communication complete FPGA <-> NIOS II <-> LTC2308.

Le projet constitue maintenant une base solide pour :

* suivi de ligne,
* controle autonome,
* fusion capteurs/moteurs,
* algorithmes embarques sur CuteCar.

L'accent est volontairement mis sur le composant `acquisition_avalon_interface.vhd`, qui constitue le coeur du projet et la brique de reutilisation la plus importante pour la suite.
