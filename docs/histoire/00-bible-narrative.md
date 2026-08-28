# 00 — Bible narrative

> Titre de travail : **VOID**
> Genre : survival horror FPS, science-fiction psychologique
> Référence de ton : *Signalis* (froideur bureaucratique) + *Silent Hill 2* (deuil) + *Resident Evil 1* (complexe verrouillé)

---

## 1. Pitch

**1991.** Le Centre d'Études Perceptuelles de Valmont (CEP-V), un laboratoire enterré sous une maison de fonction isolée, mène le **Protocole VOID**. Une nuit de mars, l'expérience dérape. Le site est scellé, les 34 personnes présentes sont déclarées disparues.

**2003.** Camille Reyes reçoit par courrier notarié les clés d'une maison dont elle ignorait l'existence, léguée par sa mère **Hélène Reyes**, chercheuse disparue en 1991. Camille vient chercher une explication. Elle trouvera une trappe.

**La question du jeu :** *que reste-t-il d'une personne quand ce qu'elle perçoit cesse de correspondre à ce qui est ?*

---

## 2. Thème et règle du monde

### Le concept central : l'ancrage

Toute la science-fiction du jeu tient en une phrase, et **tout le reste en découle** :

> La perception n'est pas une lecture du réel. C'est une **négociation** avec lui. Et cette négociation peut être perdue.

Les chercheurs de Valmont ont découvert que sous une stimulation sensorielle très précise (lumière stroboscopique, tonalité de calibrage, privation vestibulaire), le cerveau humain cesse d'ajuster son modèle interne au monde — et le monde commence, faiblement, à s'ajuster au modèle interne.

Ils ont nommé ce couplage **l'ancrage**. Un sujet ancré impose localement sa perception à la matière. L'effet est minuscule : quelques centimètres, quelques degrés, quelques secondes. À l'échelle du site entier, avec 34 modèles internes contradictoires bloqués en boucle, il devient une **géométrie impossible**.

### VOID n'est pas un mot anglais

C'est un **acronyme administratif français**, ce qui est infiniment plus inquiétant :

> **V**ection **O**ptique et **I**nduction **D**issociative

C'est le nom d'une ligne budgétaire. C'est écrit sur des chemises cartonnées. **Concept clé de game design :** l'horreur bureaucratique fonctionne parce qu'elle refuse le spectaculaire — le mot passé au cadenas du sous-sol (Énigme 3) est un sigle de dossier, pas une incantation.

### Les trois lois (à ne jamais contredire)

1. **Rien n'est surnaturel.** Tout phénomène a un rapport de laboratoire qui le décrit en langage administratif.
2. **L'ancrage a besoin d'un observateur.** Les couloirs ne se plient que là où quelqu'un est encore en train de percevoir.
3. **Le protocole est réversible, jamais annulable.** On peut refermer, pas défaire.

---

## 3. Personnages

### Camille Reyes — protagoniste (muette, 34 ans, archiviste)

- Élevée par sa grand-mère. Sa mère « travaillait loin » et revenait trois fois par an.
- N'a jamais su ce qu'était Valmont. Le legs est sa première information en douze ans.
- **Motivation d'acte I :** comprendre. **Motivation d'acte III :** sortir.
- Muette et sans visage (FPS). Sa caractérisation passe **entièrement par ses annotations** sur les documents ramassés — une ligne manuscrite en bas de chaque note, affichée en italique dans l'UI. C'est le seul canal de voix du personnage, et il coûte zéro asset.

### Hélène Reyes — mère, chercheuse en psychophysique (Aile Recherche)

- A rejoint Valmont en 1986. **A compris avant les autres** que le protocole ne mesurait pas la perception mais la déformait.
- A caché le code du sous-sol dans quatre photos de famille — le seul endroit que ses collègues n'auraient jamais fouillé.
- **Son arc, découvert par documents :** elle n'a pas fui. Elle est restée pour verrouiller le site depuis l'intérieur. Le Badge Vert est le sien.
- **Son dernier outil :** dans les semaines précédant l'incident, elle a détourné le matériel de calibrage pour construire un prototype portatif — le **pistolet d'ancrage**, la seule arme capable de forcer Achard à se resynchroniser une fois qu'il a cessé de se refléter. Elle l'a caché dans le coffre du Poste de sécurité, verrouillé sur le seul code qu'elle savait ne jamais oublier : 345. **Mécaniquement, c'est un objet-clé au même titre qu'un badge :** Camille ne peut pas vaincre Achard sans retrouver, physiquement, la dernière chose que sa mère a construite contre lui.

### Paul Achard — Directeur du site (antagoniste)

