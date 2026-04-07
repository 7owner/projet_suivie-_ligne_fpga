# TP1_v5 - Calcul de position et suivi de ligne

Cette version ajoute la logique de suivi de ligne a partir du vecteur capteurs.

## Contenu

- `CUTECAR/POS.vhd` : conversion du vecteur `vect_capt` en position signee `POSL` et indication `ligne_presente`.
- `CUTECAR/suivi_ligne.vhd` : correction des PWM moteur gauche/droit selon l'erreur de position.
- `CUTECAR/Top_CUTECAR.vhd` : integration au niveau robot.
- `ip_modules/` : modules bas niveau reutilises.
- `seuil.xlsx` : valeurs de seuil capteurs.

Cette version transforme la detection capteur en action moteur pour suivre une ligne.
