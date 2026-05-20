# README – Projet SoC : Composant Qsys `swap_bytes_component`

---

# 1. Objectif du projet

L’objectif de ce projet est de concevoir un **IP Core personnalisé** sous **Qsys / Platform Designer** utilisant une interface **Avalon Memory-Mapped Slave**.

Ce composant permet d’effectuer une **inversion d’octets** sur un mot de 32 bits.

Le système est piloté par un processeur **NIOS II**.

---

# 2. Structure du mot 32 bits

Le mot 32 bits est organisé de la manière suivante :

```text
[ Octet3 | Octet2 | Octet1 | Octet0 ]
```

Exemple :

```text
0x12 34 56 78
```

avec :

| Octet  | Valeur |
| ------ | ------ |
| Octet3 | 0x12   |
| Octet2 | 0x34   |
| Octet1 | 0x56   |
| Octet0 | 0x78   |

---

# 3. Modes d’inversion implémentés

Deux modes de swap ont été implémentés.

---

## MODE 0

Transformation :

```text
[ O3 | O2 | O1 | O0 ]
→
[ O0 | O1 | O2 | O3 ]
```

Exemple :

```text
Entrée  : 0x12345678
Sortie  : 0x78563412
```

---

## MODE 1

Transformation :

```text
[ O3 | O2 | O1 | O0 ]
→
[ O1 | O0 | O3 | O2 ]
```

Exemple :

```text
Entrée  : 0x12345678
Sortie  : 0x56781234
```

---

# 4. Architecture globale du système

Le système contient :

* Un processeur NIOS II
* Un composant `swap_bytes_component`
* Un composant `pio_select`
* Le bus Avalon-MM
* Des LEDs pour visualisation

Architecture générale :

```text
                    =========================
                    =      NIOS II CPU      =
                    =   Avalon-MM MASTER    =
                    =========================
                               |
                               |
                               v

        =================================================
        ||         AVALON INTERCONNECT / BUS           ||
        =================================================
                     |                         |
                     |                         |
                     v                         v

         ====================      ==========================
         =    pio_select    =      = swap_bytes_component  =
         = Avalon-MM Slave  =      =  Avalon-MM Slave      =
         ====================      ==========================
                    |                          |
                    | q(0)                     |
                    +-------> mode_select -----+

```

---

# 5. Rôle du composant `pio_select`

Le composant `pio_select` a été créé afin de choisir dynamiquement le mode d’inversion utilisé par `swap_bytes_component`.

Il fonctionne comme un simple registre 16 bits accessible via Avalon-MM.

---

# 6. Interface du composant `pio_select`

```vhdl
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY pio_select IS
    PORT(
        clk        : IN  STD_LOGIC;
        reset_n    : IN  STD_LOGIC;
        chipselect : IN  STD_LOGIC;
        write      : IN  STD_LOGIC;
        writedata  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        q          : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END pio_select;
```

---

# 7. Fonctionnement du `pio_select`

Quand :

```text
chipselect = '1'
ET
write = '1'
```

la valeur :

```text
writedata
```

est stockée dans le registre interne.

La sortie :

```text
q(0)
```

est utilisée comme signal :

```text
mode_select
```

pour sélectionner le mode d’inversion du composant swap.

---

# 8. Interface du composant `swap_bytes_component`

```vhdl
ENTITY swap_bytes IS
    PORT(
        clk         : IN  std_logic;
        reset_n     : IN  std_logic;
        address     : IN  std_logic_vector(1 downto 0);
        chipselect  : IN  std_logic;
        read        : IN  std_logic;
        write       : IN  std_logic;
        writedata   : IN  std_logic_vector(31 downto 0);
        readdata    : OUT std_logic_vector(31 downto 0);
        waitrequest : OUT std_logic;
        mode_select : IN  std_logic
    );
END swap_bytes;
```

---

# 9. Fonctionnement du composant `swap_bytes_component`

Le processeur NIOS II écrit un mot 32 bits dans :

