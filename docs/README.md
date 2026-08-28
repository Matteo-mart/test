# 🕳️ VOID — Centre d'Études Perceptuelles de Valmont

> **Titre de travail :** VOID  
> **Genre :** Survival Horror FPS, Science-Fiction Psychologique  
> **Moteur :** Godot 4.x (Forward+ / GDScript)  
> **Plateformes :** PC (Windows / Linux)  
> **Ton & Références :** *Signalis* (froideur bureaucratique), *Silent Hill 2* (deuil), *Resident Evil 1* (complexe sous verrouillage)

---

## 📑 Table des matières
1. [Vue d'ensemble & Pitch](#1-vue-densemble--pitch)
2. [Piliers Narratifs & Univers](#2-piliers-narratifs--univers)
3. [Personnages Principaux](#3-personnages-principaux)
4. [Structure du Jeu & Progression](#4-structure-du-jeu--progression)
5. [Systèmes de Gameplay & Mechanics](#5-systèmes-de-gameplay--mechanics)
6. [Bestiaire & Bosses](#6-bestiaire--bosses)
7. [Architecture Technique & Code](#7-architecture-technique--code)
8. [Configuration du Projet Godot](#8-configuration-du-projet-godot)
9. [Structure du Dépôt](#9-structure-du-dépôt)
10. [Guide de Sauvegarde & Persistance](#10-guide-de-sauvegarde--persistance)

---

## 1. Vue d'ensemble & Pitch

* **1991.** Le Centre d'Études Perceptuelles de Valmont (CEP-V), un laboratoire souterrain dissimulé sous une maison de fonction isolée, mène le **Protocole VOID**. Au cours d'une nuit de mars, l'expérience dérape. Le complexe est scellé par une procédure automatique. 34 personnes sont déclarées disparues.
* **2003.** Camille Reyes hérite par courrier notarié d'une propriété dont elle ignorait l'existence. C'est le legs de sa mère, **Hélène Reyes**, chercheuse volatilisée en 1991. En cherchant des réponses dans la résidence, Camille découvre une trappe vers le complexe.

> **La question centrale du jeu :** *Que reste-t-il d'une personne quand ce qu'elle perçoit cesse de correspondre à ce qui est ?*

---

## 2. Piliers Narratifs & Univers

### Le Concept d'Ancrage
La perception humaine n'est pas une simple observation du réel, mais une **négociation avec lui**. Sous une stimulation sensorielle précise (lumière stroboscopique, fréquence de calibrage, privation vestibulaire), le modèle interne du cerveau s'impose à la matière environnante.  
À l'échelle d'un site scellé contenant 34 sujets bloqués dans des boucles perceptives contradictoires, l'espace se déforme et génère une **géométrie impossible**.

### Signification de VOID
`VOID` n'est pas une incantation magique ni un terme anglais, mais un sigle administratif français :
$$\text{VOID} = \textbf{V}\text{ection }\textbf{O}\text{ptique et }\textbf{I}\text{nduction }\textbf{D}\text{issociative}$$

### Les Trois Lois Impératives
1. **Rien n'est surnaturel :** Tout phénomène physique défaillant possède un rapport administratif ou technique qui l'explique.
2. **L'ancrage nécessite un observateur :** Les espaces ne se déforment que là où une perception est active.
3. **Le protocole est réversible, jamais annulable :** On peut sceller ou rééquilibrer, mais pas effacer ce qui a été modified.

---

## 3. Personnages Principaux

* **Camille Reyes (Protagoniste) :** 34 ans, archiviste. Personnage muet en vue FPS. Sa voix et sa personnalité s'expriment exclusivement via des **annotations manuscrites** inscrites en bas des documents collectés.
* **Hélène Reyes (Mère de Camille) :** Chercheuse en psychophysique à l'Aile Recherche. Elle a compris la dérive du protocole et s'est enfermée pour verrouiller le site. Elle a conçu le prototype du **Pistolet d'ancrage**.
* **Paul Achard (Directeur du CEP-V) :** Antagoniste principal (61 ans en 1991). Convaincu que l'ancrage est la clé de l'immortalité. S'est ancré lui-même dans la structure du Secteur Ouest.
* **Dr. Anne-Marie Sorel :** Cheffe de l'Aile Médicale. A conçu le sérum d'ancrage pour tenter de stabiliser les sujets.
* **Rémi Delcourt :** Technicien électricien. A laissé derrière lui des notes, des marquages à la peinture UV et la **lampe torche** récupérée par le joueur.

---

## 4. Structure du Jeu & Progression

### Layout Spatial & Progression des Badges
Le CEP-Valmont s'articule autour d'un **Hub Central** desservant trois ailes de recherche, avant d'accéder au Secteur Ouest et à la sortie.



schéma: 
````bash
[ MAISON DE FONCTION ]         <- Acte I (Surface)
                 Salon / Bureau / Sous-sol
                           |
                   (Monte-charge)
                           |
 ============================================================
                 [ HALL D'ACCUEIL — HUB ]       <- Acte II
          _________________|______________________
         |                 |                      |
   [AILE MÉDICALE]    [AILE COMS]          [AILE RECHERCHE]
    Dr. Sorel          Radio / Morgue       Hélène / Rémi
    Badge ROUGE        -> Fréquence ->      Badge VERT
         |_________________|______________________|
                           |
                 [ SECTEUR OUEST ]              <- Acte III
                 Couloir plié / Bureau Achard
                 Badge BLEU
                           |
                 [ PORTE BLINDÉE — SORTIE ]
````


### Chronologie des Révocations (Ordre des Badges)
Pour ouvrir la porte blindée lors de l'Acte III (Énigme 10), l'ordre d’insertion des badges découle de la chronologie des révocations administratives :

| Badge | Titulaire | Date de révocation |
| :--- | :--- | :--- |
| **ROUGE** | A.-M. Sorel | 12 mars 1991 |
| **BLEU** | P. Achard | 14 mars 1991 |
| **VERT** | H. Reyes | 19 mars 1991 |

---

## 5. Systèmes de Gameplay & Mechanics

### Gestion du Bruit & Infiltration
Les ennemis (les *Désancrés*) sont bloqués dans leur perception de 1991. **Ils ne voient pas le joueur mais réagissent au son**.
* **Accroupi :** Rayon d'audibilité $\approx 2.0\text{ m}$.
* **Marche :** Rayon d'audibilité $\approx 7.0\text{ m}$.
* **Course :** Rayon d'audibilité $\approx 16.0\text{ m}$ (consomme également de l'endurance).
* **Portes / Panneaux :** L'ouverture d'une porte propage une onde sonore de $12.0\text{ m}$.

### Inspection 3D d'Objets
Certains objets (dont les badges d'habilitation et la gemme de calibrage) révèlent des indices ou des composants lorsqu'ils sont manipulés sous des angles spécifiques dans l'inspecteur 3D (`SubViewport` dédié).

### Les 10 Énigmes Narratives
Toutes les énigmes disposent d'une justification diégétique au sein du complexe :
1. **Perche (Manche + Crochet) :** Récupération de la clé du bureau sur le lustre.
2. **Horloge (03:45) :** Réglage sur l'heure de l'incident pour ouvrir la trappe du sous-sol.
3. **Cadenas VOID :** Combinaison issue du sigle administratif.
4. **Statue Anatomique :** Extraction de la puce d’accès sous la lentille de calibrage.
5. **Centrifugeuse :** Équilibrage des jauges pour purifier le sérum et déverrouiller le Badge Rouge.
6. **Fréquence Radio :** Alignement d'onde porteuse pour réouvrir l'Aile Recherche.
7. **Circuit & Lampe UV :** Révélation du code de la caisse à outils à la lumière UV et remplacement du fusible.
8. **Miroir du Couloir Plié :** Alignement d'un objet avec son reflet pour résoudre la déformation spatiale.
9. **Piano :** Reproduction du ton de calibrage de la boîte à musique pour ouvrir le coffre du Directeur.
10. **Console Finale :** Séquence d'insertion des badges (Rouge → Bleu → Vert) et saisie du code gravé sous chronomètre.

---

## 6. Bestiaire & Bosses

### Les Désancrés
Les 34 survivants de l'incident de 1991. 
* **Tardifs (Actes I-II) :** Lents, 60 PV.
* **De terrain (Acte II) :** Rapides, 90 PV, frappe lourde.
* **Profonds (Acte III) :** Silencieux. Se déplacent uniquement lorsque le joueur détourne le regard (libérés du rôle d'observateur).

### Affrontements de Boss
Aucun boss ne s'élimine par simple confrontation directe ou dégâts bruts :
* **Le Gardien (Acte I) :** Aveugle. Nécessite d'attirer l'ennemi sous le monte-charge à l'aide de bruits distractifs.
* **La Matrone (Acte II) :** Fusion de 7 sujets. Doit être attirée dans le sas de décontamination via 3 appâts sonores successifs.
* **L'Ancre / Paul Achard (Acte III) :** Phase 1 & 2 : destruction des reflets dans les miroirs. Phase finale : désynchronisation obligatoire au **Pistolet d'ancrage**.

---

## 7. Architecture Technique & Code

Le projet est articulé autour de **Singletons (Autoloads)** isolés et d'une architecture orientée composants.

### Architecture des Singletons (`Autoload`)
Ordre strict de déclaration dans Godot :
1. `GameState` (`autoload/game_state.gd`) : Gestionnaire de l'état, de la santé et des flags de progression.
2. `InventoryManager` (`autoload/inventory_manager.gd`) : Gestion de l'inventaire, catalogue d'objets `.tres` et recettes.
3. `AudioDirector` (`autoload/audio_director.gd`) : Propagation des événements sonores et ambiances.
4. `SceneLoader` (`autoload/scene_loader.gd`) : Chargement dynamique et mise en cache des zones.
5. `SaveSystem` (`autoload/save_system.gd`) : Sérialisation et restauration de l'état du jeu au format JSON.

### Aperçu des Classes Principales (GDScript)

#### `GameState` (`autoload/game_state.gd`)
````bash gdscript
extends Node

signal flag_changed(flag_name: String, value: bool)
signal health_changed(current: int, maximum: int)

const MAX_HEALTH := 100

var current_act: int = 1
var current_zone: String = "act1_maison"
var health: int = MAX_HEALTH
var ammo_revolver: int = 0
var ammo_shotgun: int = 0
var flashlight_battery: float = 1.0

var flags: Dictionary = {}

func set_flag(flag_name: String, value: bool = true) -> void:
	if flags.get(flag_name, false) == value:
		return
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)
````
````bash
extends StaticBody3D
class_name Interactable

signal interacted(by: Node3D)

@export var prompt_text: String = "Examiner"
@export var enabled: bool = true
@export var locked_prompt: String = ""

func interact(by: Node3D) -> void:
	if not enabled or not can_interact(by):
		if locked_prompt != "":
			Hud.show_message(locked_prompt)
		return
	_do_interact(by)
	interacted.emit(by)

func can_interact(_by: Node3D) -> bool:
	return true

func _do_interact(_by: Node3D) -> void:
	pass
````

## Structure du projet: 
````bash
res://
├── autoload/                  # Singletons globaux (GameState, Inventory, etc.)
├── core/                      # Composants de base (Interactable, Health, StateMachine)
├── data/                      # Ressources (.tres) : items, recettes, documents
│   ├── docs/                  # D01 à D16 (les 16 documents narratifs)
│   ├── items/                 # ItemData pour chaque objet
│   └── recipes/               # Recettes de combinaison d'objets
├── player/                    # Controller FPS, Lampe torche, Gestion de caméra
├── objects/                   # Props interactifs (Portes, Ramassables, Cassettes)
├── puzzles/                   # Scènes et scripts d'énigmes (p01 à p10)
├── enemies/                   # AI des Désancrés et scènes de Boss
├── levels/                    # Cartes de niveaux découpées par Zone/Acte
│   ├── act1_maison/
│   ├── act2_hub/
│   ├── act2_medical/
│   ├── act2_coms/
│   ├── act2_recherche/
│   └── act3_ouest/
└── ui/                        # Interface utilisateur, HUD, Inspecteur 3D, Lecteur de docs
````

### Configuration du projet Godot:
Afin de garantir le rendu rétro 90s et les performances physiques, appliquez les paramètres suivants dans `project.godot` :
| Paramètre | Valeur | Raison |
|---|---|---|
| `rendering/renderer/rendering_method` | `forward_plus` | Brouillard |
| `display/window/size/viewport_width` | `640` | Résolution native rétro |
| `display/window/size/viewport_height` | `360` | Format 16:9 Pixel-Perfect |
| `display/window/stretch/mode` | `viewport` | Upscale net des pixels |
| `display/window/stretch/scale_mode` | `integer` | Conservation du ratio de pixels |
| `rendering/textures/canvas_textures/default_texture_filter` | `nearest` | Rendu de textures sans filtrage linéaire |
| `physics/common/physics_ticks_per_second` | `60` | Stabilité de la simulation physique |
| `rendering/anti_aliasing/quality/msaa_3d` | `disabled` | Conservation de l'aliasing esthétique 90s |