- Physicien, 61 ans en 1991. Convaincu que l'ancrage est **la première technologie d'immortalité** : un modèle interne assez stable survit au corps qui le porte.
- A ordonné l'essai à intensité maximale malgré trois rapports d'opposition.
- **S'est ancré lui-même.** Boss final de l'Acte III.

### Anne-Marie Sorel — Chef de l'Aile Médicale

- A conçu le **sérum d'ancrage**, stabilisateur destiné à ramener les sujets. Trop peu, trop tard.
- Badge Rouge. Son corps est dans l'unité de stase de l'Aile Médicale — c'est ce que le joueur trouve à l'Énigme 5.

### Rémi Delcourt — technicien électricien (Aile Recherche)

- Personnage secondaire le plus attachant : notes maladroites, blagues, croquis dans les marges.
- C'est lui qui écrit les codes au **marqueur UV** parce qu'il les oublie tout le temps (Énigme 7). Justification diégétique parfaite d'un puzzle.
- Mort dans le noir, une lampe torche vide à la main. Le joueur trouve la lampe et **c'est celle qu'il utilise tout le jeu**.

---

## 4. Le site : CEP-Valmont

```
                    [ MAISON DE FONCTION ]        <- Acte I, surface
                    Salon / Bureau / Sous-sol
                              |
                      (monte-charge de service)
                              |
    ============================================================
                    [ HALL D'ACCUEIL — HUB ]      <- Acte II
                    Statue anatomique, tourniquets
             ______________|______________________
            |              |                      |
      [AILE MÉDICALE] [AILE COMS]          [AILE RECHERCHE]
       Dr. Sorel       Radio / Morgue       Hélène / Rémi
       Badge ROUGE     -> déverrouille ->   Badge VERT
            |______________|______________________|
                              |
                    [ SECTEUR OUEST ]             <- Acte III
                    Couloir plié / Bureau Achard
                    Badge BLEU
                              |
                    [ PORTE BLINDÉE — SORTIE ]
```

