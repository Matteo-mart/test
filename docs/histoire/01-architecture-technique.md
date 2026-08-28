# 01 — Architecture technique

Cible : **Godot 4.x, renderer Forward+**, GDScript, PC (Windows/Linux).

---

## 1. Arborescence du projet

```
res://
├── project.godot
├── autoload/                  # Singletons (voir §2)
│   ├── game_state.gd
│   ├── inventory_manager.gd
│   ├── save_system.gd
│   ├── audio_director.gd
│   └── scene_loader.gd
├── core/                      # Classes de base réutilisables
│   ├── interactable.gd
│   ├── health_component.gd
│   ├── hitbox.gd
│   └── state_machine/
│       ├── state_machine.gd
│       └── state.gd
├── data/                      # Ressources (.tres) — le contenu, pas le code
│   ├── items/                 # ItemData : manche.tres, crochet.tres, perche.tres…
│   ├── recipes/               # CombineRecipe
│   ├── enemies/               # EnemyProfile
│   └── docs/                  # DocumentData (les 16 documents)
├── player/
│   ├── player.tscn
│   ├── player.gd
│   ├── flashlight.gd
│   └── weapons/
├── objects/                   # Props interactifs
│   ├── door.tscn / door.gd
│   ├── pickup.tscn / pickup.gd
│   ├── save_point.tscn / save_point.gd
│   └── examinable.tscn
├── puzzles/                   # Une scène + un script par énigme
│   ├── p01_perche/ … p10_badges/
├── enemies/
│   ├── enemy_base.tscn / enemy_base.gd
│   └── bosses/
├── levels/
│   ├── act1_maison/
│   ├── act2_hub/  act2_medical/  act2_coms/  act2_recherche/
│   └── act3_ouest/  act3_bureau/
├── ui/
│   ├── hud.tscn                # Réticule, prompt, santé
│   ├── inventory_ui.tscn
│   ├── inspector_ui.tscn       # Inspection 3D
│   ├── document_reader.tscn
│   └── pause_menu.tscn
├── audio/
├── art/                       # Modèles importés, matériaux, shaders
│   └── shaders/
└── addons/
```

**Convention :** un dossier = une responsabilité. Une énigme ne connaît jamais une autre énigme ; elles ne communiquent que par des **flags** dans `GameState`.

---

## 2. Autoloads (singletons)

Un **autoload** (ou *singleton*) est un nœud instancié une seule fois au lancement et accessible depuis n'importe quel script par son nom. C'est le bon outil pour l'état global — et le mauvais outil pour tout le reste : cinq autoloads maximum, sinon le projet devient un sac de variables globales.

