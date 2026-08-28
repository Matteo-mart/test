# 03 — Combat, bestiaire et boss

**Principe directeur :** dans un survival horror, le combat n'est pas là pour être gagné, il est là pour être **évalué**. Chaque rencontre doit poser au joueur la question « est-ce que ça vaut le coup ? » — coût en munitions, en santé, en bruit.

---

## 1. Courbe d'armement

| Acte | Outil | Ce que ça change |
|---|---|---|
| I (0-15 min) | **Mains nues** | On ne se bat pas. On fuit ou on se cache. Le joueur apprend la peur. |
| I (15-25 min) | **Barre à mine** | Arme lourde, lente, bruyante. Un Désancré = 3 coups + 6 s d'exposition. |
| II (début) | Barre à mine + **endurance** | Frapper vide la même jauge que courir. Choix permanent. |
| II (milieu) | **Revolver .38** | 6 coups, rechargement 2,4 s, **34 balles dans tout le jeu**. |
| III (avant le Poste de sécurité) | Revolver + **fuite** | Les Désancrés profonds ne meurent pas durablement. Économie de survie. |
| III (Poste de sécurité, juste avant le Bureau du Directeur) | **Arsenal du Poste de sécurité** — fusil à pompe et Molotov (optionnels), **pistolet d'ancrage (obligatoire)** | Le pistolet est la seule condition de victoire de la phase 3 du Boss III. Voir §6 et §9. |

### Économie de munitions (placement exact)

Total : **34 balles** pour ~30 rencontres. Un joueur qui tire sur tout finit à sec avant l'Acte III — et c'est le but.

| Lieu | Quantité | Cumul |
|---|---|---|
| Aile Coms — tiroir du veilleur (avec le revolver) | 6 | 6 |
| Aile Médicale — armoire de sécurité | 5 | 11 |
| Aile Recherche — après le rétablissement du courant | 4 | 15 |
| Hub — sous le comptoir d'accueil (fouille optionnelle) | 3 | 18 |
| Morgue — casier 12 | 6 | 24 |
| Secteur Ouest — corps d'un agent | 4 | 28 |
| Bureau du Directeur — coffre | 6 | 34 |

> **Règle de placement :** aucune munition n'est jamais placée *après* un boss. Toujours *avant*, pour que le joueur arrive avec un stock qu'il a choisi de dépenser ou d'économiser.

---

## 2. `core/health_component.gd`

Le même fichier équipe le joueur, les Désancrés et les trois boss.

```gdscript
extends Node
class_name HealthComponent

signal damaged(amount: int, from: Node3D)
signal healed(amount: int)
signal died

@export var max_health: int = 100
@export var invulnerability_time: float = 0.0   ## i-frames après un coup

var current_health: int
var is_dead: bool = false

var _invuln_timer: float = 0.0

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if _invuln_timer > 0.0:
		_invuln_timer -= delta

func take_damage(amount: int, from: Node3D = null) -> bool:
	if is_dead or _invuln_timer > 0.0:
		return false
	current_health = maxi(current_health - amount, 0)
	_invuln_timer = invulnerability_time
	damaged.emit(amount, from)
	if current_health == 0:
		is_dead = true
		died.emit()
	return true

func heal(amount: int) -> void:
	if is_dead:
		return
	current_health = mini(current_health + amount, max_health)
	healed.emit(amount)

func health_ratio() -> float:
	return float(current_health) / float(max_health)
```

---

## 3. Armes

### `player/weapons/weapon_base.gd`

```gdscript
extends Node3D
class_name WeaponBase

signal attacked
signal out_of_ammo

@export var damage: int = 20
@export var cooldown: float = 0.8
@export var noise_radius: float = 10.0

var _cooldown_timer: float = 0.0

func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

func can_attack() -> bool:
	return _cooldown_timer <= 0.0

func attack(_from: Camera3D) -> void:
	_cooldown_timer = cooldown
	attacked.emit()
```

### `player/weapons/weapon_melee.gd` — la barre à mine

```gdscript
extends WeaponBase
class_name WeaponMelee
## Arme lourde. La fenêtre d'impact s'ouvre au milieu de l'animation
## (méthode d'appel dans l'AnimationPlayer), pas au moment de la touche :
## le joueur s'engage AVANT de savoir si ça passe. C'est le cœur du ressenti.

const STAMINA_COST := 26.0

@export var swing_arc_degrees: float = 70.0
@export var stagger_force: float = 1.0

@onready var _hitbox: Area3D = $HitBox
@onready var _anim: AnimationPlayer = $AnimationPlayer
@onready var _audio: AudioStreamPlayer3D = $Audio

var _already_hit: Array[Node] = []

func _ready() -> void:
	_hitbox.monitoring = false
	damage = 34
	cooldown = 1.1
	noise_radius = 9.0

func attack(_from: Camera3D) -> void:
	var player := owner as Player
	if not can_attack() or player.stamina < STAMINA_COST:
		return
	super.attack(_from)
	player.stamina -= STAMINA_COST
	_already_hit.clear()
	_anim.play("swing")

## Appelée par une piste d'appel de méthode dans l'animation "swing",
## à la frame 8 (ouverture) et 14 (fermeture).
func _open_hitbox() -> void:
	_hitbox.monitoring = true
	_audio.stream = preload("res://audio/sfx/crowbar_swing.ogg")
	_audio.play()
	AudioDirector.emit_noise(global_position, noise_radius)

func _close_hitbox() -> void:
	_hitbox.monitoring = false

func _on_hit_box_body_entered(body: Node3D) -> void:
	# Une seule touche par cible et par coup, sinon un swing tue tout.
	if _already_hit.has(body):
		return
	_already_hit.append(body)

	var health := body.get_node_or_null("HealthComponent") as HealthComponent
	if health and health.take_damage(damage, owner):
		AudioDirector.play_positional("impact_flesh", body.global_position)
		if body.has_method("stagger"):
			body.stagger(stagger_force)
```

