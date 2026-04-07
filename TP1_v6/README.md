# TP1_v6 - Controle suivi de ligne et rotation

Cette version est la plus avancee du depot. Elle separe le controle du suivi de ligne et le controle de rotation dans des blocs VHDL dedies.

## Contenu

- `CUTECAR/CTL_SL.vhd` : controle de suivi de ligne, mise a jour sur front de `data_ready`, calcul de l'erreur et generation des commandes moteurs.
- `CUTECAR/CTL_Rot.vhd` : controle de rotation avec machine d'etats `IDLE`, `ROTATE`, `DONE` et arret quand le capteur central retrouve la ligne.
- `CUTECAR/POS.vhd` et `CUTECAR/suivi_ligne.vhd` : modules de positionnement et suivi issus de l'etape precedente.
- `CUTECAR/Top_CUTECAR.vhd` : integration globale.
- `ip_modules/` : PWM, capteurs, seuillage, IRDA et PLL.

Cette version organise la commande robot autour de signaux de demarrage, de fin et de donnees capteurs synchronisees.
