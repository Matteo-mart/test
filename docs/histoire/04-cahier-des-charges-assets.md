# 04 — Cahier des charges des assets gratuits

> **Avertissement de méthode.** Les noms de packs ci-dessous ont été vérifiés sur les sites officiels au moment de la rédaction. Les **licences changent** : vérifiez toujours la page du pack avant d'intégrer quoi que ce soit à un projet commercial. Pour l'audio, ce document donne des **requêtes de recherche** et non des identifiants de fichiers : sur Freesound, un ID renvoie à un son précis qui peut être supprimé ou reversé sous une autre licence, et un ID inventé vous ferait perdre une heure.

---

## 1. Stratégie générale d'assets

Vous ne modélisez pas. Votre contrainte n'est donc pas « trouver les bons objets » mais **« unifier des objets qui ne viennent pas du même endroit »**. Trois décisions résolvent 90 % du problème :

1. **Un seul style de base : Kenney.** Ses packs 3D partagent une échelle, une palette et un niveau de détail communs. Ils forment la fondation ; le reste vient s'y greffer.
2. **Le rendu rétro est un uniformiseur.** Résolution 640×360, filtre `Nearest`, palette réduite et brouillard dense (voir `05`) : à ce niveau de dégradation, un asset Kenney et un asset Quaternius deviennent indiscernables. **Le style rétro n'est pas seulement esthétique, c'est votre outil de cohérence.**
3. **Un `.tres` de matériau unique par famille de surface.** Tous les murs du labo partagent un `mur_labo.tres`. Réassigner les matériaux à l'import écrase les différences de texturage d'origine.

### Ordre de priorité des sources

| Rang | Source | Licence | Pourquoi |
|---|---|---|---|
| 1 | **Kenney.nl** | CC0 | Cohérence maximale, aucune attribution, énorme volume |
| 2 | **KayKit** (Kay Lousberg, itch.io) | CC0 sur les packs gratuits | Personnages **riggés et animés** — le point critique |
| 3 | **Quaternius** | CC0 | Complète Kenney, style compatible |
| 4 | **Poly Haven** | CC0 | Textures PBR et HDRI de qualité |
| 5 | **Mixamo** (Adobe) | Gratuit, compte requis | Animations de personnages — voir §4 |
| 6 | **itch.io** (divers) | Variable — **à vérifier au cas par cas** | Comble les trous |

---

## 2. Packs 3D par zone

### Fondation commune (à télécharger en premier)

| Pack | Source | Usage |
|---|---|---|
| **Prototype Kit** | kenney.nl | Le greybox complet : murs, sols, escaliers, rampes modulaires. **C'est avec ça que vous construisez tout l'Acte 1 à 4 de la roadmap.** |
| **Prototype Textures** | kenney.nl | Damiers et quadrillages avec échelle lisible. Indispensable au greybox. |
| **Development Essentials** | kenney.nl | Repères, mannequin d'échelle, primitives de test |
| **UI Pack** | kenney.nl | Base de l'interface (à redessiner en style « terminal 90s » ensuite) |

### Acte I — La maison abandonnée

| Pack | Source | Ce qu'on en tire |
|---|---|---|
| **Furniture Kit** (~140 modèles) | kenney.nl | **Le pack le plus important de l'Acte I.** Canapé, fauteuils, bureau, bibliothèque, tables, lampes, tapis, portes, cadres. Couvre le salon et le bureau presque intégralement. |
| **Graveyard Kit** | kenney.nl | Ambiance extérieure d'approche : grilles, clôtures, arbres morts, pierres |
| **Mini Forest** | kenney.nl | Végétation autour de la maison |
| **Modular Cave Kit** | kenney.nl | **Le sous-sol** : parois irrégulières, cave à charbon du Boss I |

**Objets d'énigme à composer soi-même** (voir §5) : manche à balai, crochet, horloge comtoise, cadenas à rouleaux.

### Acte II — Le complexe CEP-Valmont

