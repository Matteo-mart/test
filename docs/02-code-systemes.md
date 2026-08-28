# 02 — Code des systèmes (GDScript, Godot 4)

Tous les blocs sont **complets et copiables tels quels**. API Godot 4.x uniquement.

---

## 1. `autoload/game_state.gd` — l'état global

```gdscript
extends Node
## Autoload : GameState
## Conteneur de données pures. AUCUNE logique de jeu ici, sinon ce fichier
## devient le dépotoir du projet.

signal flag_changed(flag_name: String, value: bool)
signal health_changed(current: int, maximum: int)

const MAX_HEALTH := 100

var current_act: int = 1
var current_zone: String = "act1_maison"
var health: int = MAX_HEALTH
var ammo_revolver: int = 0
var ammo_shotgun: int = 0   ## Réserve du fusil à pompe, trouvé fin d'Acte III — voir 03 §9
var flashlight_battery: float = 1.0

## Tous les verrous de progression du jeu vivent ici.
## Convention de nommage : <zone>_<sujet>_<etat>
var flags: Dictionary = {}

func set_flag(flag_name: String, value: bool = true) -> void:
	if flags.get(flag_name, false) == value:
		return
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)

func has_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func damage(amount: int) -> void:
	health = clampi(health - amount, 0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)

func heal(amount: int) -> void:
	health = clampi(health + amount, 0, MAX_HEALTH)
	health_changed.emit(health, MAX_HEALTH)

## Remet tout à zéro (nouvelle partie).
func reset() -> void:
	current_act = 1
	current_zone = "act1_maison"
	health = MAX_HEALTH
	ammo_revolver = 0
	ammo_shotgun = 0
	flashlight_battery = 1.0
	flags.clear()
```

---

## 2. Les ressources de données

### `core/item_data.gd`

```gdscript
extends Resource
class_name ItemData
## Une entrée du catalogue d'objets. Un fichier .tres par objet,
## dans data/items/. Jamais modifié à l'exécution.

@export var id: StringName                  ## Identifiant unique, ex: &"manche_balai"
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

## Scène 3D affichée dans l'inspecteur d'objet (§7).
## Laisser vide si l'objet n'est pas inspectable.
@export var inspect_scene: PackedScene

## Si true, l'objet peut apparaître dans une recette de combinaison.
@export var combinable: bool = false

## Objets à usage unique : disparaissent après utilisation réussie.
@export var consumable: bool = true

## Flag posé dans GameState quand l'objet entre dans l'inventaire.
## Sert aux énigmes qui doivent réagir à une acquisition.
@export var flag_on_pickup: String = ""
```

### `core/combine_recipe.gd`

```gdscript
extends Resource
class_name CombineRecipe
## Une recette : deux ingrédients -> un résultat.
## Un fichier .tres par recette, dans data/recipes/.

@export var ingredient_a: StringName
@export var ingredient_b: StringName
@export var result: StringName

## Texte affiché en cas de succès ("Le crochet tient bon.").
@export var success_message: String = ""

## Message d'échec spécifique si le joueur tente une paire proche mais fausse.
@export var hint_on_fail: String = ""

## Vrai si la paire fournie correspond, dans n'importe quel ordre.
func matches(a: StringName, b: StringName) -> bool:
	return (a == ingredient_a and b == ingredient_b) \
		or (a == ingredient_b and b == ingredient_a)
```

**Recette de l'Énigme 1** (`data/recipes/perche.tres`) : `ingredient_a = &"manche_balai"`, `ingredient_b = &"crochet"`, `result = &"perche"`.

---

## 3. `autoload/inventory_manager.gd` — inventaire et combinaisons

```gdscript
extends Node
## Autoload : InventoryManager
## Ne connaît ni les portes, ni les énigmes, ni l'UI. Il émet des signaux.

signal item_added(item_id: StringName)
signal item_removed(item_id: StringName)
signal items_combined(result_id: StringName, message: String)
signal combine_failed(hint: String)
signal equipped_changed(item_id: StringName)

const ITEMS_DIR := "res://data/items/"
const RECIPES_DIR := "res://data/recipes/"

## Catalogue complet, chargé une fois au démarrage : { id: ItemData }
var _catalog: Dictionary = {}
var _recipes: Array[CombineRecipe] = []

## Ce que le joueur possède réellement : { id: quantité }
var _held: Dictionary = {}

## Objet actuellement "en main" pour un usage sur le monde (clé, perche…).
var equipped: StringName = &""

func _ready() -> void:
	_load_catalog()
	_load_recipes()

# ---------------------------------------------------------------- chargement

func _load_catalog() -> void:
	for file_name in _list_tres(ITEMS_DIR):
		var res: ItemData = load(ITEMS_DIR + file_name)
		if res and res.id != &"":
			_catalog[res.id] = res
		else:
			push_error("ItemData invalide ou sans id : " + file_name)

func _load_recipes() -> void:
	for file_name in _list_tres(RECIPES_DIR):
		var res: CombineRecipe = load(RECIPES_DIR + file_name)
		if res:
			_recipes.append(res)

## Liste les .tres d'un dossier. ATTENTION : dans un export release, seuls
## les fichiers importés sont présents et l'extension devient .remap.
func _list_tres(dir_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("Dossier introuvable : " + dir_path)
		return result
	for file_name in dir.get_files():
		if file_name.ends_with(".remap"):
			file_name = file_name.trim_suffix(".remap")
		if file_name.ends_with(".tres"):
			result.append(file_name)
	return result

# ------------------------------------------------------------------ requêtes

func get_data(item_id: StringName) -> ItemData:
	return _catalog.get(item_id)

func has(item_id: StringName) -> bool:
	return _held.get(item_id, 0) > 0

func get_all_ids() -> Array:
	return _held.keys()

# ------------------------------------------------------------------ mutation

func add(item_id: StringName, amount: int = 1) -> void:
	if not _catalog.has(item_id):
		push_error("Objet inconnu au catalogue : " + str(item_id))
		return
	_held[item_id] = _held.get(item_id, 0) + amount
	var data: ItemData = _catalog[item_id]
	if data.flag_on_pickup != "":
		GameState.set_flag(data.flag_on_pickup)
	item_added.emit(item_id)

func remove(item_id: StringName, amount: int = 1) -> void:
	if not has(item_id):
		return
	_held[item_id] = _held[item_id] - amount
	if _held[item_id] <= 0:
		_held.erase(item_id)
		if equipped == item_id:
			equip(&"")
	item_removed.emit(item_id)

func equip(item_id: StringName) -> void:
	equipped = item_id
	equipped_changed.emit(item_id)

# --------------------------------------------------------------- combinaison

## Cœur de l'Énigme 1 (manche + crochet = perche).
## Retourne true si la combinaison a réussi.
func try_combine(a: StringName, b: StringName) -> bool:
	if a == b or not has(a) or not has(b):
		return false

	for recipe in _recipes:
		if recipe.matches(a, b):
			remove(a)
			remove(b)
			add(recipe.result)
			items_combined.emit(recipe.result, recipe.success_message)
			return true

	# Échec : on cherche un indice contextuel plutôt qu'un "ça ne marche pas".
	for recipe in _recipes:
		if recipe.ingredient_a == a or recipe.ingredient_b == a \
		or recipe.ingredient_a == b or recipe.ingredient_b == b:
			if recipe.hint_on_fail != "":
				combine_failed.emit(recipe.hint_on_fail)
				return false

	combine_failed.emit("Ces deux objets ne vont pas ensemble.")
	return false

# ------------------------------------------------------------- sérialisation

func to_dict() -> Dictionary:
	# Les StringName ne survivent pas au JSON : on convertit en String.
	var held_as_strings := {}
	for key in _held:
		held_as_strings[String(key)] = _held[key]
	return { "held": held_as_strings, "equipped": String(equipped) }

func from_dict(data: Dictionary) -> void:
	_held.clear()
	for key in data.get("held", {}):
		_held[StringName(key)] = int(data["held"][key])
	equip(StringName(data.get("equipped", "")))
```