### `player/weapons/weapon_ranged.gd` — le revolver

```gdscript
extends WeaponBase
class_name WeaponRanged
## Revolver .38. Viser immobilise : tirer coûte de la mobilité,
## pas seulement des balles.

const CYLINDER_SIZE := 6

@export var reload_time: float = 2.4
@export var spread_hip_degrees: float = 5.5
@export var spread_aim_degrees: float = 0.6
@export var range_meters: float = 40.0

var rounds_in_cylinder: int = 0
var is_reloading: bool = false
var is_aiming: bool = false

@onready var _muzzle_flash: OmniLight3D = $MuzzleFlash
@onready var _audio: AudioStreamPlayer3D = $Audio
@onready var _anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	damage = 55
	cooldown = 0.55
	noise_radius = 34.0        ## Un coup de feu s'entend dans toute l'aile
	_muzzle_flash.visible = false

func attack(from: Camera3D) -> void:
	if not can_attack() or is_reloading:
		return
	if rounds_in_cylinder <= 0:
		_audio.stream = preload("res://audio/sfx/dry_fire.ogg")
		_audio.play()
		out_of_ammo.emit()
		return

	super.attack(from)
	rounds_in_cylinder -= 1
	_fire_ray(from)
	_flash()
	AudioDirector.emit_noise(global_position, noise_radius)

func _fire_ray(from: Camera3D) -> void:
	var spread := deg_to_rad(spread_aim_degrees if is_aiming else spread_hip_degrees)
	var direction := -from.global_transform.basis.z
	direction = direction.rotated(Vector3.UP, randf_range(-spread, spread))
	direction = direction.rotated(from.global_transform.basis.x, randf_range(-spread, spread))

	var space := from.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		from.global_position,
		from.global_position + direction * range_meters
	)
	# Couches 1 (monde) + 3 (ennemis) : 0b101 = 5
	query.collision_mask = 5
	query.exclude = [owner.get_rid()]

	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return

	var body: Node3D = hit["collider"]
	var health := body.get_node_or_null("HealthComponent") as HealthComponent

	if health:
		# Tir à la tête : dégâts doublés. Récompense la visée, donc l'immobilité.
		var is_head := hit["position"].y > body.global_position.y + 1.4
		health.take_damage(damage * (2 if is_head else 1), owner)
		AudioDirector.play_positional("impact_flesh", hit["position"])
	else:
		AudioDirector.play_positional("impact_concrete", hit["position"])
		_spawn_decal(hit["position"], hit["normal"])

func reload() -> void:
	if is_reloading or rounds_in_cylinder == CYLINDER_SIZE or GameState.ammo_revolver <= 0:
		return
	is_reloading = true
	_anim.play("reload")
	await get_tree().create_timer(reload_time).timeout

	var needed := CYLINDER_SIZE - rounds_in_cylinder
	var taken := mini(needed, GameState.ammo_revolver)
	rounds_in_cylinder += taken
	GameState.ammo_revolver -= taken
	is_reloading = false

func _flash() -> void:
	_muzzle_flash.visible = true
	_audio.stream = preload("res://audio/sfx/revolver_shot.ogg")
	_audio.play()
	await get_tree().create_timer(0.05).timeout
	_muzzle_flash.visible = false

func _spawn_decal(pos: Vector3, normal: Vector3) -> void:
	var decal := preload("res://art/decals/bullet_hole.tscn").instantiate() as Node3D
	get_tree().current_scene.add_child(decal)
	decal.global_position = pos + normal * 0.01
	decal.look_at(pos + normal, Vector3.UP)
```

---

## 4. `enemies/enemy_base.gd` — le Désancré

### Machine à états

**Concept clé : la machine à états finis.** Un ennemi est à tout instant dans **exactement un** état, et chaque état ne connaît que ses transitions sortantes. Cela évite le bloc `if/elif` de 200 lignes qui rend toute IA indébogable au bout d'un mois.

```
IDLE ──entend un bruit──> SUSPICIOUS ──voit le joueur──> CHASE
  ^                            │                           │
  │                     (délai écoulé)               (à portée)
  └────────────────────────────┘                           v
                                                        ATTACK
  STAGGER <──coup reçu── (tous états)                      │
     │                                                (cooldown)
     └──> CHASE                                             │
                                                    <───────┘
  DEAD <── PV = 0
```