| Pack | Source | Ce qu'on en tire |
|---|---|---|
| **Modular Space Kit** | kenney.nl | **Colonne vertébrale du labo.** Couloirs modulaires, panneaux muraux, sas, portes coulissantes, consoles. Le look « station scientifique » est immédiat. |
| **Factory Kit** | kenney.nl | Aile Recherche et locaux techniques : tuyauterie, cuves, passerelles, tableaux électriques, **caisses à outils** (Énigme 7) |
| **City Kit (Industrial)** | kenney.nl | Extérieurs techniques, conteneurs, éléments de gros œuvre |
| **Modular Dungeon Kit** | kenney.nl | Sous-niveaux bruts, réserves, morgue (murs de pierre = contraste avec le labo aseptisé) |
| **KayKit — Dungeon Pack Remastered** | kaylousberg.itch.io | Props réutilisables : caisses, barils, tables, chaises, coffres, torches. Style plus stylisé, à réserver aux zones sombres. |
| **Sci-Fi / Lab props** | quaternius.com | Compléments : microscopes, éprouvettes, ordinateurs |

### Acte III — Le secteur surréaliste

**Contre-intuitif mais essentiel : n'achetez ni ne cherchez aucun asset « surréaliste ».**

Le secteur Ouest doit être bâti avec **exactement les mêmes assets que l'Acte II**. Toute l'étrangeté vient de la manière dont ils sont assemblés :

- Couloirs répétés à l'identique et bouclés (Énigme 8).
- Mobilier de bureau au plafond, rotations de 90° et 180° sur les murs.
- Échelles anormales : mêmes `Prototype Kit` mis à `scale = 1.8` ou `0.4`.
- Portes qui ne s'ouvrent sur rien.
- Copies miroir d'une salle déjà visitée à l'Acte II.

**Concept clé : le décor familier rendu faux est plus dérangeant que le décor étrange.** Une salle inconnue et bizarre se lit comme « un niveau de jeu ». Le hall d'accueil de l'Acte II retourné, dans lequel le joueur a passé une heure, se lit comme une menace personnelle.

Seuls ajouts pour l'Acte III :

| Pack | Source | Usage |
|---|---|---|
| **Fantasy Town Kit** *(à parcimonie)* | kenney.nl | Éléments hors contexte pour l'intrusion visuelle |
| **Pirate Kit** *(élément unique)* | kenney.nl | Un objet totalement incongru placé une seule fois dans tout le jeu |
| Miroirs, piano, boîte à musique | À composer (§5) | Objets clés des Énigmes 8 et 9 |

---

## 3. Personnages et ennemis — le vrai point dur

C'est le seul poste où les packs de props ne suffisent pas : il faut des modèles **riggés** avec un squelette, et des **animations**.

### Option A (recommandée) — KayKit Character Packs

- **KayKit — Character Pack : Skeletons** (kaylousberg.itch.io) : personnages low-poly riggés et animés, gratuits. Animations de marche, attaque, mort incluses.
- **KayKit — Character Pack : Adventurers** : silhouettes humaines à détourner en personnel de laboratoire.

**Avantage :** ça fonctionne immédiatement à l'import `.glb` dans Godot, les `AnimationPlayer` sont pré-remplis.
**Inconvénient :** style « fantasy stylisé » — à corriger par shader (voir §6) et par le rendu basse résolution.

### Option B — Mixamo (le chemin le plus flexible)

Procédure complète, sans aucune compétence en modélisation :

1. Récupérer un modèle humanoïde gratuit au format `.fbx` ou `.glb` (Quaternius propose des humanoïdes CC0).
2. Aller sur **mixamo.com** (compte Adobe gratuit), *Upload Character*.
3. Le rigging automatique place le squelette : placer 6 marqueurs à la souris, aucune connaissance requise.
4. Chercher et appliquer les animations : `zombie walk`, `zombie attack`, `zombie idle`, `stagger`, `falling back death`.
5. Télécharger chaque animation en **FBX Binary, 30 fps, Without Skin** (le modèle une seule fois **With Skin**).
6. Convertir en `.glb` — Blender sert ici de simple convertisseur (import FBX → export glTF), aucune modélisation.
7. Importer dans Godot : les animations arrivent dans un `AnimationLibrary`.

