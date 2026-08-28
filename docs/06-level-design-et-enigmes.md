# 06 — Level design et énigmes

---

## 1. Règles de construction spatiale

1. **Jamais plus de 8 mètres de visibilité.** Coudes, portes, mobilier, brouillard. C'est à la fois la contrainte de cohérence graphique (`04` §6) et le moteur de la claustrophobie.
2. **Toute salle a deux issues** — sauf les culs-de-sac délibérés, qui doivent être *annoncés* (une porte unique, un couloir qui rétrécit) pour que le joueur y entre en sachant qu'il s'engage.
3. **Aucun couloir droit de plus de 12 m.** Un couloir droit est une salle d'attente.
4. **Les raccourcis se débloquent depuis l'intérieur.** Un joueur qui revient au Hub par une porte qu'il vient d'ouvrir de l'autre côté comprend l'espace ; un joueur qui refait le chemin inverse s'ennuie.
5. **Le hall est mémorisable en une visite.** Une signalétique forte (couleurs par aile, panneaux) et une géométrie simple : le Hub est la carte mentale du joueur.

---

## 2. Plans des zones

### Acte I — La maison

```
                       [ EXTÉRIEUR / ALLÉE ]
                                |
                           (porte d'entrée)
                                |
  +----------------+------------+------------+
  |     SALON      |    HALL    |   CUISINE  |
  |  É1 : perche   |            |  (manche)  |
  |  lustre + clé  |  escalier  |            |
  +----------------+-----+------+------------+
                         |
                    +----+-----+
                    |  BUREAU  |
                    |  É2 : horloge comtoise
                    |  tiroir à code -> aiguille
                    |  D02, D03
                    +----+-----+
                         |
                    (trappe É2)
                         |
  +----------------------+---------------------+
  |             SOUS-SOL                        |
  |  É3 : 4 photos -> cadenas VOID              |
  |  BOSS I : Le Gardien (cave à charbon)       |
  |  monte-charge de service -> CEP-Valmont     |
  +---------------------------------------------+
```

### Acte II — Le complexe

```
                        (monte-charge, arrivée)
                                 |
        +------------------------+------------------------+
        |            HALL D'ACCUEIL — HUB                  |
        |   Statue anatomique (É4)   Comptoir   Tourniquets|
        |   POINT DE SAUVEGARDE 2    Console finale (É10)  |
        +--+--------------------+--------------------+-----+
           |                    |                    |
      (puce d'accès)      (verrou radio)        (verrou radio)
           |                    |                    |
   +-------+------+    +--------+-------+    +-------+--------+
   | AILE MÉDICALE|    |   AILE COMS    |    | AILE RECHERCHE |
   |              |    |                |    |                |
   | Labo d'analyse    | Salle radio É6 |    | Atelier É7     |
   | É5 centrifugeuse  | Morgue         |    | Tableau élec.  |
   | Sas de déconta.   | (passe-partout)|    | Bureaux        |
   | BOSS II Matrone   |                |    |                |
   | -> BADGE ROUGE    | -> déverrouille|    | -> BADGE VERT  |
   |                   |    Recherche   |    |                |
   | SAUVEGARDE 3      | SAUVEGARDE 4   |    | SAUVEGARDE 5   |
   +-------------------+----------------+----+-------+--------+
                                                     |
                                          (escalier ouest)
                                                     |
                                            [ ACTE III ]
```

### Acte III — Le secteur Ouest