> **Piège n°1 du projet :** `StringName` (`&"manche_balai"`) et `String` (`"manche_balai"`) ne sont pas interchangeables comme clés de dictionnaire. Le code ci-dessus convertit explicitement aux frontières JSON. C'est la source de bug la plus fréquente sur ce type d'architecture.

---

## 4. `core/interactable.gd` — la classe de base

```gdscript
extends StaticBody3D
class_name Interactable
## Base de tout ce que le joueur peut viser et activer.
## Le corps doit être sur la couche de collision 4 (interactable).

signal interacted(by: Node3D)

@export var prompt_text: String = "Examiner"
@export var enabled: bool = true

## Message affiché quand l'objet est verrouillé par une condition.
@export var locked_prompt: String = ""

## Surbrillance au survol : on ne touche pas au matériau importé,
## on utilise un overlay temporaire.
@export var highlight_material: Material

var _original_overlays: Dictionary = {}

## Le joueur appelle ceci. Les sous-classes surchargent can_interact/_do.
func interact(by: Node3D) -> void:
	if not enabled:
		return
	if not can_interact(by):
		if locked_prompt != "":
			Hud.show_message(locked_prompt)
		return
	_do_interact(by)
	interacted.emit(by)

## À surcharger : condition d'accès (possède la clé, flag posé…).
func can_interact(_by: Node3D) -> bool:
	return true

## À surcharger : l'effet réel.
func _do_interact(_by: Node3D) -> void:
	pass

## Texte affiché dans le HUD au survol.
func get_prompt() -> String:
	return prompt_text

func set_highlighted(active: bool) -> void:
	if highlight_material == null:
		return
	for child in find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if active:
			_original_overlays[mesh] = mesh.material_overlay
			mesh.material_overlay = highlight_material
		elif _original_overlays.has(mesh):
			mesh.material_overlay = _original_overlays[mesh]
```

### `objects/pickup.gd`

```gdscript
extends Interactable
class_name Pickup
## Un objet à ramasser. Se retire du monde et s'enregistre comme "pris"
## pour ne pas réapparaître au rechargement de zone.

@export var item: ItemData
@export var amount: int = 1

## Identifiant stable et unique, saisi à la main dans l'inspecteur.
## Ex : "maison_salon_manche". Sert à la sauvegarde.
@export var persistent_id: String = ""

func _ready() -> void:
	add_to_group("persistent")
	prompt_text = "Prendre " + (item.display_name if item else "?")
	# Déjà ramassé lors d'une session précédente : on disparaît.
	if persistent_id != "" and GameState.has_flag("picked_" + persistent_id):
		queue_free()

func _do_interact(_by: Node3D) -> void:
	InventoryManager.add(item.id, amount)
	AudioDirector.play_ui("pickup")
	if persistent_id != "":
		GameState.set_flag("picked_" + persistent_id)
	queue_free()
```

### `objects/door.gd`

```gdscript
extends Interactable
class_name Door
## Porte à trois modes de verrouillage, cumulables.

enum LockType { NONE, ITEM, FLAG, BADGE }

@export var lock_type: LockType = LockType.NONE
@export var required_item: StringName = &""
@export var required_flag: String = ""
@export var consume_item: bool = true

@export var persistent_id: String = ""
@export var open_angle_degrees: float = 95.0
@export var open_duration: float = 0.8

@onready var _pivot: Node3D = $Pivot
@onready var _audio: AudioStreamPlayer3D = $Audio

var _is_open: bool = false

func _ready() -> void:
	add_to_group("persistent")
	if persistent_id != "" and GameState.has_flag("door_open_" + persistent_id):
		_snap_open()

func can_interact(_by: Node3D) -> bool:
	if _is_open:
		return true
	match lock_type:
		LockType.ITEM:
			return InventoryManager.has(required_item)
		LockType.FLAG, LockType.BADGE:
			return GameState.has_flag(required_flag)
		_:
			return true

func get_prompt() -> String:
	if _is_open:
		return "Fermer"
	if not can_interact(null):
		return locked_prompt if locked_prompt != "" else "Verrouillée"
	return "Ouvrir"

func _do_interact(_by: Node3D) -> void:
	if not _is_open and lock_type == LockType.ITEM and consume_item:
		InventoryManager.remove(required_item)

	_is_open = not _is_open
	var target := deg_to_rad(open_angle_degrees) if _is_open else 0.0

	# Tween : interpolation gérée par le moteur, libérée automatiquement.
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(_pivot, "rotation:y", target, open_duration)

	_audio.stream = preload("res://audio/sfx/door_open.ogg") if _is_open \
		else preload("res://audio/sfx/door_close.ogg")
	_audio.play()

	# Une porte fait du bruit : les Désancrés l'entendent.
	AudioDirector.emit_noise(global_position, 12.0)

	if persistent_id != "":
		GameState.set_flag("door_open_" + persistent_id, _is_open)

func _snap_open() -> void:
	_is_open = true
	_pivot.rotation.y = deg_to_rad(open_angle_degrees)
```