```text
writedata
```

Le composant :

1. récupère le mot
2. vérifie le mode sélectionné
3. applique le swap correspondant
4. retourne le résultat via :

```text
readdata
```

---

# 10. Implémentation du swap

---

## Si `mode_select = 0`

```vhdl
reg_out <= writedata(7 downto 0)
        & writedata(15 downto 8)
        & writedata(23 downto 16)
        & writedata(31 downto 24);
```

---

## Si `mode_select = 1`

```vhdl
reg_out <= writedata(15 downto 8)
        & writedata(7 downto 0)
        & writedata(31 downto 24)
        & writedata(23 downto 16);
```

---

# 11. Pourquoi utiliser Avalon-MM ?

Avalon-MM permet :

* la communication CPU ↔ périphérique
* la lecture et écriture mémoire
* l’intégration simple dans Qsys
* la création d’IP Core personnalisés
* le pilotage matériel depuis le logiciel

---

# 12. Signaux Avalon utilisés

| Signal      | Rôle                   |
| ----------- | ---------------------- |
| clk         | Horloge système        |
| reset_n     | Reset actif bas        |
| chipselect  | Sélection du composant |
| write       | Écriture Avalon        |
| read        | Lecture Avalon         |
| writedata   | Données écrites        |
| readdata    | Données lues           |
| waitrequest | Gestion attente bus    |

---

# 13. Configuration Qsys

---

## `swap_bytes_component`

Type :

```text
Avalon-MM Slave
```

Adresse :

```text
0x0040
```

---

## `pio_select`

Type :

```text
Avalon-MM Slave
```

Adresse :

```text
0x0050
```

---

# 14. Fonctionnement logiciel (NIOS II)

Le logiciel NIOS II :

1. écrit le mode dans `pio_select`
2. écrit un mot dans `swap_bytes_component`
3. lit le résultat inversé

---

# 15. Exemple de code C

---

## Sélection du mode

```c
IOWR_16DIRECT(PIO_SELECT_BASE, 0, 0);
```

ou :

```c
IOWR_16DIRECT(PIO_SELECT_BASE, 0, 1);
```

---

## Écriture du mot

```c
IOWR_32DIRECT(SWAP_BASE, 0, 0x12345678);
```

---

## Lecture du résultat

```c
data = IORD_32DIRECT(SWAP_BASE, 0);
```

---

# 16. Exemple complet de test

---

## MODE 0

```text
Entrée  : 0x12345678
Sortie  : 0x78563412
```

---

## MODE 1

```text
Entrée  : 0x12345678
Sortie  : 0x56781234
```

---

# 17. Visualisation sur LEDs

Les LEDs affichent :

```vhdl
LED <= swapped_data(7 DOWNTO 0);
```

Cela permet de visualiser les bits du résultat du swap directement sur la carte FPGA.

---

# 18. Top-level utilisé

Le top-level :

* instancie le NIOS II
* instancie `pio_select`
* instancie `swap_bytes_component`
* connecte `q(0)` vers `mode_select`
* affiche les résultats sur LEDs

---

# 19. Résultat final

Le système est capable de :

✅ recevoir un mot 32 bits
✅ choisir dynamiquement un mode de swap
✅ réaliser l’inversion matériellement
✅ retourner le résultat au NIOS II
✅ afficher le résultat sur LEDs
✅ être piloté totalement depuis le logiciel

---

# 20. Conclusion

Ce projet illustre :

* la création d’un composant matériel personnalisé
* l’utilisation du bus Avalon-MM
* l’intégration dans Qsys / Platform Designer
* la communication matériel ↔ logiciel
* le pilotage d’un IP Core depuis NIOS II
* l’utilisation d’un registre PIO pour modifier dynamiquement le comportement matériel

Le projet constitue un exemple complet de conception SoC sur FPGA avec :

* VHDL
* Avalon-MM
* Qsys
* NIOS II
* IP Core personnalisé