```
   [escalier ouest]
          |
   +------+------------------------------------+
   |   COULOIR PLIÉ (É8)                       |
   |   Boucle spatiale : le couloir se répète  |
   |   Mur-miroir + objet à aligner            |
   +------+------------------------------------+
          |  (dépliage)
   +------+------------------------------------+
   |   ANTICHAMBRE — SAUVEGARDE 6              |
   +------+------------------------------------+
          |
          |  ( SEUL PASSAGE vers le Bureau — aucun autre chemin )
          |
   +------+------------------------------------+
   |   POSTE DE SÉCURITÉ                       |
   |   Fusil à pompe + cartouches (optionnel)  |
   |   2 Molotov + composants (optionnel)      |
   |   Coffre (code 345) -> Pistolet d'ancrage |
   |   OBLIGATOIRE pour le Boss III, D16       |
   +------+------------------------------------+
          |
   +------+------------------------------------+
   |   BUREAU DU DIRECTEUR                     |
   |   Toile déchirée -> manivelle             |
   |   É9 : boîte à musique -> piano -> coffre |
   |   BOSS III : L'Ancre (2 miroirs + pistolet d'ancrage en phase 3) |
   |   D13, D14  -> BADGE BLEU                 |
   +------+------------------------------------+
          |
   (retour au Hub — raccourci direct ouvert)
          |
   +------+------------------------------------+
   |   HUB — É10 : 3 badges, alarme, 3 minutes |
   |   PORTE BLINDÉE                           |
   +-------------------------------------------+
```

---

## 3. Fiches des 10 énigmes

Format : **prérequis → lieu → solution → indices → flag**.

---

### É1 — La perche improvisée · *Salon*

| | |
|---|---|
| **Prérequis** | Aucun |
| **Objets** | `manche_balai` (cuisine, contre le mur) + `crochet` (tiroir du salon) |
| **Action** | Combiner dans l'inventaire → `perche` |
| **Usage** | Interagir avec le lustre → `cle_rouillee` tombe |
| **Indice** | La clé est **visible** sur le lustre dès l'entrée dans le salon. Un rai de lumière la fait briller. Le joueur voit le problème avant d'avoir la solution. |
| **Échec** | Interagir sans perche : « Trop haut. Il me faudrait quelque chose de long. » |
| **Flag** | `p01_perche_solved` |
| **Rôle** | **Tutoriel de la combinaison.** Doit être résolue en moins de 4 minutes par n'importe qui. |

---

### É2 — L'horloge comtoise · *Bureau*