```gdscript
extends CharacterBody3D
class_name Enemy
## Désancré : ne voit pas le joueur, l'ENTEND. Sa vision est un cône
## très étroit et courte portée, l'ouïe est son sens principal.

enum State { IDLE, SUSPICIOUS, CHASE, ATTACK, STAGGER, DEAD }

@export var profile: EnemyProfile

@onready var _agent: NavigationAgent3D = $NavigationAgent3D
@onready var _health: HealthComponent = $HealthComponent
@onready var _anim: AnimationPlayer = $Model/AnimationPlayer
@onready var _vision_ray: RayCast3D = $VisionRay
@onready var _audio: AudioStreamPlayer3D = $Audio

var state: State = State.IDLE
var target: Node3D = null
var _last_noise_position: Vector3
var _state_timer: float = 0.0
var _attack_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	_health.max_health = profile.max_health
	_health.current_health = profile.max_health
	_health.died.connect(_on_died)
	_health.damaged.connect(_on_damaged)
	_agent.path_desired_distance = 0.6
	_agent.target_desired_distance = profile.attack_range * 0.85

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	_state_timer += delta
	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)

	match state:
		State.IDLE:        _process_idle(delta)
		State.SUSPICIOUS:  _process_suspicious(delta)
		State.CHASE:       _process_chase(delta)
		State.ATTACK:      _process_attack(delta)
		State.STAGGER:     _process_stagger(delta)

	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

# ------------------------------------------------------------------- états

func _process_idle(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 6.0 * _delta)
	velocity.z = move_toward(velocity.z, 0.0, 6.0 * _delta)
	if _can_see_player():
		_set_state(State.CHASE)

func _process_suspicious(delta: float) -> void:
	# Se dirige vers le dernier bruit entendu, lentement.
	_move_towards(_last_noise_position, profile.speed_walk * 0.6, delta)
	if _can_see_player():
		_set_state(State.CHASE)
	elif _state_timer > profile.investigate_duration:
		_set_state(State.IDLE)

func _process_chase(delta: float) -> void:
	if target == null:
		_set_state(State.SUSPICIOUS)
		return
	_move_towards(target.global_position, profile.speed_chase, delta)

	if global_position.distance_to(target.global_position) <= profile.attack_range:
		_set_state(State.ATTACK)
	elif _state_timer > profile.give_up_duration and not _can_see_player():
		_last_noise_position = target.global_position
		target = null
		_set_state(State.SUSPICIOUS)

func _process_attack(_delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	if _attack_cooldown > 0.0:
		return
	if target and global_position.distance_to(target.global_position) <= profile.attack_range * 1.2:
		_perform_attack()
	else:
		_set_state(State.CHASE)

func _process_stagger(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * _delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * _delta)
	if _state_timer > profile.stagger_duration:
		_set_state(State.CHASE if target else State.SUSPICIOUS)

func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	_state_timer = 0.0
	match new_state:
		State.IDLE:       _anim.play("idle")
		State.SUSPICIOUS: _anim.play("walk_slow"); _growl()
		State.CHASE:      _anim.play("walk"); _growl()
		State.ATTACK:     _anim.play("attack")
		State.STAGGER:    _anim.play("stagger")
		State.DEAD:       _anim.play("death")

# ------------------------------------------------------------- déplacement

func _move_towards(destination: Vector3, speed: float, delta: float) -> void:
	_agent.target_position = destination
	if _agent.is_navigation_finished():
		return
	var next := _agent.get_next_path_position()
	var direction := (next - global_position).normalized()
	velocity.x = move_toward(velocity.x, direction.x * speed, 8.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, 8.0 * delta)

	# Rotation lente : la lourdeur du mouvement fait la menace.
	var target_yaw := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, profile.turn_speed * delta)

# ---------------------------------------------------------------- percepts

## L'OUÏE. Appelé par AudioDirector pour tous les nœuds du groupe "enemies".
func on_noise(position: Vector3, radius: float) -> void:
	if state == State.DEAD or state == State.CHASE:
		return
	var distance := global_position.distance_to(position)
	if distance > radius * profile.hearing_multiplier:
		return
	_last_noise_position = position
	if state != State.SUSPICIOUS:
		_set_state(State.SUSPICIOUS)

## LA VUE. Volontairement faible : cône étroit, portée courte,
## et le joueur accroupi dans le noir est simplement invisible.
func _can_see_player() -> bool:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return false

	var to_player := player.global_position - global_position
	if to_player.length() > profile.sight_range:
		return false

	var forward := -global_transform.basis.z
	var angle := rad_to_deg(forward.angle_to(to_player.normalized()))
	if angle > profile.sight_cone_degrees * 0.5:
		return false

	# Accroupi + hors du faisceau de lampe = indétectable.
	if player.is_crouching and not _is_player_lit(player):
		return false

	_vision_ray.target_position = _vision_ray.to_local(player.global_position + Vector3.UP)
	_vision_ray.force_raycast_update()
	if _vision_ray.is_colliding() and _vision_ray.get_collider() == player:
		target = player
		return true
	return false

func _is_player_lit(player: Player) -> bool:
	var lamp := player.get_node_or_null("Head/Flashlight") as SpotLight3D
	return lamp != null and lamp.visible

# ------------------------------------------------------------------ combat

func _perform_attack() -> void:
	_attack_cooldown = profile.attack_cooldown
	_anim.play("attack")
	await get_tree().create_timer(profile.attack_windup).timeout
	if state == State.DEAD or target == null:
		return
	if global_position.distance_to(target.global_position) <= profile.attack_range * 1.3:
		GameState.damage(profile.damage)
		AudioDirector.play_positional("player_hurt", global_position)

func stagger(force: float) -> void:
	if state == State.DEAD or force < profile.stagger_resistance:
		return
	_set_state(State.STAGGER)

func _on_damaged(_amount: int, from: Node3D) -> void:
	target = from
	AudioDirector.play_positional("enemy_hurt", global_position)

func _on_died() -> void:
	_set_state(State.DEAD)
	# On coupe la physique et la détection, on laisse le corps au sol.
	set_physics_process(false)
	$CollisionShape3D.set_deferred("disabled", true)
	$HurtBox.set_deferred("monitoring", false)
	remove_from_group("enemies")

func _growl() -> void:
	if randf() < 0.35:
		_audio.stream = profile.growl_sounds.pick_random()
		_audio.play()
```

### `data/enemies/enemy_profile.gd`

```gdscript
extends Resource
class_name EnemyProfile

@export var display_name: String = "Désancré"
@export var max_health: int = 60
@export var damage: int = 12

@export_group("Déplacement")
@export var speed_walk: float = 1.0
@export var speed_chase: float = 1.9
@export var turn_speed: float = 3.0

@export_group("Perception")
@export var sight_range: float = 9.0
@export var sight_cone_degrees: float = 70.0
@export var hearing_multiplier: float = 1.0
@export var investigate_duration: float = 8.0
@export var give_up_duration: float = 6.0

@export_group("Combat")
@export var attack_range: float = 1.5
@export var attack_windup: float = 0.45
@export var attack_cooldown: float = 1.8
@export var stagger_duration: float = 0.9
@export var stagger_resistance: float = 0.5

@export_group("Audio")
@export var growl_sounds: Array[AudioStream] = []
```

