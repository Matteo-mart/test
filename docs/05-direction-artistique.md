# 05 — Direction artistique et configuration Godot 4

Renderer : **Forward+** obligatoire (le brouillard volumétrique et le SDFGI n'existent pas en Mobile ni en Compatibility).

---

## 1. Le pipeline de rendu rétro

L'idée est de **rendre le jeu en basse résolution puis de l'agrandir** avec un filtre au plus proche voisin. Cela produit le grain caractéristique de la fin des années 90 — et, accessoirement, cela masque l'hétérogénéité des assets gratuits et divise le coût GPU par cinq.

### Méthode simple (recommandée pour démarrer)

Paramètres du projet uniquement, zéro code :

| Réglage | Valeur |
|---|---|
| `display/window/size/viewport_width` | `640` |
| `display/window/size/viewport_height` | `360` |
| `display/window/size/window_width_override` | `1280` |
| `display/window/size/window_height_override` | `720` |
| `display/window/stretch/mode` | `viewport` |
| `display/window/stretch/aspect` | `keep` |
| `display/window/stretch/scale_mode` | `integer` |
| `rendering/textures/canvas_textures/default_texture_filter` | `Nearest` |
| `rendering/anti_aliasing/quality/msaa_3d` | `Disabled` |
| `rendering/anti_aliasing/quality/screen_space_aa` | `Disabled` |
| `rendering/scaling_3d/mode` | `Bilinear` |
| `rendering/scaling_3d/scale` | `1.0` |

> **Piège :** avec `stretch/mode = viewport`, **toute l'interface est également rendue en 640×360**. C'est voulu — une UI nette sur un jeu pixelisé casse l'illusion — mais cela impose des polices bitmap et des marges généreuses.

### Méthode avancée (`SubViewport` explicite)

À adopter en Phase 6 seulement, quand on veut une UI nette **par-dessus** un monde pixelisé :

```
Main (Node)
├── SubViewportContainer   (stretch = true, texture_filter = Nearest)
│   └── SubViewport        (size = 640x360, world_3d partagé)
│       └── WorldContainer   <- toutes les zones du jeu
└── HUD (CanvasLayer)        <- rendu en pleine résolution
```

---

## 2. `WorldEnvironment` — réglages par zone

Créer **trois ressources `Environment`** distinctes dans `art/environments/` et les échanger au changement de zone. Les valeurs ci-dessous sont des points de départ éprouvés, à ajuster à l'œil.

### Base commune

```
Background
  mode                    = Custom Color
  color                   = #05070a  (presque noir, légèrement bleuté)
  energy_multiplier       = 1.0

Ambient Light
  source                  = Color
  color                   = #14181f
  energy                  = 0.12          <- très faible : l'obscurité est le sujet
  sky_contribution        = 0.0

Tonemap
  mode                    = Filmic
  exposure                = 0.85
  white                   = 1.6

Glow
  enabled                 = ON
  levels 1..7             = 0 / 0 / 1 / 1 / 1 / 0 / 0
  intensity               = 0.55
  strength                = 1.1
  bloom                   = 0.06
  hdr_threshold           = 0.95
  hdr_scale               = 2.0
  blend_mode              = Additive

Adjustments
  enabled                 = ON
  brightness              = 1.0
  contrast                = 1.18
  saturation              = 0.62          <- désaturation générale
  color_correction        = <LUT du projet>
```

**Pourquoi `Filmic` plutôt qu'`ACES` :** ACES écrase les noirs de façon très contrastée et « cinéma moderne ». Filmic garde les basses lumières plus lisibles, ce qui compte quand 80 % du jeu se joue à la lampe torche. Testez les deux, mais commencez par Filmic.

**Pourquoi `exposure = 0.85` :** sous-exposer légèrement force le joueur à utiliser la lampe. L'obscurité devient une contrainte de jeu, pas un effet.

### Acte I — La maison

```
Fog (non volumétrique, pour l'extérieur et les combles)
  enabled                 = ON
  mode                    = Exponential
  light_color             = #2a2620       (brun, poussière)
  light_energy            = 0.5
  density                 = 0.035
  sky_affect              = 0.0

Volumetric Fog
  enabled                 = ON
  density                 = 0.018         <- discret : la maison est sèche
  albedo                  = #3a3228
  emission                = #000000
  emission_energy         = 0.0
  anisotropy              = 0.25
  length                  = 32
  detail_spread           = 2.0
  ambient_inject          = 0.1

Adjustments
  saturation              = 0.70          <- un peu de chaleur restante
```

Dominante : **sépia sale**. Bois, papier peint, poussière. La maison doit être *triste* avant d'être effrayante.

### Acte II — Le complexe

```
Ambient Light
  color                   = #0d1a1c
  energy                  = 0.08          <- encore plus sombre

Volumetric Fog
  enabled                 = ON
  density                 = 0.042         <- dense : la lampe fait des cônes visibles
  albedo                  = #8fa8a5
  emission                = #0a1412
  emission_energy         = 0.15
  anisotropy              = 0.4           <- diffusion vers l'avant, halo autour des lampes
  length                  = 24
  gi_inject               = 0.6

Glow
  intensity               = 0.75          <- les néons bavent
  hdr_threshold           = 0.85

SSAO
  enabled                 = ON
  radius                  = 1.2
  intensity               = 2.4
  power                   = 1.8
  detail                  = 0.6

SSIL
  enabled                 = ON
  radius                  = 3.0
  intensity               = 0.7

Adjustments
  saturation              = 0.48          <- vert-gris clinique
  contrast                = 1.25
```

Dominante : **vert-gris institutionnel**. Néons, carrelage, métal peint.

> **`anisotropy = 0.4` est le réglage le plus rentable du document.** Il concentre la diffusion du brouillard vers l'avant, ce qui rend le **cône de la lampe torche visible dans l'air**. C'est l'effet signature du survival horror moderne, et il tient en un curseur.

### Acte III — Le secteur Ouest

```
Background
  color                   = #0a0308        (dominante magenta profond)

Volumetric Fog
  density                 = 0.065          <- étouffant
  albedo                  = #6b4f7a
  emission                = #2a0f38
  emission_energy         = 0.8            <- le brouillard émet sa propre lumière
  anisotropy              = -0.2           <- diffusion arrière : halos inversés, dérangeants
  length                  = 18             <- on ne voit pas à 18 m

Tonemap
  exposure                = 0.72
  white                   = 2.2

Glow
  intensity               = 1.15
  bloom                   = 0.18           <- l'image commence à déborder

Adjustments
  saturation              = 0.85           <- la couleur REVIENT : signal de bascule
  contrast                = 1.4
```

**Concept clé de mise en scène :** en désaturant progressivement les Actes I et II puis en **ressaturant** l'Acte III, le basculement se lit physiquement à l'écran. Le joueur ne peut pas nommer ce qui a changé, mais il le ressent. C'est plus efficace qu'un effet de distorsion.

### Transition entre environnements

```gdscript
## Interpolation douce entre deux Environment (0,8 s au passage d'une porte).
func blend_environment(world_env: WorldEnvironment, target: Environment, duration: float = 0.8) -> void:
	var from := world_env.environment
	var tween := create_tween().set_parallel(true)
	tween.tween_property(from, "volumetric_fog_density", target.volumetric_fog_density, duration)
	tween.tween_property(from, "volumetric_fog_albedo", target.volumetric_fog_albedo, duration)
	tween.tween_property(from, "adjustment_saturation", target.adjustment_saturation, duration)
	tween.tween_property(from, "tonemap_exposure", target.tonemap_exposure, duration)
	tween.tween_property(from, "background_color", target.background_color, duration)
```

---

## 3. Shaders rétro

### 3.1 Jitter de sommets + affine mapping (le « look PS1 »)

Deux artefacts caractéristiques de la PlayStation : les sommets sautillent (pas de sous-pixel) et les textures se déforment sur les grands polygones (pas de correction de perspective).

`art/shaders/ps1.gdshader` :

```glsl
shader_type spatial;
render_mode vertex_lighting, diffuse_lambert_wrap, specular_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform float snap_resolution : hint_range(16.0, 256.0) = 64.0;
uniform float affine_amount : hint_range(0.0, 1.0) = 0.85;

varying float affine_w;

void vertex() {
	// 1. Quantification des sommets en espace écran : le fameux tremblement.
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 ndc = clip.xyz / clip.w;
	ndc.xy = round(ndc.xy * snap_resolution) / snap_resolution;
	clip.xyz = ndc * clip.w;
	POSITION = clip;

	// 2. On conserve w pour annuler la correction de perspective en fragment.
	affine_w = clip.w;
}

void fragment() {
	// Mélange entre UV correctes et UV affines : à 1.0, texture "qui glisse".
	vec2 affine_uv = mix(UV, UV * affine_w / max(affine_w, 0.0001), affine_amount);
	ALBEDO = texture(albedo_texture, affine_uv).rgb;
	SPECULAR = 0.0;
	ROUGHNESS = 1.0;
}
```

> `vertex_lighting` (éclairage calculé par sommet, pas par pixel) est ce qui donne le plus l'impression d'époque, pour un coût GPU dérisoire. Utilisez-le sur **tout le décor statique** ; gardez l'éclairage par pixel pour les personnages.

### 3.2 Post-traitement : dithering, quantification, grain

Placer un `ColorRect` plein écran dans un `CanvasLayer` en `layer = 100`, avec ce shader.

`art/shaders/post_retro.gdshader` :

```glsl
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float color_levels : hint_range(2.0, 64.0) = 24.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.6;
uniform float grain_amount : hint_range(0.0, 0.4) = 0.06;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.9;
uniform float aberration : hint_range(0.0, 4.0) = 0.8;
uniform float time_scale = 1.0;

// Matrice de Bayer 4x4 : le motif de tramage ordonné historique.
const float BAYER[16] = float[16](
	 0.0,  8.0,  2.0, 10.0,
	12.0,  4.0, 14.0,  6.0,
	 3.0, 11.0,  1.0,  9.0,
	15.0,  7.0, 13.0,  5.0
);

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = uv - vec2(0.5);

	// --- Aberration chromatique : les canaux se séparent vers les bords.
	float dist = length(center);
	vec2 offset = center * dist * aberration * 0.004;
	vec3 color;
	color.r = texture(screen_texture, uv + offset).r;
	color.g = texture(screen_texture, uv).g;
	color.b = texture(screen_texture, uv - offset).b;

	// --- Tramage ordonné avant quantification : c'est l'ordre qui compte.
	ivec2 pixel = ivec2(mod(FRAGCOORD.xy, 4.0));
	float threshold = BAYER[pixel.y * 4 + pixel.x] / 16.0 - 0.5;
	color += threshold * dither_strength / color_levels;

	// --- Quantification : réduit la profondeur de couleur.
	color = floor(color * color_levels + 0.5) / color_levels;

	// --- Grain animé.
	float grain = rand(uv + fract(TIME * time_scale)) - 0.5;
	color += grain * grain_amount;

	// --- Vignettage : ferme le cadre, renforce la claustrophobie.
	color *= 1.0 - dist * dist * vignette_strength;

	COLOR = vec4(color, 1.0);
}
```

**Valeurs par acte :**

| Uniform | Acte I | Acte II | Acte III |
|---|---|---|---|
| `color_levels` | 28 | 24 | 14 |
| `dither_strength` | 0.4 | 0.6 | 0.9 |
| `grain_amount` | 0.05 | 0.06 | 0.12 |
| `aberration` | 0.5 | 0.8 | 2.2 |
| `vignette_strength` | 0.8 | 0.9 | 1.3 |

**Le shader devient un outil de narration :** faire dériver ces valeurs pendant l'Acte III (le joueur voit l'image se dégrader) raconte la perte d'ancrage sans une ligne de dialogue.