À déclarer dans `Projet > Paramètres du projet > Autoload`, **dans cet ordre** (l'ordre compte : `SaveSystem` lit `GameState` et `InventoryManager` au chargement) :

| Nom | Fichier | Responsabilité unique |
|---|---|---|
| `GameState` | `autoload/game_state.gd` | Flags de progression, acte courant, santé, munitions |
| `InventoryManager` | `autoload/inventory_manager.gd` | Objets possédés, combinaisons, objet équipé |
| `AudioDirector` | `autoload/audio_director.gd` | Bus, ambiances, **propagation du bruit vers les ennemis** |
| `SceneLoader` | `autoload/scene_loader.gd` | Changement de zone, fondu, position d'arrivée |
| `SaveSystem` | `autoload/save_system.gd` | Sérialisation JSON, slots, chargement |

### Frontières à ne pas franchir

- `InventoryManager` **ne connaît pas** les portes ni les énigmes. Il émet `item_added(id)` ; les autres écoutent.
- `GameState` **ne contient aucune logique**, uniquement des données et deux méthodes (`set_flag` / `has_flag`).
- Une énigme **n'appelle jamais** `SaveSystem`. Elle pose un flag ; le flag est sauvegardé au prochain point de sauvegarde.

---

## 3. Le modèle de données : `Resource` plutôt que dictionnaires

**Concept clé : la `Resource`.** En Godot, une `Resource` est un objet de données sérialisable, éditable dans l'inspecteur et référençable comme un fichier (`.tres`). C'est l'équivalent d'un « scriptable object ».

Pourquoi ne pas utiliser des dictionnaires pour les 40 objets du jeu :

- L'auto-complétion et le typage attrapent les fautes de frappe **à l'écriture**, pas au playtest.
- On édite `perche.tres` dans l'inspecteur, sans toucher au code.
- Une `Resource` peut porter directement une référence à un `PackedScene` (le modèle 3D d'inspection).

```
ItemData        (data/items/*.tres)     id, nom, description, icône, mesh d'inspection
CombineRecipe   (data/recipes/*.tres)   [id_a, id_b] -> id_résultat
EnemyProfile    (data/enemies/*.tres)   PV, vitesse, dégâts, portée d'ouïe
DocumentData    (data/docs/*.tres)      titre, corps du texte, annotation de Camille
```

> **Piège Godot 4 :** une `Resource` chargée est **partagée** entre toutes ses références. Si un script modifie `perche.tres` à l'exécution, la modification persiste en éditeur. Règle : les `Resource` sont **en lecture seule** à l'exécution ; l'état mutable vit dans les autoloads.

---

## 4. Composition par composants

**Concept clé : la composition.** Plutôt qu'une hiérarchie d'héritage profonde (`Objet > ObjetVivant > Ennemi > Zombie > ZombieRapide`), on attache des **nœuds-composants** réutilisables aux scènes qui en ont besoin.

```
Enemy (CharacterBody3D)
├── HealthComponent          <- réutilisé tel quel par le joueur et les boss
├── StateMachine
│   ├── IdleState  ├── ChaseState  ├── AttackState  ├── StaggerState
├── NavigationAgent3D
├── HurtBox (Area3D)
└── Model (importé)
```

Le `HealthComponent` ne sait pas ce qu'il équipe. Il expose `damage(amount)` et les signaux `damaged` / `died`. Le joueur, les trois boss et les Désancrés utilisent **le même fichier**.

---

## 5. Découpage des scènes et backtracking

Le jeu a du backtracking : le joueur revient au Hub une dizaine de fois. **Ne jamais recharger le Hub depuis le disque à chaque retour.**

**Stratégie retenue — chargement par zone avec cache :**

- `SceneLoader` maintient un dictionnaire `{zone_id: Node}` des zones déjà instanciées.
- Quitter une zone la retire de l'arbre (`remove_child`) **sans la libérer** : son état runtime (portes ouvertes, objets ramassés, ennemis morts) reste intact.
- Une zone n'est libérée qu'au passage d'acte (`Acte I -> II` libère toute la maison).
- Budget mémoire : 7 zones low-poly simultanées, négligeable.

**Transition de zone** = un `Area3D` `ZoneTrigger` qui appelle `SceneLoader.go_to(zone_id, spawn_point_name)`. Fondu au noir de 0,4 s masquant l'opération — et le fondu au noir est de toute façon la grammaire du genre.

---

## 6. Couches de collision (à configurer une fois pour toutes)

`Projet > Paramètres du projet > Couche > 3D Physique` :

| N° | Nom | Contenu |
|---|---|---|
| 1 | `world` | Murs, sols, tout le statique |
| 2 | `player` | Corps du joueur |
| 3 | `enemy` | Corps des ennemis |
| 4 | `interactable` | Tout ce que le `RayCast3D` du joueur doit détecter |
| 5 | `player_hitbox` | Zone de dégâts des armes du joueur |
| 6 | `enemy_hitbox` | Zone de dégâts des ennemis |
| 7 | `trigger` | Zones de script, transitions |
| 8 | `occluder_audio` | Volumes bloquant la propagation du bruit |

**Masques :**

- Le `RayCast3D` d'interaction du joueur ne scrute **que** la couche 4 : pas de test de type dans le code, pas de faux positifs sur les murs.
- Les ennemis collisionnent avec 1 et 2, jamais entre eux (couche 3 ne se masque pas elle-même) — évite les bouchons de zombies dans les couloirs étroits, plaie classique du genre.

---

## 7. Groupes de nœuds

| Groupe | Usage |
|---|---|
| `enemies` | `get_tree().call_group("enemies", "on_noise", pos, radius)` |
| `persistent` | Nœuds dont l'état est sauvegardé (portes, ramassables) |
| `save_points` | Repérage rapide pour l'UI |

**Concept clé : les groupes** sont un système de tags natif de Godot. Ils permettent de diffuser un appel à N nœuds sans que l'émetteur ne les connaisse — exactement ce qu'il faut pour la propagation du bruit.

---

## 8. Flux d'une interaction (traversée complète)

```
Joueur appuie sur E
   |
player.gd : InteractRay.get_collider()
   |
   v
Interactable.interact(player)         <- méthode virtuelle
   |
   +-- Pickup    -> InventoryManager.add(item_id) -> signal item_added
   +-- Door      -> vérifie GameState.has_flag()  -> anime ou refuse
   +-- Examinable-> ouvre inspector_ui (SubViewport)
   +-- Document  -> ouvre document_reader
   +-- Puzzle    -> ouvre l'UI de l'énigme concernée
```

Aucun `if` géant : chaque type d'interactable **surcharge** `interact()`. Ajouter un nouveau type ne modifie pas `player.gd`.

---

## 9. Signaux vs appels directs — la règle

- **Appel direct** quand l'appelant possède l'appelé (le joueur appelle son arme).
- **Signal** quand plusieurs systèmes non liés doivent réagir (`InventoryManager.item_added` est écouté par le HUD, l'audio et les énigmes).

Émettre un signal que personne n'écoute est gratuit. Coupler deux systèmes qui n'ont pas à se connaître coûte une réécriture au troisième acte.

---

## 10. Réglages projet à faire immédiatement

| Réglage | Valeur | Pourquoi |
|---|---|---|
| `rendering/renderer/rendering_method` | `forward_plus` | Volumetric fog, SDFGI |
| `display/window/size/viewport_width` × `height` | 640 × 360 | Rendu rétro (voir `05`) |
| `display/window/stretch/mode` | `viewport` | Upscale entier, pixels nets |
| `display/window/stretch/scale_mode` | `integer` | Pas de pixels baveux |
| `rendering/textures/canvas_textures/default_texture_filter` | `Nearest` | Look 90s |
| `physics/common/physics_ticks_per_second` | 60 | Stable pour le combat |
| `application/run/max_fps` | 60 | Cohérence de ressenti |
| `rendering/anti_aliasing/quality/msaa_3d` | `Disabled` | L'aliasing **fait partie** du look |