### Les trois variantes (mêmes modèles, ressources différentes)

| Profil | PV | Vitesse poursuite | Dégâts | Ouïe | Particularité |
|---|---|---|---|---|---|
| `desancre_tardif.tres` | 60 | 1,9 | 12 | ×0,8 | L'ennemi de base. Enseigne les règles. |
| `desancre_terrain.tres` | 95 | 2,8 | 22 | ×1,2 | Ancien agent de sécurité. Résiste au stagger (0,9). |
| `desancre_profond.tres` | 70 | 3,4 | 18 | ×1,6 | Acte III. Voir ci-dessous. |

**Le Désancré profond** surcharge une seule méthode :

```gdscript
extends Enemy
class_name DeepUnanchored
## Ne se déplace QUE lorsqu'il n'est pas dans le champ de vision du joueur.
## Justification narrative : sans observateur, son ancrage se relâche.

@onready var _visibility: VisibleOnScreenNotifier3D = $VisibleOnScreenNotifier3D

func _physics_process(delta: float) -> void:
	if _visibility.is_on_screen() and state == State.CHASE:
		velocity = Vector3.ZERO
		move_and_slide()
		return
	super._physics_process(delta)
```

---

## 5. `autoload/audio_director.gd` — le bruit comme mécanique

C'est le système le plus important du jeu pour la tension : il relie le son entendu par le joueur au son entendu par les ennemis.

```gdscript
extends Node
## Autoload : AudioDirector

const NOISE_DEBUG := false   ## Passe à true pour visualiser les rayons de bruit

## Diffuse un bruit à tous les ennemis. Appelé par les pas, les portes,
## les armes, les objets qui tombent.
func emit_noise(origin: Vector3, radius: float) -> void:
	get_tree().call_group("enemies", "on_noise", origin, radius)
	if NOISE_DEBUG:
		print("BRUIT r=%.1f @ %s" % [radius, origin])

func play_positional(sound_name: String, position: Vector3) -> void:
	var player := AudioStreamPlayer3D.new()
	player.stream = load("res://audio/sfx/%s.ogg" % sound_name)
	player.bus = "SFX"
	player.unit_size = 6.0
	player.max_distance = 40.0
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	get_tree().current_scene.add_child(player)
	player.global_position = position
	player.play()
	player.finished.connect(player.queue_free)
```

**Rayons de bruit de référence** (à garder cohérents dans tout le projet) :

| Action | Rayon |
|---|---|
| Marche accroupie | 2 m |
| Marche normale | 7 m |
| Course | 16 m |
| Porte ouverte | 12 m |
| Coup de barre à mine | 9 m |
| Objet lancé (impact) | 14 m |
| Coup de feu | 34 m |
| Vitre brisée | 25 m |

---

## 6. Les trois boss

### Règle commune

Aucun des trois ne meurt par accumulation de dégâts. Chacun est une **énigme sous pression**. Concrètement, cela veut dire : pas de longue animation de combat à trouver, pas d'équilibrage de DPS, et un boss qui reste mémorable même avec des assets gratuits.

---

### Boss I — **LE GARDIEN** (fin de l'Acte I, cave à charbon)

- **PV :** invulnérable.
- **Perception :** aveugle. Ouïe ×3,0. `sight_range = 0`.
- **Salle :** cave circulaire, plateforme de monte-charge au centre, treuil sur le mur nord.

**Boucle :** le joueur possède 4 objets lançables (bouteilles). Chaque jet attire le Gardien pendant ~6 s. Il faut trois actions au treuil de 3 s chacune, sans être touché. Le Gardien tue en un coup.

```gdscript
extends Enemy
class_name BossGardien

@export var winch_stages_needed: int = 3

var _winch_progress: int = 0

func _ready() -> void:
	super._ready()
	_health.max_health = 99999            ## Invulnérable
	profile.sight_range = 0.0             ## Aveugle
	profile.hearing_multiplier = 3.0
	profile.damage = 100                  ## Un coup = mort

func on_winch_stage_completed() -> void:
	_winch_progress += 1
	# Il devient plus rapide à chaque étape : la tension monte sans
	# ajouter la moindre mécanique.
	profile.speed_chase += 0.45
	if _winch_progress >= winch_stages_needed:
		_crush()

func _crush() -> void:
	# La plateforme s'écrase. Fin scriptée, aucune animation de mort à produire.
	get_parent().get_node("Platform").drop()
	_set_state(State.DEAD)
	GameState.set_flag("boss1_gardien_dead")
```

---

### Boss II — **LA MATRONE** (Aile Médicale, sas de décontamination)

- **Quoi :** sept corps fusionnés. Immense, très lente (0,9 m/s), traverse le mobilier.
- **Ce qui la rend terrifiante :** elle ne s'arrête jamais, ne perd jamais la trace du joueur, et parle avec sept voix décalées de quelques dizaines de millisecondes (un même fichier vocal joué 7 fois avec des `pitch_scale` et délais légèrement différents — effet saisissant, coût nul).

**Résolution en trois temps :**

1. Activer trois **appâts sonores** (haut-parleurs de service) dans trois salles distinctes de l'aile, pour l'attirer vers le sas.
2. Elle entre dans le sas (`Area3D` de détection).
3. Le joueur atteint la console extérieure et lance le cycle de décontamination.

**Contrainte de tension :** un appât ne dure que 25 s. Le joueur doit donc parcourir un circuit qu'il connaît déjà (l'aile visitée à l'Énigme 5) avec une masse lente qui coupe les couloirs. **Le backtracking devient une ressource de game design**, pas une corvée.