---

## 5. `player/player.gd` — contrôleur FPS

Structure de scène :

```
Player (CharacterBody3D)
├── Collision (CapsuleShape3D, hauteur 1.8)
├── Head (Node3D, y = 1.6)
│   ├── Camera3D
│   │   ├── InteractRay (RayCast3D, target_position = (0,0,-2.5), mask = couche 4)
│   │   └── WeaponHolder (Node3D)
│   └── Flashlight (SpotLight3D)
├── Footsteps (AudioStreamPlayer3D)
└── HealthComponent
```

```gdscript
extends CharacterBody3D
class_name Player

const WALK_SPEED := 2.6
const RUN_SPEED := 4.8
const CROUCH_SPEED := 1.3
const ACCELERATION := 12.0
const MOUSE_SENSITIVITY := 0.0022
const HEAD_Y_STAND := 1.6
const HEAD_Y_CROUCH := 0.95

## Endurance : courir est bruyant ET limité. Double coût, double tension.
const STAMINA_MAX := 100.0
const STAMINA_DRAIN := 28.0
const STAMINA_REGEN := 14.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var footsteps: AudioStreamPlayer3D = $Footsteps

var stamina: float = STAMINA_MAX
var is_crouching: bool = false
var can_move: bool = true          ## Désactivé pendant l'inspection / les UI

var _current_interactable: Interactable = null
var _bob_time: float = 0.0
var _step_distance: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not can_move:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# Verrou vertical : sans ça, la caméra fait des tonneaux.
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))

	if event.is_action_pressed("interact") and _current_interactable:
		_current_interactable.interact(self)
		get_viewport().set_input_as_handled()

	if event.is_action_pressed("crouch"):
		_set_crouch(not is_crouching)

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	_apply_gravity(delta)
	_apply_movement(delta)
	_update_stamina(delta)
	_update_head_bob(delta)
	_update_interaction()
	move_and_slide()

# ------------------------------------------------------------------ mouvement

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func _apply_movement(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var speed := _current_speed()
	var target := direction * speed
	velocity.x = move_toward(velocity.x, target.x, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, target.z, ACCELERATION * delta)

func _current_speed() -> float:
	if is_crouching:
		return CROUCH_SPEED
	if Input.is_action_pressed("sprint") and stamina > 1.0:
		return RUN_SPEED
	return WALK_SPEED

func _set_crouch(value: bool) -> void:
	is_crouching = value
	var target_y := HEAD_Y_CROUCH if value else HEAD_Y_STAND
	var tween := create_tween()
	tween.tween_property(head, "position:y", target_y, 0.18)

func _update_stamina(delta: float) -> void:
	var is_running := Input.is_action_pressed("sprint") \
		and velocity.length() > 0.5 and not is_crouching
	if is_running:
		stamina = maxf(stamina - STAMINA_DRAIN * delta, 0.0)
	else:
		stamina = minf(stamina + STAMINA_REGEN * delta, STAMINA_MAX)

# --------------------------------------------------------- caméra et bruit

func _update_head_bob(delta: float) -> void:
	var speed := Vector2(velocity.x, velocity.z).length()
	if speed < 0.2 or not is_on_floor():
		return

	_bob_time += delta * speed * 1.6
	# Amplitude volontairement faible : le head-bob doit se sentir, pas se voir.
	camera.position.y = sin(_bob_time * 2.0) * 0.018
	camera.position.x = cos(_bob_time) * 0.012

	# Un pas tous les 1,7 m parcourus -> son + bruit propagé aux ennemis.
	_step_distance += speed * delta
	if _step_distance >= 1.7:
		_step_distance = 0.0
		_play_footstep(speed)

func _play_footstep(speed: float) -> void:
	footsteps.stream = AudioDirector.get_footstep_for_surface(global_position)
	footsteps.volume_db = -18.0 if is_crouching else (-6.0 if speed > 3.5 else -12.0)
	footsteps.play()

	# Rayon d'audibilité : accroupi ~2 m, marche ~7 m, course ~16 m.
	var radius := 2.0 if is_crouching else (16.0 if speed > 3.5 else 7.0)
	AudioDirector.emit_noise(global_position, radius)

# ------------------------------------------------------------- interaction

func _update_interaction() -> void:
	var hit: Interactable = null
	if interact_ray.is_colliding():
		hit = interact_ray.get_collider() as Interactable

	if hit == _current_interactable:
		return

	if _current_interactable:
		_current_interactable.set_highlighted(false)

	_current_interactable = hit

	if _current_interactable:
		_current_interactable.set_highlighted(true)
		Hud.show_prompt(_current_interactable.get_prompt())
	else:
		Hud.hide_prompt()
```

**Actions à créer** dans `Projet > Paramètres > Contrôles` :
`move_forward`, `move_back`, `move_left`, `move_right`, `sprint`, `crouch`, `interact`, `inventory`, `flashlight`, `attack`, `aim`, `reload`, `pause`.

---

## 6. `player/flashlight.gd` — la lampe torche

```gdscript
extends SpotLight3D
## Lampe de Rémi Delcourt. Batterie limitée : la lumière est une ressource.

const DRAIN_PER_SECOND := 0.0035     ## ~285 s d'autonomie continue
const FLICKER_THRESHOLD := 0.25

@export var enabled_by_default: bool = false

var _base_energy: float

func _ready() -> void:
	_base_energy = light_energy
	visible = enabled_by_default

func _process(delta: float) -> void:
	if not visible:
		return

	GameState.flashlight_battery = maxf(GameState.flashlight_battery - DRAIN_PER_SECOND * delta, 0.0)

	if GameState.flashlight_battery <= 0.0:
		visible = false
		AudioDirector.play_ui("flashlight_die")
		return

	# Sous 25 % : vacillement. Le joueur comprend sans jauge à l'écran.
	if GameState.flashlight_battery < FLICKER_THRESHOLD:
		var noise := sin(Time.get_ticks_msec() * 0.02) * randf_range(0.4, 1.0)
		light_energy = _base_energy * (0.55 + 0.45 * noise)
	else:
		light_energy = _base_energy

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flashlight") and GameState.flashlight_battery > 0.0:
		visible = not visible
		AudioDirector.play_ui("flashlight_click")
```