---

## 4. Éclairage

### Philosophie

> **L'obscurité est une ressource, pas une absence.**

Trois conséquences pratiques :

1. La lumière ambiante globale est à 0,08-0,12. Sans lampe, on ne voit **rien**.
2. Chaque source de lumière du niveau est **diégétique** : un néon, une lampe de bureau, un écran, une issue de secours. Aucune lumière « de confort » invisible.
3. La lumière **guide**. Le joueur va toujours vers la seule lumière du couloir. C'est votre outil de level design le plus puissant, et il est gratuit.

### La lampe torche

`SpotLight3D`, enfant de `Head` (pas de `Camera3D` : légèrement décalée, elle donne du relief) :

| Propriété | Valeur | Pourquoi |
|---|---|---|
| `light_energy` | `2.2` | |
| `light_color` | `#fff0d6` | Blanc chaud de lampe à incandescence, pas de LED |
| `spot_range` | `14.0` | Court : on n'éclaire jamais le fond du couloir |
| `spot_angle` | `32.0` | Cône serré : on ne voit qu'une chose à la fois |
| `spot_angle_attenuation` | `1.4` | Bords doux |
| `spot_attenuation` | `1.8` | Chute rapide |
| `shadow_enabled` | `ON` | **Non négociable** : les ombres portées mobiles font 80 % de la peur |
| `shadow_bias` | `0.03` | À ajuster si des rayures apparaissent |
| `light_projector` | texture de cookie | Imperfections du réflecteur : rend la lampe crédible |