```gdscript
extends Enemy
class_name BossMatrone

signal lure_activated(index: int)
signal entered_airlock

const LURE_DURATION := 25.0

var _lures_used: int = 0

func activate_lure(lure_position: Vector3, index: int) -> void:
	_last_noise_position = lure_position
	_set_state(State.SUSPICIOUS)
	_lures_used += 1
	lure_activated.emit(index)
	# Sourde à tout le reste pendant qu'un appât est actif.
	profile.hearing_multiplier = 0.0
	await get_tree().create_timer(LURE_DURATION).timeout
	profile.hearing_multiplier = 1.4

func _on_airlock_body_entered(body: Node3D) -> void:
	if body == self:
		entered_airlock.emit()
		GameState.set_flag("matrone_in_airlock")
```

---

### Boss III — **L'ANCRE / Paul Achard** (Bureau du Directeur)

- **Quoi :** il apparaît là où il croit être. Son corps « réel » n'est visible que dans les miroirs — **au début.**
- **Phases 1 et 2 — voie standard, deux miroirs :** le joueur doit tirer sur le **reflet** d'Achard, pas sur Achard. Chaque reflet touché brise un miroir ; à chaque miroir brisé, la salle se replie (mobilier déplacé, sol incliné, éclairage changé). Coût : 2 tirs de revolver minimum, ou la barre à mine au contact (plus dangereux, mais toujours possible — **aucun soft-lock sur ces deux phases**).
- **Continuité pédagogique :** c'est exactement la logique de l'Énigme 8 que le joueur vient de résoudre, transposée sous pression. **Aucun tutoriel nécessaire.**
- **Phase 3 — obligatoire, le pistolet d'ancrage :** après deux ancrages perdus, Achard cesse de se refléter. Le troisième miroir de la salle reste noir, intact, inutile — un joueur qui continue à tirer dessus perd son temps, et le jeu le lui dit (« Il n'est plus là-dedans. »). **Seul le pistolet d'ancrage** (`03` §9, trouvé au Poste de sécurité) peut forcer sa resynchronisation : le tir déclenche un **flottement** de 2,5 s pendant lequel Achard est pleinement vulnérable, où qu'il se trouve dans la pièce. N'importe quelle arme achève alors la phase (revolver, barre à mine, ou le fusil à pompe s'il a été trouvé) — mais **rien ne remplace le pistolet pour ouvrir la fenêtre**. C'est délibéré : le seul outil capable de vaincre Achard est celui qu'Hélène a construit contre lui. Le joueur doit littéralement se servir de l'héritage de sa mère pour finir le combat.
- **Sécurité anti-blocage :** la porte du Bureau du Directeur ne se verrouille jamais pendant le combat. Un joueur qui atteint la phase 3 sans le pistolet (coffre du Poste non ouvert, ou code 345 non retrouvé) peut sortir, revenir au Poste **sans limite de temps**, retenter le code, et revenir affronter Achard — les deux miroirs déjà brisés restent brisés. Ce n'est jamais un game over silencieux ; c'est un aller-retour, comme n'importe quel objet-clé manqué du reste du jeu.

```gdscript
extends Node3D
class_name BossAnchor
## Combat en 3 temps. Les 2 premiers miroirs se brisent au revolver ou à
## la barre à mine (voie standard, héritée de l'Énigme 8). Après le 2e,
## Achard cesse de se refléter : le 3e miroir reste noir et inerte, et
## SEUL le pistolet d'ancrage peut encore le forcer à se resynchroniser.
## Cette 3e phase n'a pas de solution de repli : c'est voulu (voir 03 §6).

signal phase_changed(phase: int)
signal flicker_started
signal flicker_ended
signal defeated

const MIRROR_PHASES := 2   ## Miroirs qui font réellement progresser le combat

@export var mirrors: Array[NodePath] = []   ## Exactement 2 entrées
@export var dead_mirror: NodePath           ## Le 3e miroir : décor, jamais brisable
@export var flicker_duration: float = 2.5

@onready var _hurtbox: Area3D = $Hurtbox   ## Actif UNIQUEMENT pendant le flottement

var _phase: int = 0
var _is_flickering: bool = false

func _ready() -> void:
	for path in mirrors:
		var mirror := get_node(path)
		mirror.shattered.connect(_on_mirror_shattered)
	_hurtbox.monitoring = false

func _on_mirror_shattered() -> void:
	if _phase >= MIRROR_PHASES:
		return   # le 3e miroir ne compte plus : voir dead_mirror
	_phase += 1
	phase_changed.emit(_phase)
	AudioDirector.play_positional("glass_shatter", global_position)
	_fold_room(_phase)
	if _phase == MIRROR_PHASES:
		AudioDirector.play_positional("achard_no_reflection", global_position)

## Appelé par WeaponAnchorPistol.attack() quand le tir touche Achard
## directement. SANS EFFET tant que les 2 miroirs ne sont pas brisés :
## avant cela, Achard se protège encore derrière ses reflets.
func trigger_flicker() -> void:
	if _phase < MIRROR_PHASES or _is_flickering:
		return
	_is_flickering = true
	_hurtbox.monitoring = true
	AudioDirector.play_positional("anchor_pulse", global_position)
	flicker_started.emit()
	await get_tree().create_timer(flicker_duration).timeout
	if _is_flickering:   # pas déjà refermé par un coup reçu
		_end_flicker()

## Touché sur le Hurtbox pendant le flottement : n'importe quelle arme
## (revolver, barre à mine, fusil à pompe) termine le combat ici.
func _on_hurtbox_area_entered(_hitbox: Area3D) -> void:
	if not _is_flickering:
		return
	_end_flicker()
	_defeat()

func _end_flicker() -> void:
	_is_flickering = false
	_hurtbox.monitoring = false
	flicker_ended.emit()

## Chaque pli est un simple échange de sous-scènes pré-construites :
## RoomVariant0 / 1 / 2. Zéro animation procédurale, zéro compétence 3D.
func _fold_room(phase: int) -> void:
	for i in 3:
		var variant := get_node_or_null("RoomVariant%d" % i)
		if variant:
			variant.visible = (i == phase)
			variant.process_mode = Node.PROCESS_MODE_INHERIT if i == phase \
				else Node.PROCESS_MODE_DISABLED

## Le Badge Bleu est déjà dans l'inventaire depuis l'ouverture du coffre
## (Énigme 9, p09_piano.gd) : ici on ne fait que clore le combat.
func _defeat() -> void:
	GameState.set_flag("boss3_ancre_dead")
	defeated.emit()
```

