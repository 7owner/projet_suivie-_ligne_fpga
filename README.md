# README – Composant Qsys `swap_bytes_component`

## 1. Objectif du projet

Le but de ce projet est de créer un **composant matériel personnalisé Qsys / Platform Designer** connecté au bus **Avalon Memory-Mapped (Avalon-MM Slave)**.

Ce composant permet de réaliser une **inversion d’octets** sur un mot de 32 bits.

---

## 2. Structure du mot 32 bits

Le mot est organisé comme suit :

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

Deux modes de swap ont été ajoutés.

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

# 4. Architecture générale du système

Le système contient :

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

# 5. Fonctionnement du système

Le processeur NIOS II :

1. écrit un mode dans `pio_select`
2. écrit un mot 32 bits dans `swap_bytes_component`
3. lit le résultat après inversion

---

# 6. Fonctionnement du PIO `pio_select`

Le composant `pio_select` est un simple registre 16 bits.

Il permet de sélectionner le mode de swap.

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

est utilisé comme :

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

Quand le CPU écrit dans le composant :

```text
chipselect = 1
write = 1
```

le composant :

1. récupère `writedata`
2. réalise le swap d’octets
3. stocke le résultat dans `reg_out`

Puis :

```text
readdata <= reg_out
```

---

# 9. Pourquoi utiliser Avalon-MM ?

Avalon-MM permet :

* la communication CPU ↔ périphérique
* la lecture/écriture mémoire
* l’intégration facile dans Qsys
* la création de périphériques personnalisés

---

# 10. Signaux Avalon utilisés

| Signal      | Rôle                      |
| ----------- | ------------------------- |
| clk         | horloge système           |
| reset_n     | reset actif bas           |
| chipselect  | sélection du périphérique |
| write       | écriture Avalon           |
| read        | lecture Avalon            |
| writedata   | données envoyées          |
| readdata    | données lues              |
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

1. écrit le mode dans le PIO
2. écrit le mot dans le composant
3. lit le résultat

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

# 13. Résultat attendu

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

# 14. Visualisation sur LEDs

Les LEDs affichent :

```vhdl
LED <= swapped_data(7 DOWNTO 0);
```

Cela permet de visualiser directement les bits du résultat.

---

# 15. Conclusion

Ce projet montre :

* la création d’un IP Core personnalisé
* l’utilisation du bus Avalon-MM
* l’intégration dans Qsys
* le pilotage via NIOS II
* l’échange matériel/logiciel
* le contrôle dynamique du comportement matériel via un PIO

Le système est maintenant capable de :

✅ recevoir un mot 32 bits
✅ choisir dynamiquement le type de swap
✅ retourner le mot inversé
✅ être piloté par logiciel depuis NIOS II
