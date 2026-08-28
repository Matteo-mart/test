Rôle : Tu es un Game Designer et Développeur Senior spécialisé sur Godot Engine 4, expert en Survival Horror (style Resident Evil, Silent Hill, Signalis).

Contexte & Contraintes techniques :
- Développeur solo avec de bonnes bases en programmation, mais 0 compétence en modélisation/dessin 3D.
- Moteur : Godot Engine 4.
- Graphismes : Assets 3D gratuits (Kenney, KayKit, Itch.io) avec rendu rétro / low-poly style Survival Horror 90s.
- Caméra : Vue à la première personne (FPS).
- Durée visée : ~2 heures de jeu.
- Ambiance : Anxiogène, claustrophobique, surréaliste, axée sur la tension et l'environnement sonore (aucun jumpscare facile).

GAMES DESIGN & DESIGN DES ÉNIGMES (DÉJÀ DÉFINIS) :
Le jeu est découpé en 3 actes interconnectés avec du backtracking autour d'un Hub Central (Hall du Laboratoire) et 10 énigmes clés :

[ACTE I : La Maison Abandonnée - Intro (25 min)]
- Énigme 1 (Salon) : Manche à balai + Crochet = Perche improvisée -> Décroche la Clé Rouillée.
- Énigme 2 (Bureau) : Document "03:45" + Aiguille en bronze (tiroir à code) -> Réglage de l'Horloge comtoise -> Ouvre la Trappe du Sous-sol.
- Énigme 3 (Sous-sol) : 4 photos de famille à symboles -> Code "VOID" sur cadenas à rouleaux -> Accès au complexe scientifique.

[ACTE II : Le Hub du Laboratoire - Le Cœur (60 min)]
- Énigme 4 (Hub) : Scalpel sur statue anatomique -> Gemme Rouge à inspecter en 3D -> Puce d'accès -> Accès Aile Médicale.
- Énigme 5 (Aile Médicale) : Seringue + Centrifugeuse (mini-jeu de jauges) -> Sérum purifié -> Libère le Badge Rouge (1/3).
- Énigme 6 (Aile Coms) : Passe-partout morgue -> Mini-jeu d'ondes radio (sinusoïde) -> Déverrouille l'Aile de Recherche.
- Énigme 7 (Aile Recherche) : Panne de courant -> Lampe UV révèle code boîte à outils -> Fusible de rechange -> Libère le Badge Vert (2/3).

[ACTE III : Le Basculement Surréaliste - Le Final (35 min)]
- Énigme 8 (Couloir Surréaliste) : Boucle spatiale infinie -> Aligner l'objet réel sur la position de son reflet dans le miroir -> Accès Bureau Directeur.
- Énigme 9 (Bureau Directeur) : Manivelle dans toile déchirée -> Boîte à musique -> Rejouer la mélodie sur le piano -> Libère le Badge Bleu (3/3).
- Énigme 10 (Hub / Fuite) : Insertion des 3 badges -> Alarme & Compte à rebours 3 min -> Ordre d'insertion via documents (Rouge -> Bleu -> Vert) + Code gravé sous les badges -> Ouverture de la Porte Blindée Finale.

Schéma de progression :
[Maison] ──(Perche + Aiguille)──> [Sous-sol] ──(Code VOID)──> [Hub Labo]
   │                                                             │
   │                                    ┌────────────────────────┴────────────────────────┐
   ▼                                    ▼                                                 ▼
[Aile Médicale] ──(Sérum)──> [Badge Rouge]   [Aile Recherche] ──(Fusible UV)──> [Badge Vert]
   │                                                                                      │
   └──────────────────────── (Fréquence Radio) ───────────────────────────────────────────┘
                                        │
                                        ▼
                  [Secteur Surréaliste / Bureau] ──(Boîte Musique)──> [Badge Bleu]
                                        │
                                        ▼
                     [Séquençage Final (Hub) & Fuite]

---

CE QUE TU DOIS ME FOURNIR :

1. ARCHITECTURE TECHNIQUE & CODE (GDScript - Godot 4) :
   - Structure des nœuds et des scripts principaux : Player (FPS/Raycast), InventoryManager (autoload), SaveSystem (JSON/Resource pour sauvegarder les états de 2h de jeu), InteractableObject, PuzzleManager, Door.
   - Script commenté pour l'inspection 3D d'un objet dans l'inventaire (rotation de l'objet à la souris pour révéler un détail dissimulé dessous).
   - Logique du système d'inventaire prenant en compte la combinaison d'objets (ex: Manche + Crochet = Perche).

2. CAHIER DES CHARGES DES ASSETS GRATUITS :
   - Liste précise des packs d'objets 3D à télécharger sur Kenney.nl, KayKit et Itch.io pour constituer les décors (Maison, Labo, Morceau Surréaliste).
   - Liste des effets sonores (SFX) et ambiances audio spatialisées 3D (bruits de pas, néons qui grésillent, voix/murmures, fréquences radio) sur Freesound.org.

3. DIRECTION ARTISTIQUE & CONFIGURATION GODOT 4 :
   - Réglages exacts du nœud `WorldEnvironment` pour générer la tension (Volumetric Fog, Glow, Tonemap, ajustement d'exposition).
   - Méthodes d'éclairage dynamique pour gérer la lampe torche et le passage dans le noir de l'énigme 7.

4. ROADMAP DE DÉVELOPPEMENT OPTIMISÉE :
   - Découpage par étapes chronologiques pour créer le jeu de manière modulaire en commençant par un prototype "Greybox" (boîtes grises) avant l'habillage visuel.

Poses moi autant de questions que nécessaire,  et fais un plan