---

## 7. `ui/object_inspector.gd` — inspection 3D (Énigme 4 et badges)

C'est la pièce demandée explicitement : **faire tourner un objet à la souris pour découvrir un détail dissimulé dessous**.

### Structure de scène `inspector_ui.tscn`

```
InspectorUI (CanvasLayer)
├── Backdrop (ColorRect, noir 85 %)
├── SubViewportContainer (stretch = true)
│   └── SubViewport            <- own_world_3d = ON, transparent_bg = ON
│       ├── PivotYaw (Node3D)
│       │   └── PivotPitch (Node3D)
│       │       └── ModelSlot (Node3D)   <- le modèle y est instancié
│       ├── InspectCamera (Camera3D, position z = 0.5)
│       ├── KeyLight (DirectionalLight3D)
│       └── FillLight (OmniLight3D, faible)
├── NameLabel
├── DescriptionLabel
└── HintLabel
```

**Concept clé : le `SubViewport`.** C'est un rendu dans le rendu. Avec `own_world_3d = true`, la scène 3D d'inspection possède son propre monde : l'objet est éclairé par ses propres lumières, indépendamment du couloir noir dans lequel se tient le joueur. Sans cela, on inspecterait une silhouette noire.

```gdscript
extends CanvasLayer
class_name ObjectInspector
## Vue d'inspection d'un objet de l'inventaire.
## Le joueur fait tourner l'objet ; certains objets révèlent un détail
## quand une face précise est présentée à la caméra.

signal secret_revealed(item_id: StringName)
signal closed

const ROTATION_SPEED := 0.008
const ZOOM_SPEED := 0.12
const ZOOM_MIN := 0.28
const ZOOM_MAX := 0.9

@onready var _yaw: Node3D = $SubViewportContainer/SubViewport/PivotYaw
@onready var _pitch: Node3D = $SubViewportContainer/SubViewport/PivotYaw/PivotPitch
@onready var _slot: Node3D = $SubViewportContainer/SubViewport/PivotYaw/PivotPitch/ModelSlot
@onready var _camera: Camera3D = $SubViewportContainer/SubViewport/InspectCamera
@onready var _name_label: Label = $NameLabel
@onready var _desc_label: Label = $DescriptionLabel
@onready var _hint_label: Label = $HintLabel

var _current_item: ItemData
var _model: Node3D
var _is_dragging: bool = false
var _secret_found: bool = false

## Marqueur optionnel placé DANS le modèle 3D, nommé "SecretMarker".
## Sa direction locale -Z pointe vers le détail caché.
var _secret_marker: Node3D

func _ready() -> void:
	hide()
	set_process_unhandled_input(false)

# ---------------------------------------------------------------- ouverture

func open(item: ItemData) -> void:
	if item == null or item.inspect_scene == null:
		push_warning("Objet non inspectable : " + str(item))
		return

	_current_item = item
	_secret_found = GameState.has_flag("inspected_" + String(item.id))

	# Nettoyage d'une éventuelle inspection précédente.
	for child in _slot.get_children():
		child.queue_free()

	_model = item.inspect_scene.instantiate()
	_slot.add_child(_model)
	_secret_marker = _model.find_child("SecretMarker", true, false) as Node3D

	_yaw.rotation = Vector3.ZERO
	_pitch.rotation = Vector3.ZERO
	_camera.position.z = 0.5

	_name_label.text = item.display_name
	_desc_label.text = item.description
	_hint_label.text = "Clic gauche maintenu : tourner   |   Molette : zoom   |   Échap : fermer"

	show()
	set_process_unhandled_input(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true          # pause pendant l'inspection
	process_mode = Node.PROCESS_MODE_ALWAYS

func close() -> void:
	hide()
	set_process_unhandled_input(false)
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	closed.emit()

# ------------------------------------------------------------------- entrée

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		close()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_is_dragging = event.pressed
			MOUSE_BUTTON_WHEEL_UP:
				_camera.position.z = clampf(_camera.position.z - ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)
			MOUSE_BUTTON_WHEEL_DOWN:
				_camera.position.z = clampf(_camera.position.z + ZOOM_SPEED, ZOOM_MIN, ZOOM_MAX)

	if event is InputEventMouseMotion and _is_dragging:
		# Deux pivots imbriqués = rotation type "trackball" sans gimbal lock
		# gênant : le yaw tourne autour de l'axe monde Y, le pitch autour
		# de l'axe local X. Le pitch est borné pour éviter le retournement.
		_yaw.rotate_y(-event.relative.x * ROTATION_SPEED)
		_pitch.rotate_x(-event.relative.y * ROTATION_SPEED)
		_pitch.rotation.x = clampf(_pitch.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		_check_secret()

# ------------------------------------------------------- détail dissimulé

## Révélation du détail caché.
##
## Principe : le modèle contient un nœud vide "SecretMarker" dont l'axe -Z
## local est planté perpendiculairement à la face secrète (le dessous de la
## gemme, la gravure sous un badge). On calcule l'angle entre cette direction
## une fois transformée en espace monde et la direction de la caméra.
## Quand l'angle passe sous le seuil, la face regarde le joueur : on révèle.
func _check_secret() -> void:
	if _secret_found or _secret_marker == null:
		return

	var marker_forward: Vector3 = -_secret_marker.global_transform.basis.z
	var to_camera: Vector3 = (_camera.global_position - _secret_marker.global_position).normalized()

	# dot() = 1.0 quand les vecteurs sont alignés. cos(25°) ~= 0.906.
	if marker_forward.dot(to_camera) > 0.906:
		_reveal_secret()

func _reveal_secret() -> void:
	_secret_found = true
	GameState.set_flag("inspected_" + String(_current_item.id))

	# Effet visuel : le détail est un enfant caché du modèle, nommé "SecretVisual".
	var visual := _model.find_child("SecretVisual", true, false) as Node3D
	if visual:
		visual.visible = true
		var tween := create_tween()
		tween.tween_property(visual, "scale", Vector3.ONE, 0.35) \
			.from(Vector3.ONE * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_hint_label.text = "Quelque chose est gravé ici."
	AudioDirector.play_ui("discovery")
	secret_revealed.emit(_current_item.id)
```

