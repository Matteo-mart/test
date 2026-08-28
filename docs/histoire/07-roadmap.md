# 07 — Roadmap de développement

**Principe :** tout est jouable en boîtes grises avant qu'un seul asset ne soit importé. Un jeu qui n'est pas amusant en greybox ne le sera pas avec de jolis murs — il sera juste plus long à corriger.

**Estimation d'effort** : en unités relatives (1 U ≈ une soirée de travail concentré). Total ≈ **134 U**. À 4 soirées par semaine, cela représente environ **8 mois**. Ce chiffre est un ordre de grandeur, pas un engagement.

---

## Phase 0 — Fondations · 4 U

**Objectif :** un projet propre dans lequel on peut travailler six mois sans dette.

- [ ] Installer Godot 4.x, créer le projet en **Forward+**
- [ ] `git init`, `.gitignore` Godot (au minimum `.godot/`, `.import/`, `export_presets.cfg`)
- [ ] Créer l'arborescence de `01-architecture-technique.md` §1 (dossiers vides)
- [ ] Configurer les **13 actions d'entrée** (`02` §5)
- [ ] Configurer les **8 couches de collision** (`01` §6)
- [ ] Appliquer les réglages projet de `01` §10 et `05` §1
- [ ] Créer les 5 autoloads, même vides

**Critère de sortie :** le projet se lance sur une scène noire, sans aucune erreur en console.

> **Piège :** ne sautez pas les couches de collision. Les renommer au bout de trois mois signifie rouvrir 200 scènes.

---

## Phase 1 — Le joueur dans une boîte · 6 U

**Objectif :** que se déplacer soit déjà agréable.