| | |
|---|---|
| **Prérequis** | `cle_rouillee` (ouvre le bureau) |
| **Objets** | `aiguille_bronze`, dans un tiroir à code 3 chiffres |
| **Code du tiroir** | **`345`** — l'heure sans les deux points, notée au dos de D03 |
| **Action** | Placer l'aiguille sur l'horloge, régler sur **03:45** |
| **Indices** | D02 (page arrachée du carnet d'Hélène) : « 03:45. Toujours 03:45. » — placé **sur le bureau, en évidence**. La mention se répète sur trois documents ultérieurs : le joueur mémorise l'heure sans effort. |
| **Échec** | Toute autre heure : le mécanisme grince mais ne s'ouvre pas |
| **Résultat** | La trappe du sous-sol s'ouvre |
| **Flag** | `p02_horloge_solved` |

---

### É3 — Le cadenas VOID · *Sous-sol*

| | |
|---|---|
| **Prérequis** | Accès au sous-sol |
| **Objets** | 4 photos de famille, à trouver dans 4 endroits distincts du sous-sol |
| **Action** | Chaque photo, **inspectée en 3D** (`02` §7), révèle une lettre à son dos : V, O, I, D |
| **Solution** | Régler les 4 rouleaux sur **VOID** |
| **Indices** | Chaque photo est datée au dos ; l'ordre chronologique donne l'ordre des lettres. Le joueur qui ne remarque pas l'ordre a 24 permutations — trop. **Le rôle des dates est donc de rendre l'énigme *rapide*, pas *possible*.** |
| **Résultat** | Accès au monte-charge → CEP-Valmont |
| **Flag** | `p03_cadenas_solved` |
| **Rôle** | **Tutoriel de l'inspection 3D**, avant que celle-ci ne soit obligatoire à l'É4. |

---

### É4 — La statue anatomique · *Hub*

| | |
|---|---|
| **Prérequis** | `scalpel` (comptoir d'accueil, tiroir) |
| **Action** | Utiliser le scalpel sur la statue → récupérer `gemme_rouge` |
| **Puis** | **Inspecter la gemme en 3D**, la retourner : `SecretMarker` sous l'objet → révèle `puce_acces` |
| **Indice** | Une fissure est visible sur le thorax de la statue. Le HUD affiche « Une entaille, à hauteur du sternum. » |
| **Piège à éviter** | Si le joueur ne pense pas à retourner la gemme, il est bloqué. **Filet de sécurité :** après 90 s avec la gemme en inventaire sans l'avoir inspectée, le HUD affiche « Elle est plus lourde qu'elle n'en a l'air. » |
| **Flag** | `p04_gemme_solved` |
| **Résultat** | Ouvre l'Aile Médicale |

---

### É5 — La centrifugeuse · *Aile Médicale*

| | |
|---|---|
| **Prérequis** | `seringue` (salle de soins), `serum_brut` (prélevé sur l'unité de stase de Sorel) |
| **Action** | Placer l'échantillon dans la centrifugeuse → mini-jeu à 3 jauges, maintenir 4 s |
| **Difficulté** | Trois vitesses de dérive différentes ; le joueur ne corrige qu'une jauge à la fois |
| **Résultat** | `serum_purifie` → injecté dans l'analyseur du sas → libère `badge_rouge` |
| **Indice** | Affiche murale : « Protocole 12-B : le sas ne s'ouvre pas tant qu'une contamination est détectée. » |
| **Échec** | Aucune punition. On recommence. Le mini-jeu doit frustrer, jamais bloquer. |
| **Flag** | `p05_serum_solved` |
| **Note** | **BOSS II (la Matrone) se déclenche à la récupération du badge**, pas avant. Le joueur connaît alors la topologie de l'aile — condition indispensable à la poursuite. |

---

### É6 — L'accord radio · *Aile Coms*

| | |
|---|---|
| **Prérequis** | `passe_morgue` (sur le corps du veilleur, casier 12) |
| **Action** | Ouvrir la salle radio, accorder l'émetteur sur **88.6 MHz** et faire coïncider la phase |
| **Retour** | Deux sinusoïdes sur un oscilloscope + grésillement dont le volume indique la proximité. **Le son est l'indice principal** ; l'écran ne fait que confirmer. |
| **Indice** | D07 (registre du veilleur) : « Canal de secours 88.6 — noté ici parce que je l'oublie une fois sur deux. » |
| **Résultat** | Déverrouille l'Aile Recherche |
| **Flag** | `p06_radio_solved` |

---

### É7 — Le fusible et la lampe UV · *Aile Recherche*

| | |
|---|---|
| **Déclencheur** | L'entrée dans l'aile provoque la panne (séquence de `05` §4) |
| **Étape 1** | Trouver `lampe_uv` (paillasse du labo, sous une bâche) |
| **Étape 2** | Balayer les murs de l'atelier → le code **417** apparaît près de la caisse à outils |
| **Étape 3** | Ouvrir la caisse (code 417) → `fusible` |
| **Étape 4** | Placer le fusible dans le tableau électrique → courant rétabli |
| **Résultat** | Le verrou électromagnétique lâche → `badge_vert` |
| **Indice** | D09, post-it de Rémi : « Le marqueur est dans la caisse à outils. (Oui, je sais.) » — **l'humour rend l'indice mémorable** et caractérise le personnage en une ligne. |
| **Flag** | `p07_fusible_solved` |
| **Tension** | Deux Désancrés patrouillent dans le noir. La lampe UV n'éclaire presque pas : le joueur alterne entre lampe torche (voir, mais être vu) et lampe UV (chercher, à l'aveugle). |

---

### É8 — Le couloir plié · *Secteur Ouest*

| | |
|---|---|
| **Prérequis** | Accès au secteur Ouest |
| **Constat** | Le couloir se répète à l'infini. Chaque traversée ramène au point de départ. |
| **Élément clé** | Un mur-miroir montrant la salle **telle qu'elle est réellement** — dans le reflet, une chaise se trouve à un endroit différent de la chaise réelle |
| **Action** | Pousser/porter la chaise jusqu'à ce que sa position et son orientation coïncident avec celles du reflet |
| **Tolérance** | 0,35 m et 15° — généreuse, l'énigme est conceptuelle, pas manuelle |
| **Retour** | Quand l'alignement approche, le grésillement de fond diminue ; à la coïncidence, un claquement sec et le couloir se déplie |
| **Indice** | D12 (transcription de l'essai) : « Le sujet et son reflet ont cessé de concorder à 03:41. » |
| **Flag** | `p08_miroir_solved` |
| **Rôle** | **Enseigne la logique du BOSS III.** Le joueur apprend ici que le reflet est la vérité. |

---

### Passage obligatoire — Le Poste de sécurité · *entre l'Antichambre et le Bureau du Directeur*

| | |
|---|---|
| **Prérequis** | `p08_miroir_solved`. La porte s'ouvre automatiquement — c'est désormais le **seul chemin** vers le Bureau du Directeur, il n'existe aucun autre passage à contourner. |
| **Contenu (optionnel)** | Fusil à pompe + 2 cartouches, 4 cartouches en réserve, 2 Molotov assemblés, composants (`bouteille_vide`, `chiffon`) — l'alcool (`bidon_alcool`) est sur le bar du Bureau du Directeur, une salle plus loin |
| **Coffre (obligatoire)** | Verrouillé par le code **345** — celui de l'horloge de l'Énigme 2. Un joueur qui a mémorisé l'heure de l'incident (répétée sur 3 documents distincts) le devine sans indice supplémentaire dans le Poste lui-même |
| **Contenu du coffre** | `pistolet_ancrage`, 3 charges intégrées — **condition de victoire de la phase 3 du Boss III**, aucune arme ne le remplace (`03-combat-et-bestiaire.md` §6) |
| **Indice** | D16 (registre du Poste), voir `00-bible-narrative.md` §8 |
| **Rôle** | **La salle est obligatoire ; le coffre ne l'est qu'en apparence.** Le joueur traverse forcément le Poste, mais peut en théorie repartir sans avoir ouvert le coffre. Filet de sécurité : le Boss III bloque volontairement en phase 3 sans le pistolet, et la porte du Bureau du Directeur ne se reverrouille jamais — un joueur pris au dépourvu revient ici sans limite de temps pour retenter le code (`03` §6, « sécurité anti-blocage »). |
| **Détail** | Aucun ennemi dans cette salle — c'est une pause avant l'affrontement, pas une rencontre de plus. |

---

### É9 — La boîte à musique et le piano · *Bureau du Directeur*

| | |
|---|---|
| **Étape 1** | Une toile déchirée au mur cache `manivelle` (à inspecter en 3D pour voir la déchirure) |
| **Étape 2** | Manivelle → `boite_musique` → **écouter la mélodie** (6 notes) |
| **Étape 3** | Rejouer les 6 notes sur le piano du bureau |
| **Aide** | La boîte peut être rejouée autant de fois qu'on veut. Chaque note fait s'allumer brièvement la touche correspondante du piano si le joueur tient la boîte à côté — **aide silencieuse pour les joueurs non musiciens**, indispensable. |
| **Erreur** | Réinitialisation silencieuse, sans son d'échec. Une énigme musicale punitive est une énigme abandonnée. |
| **Résultat** | Le coffre s'ouvre → `badge_bleu` + D14 |
| **Flag** | `p09_piano_solved` |
| **Note** | **BOSS III se déclenche à l'ouverture du coffre.** |

---

### É10 — La séquence finale · *Hub*

| | |
|---|---|
| **Prérequis** | Les 3 badges |
| **Déclenchement** | Insertion du premier badge → alarme + **180 secondes** |
| **Étape 1** | Insérer dans l'ordre **ROUGE → BLEU → VERT** |
| **Étape 2** | Saisir le code à 3 chiffres gravé sous les badges (découvert par inspection 3D) |
| **Erreur d'ordre** | Réinitialisation + **−15 s** |
| **Erreur de code** | **−10 s** |
| **Indices** | D05 (12 mars, Sorel/rouge), D08 (14 mars, Achard/bleu), D11 (19 mars, Reyes/vert), trouvés dans trois ailes différentes. **L'ordre est la chronologie.** |
| **Filet de sécurité** | Un joueur qui n'a lu aucun document a 6 permutations et 180 s : c'est **faisable mais serré**. Le jeu ne bloque jamais le joueur qui n'a pas lu ; il le fait transpirer. |
| **Tension** | Trois Désancrés entrent dans le hall au déclenchement de l'alarme. Fuir, pas combattre. |
| **Arsenal du Poste** | Le pistolet d'ancrage est **déjà en possession du joueur** à ce stade (obligatoire pour avoir vaincu le Boss III) : ses charges restantes servent à figer un Désancré sans combattre. Le fusil à pompe (groupe) et le Molotov (bloquer un couloir 6 s pendant la saisie du code) restent facultatifs (`03-combat-et-bestiaire.md` §9.4). **Ni l'un ni l'autre n'est requis :** le revolver seul suffit à survivre aux 180 s. |
| **Flag** | `p10_final_solved` → Porte blindée → fin |

---

## 4. Graphe de dépendances (vérification anti-soft-lock)

```
manche_balai ─┐
              ├─> perche ──> cle_rouillee ──> [BUREAU]
crochet ──────┘                                   │
                                                  v
                                    aiguille_bronze (tiroir, code 345)
                                                  │
                                                  v
                                       horloge 03:45 ──> [SOUS-SOL]
                                                              │
                              4 photos ──> code VOID ─────────┤
                                                              v
                                                        [HUB LABO]
                                                              │
                          scalpel ──> gemme_rouge ──> puce_acces
                                                              │
                                                              v
                                                    [AILE MÉDICALE]
                                                              │
                              seringue + serum_brut ──> serum_purifie
                                                              │
                                                              v
                                             BOSS II ──> BADGE ROUGE
                                                              │
                                                              v
                                                      [AILE COMS]
                                                              │
                              passe_morgue ──> radio 88.6 MHz
                                                              │
                                                              v
                                                   [AILE RECHERCHE]
                                                              │
                          lampe_uv ──> code 417 ──> fusible ──> courant
                                                              │
                                                              v
                                                        BADGE VERT
                                                              │
                                                              v
                                                    [SECTEUR OUEST]
                                                              │
                                            alignement miroir (É8)
                                                              │
                                                              v
                                                 [BUREAU DIRECTEUR]
                                                              │
                              manivelle ──> boite_musique ──> piano
                                                              │
                                             BOSS III ──> BADGE BLEU
                                                              │
                                                              v
                                        [HUB] R->B->V + code ──> FIN
```

**Vérifications effectuées :**

- Aucun objet consommé n'est requis deux fois.
- Aucun objet n'est atteignable uniquement depuis une zone qui se referme.
- Chaque badge est obtenu dans une aile distincte, sans dépendance croisée entre les ailes Médicale et Recherche (seule l'Aile Coms est un verrou intermédiaire).
- L'É8 ne nécessite aucun objet : un joueur ayant tout dépensé peut la résoudre.
- Le boss III est franchissable sans munitions (barre à mine sur les miroirs).
- **Le Poste de sécurité est un passage obligatoire** entre l'É8 et le Bureau du Directeur : il n'existe aucun autre chemin. Son coffre (`pistolet_ancrage`) est requis pour la phase 3 du Boss III — c'est l'unique objet de tout le jeu sans solution de repli en munitions ou en force brute. Le fusil à pompe et les Molotov restent, eux, facultatifs : le Boss III (phases 1-2) et l'É10 restent finissables avec le seul revolver et la barre à mine déjà obtenus en Acte II.

---

## 5. Rythme et minutage

| Séquence | Durée cible | Tension | Ennemis |
|---|---|---|---|
| Arrivée, extérieur, salon | 5 min | Basse | 0 |
| É1 + exploration maison | 7 min | Basse | 0 |
| Bureau, É2 | 6 min | Montante | 1 (première rencontre, fuite imposée) |
| Sous-sol, É3 | 5 min | Haute | 2 |
| **BOSS I** | 4 min | Pic | — |
| *Descente au labo — silence total* | 1 min | **Répit** | 0 |
| Hub, É4, première exploration | 8 min | Basse | 1 |
| Aile Médicale, É5 | 14 min | Montante | 5 |
| **BOSS II** | 7 min | Pic | — |
| *Retour au Hub, sauvegarde* | 2 min | **Répit** | 0 |
| Aile Coms, morgue, É6 | 13 min | Haute | 6 |
| Aile Recherche, blackout, É7 | 16 min | Très haute | 6 |
| *Retour au Hub* | 2 min | **Répit** | 0 |
| Couloir plié, É8 | 12 min | Étrange (pas d'ennemi) | 0 |
| Poste de sécurité (passage obligatoire) | 3 min | **Répit** | 0 |
| Bureau, É9 | 11 min | Montante | 4 |
| **BOSS III** | 6 min | Pic | — |
| Course finale, É10 | 5 min | Pic | 3 |
| Fin | 2 min | Retombée | 0 |
| **Total** | **≈ 2 h 09** | | **28 ennemis** |

**Règle de rythme :** après chaque pic, un répit **obligatoire** d'au moins 60 secondes sans menace, avec un point de sauvegarde. Une tension continue devient un bruit de fond, et le joueur cesse d'avoir peur au bout de vingt minutes.

**L'Énigme 8 sans aucun ennemi** est délibérée : après l'Aile Recherche (le passage le plus éprouvant), on remplace la menace physique par le malaise spatial. Le changement de nature de la peur relance l'attention.

---

## 6. Points de sauvegarde

| # | Lieu | Justification |
|---|---|---|
| 1 | Salon de la maison | Après le tutoriel de combinaison |
| 2 | Hub, comptoir d'accueil | Le point de repère central |
| 3 | Aile Médicale, vestiaire | Avant le Boss II |
| 4 | Aile Coms, salle radio | Après un long trajet |
| 5 | Aile Recherche, atelier | Avant le blackout |
| 6 | Antichambre du secteur Ouest | Avant le Boss III |

**Six points pour deux heures** = un toutes les 20 minutes. Chaque point rend 20 PV : sauvegarder est aussi se soigner, ce qui en fait un objectif désirable et non une formalité.

---

## 7. Ce qui rend le backtracking supportable

C'est le risque principal d'un jeu à hub. Cinq mesures :

1. **Raccourcis à sens unique.** Chaque aile a une porte de service qui ne s'ouvre que depuis l'intérieur et débouche sur le Hub. Le retour est toujours plus court que l'aller.
2. **L'état persiste.** Portes ouvertes, ennemis morts, objets ramassés : une aile nettoyée reste nettoyée. Le joueur voit le fruit de son travail.
3. **Le décor change.** Après le rétablissement du courant (É7), le Hub est éclairé différemment. Après l'É8, deux couloirs de l'Acte II sont subtilement modifiés — un tableau retourné, une porte déplacée. Le joueur qui remarque a une récompense gratuite ; celui qui ne remarque pas ne perd rien.
4. **Aucun aller-retour à vide.** Chaque retour au Hub sert au moins deux choses : sauvegarder + progresser.
5. **La carte n'est pas nécessaire.** La signalétique de couleur des ailes suffit. Si vous devez ajouter une carte pour que le joueur s'y retrouve, c'est que le niveau est mal construit.

---

## 8. Checklist de validation d'une salle

Avant de passer à la salle suivante, en greybox :

- [ ] La sortie est identifiable en moins de 5 secondes depuis l'entrée
- [ ] La visibilité maximale est inférieure à 8 mètres
- [ ] Il y a au moins un élément de silhouette mémorable (pour la carte mentale du joueur)
- [ ] La salle a une source de lumière diégétique justifiée
- [ ] Un ennemi peut naviguer partout (`NavigationRegion3D` cuite et testée)
- [ ] Il existe au moins un couvert ou un point de rupture de ligne de vue
- [ ] Le joueur ne peut pas se coincer géométriquement
- [ ] Aucun objet requis n'est hors du champ de vision naturel du joueur qui entre