**Comment l'utiliser pour les deux cas prévus :**

- **Gemme Rouge (Énigme 4)** : `SecretMarker` sous la gemme, `SecretVisual` = la puce d'accès. Un `PuzzleManager` écoute `secret_revealed` et donne l'objet `puce_acces` au joueur.
- **Badges (Énigme 10)** : `SecretMarker` sous chaque badge, `SecretVisual` = un `Label3D` portant un chiffre. Trois badges inspectés = code à trois chiffres.

> **Préparation du modèle sans compétence 3D :** ouvrir le `.glb` importé dans Godot, clic droit → *Rendre local*, ajouter un `Node3D` nommé `SecretMarker` orienté à la main dans l'éditeur, et un `Label3D` nommé `SecretVisual` avec `visible = false`. Aucun logiciel de modélisation nécessaire.

---

## 8. `autoload/save_system.gd` — sauvegarde JSON

```gdscript
extends Node
## Autoload : SaveSystem
## Sauvegarde par snapshot complet. Format JSON versionné.

signal game_saved(slot: int)
signal game_loaded(slot: int)

const SAVE_VERSION := 1
const SAVE_DIR := "user://saves/"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func _path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

# --------------------------------------------------------------- écriture

func save_game(slot: int = 0) -> bool:
	var data := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"playtime_seconds": int(Time.get_ticks_msec() / 1000.0),
		"state": {
			"current_act": GameState.current_act,
			"current_zone": GameState.current_zone,
			"health": GameState.health,
			"ammo_revolver": GameState.ammo_revolver,
			"ammo_shotgun": GameState.ammo_shotgun,
			"flashlight_battery": GameState.flashlight_battery,
			"flags": GameState.flags,
		},
		"inventory": InventoryManager.to_dict(),
	}

	var file := FileAccess.open(_path(slot), FileAccess.WRITE)
	if file == null:
		push_error("Sauvegarde impossible : " + str(FileAccess.get_open_error()))
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	game_saved.emit(slot)
	return true

# --------------------------------------------------------------- lecture

func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(_path(slot))

func load_game(slot: int = 0) -> bool:
	if not has_save(slot):
		return false

	var file := FileAccess.open(_path(slot), FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Sauvegarde corrompue (slot %d)" % slot)
		return false

	var data: Dictionary = parsed
	data = _migrate(data)

	var st: Dictionary = data.get("state", {})
	GameState.current_act = int(st.get("current_act", 1))
	GameState.current_zone = String(st.get("current_zone", "act1_maison"))
	GameState.health = int(st.get("health", GameState.MAX_HEALTH))
	GameState.ammo_revolver = int(st.get("ammo_revolver", 0))
	GameState.ammo_shotgun = int(st.get("ammo_shotgun", 0))
	GameState.flashlight_battery = float(st.get("flashlight_battery", 1.0))
	GameState.flags = st.get("flags", {})

	InventoryManager.from_dict(data.get("inventory", {}))

	game_loaded.emit(slot)
	SceneLoader.go_to(GameState.current_zone, "spawn_load")
	return true

## Fait remonter une vieille sauvegarde au format courant.
## À compléter à chaque incrément de SAVE_VERSION plutôt que de casser
## les sauvegardes des playtesteurs.
func _migrate(data: Dictionary) -> Dictionary:
	var version := int(data.get("version", 0))
	if version == SAVE_VERSION:
		return data
	# Exemple : if version < 1: data["state"]["flashlight_battery"] = 1.0
	data["version"] = SAVE_VERSION
	return data

## Métadonnées pour l'écran de chargement, sans charger la partie.
func get_slot_info(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}
	var file := FileAccess.open(_path(slot), FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return {
		"saved_at": parsed.get("saved_at", "?"),
		"zone": parsed.get("state", {}).get("current_zone", "?"),
		"playtime": parsed.get("playtime_seconds", 0),
	}
```

**Pourquoi JSON plutôt que `ResourceSaver` :** un `.tres` sauvegardé peut embarquer du code et se recharge mal entre versions du jeu ; le JSON est inspectable dans un éditeur de texte pendant le développement (gain de temps considérable au debug) et trivialement versionnable.

**Ce qui n'est PAS sauvegardé, volontairement :** la position exacte du joueur, l'état des ennemis, les objets physiques en cours de chute. Le rechargement replace le joueur au point de sauvegarde et **fait réapparaître tous les ennemis** — convention Resident Evil, qui évite 90 % des bugs de sérialisation.

### `objects/save_point.gd`

```gdscript
extends Interactable
class_name SavePoint
## Magnétophone à cassette. Sauvegarde uniquement ici.

@export var zone_label: String = "Hall d'accueil"

func _ready() -> void:
	add_to_group("save_points")
	prompt_text = "Enregistrer une cassette"

func _do_interact(by: Node3D) -> void:
	GameState.current_zone = SceneLoader.current_zone_id
	if SaveSystem.save_game(0):
		AudioDirector.play_ui("tape_recorder")
		Hud.show_message("Partie enregistrée — " + zone_label)
		GameState.heal(20)     # un point de sauvegarde est aussi un répit
```

---

## 9. `puzzles/puzzle_base.gd` et les 10 énigmes

```gdscript
extends Node
class_name PuzzleBase
## Base commune : une énigme pose UN flag quand elle est résolue,
## et se réinitialise correctement si le joueur la quitte en cours.

signal solved
signal failed(reason: String)

@export var puzzle_id: String = ""
@export var flag_on_solve: String = ""
@export var reward_item: StringName = &""

var is_solved: bool = false

func _ready() -> void:
	if flag_on_solve != "" and GameState.has_flag(flag_on_solve):
		is_solved = true
		_apply_solved_state()

func solve() -> void:
	if is_solved:
		return
	is_solved = true
	if flag_on_solve != "":
		GameState.set_flag(flag_on_solve)
	if reward_item != &"":
		InventoryManager.add(reward_item)
	AudioDirector.play_ui("puzzle_solved")
	_apply_solved_state()
	solved.emit()

## À surcharger : état visuel d'une énigme déjà résolue au rechargement
## (porte ouverte, cadran en place, lumière verte…).
func _apply_solved_state() -> void:
	pass
```