- [ ] Une salle de test en `Prototype Kit` (4 murs, 10 × 10 m)
- [ ] `player.gd` complet (`02` §5)
- [ ] `Interactable` + un cube qui affiche un prompt
- [ ] HUD minimal : réticule + texte de prompt
- [ ] Lampe torche fonctionnelle (`02` §6)
- [ ] Bruits de pas (n'importe quel son temporaire)

**Critère de sortie :** vous marchez, courez, vous accroupissez, visez un cube, le prompt s'affiche, la lampe s'allume — **et vous avez envie de continuer à vous promener**. Si le déplacement n'est pas satisfaisant maintenant, il ne le sera jamais : réglez `WALK_SPEED`, l'accélération et le head-bob jusqu'à ce que ça le soit.

---

## Phase 2 — Les systèmes cœur · 14 U

**Objectif :** toute la mécanique non-combat du jeu, testée hors contexte.

- [ ] `ItemData` + 5 objets de test en `.tres`
- [ ] `InventoryManager` complet + UI d'inventaire (grille simple)
- [ ] `CombineRecipe` + combinaison manche/crochet fonctionnelle
- [ ] `ObjectInspector` (`02` §7) avec un cube portant un `SecretMarker`
- [ ] `Door` avec ses trois modes de verrouillage
- [ ] `SaveSystem` + `SavePoint` : sauvegarder, quitter, relancer, retrouver l'état
- [ ] `SceneLoader` avec deux zones de test et un aller-retour

**Critère de sortie :** dans une salle de test, ramasser deux objets, les combiner, inspecter le résultat pour révéler un secret, ouvrir une porte avec, sauvegarder, **fermer le jeu, le rouvrir, et retrouver exactement le même état**.

> **C'est la phase la plus ingrate et la plus déterminante.** Tout ce qui suit s'appuie dessus. Ne passez pas à la Phase 3 avec une sauvegarde qui « marche presque ».

---

## Phase 3 — Vertical slice : l'Acte I en greybox · 12 U

**Objectif :** 25 minutes de jeu complètes, jouables du début à la fin, en boîtes grises.

- [ ] Maison en `Prototype Kit` : salon, hall, cuisine, bureau, sous-sol
- [ ] Énigmes 1, 2 et 3 implémentées et résolubles
- [ ] Points de sauvegarde 1
- [ ] Documents D01 à D04 avec leur texte réel
- [ ] Transitions de zone maison ↔ sous-sol
- [ ] Écran de fin provisoire à l'arrivée au monte-charge

**Critère de sortie — le jalon le plus important du projet :**

> **Faites jouer une personne qui ne connaît pas le jeu, sans lui donner aucune indication, et regardez-la en silence.**

Si elle termine l'Acte I sans être bloquée plus de 3 minutes sur une énigme, le design tient. Sinon, corrigez **maintenant**, avant d'avoir construit deux autres actes sur les mêmes hypothèses.

C'est aussi le moment de décider honnêtement si le projet vous plaît toujours. Un abandon en Phase 3 coûte 36 U ; en Phase 8, il en coûte 122.

---

## Phase 4 — Actes II et III en greybox · 26 U

**Objectif :** les 10 énigmes fonctionnelles, le jeu terminable de bout en bout. **Toujours aucun ennemi.**

- [ ] Hub + les 3 ailes en boîtes grises (`06` §2)
- [ ] Énigmes 4, 5, 6, 7 (les mini-jeux sont ici, ils prennent du temps)
- [ ] Secteur Ouest + couloir bouclé + système de miroir (É8)
- [ ] Bureau du Directeur, É9
- [ ] Séquence finale É10 avec compte à rebours
- [ ] Les 6 points de sauvegarde
- [ ] Les 16 documents avec leur texte définitif
- [ ] `NavigationRegion3D` cuite dans toutes les zones (**maintenant**, pas en Phase 5)

**Critère de sortie :** une partie complète, du salon à la porte blindée, en une session. Chronométrez-la : vous devriez être autour de **75-90 minutes** sans ennemis. Les 30 minutes restantes viendront du combat et de la prudence.

> **Piège du couloir bouclé (É8) :** la boucle spatiale est la seule pièce techniquement risquée du jeu. Prototypez-la **isolément** avant de construire le secteur Ouest autour. Solution la plus simple : trois copies du même couloir, et un `Area3D` de sortie qui téléporte le joueur à l'entrée du premier avec le même décalage — le joueur ne voit jamais de coupure si la téléportation se fait hors du champ de vision.

---

## Phase 5 — Combat · 20 U

**Objectif :** rendre l'espace dangereux.

- [ ] `HealthComponent` sur le joueur, dégâts, mort, retour au point de sauvegarde
- [ ] `Enemy` + machine à états + `NavigationAgent3D`
- [ ] `AudioDirector.emit_noise()` branché sur les pas, portes, armes
- [ ] Barre à mine (`WeaponMelee`) avec ses fenêtres d'impact
- [ ] Revolver (`WeaponRanged`) et son économie de munitions
- [ ] Les 3 profils de Désancré
- [ ] Boss I, II, III
- [ ] Placement des 28 rencontres selon `06` §5
- [ ] Retour d'information de combat (`03` §8)
- [ ] **Arsenal du Poste de sécurité** (`03` §9) : fusil à pompe, recette de combinaison du Molotov, pistolet d'ancrage — et le crochet `trigger_flicker()` / `stun()` sur `BossAnchor` et `Enemy`

**Critère de sortie :** une partie complète terminable **de deux façons** — en tirant moins de 10 balles (jeu furtif), et en combattant (jeu agressif, à sec en Acte III). Si l'une des deux est impossible, l'équilibrage est faux. Vérifier en plus que **le Boss III est réellement insoluble sans le pistolet d'ancrage** (phase 3 ne doit jamais se résoudre au revolver ou à la barre à mine), et qu'un joueur arrivé sans lui peut toujours reculer jusqu'au Poste de sécurité sans blocage ni limite de temps.

> Le combat arrive volontairement **après** que le jeu est terminable. Si le temps manque, un jeu d'énigmes sans combat reste un jeu ; un jeu de combat sans énigmes n'est plus votre jeu.

---

## Phase 6 — Habillage visuel · 22 U

**Objectif :** remplacer les boîtes grises. **Une zone à la fois, entièrement finie avant de passer à la suivante.**

- [ ] Télécharger et importer les packs de `04` §2
- [ ] Réglages d'import : `Nearest`, mipmaps off, textures ≤ 256 px
- [ ] Créer les matériaux partagés du projet
- [ ] Habiller la maison → **puis y rejouer intégralement**
- [ ] Habiller le Hub → y rejouer
- [ ] Habiller les 3 ailes → y rejouer
- [ ] Habiller le secteur Ouest (à partir des assets de l'Acte II, `04` §2)
- [ ] Les 3 `Environment` (`05` §2)
- [ ] Shader PS1 sur le décor, post-traitement plein écran
- [ ] Éclairage : lumières diégétiques, `LightmapGI` cuite par zone
- [ ] Séquence de blackout (É7)
- [ ] Encre UV

**Critère de sortie :** une capture d'écran de chaque zone qui vous donne envie d'y jouer.

> **Piège :** ne réglez pas l'éclairage avant que la géométrie soit finie. Chaque déplacement de mur invalide la lightmap.

---

## Phase 7 — Audio · 10 U

**Objectif :** c'est ici que le jeu devient effrayant. Ne sous-estimez pas cette phase : **l'audio fait plus pour la peur que tout le travail visuel de la Phase 6.**

- [ ] Créer les 5 bus + effets (`04` §7)
- [ ] Pas par surface, 4 variantes chacun
- [ ] Ambiances de zone en boucle
- [ ] Réverbération par volume
- [ ] Sons d'énigme, de porte, de mécanisme
- [ ] Sons de combat et d'ennemis
- [ ] Les 7 voix de la Matrone
- [ ] Ducking dynamique en poursuite
- [ ] Filtre passe-bas sous 30 PV
- [ ] Les 4 morceaux de musique

**Critère de sortie :** jouez au casque, lumières éteintes. Si vous n'êtes pas mal à l'aise dans votre propre jeu, il manque quelque chose.

---

## Phase 8 — Narration et finition du contenu · 8 U

- [ ] Placement définitif des 16 documents
- [ ] Annotations manuscrites de Camille sur chacun
- [ ] Séquence d'introduction (arrivée devant la maison)
- [ ] Séquence de fin + Fin B
- [ ] Menu principal, écran de chargement, options
- [ ] Écran de mort et retour au point de sauvegarde
- [ ] Générique

---

## Phase 9 — Polish, playtest, export · 12 U

- [ ] **Trois playtests complets** par trois personnes différentes, sans aide
- [ ] Corriger tout point de blocage supérieur à 3 minutes
- [ ] Vérifier l'absence de soft-lock (`06` §4)
- [ ] Options : sensibilité souris, volume par bus, **désactivation du head-bob**, sous-titres
- [ ] Optimisation : occlusion culling, budget de lumières à ombres (max 4)
- [ ] Tester la sauvegarde dans tous les cas limites (sauvegarder juste avant un boss, pendant l'alarme finale…)
- [ ] Export Windows + Linux, tester sur une machine qui n'est pas la vôtre

**Critère de sortie :** une personne extérieure installe le build, joue 2 heures, termine, et n'a besoin de vous à aucun moment.

---

## Récapitulatif

| Phase | Contenu | Effort | Cumul |
|---|---|---|---|
| 0 | Fondations | 4 U | 4 |
| 1 | Joueur | 6 U | 10 |
| 2 | Systèmes cœur | 14 U | 24 |
| 3 | **Vertical slice Acte I** | 12 U | 36 |
| 4 | Actes II-III greybox | 26 U | 62 |
| 5 | Combat + arsenal du Poste | 20 U | 82 |
| 6 | Habillage | 22 U | 104 |
| 7 | Audio | 10 U | 114 |
| 8 | Narration | 8 U | 122 |
| 9 | Polish | 12 U | 134 |

---

## Les cinq pièges qui tuent les projets solo

1. **Habiller avant que ce soit jouable.** Vous passerez trois semaines à faire une belle salle, puis vous découvrirez que l'énigme qu'elle contient n'est pas amusante.
2. **Vouloir un système générique.** Vous n'avez que 10 énigmes. Une énigme codée en dur et terminée vaut mieux qu'un « éditeur d'énigmes » qui n'en produira jamais aucune.
3. **Chercher l'asset parfait.** Trois heures sur itch.io à comparer des modèles de chaise. Prenez la première qui a la bonne silhouette : à 640×360, dans le brouillard, ce sera la même.
4. **Reporter la sauvegarde.** Ajouter la persistance à la fin oblige à réécrire chaque énigme. Elle est en Phase 2 pour cette raison exacte.
5. **Ne jamais faire tester.** Vous connaissez la solution de vos dix énigmes. Vous êtes structurellement incapable de juger leur difficulté. Le playtest de la Phase 3 n'est pas optionnel.

---

## Ordre de lecture des documents en cours de développement

| Vous êtes en… | Lisez |
|---|---|
| Phase 0-1 | `01-architecture-technique.md`, `02` §1-5 |
| Phase 2 | `02-code-systemes.md` intégralement |
| Phase 3-4 | `06-level-design-et-enigmes.md`, `02` §9 |
| Phase 5 | `03-combat-et-bestiaire.md` |
| Phase 6 | `04-cahier-des-charges-assets.md`, `05-direction-artistique.md` |
| Phase 7 | `04` §7, `05` §5 |
| Phase 8 | `00-bible-narrative.md` §8-9 |