**La texture `light_projector`** est le détail qui change tout : une image en niveaux de gris avec quelques taches sombres et un léger halo décentré, projetée par la lampe. Une lampe torche réelle n'éclaire jamais uniformément. Se fabrique en 3 minutes dans GIMP (dégradé radial + bruit).

**Position de design :** la batterie ne s'épuise **jamais complètement** de façon punitive. À 0 %, le joueur trouve toujours une pile dans les 5 minutes. La jauge sert à produire de l'anxiété, pas un game over.

### Blackout de l'Énigme 7

Séquence en trois temps :

```gdscript
extends Node
## Coupure de courant de l'Aile Recherche.

@export var flicker_duration: float = 2.4

func trigger_blackout() -> void:
	var lights := get_tree().get_nodes_in_group("wing_lights")

	# 1. Vacillement de panique (2,4 s) : le joueur comprend ce qui arrive
	#    avant que ça n'arrive. L'anticipation vaut mieux que la surprise.
	var elapsed := 0.0
	while elapsed < flicker_duration:
		var wait := randf_range(0.04, 0.22)
		var on := randf() > 0.45
		for light in lights:
			(light as Light3D).light_energy = 1.0 if on else 0.0
		AudioDirector.play_positional("neon_flicker", lights[0].global_position)
		await get_tree().create_timer(wait).timeout
		elapsed += wait

	# 2. Noir complet + coupure du son ambiant. 1,5 s de silence total.
	for light in lights:
		(light as Light3D).light_energy = 0.0
	AudioDirector.set_ambience_volume(-80.0)
	await get_tree().create_timer(1.5).timeout

	# 3. Bourdonnement du groupe de secours. Éclairage rouge très faible.
	AudioDirector.play_ambience("emergency_hum")
	for light in get_tree().get_nodes_in_group("emergency_lights"):
		var l := light as Light3D
		l.light_color = Color(0.9, 0.12, 0.1)
		var tween := create_tween()
		tween.tween_property(l, "light_energy", 0.35, 1.2)

	GameState.set_flag("recherche_blackout")
```