### Énigme 2 — cadran d'horloge (`p02_horloge.gd`)

```gdscript
extends PuzzleBase
## Horloge comtoise. Le joueur règle deux aiguilles ; 03:45 ouvre la trappe.
## Prérequis : posséder l'aiguille en bronze.

const TARGET_HOUR := 3
const TARGET_MINUTE := 45

@onready var _hour_hand: Node3D = $HourHand
@onready var _minute_hand: Node3D = $MinuteHand

var _hour: int = 12
var _minute: int = 0

func can_use() -> bool:
	return InventoryManager.has(&"aiguille_bronze")

func adjust_hour(delta_steps: int) -> void:
	_hour = wrapi(_hour + delta_steps, 1, 13)
	_refresh()

func adjust_minute(delta_steps: int) -> void:
	_minute = wrapi(_minute + delta_steps * 5, 0, 60)
	_refresh()

func _refresh() -> void:
	# 360° / 12 h = 30° par heure ; 360° / 60 min = 6° par minute.
	_hour_hand.rotation.z = deg_to_rad(-(_hour % 12) * 30.0 - _minute * 0.5)
	_minute_hand.rotation.z = deg_to_rad(-_minute * 6.0)
	AudioDirector.play_ui("clock_tick")
	_check()

func _check() -> void:
	if _hour == TARGET_HOUR and _minute == TARGET_MINUTE:
		solve()

func _apply_solved_state() -> void:
	_hour = TARGET_HOUR
	_minute = TARGET_MINUTE
	get_node("../TrapDoor").open()
```

### Énigme 3 — cadenas à rouleaux (`p03_cadenas.gd`)

```gdscript
extends PuzzleBase
## Cadenas à 4 rouleaux alphabétiques. Solution : VOID.

const SOLUTION := ["V", "O", "I", "D"]
const ALPHABET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var _dials: Array[int] = [0, 0, 0, 0]

@onready var _labels: Array[Label3D] = [
	$Dial0/Label, $Dial1/Label, $Dial2/Label, $Dial3/Label
]

func cycle_dial(index: int, direction: int) -> void:
	if is_solved:
		return
	_dials[index] = wrapi(_dials[index] + direction, 0, ALPHABET.length())
	_labels[index].text = ALPHABET[_dials[index]]
	AudioDirector.play_ui("dial_click")
	_check()

func _check() -> void:
	for i in 4:
		if ALPHABET[_dials[i]] != SOLUTION[i]:
			return
	solve()

func _apply_solved_state() -> void:
	for i in 4:
		_dials[i] = ALPHABET.find(SOLUTION[i])
		_labels[i].text = SOLUTION[i]
	$Shackle.visible = false
```

### Énigme 5 — centrifugeuse, mini-jeu de jauges (`p05_centrifugeuse.gd`)

```gdscript
extends PuzzleBase
## Trois jauges à maintenir simultanément dans leur zone verte pendant 4 s.
## Chaque jauge dérive à une vitesse différente ; le joueur ne peut en
## corriger qu'une à la fois. Tension par la division de l'attention.

const HOLD_REQUIRED := 4.0
const SAFE_MIN := 0.42
const SAFE_MAX := 0.58

@export var drift_rates: Array[float] = [0.055, -0.08, 0.11]
@export var correction_strength: float = 0.55

var _values: Array[float] = [0.5, 0.5, 0.5]
var _hold_timer: float = 0.0
var _active: bool = false

@onready var _bars: Array[ProgressBar] = [$UI/Bar0, $UI/Bar1, $UI/Bar2]

func start() -> void:
	_values = [0.5, 0.5, 0.5]
	_hold_timer = 0.0
	_active = true

func _process(delta: float) -> void:
	if not _active or is_solved:
		return

	var all_safe := true
	for i in 3:
		_values[i] = clampf(_values[i] + drift_rates[i] * delta, 0.0, 1.0)
		_bars[i].value = _values[i] * 100.0
		if _values[i] < SAFE_MIN or _values[i] > SAFE_MAX:
			all_safe = false
		# Retour visuel immédiat : rouge hors zone.
		_bars[i].modulate = Color.WHITE if (_values[i] >= SAFE_MIN and _values[i] <= SAFE_MAX) else Color(1, 0.3, 0.3)

	if all_safe:
		_hold_timer += delta
		if _hold_timer >= HOLD_REQUIRED:
			_active = false
			solve()
	else:
		_hold_timer = maxf(_hold_timer - delta * 2.0, 0.0)

## Appelé par les trois boutons de l'UI (touches 1/2/3 ou clic).
func correct(index: int, delta: float) -> void:
	if not _active:
		return
	_values[index] = clampf(_values[index] - drift_rates[index] * correction_strength * 8.0 * delta, 0.0, 1.0)
```

### Énigme 6 — accord de fréquence radio (`p06_radio.gd`)

```gdscript
extends PuzzleBase
## Deux sinusoïdes affichées sur un oscilloscope : la porteuse cible
## (fixe) et celle du joueur. Il faut faire coïncider fréquence ET phase.

const TARGET_FREQUENCY := 88.6
const TARGET_PHASE := 1.2
const TOLERANCE_FREQ := 0.15
const TOLERANCE_PHASE := 0.25

var frequency: float = 92.0
var phase: float = 0.0

@onready var _scope: Line2D = $UI/Scope/PlayerWave
@onready var _target_scope: Line2D = $UI/Scope/TargetWave
@onready var _static_player: AudioStreamPlayer = $Static

func _process(_delta: float) -> void:
	if is_solved:
		return
	_draw_wave()
	_update_static()
	_check()

func tune_frequency(amount: float) -> void:
	frequency = clampf(frequency + amount, 80.0, 108.0)

func tune_phase(amount: float) -> void:
	phase = wrapf(phase + amount, 0.0, TAU)

func _draw_wave() -> void:
	var points := PackedVector2Array()
	for x in range(0, 320, 2):
		var t := x / 320.0
		# La fréquence radio est remappée sur une fréquence visuelle lisible.
		var visual_freq := remap(frequency, 80.0, 108.0, 2.0, 14.0)
		var y := sin(t * TAU * visual_freq + phase) * 40.0
		points.append(Vector2(x, y))
	_scope.points = points

func _update_static() -> void:
	# Plus on est loin de la cible, plus le grésillement est fort.
	var error := absf(frequency - TARGET_FREQUENCY) / 28.0
	_static_player.volume_db = linear_to_db(clampf(error * 2.0, 0.02, 1.0))

func _check() -> void:
	var freq_ok := absf(frequency - TARGET_FREQUENCY) <= TOLERANCE_FREQ
	var phase_ok := absf(angle_difference(phase, TARGET_PHASE)) <= TOLERANCE_PHASE
	if freq_ok and phase_ok:
		solve()
```

