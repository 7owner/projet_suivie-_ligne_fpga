# TP1_v4_bis - Architecture CUTECAR et capteurs

Cette version bascule vers une architecture plus proche du robot CUTECAR complet.

## Contenu

- `CUTECAR/Top_CUTECAR.vhd` : top-level du robot.
- `CUTECAR/Nios_CUTECAR.qsys` : systeme Platform Designer associe.
- `ip_modules/` : modules reutilisables, dont PWM, capteurs de sol, seuillage, reception IRDA et PLL.
- `TP_DOC/` : documents de reference du TP et du robot.
- `seuil.xlsx` : suivi des valeurs de seuil capteurs.

Cette version consolide les modules utiles pour les etapes suivantes de detection et de suivi de ligne.