**Éclairage de secours :** des `OmniLight3D` rouges de très faible énergie (0,35) tous les 8 m, portée 4 m. Ils ne permettent **pas** de jouer : ils permettent de ne pas être perdu. La lampe torche devient obligatoire, ce qui rend visible le joueur — donc audible et détectable. La mécanique et l'ambiance se renforcent.

### Encre invisible UV

Les inscriptions révélées par la lampe UV sont des `MeshInstance3D` plats (`QuadMesh`) plaqués sur les murs, avec ce shader :

`art/shaders/uv_ink.gdshader` :

```glsl
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;

uniform sampler2D ink_texture : source_color, filter_nearest;
uniform vec4 ink_color : source_color = vec4(0.45, 0.85, 1.0, 1.0);
uniform float uv_light_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 ink = texture(ink_texture, UV);
	// Rien n'est visible tant que uv_light_amount vaut 0.
	ALBEDO = ink.rgb * ink_color.rgb * uv_light_amount;
	ALPHA = ink.a * uv_light_amount;
}
```

Pilotage : un `Area3D` autour de l'inscription détecte le cône de la lampe UV et interpole `uv_light_amount` de 0 à 1.

```gdscript
extends Area3D
## Inscription à l'encre UV. Ne se révèle que sous la lampe UV.

@export var reveal_speed: float = 4.0
@onready var _mesh: MeshInstance3D = $Ink
@onready var _material: ShaderMaterial = _mesh.get_surface_override_material(0)

var _target_amount: float = 0.0

func _process(delta: float) -> void:
	var current: float = _material.get_shader_parameter("uv_light_amount")
	var next := move_toward(current, _target_amount, reveal_speed * delta)
	_material.set_shader_parameter("uv_light_amount", next)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and _is_uv_lamp_on(body):
		_target_amount = 1.0

func _on_body_exited(_body: Node3D) -> void:
	_target_amount = 0.0

func _is_uv_lamp_on(player: Node3D) -> bool:
	return InventoryManager.equipped == &"lampe_uv" \
		and player.get_node_or_null("Head/UVLamp") != null \
		and player.get_node("Head/UVLamp").visible
```