---

## 7. Table d'équilibrage

| | Acte I | Acte II | Acte III |
|---|---|---|---|
| PV max du joueur | 100 | 100 | 100 |
| Soins disponibles | 2 | 5 | 3 |
| Ennemis rencontrés | 4 | 18 | 9 |
| Munitions gagnées | 0 | 24 | 10 |
| Dégâts moyens reçus par rencontre ratée | 12 | 18 | 22 |
| Rencontres évitables sans combat | 4 / 4 | 12 / 18 | 7 / 9 |

> **Objectif chiffré :** un joueur prudent doit pouvoir terminer le jeu **en ne tirant que 8 balles de revolver** (2 pour les deux premiers miroirs du Boss III, 6 en secours) **plus le pistolet d'ancrage**, obligatoire pour la phase 3 et non substituable par des munitions. Un joueur agressif doit se retrouver à sec au milieu de l'Acte III — mais jamais sans le pistolet, sous peine de rendre le Boss III insoluble : voir la sécurité anti-blocage du §6.

---

## 8. Retour d'information au joueur (« game feel »)

Sans ces éléments, le combat paraît mou même parfaitement équilibré.

| Événement | Retour |
|---|---|
| Coup porté | Arrêt sur image de 60 ms (`Engine.time_scale = 0.05`), son sec, léger recul de caméra |
| Coup reçu | Vignette rouge 0,4 s, secousse de caméra, souffle audible, `pitch_scale` de l'ambiance abaissé 1,5 s |
| Sous 30 PV | Battement de cœur en boucle, filtre passe-bas sur le bus MASTER, respiration accélérée |
| Ennemi qui vous repère | **Aucun** son de « détection ». Le grognement suffit. Un stinger musical détruirait le naturalisme. |
| Ennemi mis à terre | Le corps reste. Définitivement. Une aile nettoyée doit se voir. |

```gdscript
## À placer dans un autoload ou un utilitaire : arrêt sur image.
func hit_stop(duration: float = 0.06) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration * 0.05, true, false, true).timeout
	Engine.time_scale = 1.0
```

> Le quatrième argument `true` de `get_tree().create_timer()` (`ignore_time_scale`) est indispensable : sans lui, le timer est lui-même ralenti et le jeu reste figé 20 fois trop longtemps.

---

## 9. L'arsenal du Poste de sécurité (fin d'Acte III)

**Position de design :** ce n'est pas un arsenal de milieu de partie, et ce n'est **plus un simple bonus**. Le pistolet d'ancrage est **obligatoire pour vaincre le Boss III** (§6, phase 3) : sans lui, le combat n'a pas de solution. Le fusil à pompe et le Molotov, eux, restent des outils optionnels de confort pour la phase finale et pour la course de sortie de l'Énigme 10. Trois armes, deux statuts différents — c'est délibéré : la pièce narrativement centrale (l'héritage d'Hélène) est la seule qu'on ne peut pas rater.

### Où et pourquoi

Le **Poste de sécurité** (ancienne loge du gardien du secteur Ouest) n'est plus une salle annexe : c'est désormais le **seul passage** entre l'antichambre du couloir plié et le Bureau du Directeur. La porte s'ouvre automatiquement dès que `p08_miroir_solved` est vrai, et il n'existe aucune autre route vers le Bureau — impossible de l'ignorer par inadvertance (voir le plan mis à jour, `06-level-design-et-enigmes.md` §2).

**Justification narrative :** c'est le poste du dernier agent de sécurité en faction le 19 mars 1991. Il n'a jamais eu le temps de s'en servir. Un nouveau document (D16, voir `00-bible-narrative.md` §8) explique le fusil et le Molotov en deux lignes administratives ; le pistolet d'ancrage, lui, est un prototype d'Hélène — cohérent avec sa caractérisation déjà établie (`00` §3). Le joueur n'a pas le choix de trouver l'arme de sa mère : il doit forcément traverser la pièce où elle l'a cachée.