**Hiérarchie des badges (justifie l'ordre final, Énigme 10) :**

| Badge | Titulaire | Habilitation révoquée le |
|---|---|---|
| ROUGE | A.-M. Sorel | 12 mars 1991 |
| BLEU | P. Achard | 14 mars 1991 |
| VERT | H. Reyes | 19 mars 1991 |

L'ordre **Rouge → Bleu → Vert** n'est pas arbitraire : c'est la **chronologie des révocations**, lisible sur trois documents distincts trouvés dans trois ailes différentes. Le joueur qui lit reconstitue l'ordre ; le joueur qui ne lit pas doit essayer six permutations sous chronomètre de 3 minutes.

---

## 5. Les Désancrés (bestiaire commun)

**Ce ne sont pas des zombies.** Ce sont les 34 personnes présentes la nuit du 19 mars 1991, toujours vivantes, toujours en train de percevoir un site qui n'existe plus.

| Observation en jeu | Explication interne |
|---|---|
| Ils marchent lentement, par à-coups | Leur boucle sensori-motrice a ~800 ms de retard sur le réel |
| Ils réagissent au **son** avant la vue | Leur modèle visuel est figé en 1991 : ils ne « voient » pas le joueur, qui n'y figure pas |
| Ils s'arrêtent devant des murs inexistants | Ils contournent le mobilier de 1991 |
| Ils portent encore blouses et badges | Personne ne les a déshabillés |
| Ils saignent | Ils sont vivants |

**Conséquence de game design capitale :** l'ennemi ignore un joueur immobile et silencieux. **Le bruit est la ressource la plus dangereuse du jeu**, pas la lumière. Courir, recharger, casser une vitre : chaque action a un coût audible. Cela donne au joueur un vrai levier tactique sans coûter une seule ligne d'IA de vision complexe.

**Variantes** (même modèle 3D, ressources différentes — voir `03-combat-et-bestiaire.md`) :

- **Désancré tardif** (Acte I-II) : lent, sourd d'une oreille, 60 PV.
- **Désancré de terrain** (Acte II) : ancien agent de sécurité, plus rapide, 90 PV, frappe fort.
- **Désancré profond** (Acte III) : silencieux, se déplace quand le joueur ne le regarde **pas** (le classique « ange pleureur », ici justifié : sans observateur, son ancrage se relâche et il peut occuper une position impossible).

---

## 6. Les trois boss

Règle de conception commune : **aucun boss ne se tue aux dégâts bruts.** Chacun se résout par l'environnement. C'est cohérent avec la pénurie de munitions, avec zéro compétence en animation (pas de longues séquences de combat à animer), et avec le thème (on ne combat pas la perception, on la manipule).

### Acte I — **LE GARDIEN** (sous-sol de la maison)

- **Qui :** Marcel Aubry, gardien du site. Premier contaminé, remonté par le monte-charge en 1991, jamais redescendu.
- **Où :** cave à charbon du sous-sol, à la lueur de la seule lampe torche.
- **Mécanique :** il est **aveugle** (yeux opacifiés). Il ne suit que le son. Le joueur doit lancer des objets pour le détourner, atteindre le treuil du monte-charge et **le faire s'écraser sous la plateforme**.
- **Rôle pédagogique :** enseigne la mécanique du bruit avant que le jeu ne l'exige.

### Acte II — **LA MATRONE** (Aile Médicale, salle de décontamination)

- **Quoi :** sept sujets qui se percevaient au même endroit au même instant. L'ancrage les a résolus en un seul corps. Une masse lente, énorme, qui **parle avec sept voix décalées**.
- **Mécanique :** trop lourde pour être blessée. Le joueur doit l'attirer dans le **sas de décontamination** en trois étapes (trois appâts sonores placés dans trois salles), puis lancer le cycle depuis la console extérieure.
- **Récompense :** ouvre l'accès au Badge Rouge.

### Acte III — **L'ANCRE** (Bureau du Directeur / Secteur Ouest)

- **Qui :** Paul Achard. Il a réussi. Son modèle interne est stable, son corps ne l'est plus : il apparaît là où il **croit** être, jamais là où il est.
- **Mécanique :** il est invulnérable à sa position perçue. Les deux premières fois, le joueur le touche en tirant sur son **reflet** dans un miroir du secteur — reprise directe de la logique de l'Énigme 8, que le joueur vient d'apprendre.
- **Trois phases :** deux miroirs à briser, la salle se replie à chaque fois. Après le second, Achard cesse de se refléter — plus aucun miroir ne le montre. Seul le **pistolet d'ancrage** d'Hélène, retrouvé au Poste de sécurité, peut encore le forcer à se resynchroniser pour la phase finale. C'est délibéré : Camille ne peut vaincre le Directeur qu'avec l'outil que sa propre mère a conçu contre lui.

---

## 7. Justification narrative des 10 énigmes

**Test de cohérence :** chaque énigme du design validé doit avoir une raison d'exister *dans le monde*, pas seulement dans le jeu.

| # | Énigme | Justification diégétique |
|---|---|---|
| 1 | Perche (manche + crochet) | La clé du bureau est sur le lustre : Hélène la jetait là quand elle partait en mission, hors de portée d'un enfant. Camille s'en souvient (annotation). |
| 2 | Horloge réglée sur 03:45 | 03:45 est l'heure de l'incident, gravée sur tous les rapports. Hélène a converti la mécanique de l'horloge comtoise en verrou de trappe : seule quelqu'un connaissant l'heure exacte peut descendre. |
| 3 | Code VOID (4 photos) | Les quatre photos de famille portent au dos une lettre chacune. Hélène a caché le sigle du programme dans le seul objet que ses collègues n'auraient pas fouillé. |
| 4 | Scalpel → statue → gemme → puce | La statue anatomique du hall est un modèle d'anatomie de 1974 ; Sorel y a dissimulé une puce d'accès de secours dans la cavité thoracique, sous une « gemme » qui est en réalité une **lentille de calibrage** en verre au plomb. |
| 5 | Centrifugeuse → sérum | Le sas biologique refuse de s'ouvrir tant que le capteur détecte une contamination active. Injecter un échantillon **purifié** dans l'analyseur satisfait le protocole de sécurité et libère le casier du Badge Rouge. |
| 6 | Passe-partout morgue → radio | Le site a été verrouillé par une procédure automatique. L'Aile Recherche ne rouvre que sur **onde porteuse codée** — c'était le canal de secours en cas de coupure. La fréquence est notée dans le registre de la morgue, seul local où le veilleur passait la nuit. |
| 7 | Panne → lampe UV → fusible | Rémi Delcourt notait tous ses codes au marqueur UV « pour pas que le chef les voie ». Le verrou électromagnétique du Badge Vert exige le courant : pas de fusible, pas de badge. |
| 8 | Couloir plié / miroir | Zone d'ancrage résiduel maximal. Le miroir montre la **géométrie réelle** ; le couloir montre la géométrie perçue. Faire coïncider un objet avec son reflet force la résolution du conflit et déplie le couloir. |
| 9 | Manivelle → boîte à musique → piano | La mélodie est le **ton de calibrage** joué à chaque session pour synchroniser les sujets. Achard en avait fait faire une boîte à musique — vanité de directeur. Le rejouer au piano réémet la séquence et ouvre son coffre. |
| 10 | 3 badges, ordre + chrono | Insérer les badges relance le protocole (seule façon de déverrouiller la porte blindée). La relance déstabilise le secteur : d'où l'alarme et les 3 minutes. L'ordre est la chronologie des révocations d'habilitation. |

---

## 8. Documents à ramasser (16)

Chaque document est **court** (5 à 12 lignes). Trois fonctions : indice mécanique, information narrative, caractérisation. Aucun ne fait les trois à la fois.

| # | Titre | Lieu | Fonction |
|---|---|---|---|
| D01 | Lettre du notaire | Salon (départ) | Cadre le personnage |
| D02 | Carnet d'Hélène — page arrachée | Bureau maison | **Indice : « 03:45 »** (Énigme 2) |
| D03 | Photo de classe annotée | Bureau maison | Révèle qu'Hélène connaissait Achard depuis 1974 |
| D04 | Formulaire CEP-V 12-B | Sous-sol | Développe l'acronyme **VOID** (Énigme 3) |
| D05 | Note de service — révocation Sorel | Aile Médicale | **Indice : ROUGE, 12 mars** (Énigme 10) |
| D06 | Rapport d'autopsie inachevé | Aile Médicale | « Le sujet respire toujours. » |
| D07 | Registre du veilleur de nuit | Aile Coms / morgue | **Indice : fréquence radio** (Énigme 6) |
| D08 | Note de service — révocation Achard | Aile Coms | **Indice : BLEU, 14 mars** (Énigme 10) |
| D09 | Post-it de Rémi | Aile Recherche | « Le marqueur est dans la caisse à outils » (Énigme 7) |
| D10 | Trois rapports d'opposition | Aile Recherche | Hélène, Sorel et un tiers ont tenté d'arrêter l'essai |
| D11 | Note de service — révocation Reyes | Aile Recherche | **Indice : VERT, 19 mars** (Énigme 10) |
| D12 | Transcription de l'essai 19/03 | Secteur Ouest | Le compte-rendu minute par minute jusqu'à 03:45 |
| D13 | Journal d'Achard (dernières pages) | Bureau Directeur | « Je n'ai pas peur de mourir. J'ai peur d'être mal perçu. » |
| D14 | Lettre d'Hélène à Camille (jamais envoyée) | Bureau Directeur, coffre | Cœur émotionnel du jeu |
| D15 | Procédure de scellement du site | Hub, console finale | Explique la porte blindée et le compte à rebours |
| D16 | Registre du Poste de sécurité | Poste de sécurité, Secteur Ouest (optionnel) | « Fusil et incendiaires sous scellés depuis l'incident. Accès agent uniquement. » — justifie le fusil à pompe et les Molotov (`03-combat-et-bestiaire.md` §9) |

> **Note de production :** D14 est le seul document optionnel *à ne pas manquer* (placé dans le coffre du Badge Bleu). D16 est le seul document **entièrement facultatif** : il n'existe que si le joueur trouve le Poste de sécurité, et son absence ne prive d'aucune information nécessaire à la progression.

---

## 9. Fin

À l'ouverture de la porte blindée, Camille remonte un escalier de service et sort dans un champ, à l'aube. Derrière elle, la maison. Le compteur électrique de la maison, qu'elle avait trouvé mort en arrivant, **tourne**.

Plan fixe. Puis, hors champ, le bruit d'une horloge comtoise qui sonne. Il est 03:45.

**Fin B (si les 16 documents sont trouvés) :** avant l'écran-titre, une carte postale s'affiche — l'écriture d'Hélène, datée de la semaine dernière. Le jeu ne dit pas d'où elle vient.

> **Position de design :** pas de « boss final surprise », pas de révélation qui invalide les 2 heures précédentes. L'inquiétude finale doit être **une conséquence logique** de la règle d'ancrage posée dès l'Acte I. Le joueur doit pouvoir se dire « j'aurais pu le déduire », jamais « on m'a menti ».

---

## 10. Charte d'écriture

- **Registre administratif** pour tout ce qui vient du CEP-V : sigles, numéros de formulaire, tampons. Jamais d'adjectif d'horreur dans un document officiel.
- **Registre manuscrit** pour les personnages : ratures, abréviations, familiarité.
- **Jamais d'exposition orale.** Aucun PNJ vivant ne parle au joueur. Toute l'information est écrite, entendue à la radio, ou déduite de l'espace.
- **Le mot « ancrage » n'apparaît qu'au document D04**, soit à la fin de l'Acte I. Avant, le joueur ne dispose que de symptômes.
- **Longueur maximale d'un document : 12 lignes.** Un mur de texte dans un survival horror n'est pas lu.