> **Point de licence :** les animations Mixamo sont utilisables gratuitement, y compris commercialement, mais **ne peuvent pas être redistribuées en tant que telles**. Les intégrer dans un jeu est autorisé ; publier un pack d'animations extrait de Mixamo ne l'est pas.

### Ce dont vous avez besoin, exactement

| Animation | Utilisée par | Priorité |
|---|---|---|
| `idle` | Tous | Critique |
| `walk_slow` | Désancré (état SUSPICIOUS) | Critique |
| `walk` | Désancré (état CHASE) | Critique |
| `attack` | Désancré, boss | Critique |
| `stagger` | Désancré | Importante |
| `death` | Désancré | Importante |
| `crawl` | Variante de sol (recyclage gratuit d'un ennemi) | Optionnelle |

**7 animations pour tout le jeu.** Le boss I n'a pas besoin d'animation de mort (il est écrasé, la scène est masquée). Le boss II réutilise le jeu de base avec `scale = 2.4`. Le boss III n'a **aucune animation** : il apparaît et disparaît.

---

## 4. Correspondance objets d'énigme → asset

Les objets scénarisés n'existent dans aucun pack tel quel. Colonne « solution » = ce qu'on fait concrètement.

| Objet | Source ou solution |
|---|---|
| Manche à balai | `CylinderMesh` (r 0,02 / h 1,2), matériau bois. **2 minutes.** |
| Crochet | `TorusMesh` tronqué + petit cylindre. Ou crochet du *Pirate Kit*. |
| Perche improvisée | Les deux précédents dans un `Node3D` parent. |
| Clé rouillée | Furniture Kit / Dungeon Pack (clés incluses) |
| Aiguille en bronze | `PrismMesh` très allongé, matériau métal sombre |
| Horloge comtoise | `BoxMesh` haut + 2 `CylinderMesh` aplatis (aiguilles) + `Label3D` pour le cadran. **L'important est la silhouette**, pas le détail : à 640×360 dans le brouillard, personne ne verra la différence. |
| Cadenas à rouleaux | 4 `CylinderMesh` sur un axe + `Label3D` par rouleau (le code du §Énigme 3 l'exploite déjà) |
| Photos de famille | `QuadMesh` + textures créées dans GIMP/Krita (photo libre de droits + filtre grain) |
| Statue anatomique | Personnage KayKit figé, matériau plâtre blanc, `AnimationPlayer` désactivé. **Détournement gratuit et très efficace.** |
| Scalpel | `BoxMesh` fin + `PrismMesh`. Ou props médicaux Quaternius. |
| Gemme rouge / lentille | `SphereMesh` + matériau transmission + `SecretMarker` (voir `02` §7) |
| Puce d'accès | `BoxMesh` 2×3 cm, matériau émissif |
| Seringue | 2 `CylinderMesh` + 1 `PrismMesh` |
| Centrifugeuse | Factory Kit (machines cylindriques) + `Label3D` |
| Badges ×3 | `QuadMesh` + texture + `Label3D` caché en dessous |
| Lampe UV | Blaster Kit (kenney) : une lampe torche détournée, `light_color` violet |
| Fusible | `CylinderMesh` 2 cm |
| Boîte à musique | Furniture Kit (petits coffres) + manivelle en cylindre |
| Piano | Furniture Kit / Dungeon Pack (recherche « piano »). À défaut : `BoxMesh` + 12 `BoxMesh` blancs et noirs — le puzzle du §Énigme 9 ne demande rien de plus. |
| Miroirs | `QuadMesh` + matériau très réfléchissant + salle jumelle derrière (voir `02` §Énigme 8) |
| Barre à mine | `BoxMesh` étiré + coude. Ou Factory Kit. |
| Revolver | **Blaster Kit** (kenney) — armes low-poly stylisées, parfaites pour du rétro |
| Fusil à pompe | **Blaster Kit** (kenney) — même pack que le revolver, cohérence garantie |
| Cocktail Molotov | `CylinderMesh` fin (bouteille) + `QuadMesh` (chiffon) + particules de feu natives de Godot (`GPUParticles3D`, preset « fire ») |
| Pistolet d'ancrage | Blaster Kit détourné : arme existante + matériau émissif bleu-violet (même dominante que la lampe UV, `05` §4) — aucun nouvel asset à chercher |
| Documents (×16) | `QuadMesh` + texture générée : page blanche + texte tapé dans GIMP. Le contenu s'affiche en UI 2D de toute façon. |

> **Règle des 5 minutes :** si un objet d'énigme prend plus de 5 minutes à composer avec des primitives, c'est qu'il est trop détaillé pour ce jeu. La lisibilité de la **silhouette** est le seul critère.

---

## 5. Textures et matériaux

| Besoin | Source |
|---|---|
| Béton, carrelage, métal, peinture écaillée | **Poly Haven** (CC0, PBR complet) |
| Textures de prototypage | Kenney — Prototype Textures |
| Papier, papier peint, bois | **ambientCG** (CC0) |
| HDRI (fond de ciel pour l'extérieur de la maison) | Poly Haven |

**Réglages d'import obligatoires pour le look rétro** (onglet Import de Godot, puis *Réimporter*) :

- `Mipmaps > Generate` : **désactivé** sur les textures de décor (le scintillement au loin fait partie du look PS1).
- `Filter` : **Nearest**.
- Redimensionner les textures à **256×256 maximum**, souvent 128×128. Une texture 4K de Poly Haven, réduite à 128 px, ressemble exactement à une texture de 1998 — et divise le temps de chargement par 40.

---

## 6. Unifier des assets hétérogènes

Trois techniques cumulables, par ordre d'efficacité :

1. **Palette imposée.** Un `Environment > Adjustments` avec une LUT de 32 couleurs applique la même dominante à tout ce qui est à l'écran. Détails dans `05`.
2. **Matériau override commun.** Sur les assets qui jurent, écraser `material_override` avec un `StandardMaterial3D` du projet.
3. **Brouillard.** Au-delà de 8 mètres, un brouillard dense supprime tout détail. Le corollaire tient en une phrase : **construisez des espaces où l'on ne voit jamais à plus de 8 mètres.** C'est bon pour la cohérence graphique, bon pour la claustrophobie, bon pour les performances.

---

## 7. Audio

### Où chercher

| Source | Licence | Remarque |
|---|---|---|
| **Freesound.org** | CC0 / CC-BY / CC-BY-NC | **Filtrez sur CC0** dans la barre latérale gauche pour éviter tout suivi d'attributions |
| **Sonniss — GDC Game Audio Bundle** | Libre d'usage commercial | Plusieurs dizaines de Go, publié chaque année, qualité professionnelle. **La meilleure ressource gratuite en audio de jeu.** |
| **Pixabay Audio** | Licence Pixabay | Ambiances et nappes musicales |
| **BBC Sound Effects** | Usage personnel/éducatif — **vérifier avant usage commercial** | Bibliothèque historique |
| **Zapsplat** | Gratuit avec attribution | Bon fonds d'ambiances |

### Requêtes de recherche par catégorie

> Sur Freesound : cochez **Creative Commons 0** dans les filtres, triez par « rating », privilégiez les fichiers ≥ 44,1 kHz. Convertissez tout en **`.ogg` Vorbis** pour Godot (le `.wav` fait exploser la taille du build ; réservez-le aux sons très courts et très fréquents).

**Pas du joueur** — un fichier par surface, 4 variantes chacune pour éviter l'effet mitraillette :

- `footstep wood hollow`, `footsteps concrete slow`, `footstep gravel single`, `footstep metal grate`, `footstep water shallow`

**Ambiances de zone** (boucles de 60 s minimum, en `.ogg`) :

- Maison : `old house creaking ambience`, `wind through window night`, `wooden house settling`
- Labo : `room tone hum air conditioning`, `server room hum loop`, `industrial ventilation drone`
- Surréaliste : `low drone unsettling`, `deep rumble subbass loop`, `metallic groan distant`

**Néons et électricité** (les plus importants du jeu pour l'ambiance) :

- `fluorescent light buzz`, `neon flicker electric`, `electrical hum 50hz`, `light bulb pop`, `power surge electrical`, `breaker switch throw`

**Voix et présence** (à traiter, jamais bruts) :

- `whisper unintelligible`, `distant voices reverb`, `breathing slow male`, `crowd murmur distant`
- **Traitement :** ralentir à 0,7×, ajouter une réverbération très longue, filtrer sous 400 Hz. Les sept voix de la Matrone = un même souffle joué 7 fois à `pitch_scale` 0,88 / 0,93 / 1,0 / 1,04 / 1,11 / 0,97 / 1,07 avec 20 à 90 ms de décalage.

**Radio (Énigme 6)** :

- `radio static white noise`, `radio tuning sweep`, `shortwave radio interference`, `morse code beeps`, `numbers station`

**Portes, mécanismes, énigmes** :

- `door creak slow open`, `heavy metal door close`, `padlock click`, `dial click mechanical`, `clock ticking grandfather`, `music box melody`, `piano single note` (×12), `centrifuge machine spin`, `airlock hiss`

**Combat** :

- `metal impact flesh`, `revolver gunshot`, `revolver reload cylinder`, `bone crack`, `body fall heavy`, `crowbar swing whoosh`
- **Arsenal du Poste (fin de jeu)** : `shotgun blast close`, `shotgun pump action`, `shotgun shell load`, `glass bottle break small`, `fire ignite whoosh`, `fire crackling loop`, `sci-fi energy pulse`, `electronic device empty beep`, `sci-fi stun zap`

**Interface** :

- `paper page turn`, `cassette tape recorder click`, `inventory item pickup`, `access denied buzzer`, `alarm klaxon industrial loop`

### Bus audio à créer dans Godot

`Audio > Barre de bus` :

```
MASTER
├── MUSIC        (rare : 4 morceaux dans tout le jeu)
├── AMBIENCE     (nappes de zone, en boucle)
├── SFX          (le monde)
├── VOICE        (murmures, radio, Matrone)
└── UI           (2D, non spatialisé)
```

Effets à poser :

- Sur **MASTER** : un `AudioEffectLimiter` en dernière position, systématiquement.
- Sur **AMBIENCE** : un `AudioEffectReverb` dont `room_size` est piloté par zone (couloir étroit 0,4 ; hall 0,9).
- Sur **MASTER**, un `AudioEffectLowPassShelf` activé sous 30 PV — le monde devient sourd quand le personnage faiblit.

### Musique

**Position de design : quasiment pas de musique.** Quatre morceaux dans tout le jeu :

1. Menu principal (nappe, 90 s).
2. Première descente au sous-sol (30 s, puis silence total).
3. Boss III.
4. Générique de fin.

Partout ailleurs : **ambiance spatialisée seule**. Le silence rend chaque son diégétique signifiant — un pas au loin devient une information, pas une décoration. C'est la leçon principale de *Silent Hill* et *Signalis*, et c'est aussi le choix le moins coûteux pour un développeur solo.

---

## 8. Polices

| Usage | Piste |
|---|---|
| Interface / terminal | Polices bitmap type « VT323 », « Press Start 2P », ou toute police SIL OFL sur Google Fonts |
| Documents (§ Bible narrative) | Une police de machine à écrire à chasse fixe |
| Titres | Une grotesque condensée, en majuscules, très espacée |

**Réglage indispensable** : dans l'import de la police, désactiver l'antialiasing (`Antialiasing > None`) et fixer une taille en pixels multiple de la taille de rendu, sinon le texte bavera sur le viewport 640×360.

---

## Sources vérifiées

- [Kenney — Assets 3D](https://kenney.nl/assets/category:3D)
- [Kenney — Furniture Kit](https://kenney.nl/assets/furniture-kit)
- [Kenney — Prototype Kit](https://kenney.nl/assets/prototype-kit)
- [Kenney — Prototype Textures](https://kenney.nl/assets/prototype-textures)
- [Kenney — Development Essentials](https://kenney.nl/assets/development-essentials)
- [Kenney — UI Pack](https://kenney.nl/assets/ui-pack)
- [KayKit — Dungeon Pack Remastered](https://kaylousberg.itch.io/kaykit-dungeon-remastered)
- [KayKit — Character Pack : Adventurers](https://kaylousberg.itch.io/kaykit-adventurers)
- [The Complete KayKit](https://kaylousberg.itch.io/kaykit-complete)