| Objet | Quantité totale | Trouvé | Statut |
|---|---|---|---|
| `fusil_pompe` + 2 `cartouches_fusil` | Arme + 2 munitions | Râtelier du Poste | Optionnel |
| `cartouches_fusil` (réserve) | 4 | Tiroir du Poste, fouille | Optionnel |
| `molotov` (déjà assemblés) | 2 | Étagère du Poste | Optionnel |
| `bouteille_vide` + `chiffon` + `bidon_alcool` | Composants de fabrication | Poste + Bureau du Directeur (l'alcool est sur le bar du Directeur) | Optionnel |
| `pistolet_ancrage` + 3 charges intégrées, non rechargeables | Arme | Coffre-fort du Poste, verrouillé par le code **345** (le même que l'horloge de l'Énigme 2 — Hélène réutilise ses propres repères, un joueur attentif le devine sans indice supplémentaire) | **Obligatoire** |

> **Anti-blocage, pas anti-obligation :** la pièce est imposée, mais le **coffre** du pistolet reste un code à trouver, pas un ramassage automatique. Un joueur qui échoue au code peut ressortir de la salle, relire D02 (l'indice de l'heure, déjà en sa possession depuis l'Acte I), et revenir retenter — **sans limite de temps, sans ennemi dans cette pièce.** Un joueur qui atteint quand même le Boss III sans le pistolet peut reculer jusqu'au Poste en cours de combat, comme détaillé en §6.

### 9.1 — Le fusil à pompe

Dégâts lourds, portée très courte, cadence lente : l'arme qui **force le rapprochement**, à l'opposé du revolver qui récompensait la distance.

```gdscript
extends WeaponBase
class_name WeaponShotgun
## Fusil à pompe à canon court. Deux coups, rechargement lent, dispersion large.
## Trouvé en fin de jeu : jamais assez de cartouches pour changer la façon
## de jouer, juste assez pour un choix ponctuel dans une situation serrée.

const CHAMBER_SIZE := 2
const PELLET_COUNT := 8

@export var reload_time_per_shell: float = 1.1
@export var spread_degrees: float = 9.0
@export var range_meters: float = 7.0        ## Très court : c'est la contrepartie des dégâts

var shells_loaded: int = 0
var is_reloading: bool = false

@onready var _audio: AudioStreamPlayer3D = $Audio
@onready var _muzzle_flash: OmniLight3D = $MuzzleFlash

func _ready() -> void:
	damage = 22             ## par plomb ; jusqu'à 176 à bout portant si tous touchent
	cooldown = 0.9
	noise_radius = 34.0
	_muzzle_flash.visible = false

func attack(from: Camera3D) -> void:
	if not can_attack() or is_reloading or shells_loaded <= 0:
		if shells_loaded <= 0:
			_audio.stream = preload("res://audio/sfx/dry_fire.ogg")
			_audio.play()
			out_of_ammo.emit()
		return

	super.attack(from)
	shells_loaded -= 1
	_fire_pellets(from)
	_flash()
	AudioDirector.emit_noise(global_position, noise_radius)

## Dégâts au boss III : ne s'applique que si un Hurtbox de flottement
## (BossAnchor.trigger_flicker) est actif — voir §6. Sur un ennemi normal,
## comportement standard : plusieurs plombs peuvent toucher la même cible.
func _fire_pellets(from: Camera3D) -> void:
	var space := from.get_world_3d().direct_space_state
	var hits_registered: Array[Node] = []

	for i in PELLET_COUNT:
		var spread := deg_to_rad(spread_degrees)
		var direction := -from.global_transform.basis.z
		direction = direction.rotated(Vector3.UP, randf_range(-spread, spread))
		direction = direction.rotated(from.global_transform.basis.x, randf_range(-spread, spread))

		var query := PhysicsRayQueryParameters3D.create(
			from.global_position, from.global_position + direction * range_meters
		)
		query.collision_mask = 5   ## couches 1 (monde) + 3 (ennemis)
		query.exclude = [owner.get_rid()]

		var hit := space.intersect_ray(query)
		if hit.is_empty():
			continue

		var body: Node3D = hit["collider"]
		if body in hits_registered:
			continue   ## un plomb par cible et par tir compte une fois pour le hit-stop

		var health := body.get_node_or_null("HealthComponent") as HealthComponent
		if health and health.take_damage(damage, owner):
			hits_registered.append(body)
			AudioDirector.play_positional("impact_flesh", hit["position"])

func reload() -> void:
	if is_reloading or shells_loaded == CHAMBER_SIZE or GameState.ammo_shotgun <= 0:
		return
	is_reloading = true
	# Un fusil à pompe se recharge cartouche par cartouche, pas en bloc :
	# le joueur peut interrompre un rechargement pour tirer avec 1 seul coup en cas d'urgence.
	while shells_loaded < CHAMBER_SIZE and GameState.ammo_shotgun > 0:
		AudioDirector.play_positional("shotgun_load_shell", global_position)
		await get_tree().create_timer(reload_time_per_shell).timeout
		shells_loaded += 1
		GameState.ammo_shotgun -= 1
	is_reloading = false

func _flash() -> void:
	_muzzle_flash.visible = true
	_audio.stream = preload("res://audio/sfx/shotgun_blast.ogg")
	_audio.play()
	await get_tree().create_timer(0.06).timeout
	_muzzle_flash.visible = false
```

### 9.2 — Le cocktail Molotov improvisé

**Fabriqué, pas trouvé tout fait** (sauf les 2 déjà assemblés du Poste) : c'est la seule arme du jeu qui passe par le système de combinaison déjà utilisé pour la perche de l'Énigme 1 (`02` §2-3). Ressource de zone, pas de précision : il sert à **couper une route de poursuite**, pas à viser.

```gdscript
extends Node3D
class_name WeaponMolotov
## Objet lancé, à ressource unique. Fabriqué via
## InventoryManager.try_combine(&"bouteille_vide", &"chiffon") -> &"molotov"
## (le bidon d'alcool est consommé automatiquement par la recette, voir data/recipes/molotov.tres).

@export var throw_force: float = 11.0
@export var fire_radius: float = 3.5
@export var fire_duration: float = 6.0
@export var damage_per_tick: float = 8.0
@export var tick_interval: float = 0.5

@onready var _mesh: MeshInstance3D = $Mesh
@onready var _fuse_light: OmniLight3D = $FuseLight

var _has_landed: bool = false

func throw_from(camera: Camera3D) -> void:
	global_position = camera.global_position
	var body := self as RigidBody3D   # la scène racine est un RigidBody3D
	body.linear_velocity = -camera.global_transform.basis.z * throw_force + Vector3.UP * 2.0
	AudioDirector.emit_noise(global_position, 14.0)

func _on_body_entered(_body: Node) -> void:
	if _has_landed:
		return
	_has_landed = true
	_shatter()

func _shatter() -> void:
	AudioDirector.play_positional("glass_break_small", global_position)
	AudioDirector.play_positional("fire_ignite", global_position)
	_mesh.visible = false
	_fuse_light.light_color = Color(1.0, 0.45, 0.1)
	_fuse_light.light_energy = 2.5

	var elapsed := 0.0
	while elapsed < fire_duration:
		# Bloque le passage : les Désancrés évitent le feu comme n'importe
		# quel obstacle de navigation (voir NavigationObstacle3D ci-dessous).
		for body in get_tree().get_nodes_in_group("enemies"):
			if (body as Node3D).global_position.distance_to(global_position) <= fire_radius:
				var health := body.get_node_or_null("HealthComponent") as HealthComponent
				if health:
					health.take_damage(int(damage_per_tick), self)
		await get_tree().create_timer(tick_interval).timeout
		elapsed += tick_interval

	queue_free()
```

**En zone de fuite (Énigme 10) :** jeter un Molotov dans un couloir derrière soi crée une **barrière temporaire de 6 secondes** — un `NavigationObstacle3D` s'active avec le foyer, forçant les Désancrés à un détour. C'est la seule arme du jeu conçue pour ne toucher personne directement : elle achète du temps, pas des points de dégâts.

### 9.3 — Le pistolet d'ancrage

L'arme la plus liée au lore (`00-bible-narrative.md` §3, Hélène Reyes) : un prototype de stabilisation qui exploite directement la physique de l'ancrage plutôt que de faire des dégâts.

```gdscript
extends WeaponBase
class_name WeaponAnchorPistol
## Prototype d'Hélène. Trois charges, non rechargeables — un choix de
## conception délibéré : le joueur doit décider AVANT le Boss III s'il
## les garde pour lui ou les utilise contre le Boss.
##
## Contre un Désancré : le fige 4 s dans son état actuel (resynchronisation
## forcée, non létale — cohérent avec le fait que ce sont des victimes,
## pas des monstres, voir 00-bible-narrative.md §5).
## Contre le Boss III : voir BossAnchor.trigger_flicker() en §6.

const MAX_CHARGES := 3
const STUN_DURATION := 4.0

var charges_remaining: int = MAX_CHARGES

@onready var _beam: MeshInstance3D = $Beam
@onready var _audio: AudioStreamPlayer3D = $Audio

func _ready() -> void:
	damage = 0          ## Ne fait jamais de dégâts directs : c'est le point.
	cooldown = 1.4
	noise_radius = 4.0   ## Presque silencieux : un outil de discrétion, pas d'assaut

func attack(from: Camera3D) -> void:
	if not can_attack() or charges_remaining <= 0:
		if charges_remaining <= 0:
			AudioDirector.play_ui("anchor_pistol_empty")
			out_of_ammo.emit()
		return

	super.attack(from)
	charges_remaining -= 1
	AudioDirector.emit_noise(global_position, noise_radius)
	_fire_beam(from)

func _fire_beam(from: Camera3D) -> void:
	var space := from.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		from.global_position, from.global_position - from.global_transform.basis.z * 20.0
	)
	query.collision_mask = 5
	query.exclude = [owner.get_rid()]

	var hit := space.intersect_ray(query)
	_show_beam(from.global_position, hit.get("position", from.global_position - from.global_transform.basis.z * 20.0))
	if hit.is_empty():
		return

	var target: Node3D = hit["collider"]
	_audio.stream = preload("res://audio/sfx/anchor_pulse.ogg")
	_audio.play()

	if target is BossAnchor:
		target.trigger_flicker()
	elif target.is_in_group("enemies") and target.has_method("stun"):
		target.stun(STUN_DURATION)

func _show_beam(from_pos: Vector3, to_pos: Vector3) -> void:
	_beam.visible = true
	_beam.global_position = from_pos.lerp(to_pos, 0.5)
	_beam.look_at(to_pos, Vector3.UP)
	_beam.scale.z = from_pos.distance_to(to_pos)
	await get_tree().create_timer(0.12).timeout
	_beam.visible = false
```

`stun()` s'ajoute à `enemies/enemy_base.gd` (§4) — une figure imposée courte, qui ne modifie aucune autre méthode existante :

```gdscript
## Ajout à Enemy (04-code-systemes) : resynchronisation forcée, non létale.
func stun(duration: float) -> void:
	if state == State.DEAD:
		return
	set_physics_process(false)
	_anim.pause()
	AudioDirector.play_positional("anchor_stun", global_position)
	await get_tree().create_timer(duration).timeout
	if state != State.DEAD:
		_anim.play()
		set_physics_process(true)
```

### 9.4 — Emploi pendant la fuite finale (Énigme 10)

Pendant les 180 secondes de l'alarme, trois Désancrés entrent dans le Hub (`06` §3, É10). L'arsenal du Poste change la nature de cette course :

| Situation | Outil le plus adapté | Pourquoi |
|---|---|---|
| Un Désancré bloque le passage vers la console | Pistolet d'ancrage | Fige sans combattre ; ne coûte pas de temps d'animation d'attaque |
| Deux Désancrés groupés dans un couloir étroit | Fusil à pompe | Un seul tir peut toucher les deux ; dégâts qui comptent enfin |
| Se faire une avance après avoir posé le dernier badge | Molotov jeté derrière soi | Barrière de 6 s pendant la saisie du code final |

> **Équilibrage :** un joueur qui a tout dépensé contre le Boss III arrive à l'Énigme 10 les mains vides — **c'est voulu, et c'est réglé** : la table de placement des munitions (§1) garantit que le revolver seul suffit à survivre aux 180 secondes. L'arsenal du Poste rend la fin plus confortable ; il n'est jamais la condition pour la terminer.

### 9.5 — Table des identifiants (à ajouter à `02-code-systemes.md` §11)

| `id` | Objet |
|---|---|
| `fusil_pompe` | Fusil à pompe |
| `cartouches_fusil` | Cartouches de calibre 12 |
| `bouteille_vide` | Bouteille vide |
| `chiffon` | Chiffon imbibé |
| `bidon_alcool` | Bidon d'alcool à brûler |
| `molotov` | Cocktail Molotov *(combinaison)* |
| `pistolet_ancrage` | Pistolet d'ancrage — prototype d'Hélène |
