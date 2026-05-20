# README - Composant Qsys `swap_bytes_component`

## 1. Objectif du projet

Le but de ce projet est de creer un **composant materiel personnalise Qsys / Platform Designer** connecte au bus **Avalon Memory-Mapped (Avalon-MM Slave)**.

Ce composant permet de realiser une **inversion d'octets** sur un mot de 32 bits.

---

## 2. Structure du mot 32 bits

Le mot est organise comme suit :

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

# 3. Modes d'inversion implementes

Deux modes de swap ont ete ajoutes.

---

## MODE 0

Transformation :

```text
[ O3 | O2 | O1 | O0 ]
->
[ O0 | O1 | O2 | O3 ]
```

Exemple :

```text
Entree  : 0x12345678
Sortie  : 0x78563412
```

---

## MODE 1

Transformation :

```text
[ O3 | O2 | O1 | O0 ]
->
[ O1 | O0 | O3 | O2 ]
```

Exemple :

```text
Entree  : 0x12345678
Sortie  : 0x56781234
```

---

# 4. Architecture generale du systeme

Le systeme contient :

* Un processeur NIOS II
* Un composant Avalon-MM Slave `swap_bytes_component`
* Un registre PIO `pio_select`
* Le bus Avalon-MM

Architecture :

```text
                =========================
                =      NIOS II CPU      =
                =   Avalon-MM MASTER    =
                =========================
                           |
                           | Avalon-MM
                           v

    ==================================================
    ||          AVALON INTERCONNECT / BUS           ||
    ==================================================
              |                           |
              |                           |
              v                           v

   =====================      =====================
   =    pio_select      =      = swap_bytes_comp =
   = Avalon-MM Slave    =      = Avalon-MM Slave =
   =====================      =====================
              |                           |
              | q(0)                      |
              +-----------> mode_select --+

```

---

# 5. Fonctionnement du systeme

Le processeur NIOS II :

1. ecrit un mode dans `pio_select`
2. ecrit un mot 32 bits dans `swap_bytes_component`
3. lit le resultat apres inversion

---

# 6. Fonctionnement du PIO `pio_select`

Le composant `pio_select` est un simple registre 16 bits.

Il permet de selectionner le mode de swap.

---

## Interface du PIO

```vhdl
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

## Fonctionnement

Quand :

```text
chipselect = '1'
ET
write = '1'
```

alors :

```text
q <= writedata
```

Le bit :

```text
q(0)
```

est utilise comme :

```text
mode_select
```

du composant swap.

---

# 7. Fonctionnement du composant `swap_bytes_component`

---

## Interface Avalon-MM

```vhdl
ENTITY swap_bytes IS
    PORT(
        clk         : IN  std_logic;
        reset_n     : IN  std_logic;
        address     : IN  std_logic_vector(1 DOWNTO 0);
        chipselect  : IN  std_logic;
        read        : IN  std_logic;
        write       : IN  std_logic;
        writedata   : IN  std_logic_vector(31 DOWNTO 0);
        readdata    : OUT std_logic_vector(31 DOWNTO 0);
        waitrequest : OUT std_logic;
        mode_select : IN  std_logic
    );
END swap_bytes;
```

---

# 8. Fonctionnement interne du swap

Quand le CPU ecrit dans le composant :

```text
chipselect = 1
write = 1
```

le composant :

1. recupere `writedata`
2. realise le swap d'octets
3. stocke le resultat dans `reg_out`

Puis :

```text
readdata <= reg_out
```

---

# 9. Pourquoi utiliser Avalon-MM ?

Avalon-MM permet :

* la communication CPU <-> peripherique
* la lecture/ecriture memoire
* l'integration facile dans Qsys
* la creation de peripheriques personnalises

---

# 10. Signaux Avalon utilises

| Signal      | Role                      |
| ----------- | ------------------------- |
| clk         | horloge systeme           |
| reset_n     | reset actif bas           |
| chipselect  | selection du peripherique |
| write       | ecriture Avalon           |
| read        | lecture Avalon            |
| writedata   | donnees envoyees          |
| readdata    | donnees lues              |
| waitrequest | attente bus               |

---

# 11. Configuration Qsys

## Composant `swap_bytes_component`

Type :

```text
Avalon Memory-Mapped Slave
```

Adresse :

```text
0x0040
```

---

## Composant `pio_select`

Type :

```text
Avalon Memory-Mapped Slave
```

Adresse :

```text
0x0050
```

---

# 12. Code C de test NIOS II

Le programme C :

1. ecrit le mode dans le PIO
2. ecrit le mot dans le composant
3. lit le resultat

Exemple :

```c
select_write(0);
swap_write(0x12345678);
```

Puis :

```c
output = swap_read();
```

---

# 13. Resultat attendu

---

## MODE 0

```text
Entree  : 0x12345678
Sortie  : 0x78563412
```

---

## MODE 1

```text
Entree  : 0x12345678
Sortie  : 0x56781234
```

---

# 14. Visualisation sur LEDs

Les LEDs affichent :

```vhdl
LED <= swapped_data(7 DOWNTO 0);
```

Cela permet de visualiser directement les bits du resultat.

---

# 15. Conclusion

Ce projet montre :

* la creation d'un IP Core personnalise
* l'utilisation du bus Avalon-MM
* l'integration dans Qsys
* le pilotage via NIOS II
* l'echange materiel/logiciel
* le controle dynamique du comportement materiel via un PIO

Le systeme est maintenant capable de :

* recevoir un mot 32 bits
* choisir dynamiquement le type de swap
* retourner le mot inverse
* etre pilote par logiciel depuis NIOS II