### Énigme 7 — circuit électrique et lampe UV (`p07_fusible.gd`)

```gdscript
extends PuzzleBase
## Deux temps : (1) la lampe UV révèle le code de la caisse à outils,
## (2) le fusible remis en place rétablit le courant.

@export var toolbox_code: String = "417"

@onready var _fuse_slot: Interactable = $FuseSlot
@onready var _lights: Array[Node] = get_tree().get_nodes_in_group("wing_lights")

func try_code(input: String) -> bool:
	if input == toolbox_code:
		InventoryManager.add(&"fusible")
		AudioDirector.play_ui("latch_open")
		return true
	AudioDirector.play_ui("latch_fail")
	return false

func insert_fuse() -> void:
	if not InventoryManager.has(&"fusible"):
		Hud.show_message("Le logement est vide. Il manque un fusible.")
		return
	InventoryManager.remove(&"fusible")
	_restore_power()
	solve()

func _restore_power() -> void:
	GameState.set_flag("recherche_power_on")
	AudioDirector.play_positional("power_surge", global_position)
	# Rallumage progressif, néon par néon : moment de respiration.
	for i in _lights.size():
		var light := _lights[i] as Light3D
		var tween := create_tween()
		tween.tween_interval(i * 0.22)
		tween.tween_property(light, "light_energy", 1.0, 0.1).from(0.0)
		tween.tween_property(light, "light_energy", 0.15, 0.06)
		tween.tween_property(light, "light_energy", 1.0, 0.2)
```

**La lampe UV** est un `SpotLight3D` avec `light_color = Color(0.45, 0.25, 1.0)` et un **`light_projector`** (masque de texture). Les inscriptions cachées sont des `MeshInstance3D` plats, invisibles par défaut, dont le matériau n'a d'émission que dans le bleu-violet : voir `05-direction-artistique.md` §5.

### Énigme 8 — alignement sur le reflet (`p08_miroir.gd`)

```gdscript
extends PuzzleBase
## Le joueur déplace un objet réel jusqu'à ce qu'il coïncide avec la
## position que montre son reflet. Quand les deux coïncident, le couloir
## se déplie.

const POSITION_TOLERANCE := 0.35
const ANGLE_TOLERANCE := 15.0

@onready var _real_object: Node3D = $RealObject
@onready var _reflection_target: Node3D = $ReflectionTarget  ## Marqueur invisible
@onready var _loop_corridor: Node3D = $"../LoopCorridor"

func _process(_delta: float) -> void:
	if is_solved:
		return
	if _is_aligned():
		solve()

func _is_aligned() -> bool:
	var distance := _real_object.global_position.distance_to(_reflection_target.global_position)
	if distance > POSITION_TOLERANCE:
		return false
	var angle := rad_to_deg(_real_object.global_basis.get_rotation_quaternion() \
		.angle_to(_reflection_target.global_basis.get_rotation_quaternion()))
	return angle <= ANGLE_TOLERANCE

func _apply_solved_state() -> void:
	_loop_corridor.set_looping(false)
	GameState.set_flag("ouest_couloir_deplie")
```

> **Réalisation du reflet sans miroir temps réel :** un vrai miroir plan coûte cher et Godot n'a pas de réflexion planaire native en Forward+. On triche : la « surface réfléchissante » est un mur portant une **copie miroir de la salle** derrière une vitre, avec le décor dupliqué et inversé sur l'axe. C'est la technique de Portal et de Superliminal. Le `ReflectionTarget` est simplement le jumeau symétrique de l'objet.

### Énigme 9 — séquence mélodique au piano (`p09_piano.gd`)

```gdscript
extends PuzzleBase
## Rejouer sur le piano la mélodie de la boîte à musique.
## Prérequis : avoir entendu la boîte (flag), sinon le joueur joue à l'aveugle.

const MELODY: Array[int] = [4, 2, 7, 7, 5, 0]   ## Index des touches
const INPUT_TIMEOUT := 3.0

var _input: Array[int] = []
var _timer: float = 0.0

@onready var _keys: Array[Node] = $Keys.get_children()

func _process(delta: float) -> void:
	if _input.is_empty() or is_solved:
		return
	_timer += delta
	if _timer > INPUT_TIMEOUT:
		_input.clear()   # Réinitialisation silencieuse : pas de punition sonore

func press_key(index: int) -> void:
	if is_solved:
		return
	_timer = 0.0
	AudioDirector.play_note(index)
	_animate_key(index)
	_input.append(index)

	# Comparaison au fur et à mesure : une erreur repart de zéro.
	var position := _input.size() - 1
	if _input[position] != MELODY[position]:
		_input.clear()
		return

	if _input.size() == MELODY.size():
		await get_tree().create_timer(0.6).timeout
		solve()

func _animate_key(index: int) -> void:
	var key := _keys[index] as Node3D
	var tween := create_tween()
	tween.tween_property(key, "rotation:x", deg_to_rad(-4), 0.05)
	tween.tween_property(key, "rotation:x", 0.0, 0.12)

func _apply_solved_state() -> void:
	$"../Safe".open()
```

### Énigme 10 — séquence finale chronométrée (`p10_badges.gd`)

