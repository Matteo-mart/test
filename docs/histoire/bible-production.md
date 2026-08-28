# VOID — Bible de production

Documentation complète pour développer en solo un **survival horror FPS rétro** sur **Godot 4**, d'environ 2 heures de jeu, sans aucune compétence en modélisation 3D.

---

## Le projet en une page

| | |
|---|---|
| **Titre de travail** | VOID |
| **Genre** | Survival horror FPS, science-fiction psychologique |
| **Moteur** | Godot 4.x, renderer **Forward+** |
| **Durée** | ≈ 2 h 09 |
| **Structure** | 3 actes, hub central, backtracking, 10 énigmes |
| **Combat** | Progressif : mains nues → barre à mine → revolver (34 balles en tout) → fuite. Arsenal de fin de jeu au Poste de sécurité : fusil à pompe et Molotov optionnels, **pistolet d'ancrage obligatoire** pour vaincre le Boss III |
| **Bestiaire** | Les Désancrés (3 variantes d'un même modèle) + 1 boss par acte |
| **Sauvegarde** | Points de sauvegarde façon Resident Evil, snapshot JSON |
| **Assets** | 100 % gratuits (Kenney, KayKit, Quaternius, Poly Haven, Mixamo, Freesound) |
| **Références** | *Signalis*, *Silent Hill 2*, *Resident Evil 1* |

---

## Sommaire

| Document | Contenu |
|---|---|
| [00 — Bible narrative](00-bible-narrative.md) | L'histoire, les personnages, la règle du monde, les 16 documents, la justification narrative des 10 énigmes |
| [01 — Architecture technique](01-architecture-technique.md) | Arborescence, autoloads, `Resource`, composants, couches de collision, découpage des scènes |
| [02 — Code des systèmes](02-code-systemes.md) | GDScript complet : joueur, inventaire, combinaisons, **inspection 3D**, sauvegarde, portes, les 10 énigmes |
| [03 — Combat et bestiaire](03-combat-et-bestiaire.md) | Armes, IA à machine à états, propagation du bruit, les 3 boss, équilibrage |
| [04 — Cahier des charges des assets](04-cahier-des-charges-assets.md) | Packs 3D par zone, filière Mixamo, correspondance objets d'énigme, audio, polices |
| [05 — Direction artistique](05-direction-artistique.md) | Pipeline rétro, `WorldEnvironment` par acte, shaders PS1, éclairage, lampe torche, blackout, audio spatialisé |
| [06 — Level design et énigmes](06-level-design-et-enigmes.md) | Plans des zones, les 10 fiches d'énigme, graphe anti-soft-lock, rythme, backtracking |
| [07 — Roadmap](07-roadmap.md) | 10 phases, du greybox à l'export, avec critères de sortie mesurables |

---

## Par où commencer

1. Lisez **[07 — Roadmap](07-roadmap.md)** en entier. C'est votre plan de route.
2. Faites la **Phase 0** (fondations) en suivant [01 — Architecture technique](01-architecture-technique.md).
3. Ne lisez le reste **qu'au moment où la roadmap vous y renvoie**. Le tableau en fin de `07` indique quoi lire à quelle phase.

> Le jalon décisif est la **Phase 3** : l'Acte I complet en boîtes grises, testé par quelqu'un d'autre. Tout le reste du projet dépend de ce que ce test vous apprendra.

---

## Les cinq décisions structurantes

Si vous ne deviez retenir que cinq choses de cette documentation :

1. **Le greybox d'abord.** Le jeu doit être terminable en boîtes grises (fin de Phase 4) avant qu'un seul asset ne soit importé.
2. **Le bruit est la mécanique centrale.** Les ennemis entendent plus qu'ils ne voient. Courir, tirer, ouvrir une porte : tout a un coût audible. C'est ce qui rend le joueur tendu en permanence, sans un seul jumpscare.
3. **Aucun boss ne se tue aux dégâts.** Chacun est une énigme sous pression, résolue par l'environnement. Cohérent avec la pénurie de munitions, avec le thème, et avec zéro compétence en animation.
4. **Le rendu rétro est un outil de cohérence, pas seulement un style.** En 640×360 avec du brouillard dense, des assets de six auteurs différents deviennent indiscernables.
5. **L'audio fait plus pour la peur que le visuel.** Quatre morceaux de musique dans tout le jeu ; partout ailleurs, de l'ambiance spatialisée et du silence.