### Lumière statique vs dynamique

| Type | Traitement |
|---|---|
| Néons du décor, lampes fixes | **`LightmapGI` précalculé.** Marquer les meshes en `Static` et cuire une lightmap par zone. Gain de performance massif. |
| Lampe torche, lampe UV, muzzle flash | Dynamiques, ombres activées |
| Éclairage de secours | Dynamique (leur couleur change à l'exécution) |

**Nombre de lumières à ombres simultanées : 4 maximum.** Au-delà, les performances chutent en Forward+ avec du brouillard volumétrique. En pratique : la lampe torche + 3 lumières de salle.

**SDFGI :** l'activer uniquement dans le hall et les grands volumes. Coûteux, et invisible dans les couloirs étroits — ne le laissez pas allumé partout « au cas où ».

---

## 5. Audio spatialisé

| Réglage `AudioStreamPlayer3D` | Valeur | Effet |
|---|---|---|
| `attenuation_model` | `Inverse Square Distance` | Réaliste : le son chute vite |
| `unit_size` | `4.0` à `8.0` | Distance à laquelle le son est à pleine puissance |
| `max_distance` | `30.0` | Au-delà, le son est coupé (économie de voix) |
| `panning_strength` | `1.4` | Stéréo un peu exagérée : la localisation devient une information |
| `attenuation_filter_cutoff_hz` | `4500` | **Le son lointain devient sourd.** Effet de présence considérable pour un seul curseur. |

**Réverbération par zone :** placer un `Area3D` avec `AudioEffectReverb` par type d'espace.

| Espace | `room_size` | `damping` | `wet` |
|---|---|---|---|
| Couloir étroit | 0.35 | 0.6 | 0.25 |
| Salle carrelée | 0.55 | 0.25 | 0.4 |
| Hall d'accueil | 0.85 | 0.3 | 0.5 |
| Cave / sous-sol | 0.7 | 0.8 | 0.35 |
| Secteur Ouest | 0.95 | 0.1 | 0.65 |

**Ducking dynamique :** quand un ennemi passe en `CHASE`, baisser `AMBIENCE` de 6 dB en 0,3 s et monter `VOICE`. Le joueur perçoit le changement avant de comprendre pourquoi. À la perte de la trace, remonter en 2 s — lentement, pour laisser la tension retomber trop tard.