```gdscript
extends PuzzleBase
## Insérer les 3 badges dans le bon ordre (ROUGE -> BLEU -> VERT),
## puis saisir le code à 3 chiffres gravé sous les badges,
## le tout en 180 secondes.

const CORRECT_ORDER: Array[StringName] = [&"badge_rouge", &"badge_bleu", &"badge_vert"]
const COUNTDOWN := 180.0

signal countdown_started
signal countdown_tick(remaining: float)
signal sequence_failed

var _inserted: Array[StringName] = []
var _remaining: float = COUNTDOWN
var _running: bool = false

func start_sequence() -> void:
	if _running:
		return
	_running = true
	_remaining = COUNTDOWN
	GameState.set_flag("final_alarm_active")
	AudioDirector.start_alarm()
	countdown_started.emit()

func _process(delta: float) -> void:
	if not _running or is_solved:
		return
	_remaining -= delta
	countdown_tick.emit(_remaining)
	if _remaining <= 0.0:
		_running = false
		_on_timeout()

func insert_badge(badge_id: StringName) -> void:
	if not _running or not InventoryManager.has(badge_id):
		return
	if _inserted.has(badge_id):
		return

	var expected := CORRECT_ORDER[_inserted.size()]
	if badge_id != expected:
		# Mauvais ordre : on repart de zéro et on perd 15 secondes.
		_inserted.clear()
		_remaining = maxf(_remaining - 15.0, 1.0)
		AudioDirector.play_ui("access_denied")
		sequence_failed.emit()
		return

	_inserted.append(badge_id)
	AudioDirector.play_ui("badge_accepted")

	if _inserted.size() == CORRECT_ORDER.size():
		$Keypad.enable()

func submit_code(code: String) -> void:
	# Le code est composé des chiffres gravés sous chaque badge,
	# découverts via l'inspecteur 3D (§7), dans l'ordre d'insertion.
	if code == _expected_code():
		_running = false
		AudioDirector.stop_alarm()
		solve()
	else:
		_remaining = maxf(_remaining - 10.0, 1.0)
		AudioDirector.play_ui("access_denied")

func _expected_code() -> String:
	return "%d%d%d" % [7, 1, 4]   ## À aligner sur les Label3D des modèles

func _on_timeout() -> void:
	GameState.damage(GameState.MAX_HEALTH)   ## Game over : le site se referme
```

---

## 10. `autoload/scene_loader.gd` — zones et backtracking

```gdscript
extends Node
## Autoload : SceneLoader
## Garde les zones visitées en mémoire pour un backtracking instantané.

signal zone_changed(zone_id: String)

const ZONES := {
	"act1_maison":    "res://levels/act1_maison/maison.tscn",
	"act2_hub":       "res://levels/act2_hub/hub.tscn",
	"act2_medical":   "res://levels/act2_medical/medical.tscn",
	"act2_coms":      "res://levels/act2_coms/coms.tscn",
	"act2_recherche": "res://levels/act2_recherche/recherche.tscn",
	"act3_ouest":     "res://levels/act3_ouest/ouest.tscn",
	"act3_bureau":    "res://levels/act3_bureau/bureau.tscn",
}

var current_zone_id: String = ""

var _cache: Dictionary = {}          ## { zone_id: Node }
var _active: Node = null
@onready var _container: Node = get_tree().current_scene.get_node("WorldContainer")
@onready var _fade: ColorRect = get_tree().current_scene.get_node("Fade/ColorRect")

func go_to(zone_id: String, spawn_name: String = "spawn_default") -> void:
	if not ZONES.has(zone_id):
		push_error("Zone inconnue : " + zone_id)
		return

	await _fade_out()

	# On retire la zone courante SANS la libérer : son état reste intact.
	if _active:
		_container.remove_child(_active)

	if not _cache.has(zone_id):
		_cache[zone_id] = load(ZONES[zone_id]).instantiate()

	_active = _cache[zone_id]
	_container.add_child(_active)
	current_zone_id = zone_id
	GameState.current_zone = zone_id

	_place_player(spawn_name)
	AudioDirector.set_ambience_for_zone(zone_id)
	zone_changed.emit(zone_id)

	await _fade_in()

func _place_player(spawn_name: String) -> void:
	var spawn := _active.find_child(spawn_name, true, false) as Node3D
	if spawn == null:
		spawn = _active.find_child("spawn_default", true, false) as Node3D
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if spawn and player:
		player.global_transform = spawn.global_transform

## Libère toutes les zones d'un acte terminé (la maison après l'Acte I).
func purge_act(act_prefix: String) -> void:
	for zone_id in _cache.keys():
		if zone_id.begins_with(act_prefix) and _cache[zone_id] != _active:
			_cache[zone_id].queue_free()
			_cache.erase(zone_id)

func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 1.0, 0.4)
	await tween.finished

func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 0.0, 0.5)
	await tween.finished
```

---

## 11. Table des identifiants d'objets

Référence unique, à respecter à l'identique dans `data/items/` et dans `06-level-design-et-enigmes.md`.

| `id` | Objet | Acte |
|---|---|---|
| `manche_balai` | Manche à balai | I |
| `crochet` | Crochet métallique | I |
| `perche` | Perche improvisée *(combinaison)* | I |
| `cle_rouillee` | Clé rouillée | I |
| `aiguille_bronze` | Aiguille en bronze | I |
| `lampe_torche` | Lampe torche de Rémi | I |
| `barre_a_mine` | Barre à mine | I |
| `scalpel` | Scalpel | II |
| `gemme_rouge` | Lentille de calibrage | II |
| `puce_acces` | Puce d'accès | II |
| `seringue` | Seringue | II |
| `serum_brut` | Échantillon contaminé | II |
| `serum_purifie` | Sérum purifié *(combinaison)* | II |
| `badge_rouge` | Badge Rouge — Sorel | II |
| `passe_morgue` | Passe-partout de la morgue | II |
| `lampe_uv` | Lampe UV | II |
| `fusible` | Fusible 20 A | II |
| `badge_vert` | Badge Vert — Reyes | II |
| `revolver` | Revolver de service | II |
| `munitions` | Balles .38 | II |
| `manivelle` | Manivelle | III |
| `boite_musique` | Boîte à musique | III |
| `badge_bleu` | Badge Bleu — Achard | III |
| `fusil_pompe` | Fusil à pompe — Poste de sécurité | III |
| `cartouches_fusil` | Cartouches de calibre 12 | III |
| `bouteille_vide` | Bouteille vide | III |
| `chiffon` | Chiffon imbibé | III |
| `bidon_alcool` | Bidon d'alcool à brûler | III |
| `molotov` | Cocktail Molotov *(combinaison)* | III |
| `pistolet_ancrage` | Pistolet d'ancrage — prototype d'Hélène | III |

> Les 7 derniers objets forment l'**arsenal du Poste de sécurité**, détaillé dans `03-combat-et-bestiaire.md` §9.
