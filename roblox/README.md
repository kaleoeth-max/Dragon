# Kirasa pour Roblox (low poly)

Kirasa est construite avec environ 340 pièces Roblox (Parts et WedgeParts) : pas de mesh à importer.
Elle est animée : **repos**, **marche**, **décollage**, **vol** (battements et vol plané), **atterrissage**.
Au repos, elle fait des actions au hasard : **rugir** (elle ouvre la gueule), **s'étirer** (avec un bâillement), **regarder autour d'elle**, **secouer la tête**.

![Aperçu : rugissement, marche, décollage, vol, atterrissage](apercu.png)

Le bloc jaune sur l'aperçu a la taille d'un avatar Roblox (5 studs).

![Gros plan](apercu-detail.png)

## Installation (Roblox Studio sur ordinateur)

1. Ouvre ton jeu dans **Roblox Studio**.
2. Menu **Affichage** (View), puis **Barre de commande** (Command Bar).
3. Copie tout le contenu de [`KirasaBuilder.lua`](KirasaBuilder.lua), colle-le dans la barre de commande, puis appuie sur **Entrée**.
4. Kirasa apparaît devant la caméra. Clique sur **Jouer** (Play) pour la voir bouger. Avec **Exécuter** (Run), elle reste immobile, car les animations sont calculées chez le joueur.

## Réglages

Sélectionne le modèle `Kirasa` dans l'Explorer, puis change ses **attributs** dans les Propriétés :

| Attribut | Rôle |
|---|---|
| `AutoWander` | Coché : elle se promène toute seule (pauses, marche, vols). Décoché : elle reste sur place et joue l'animation de `Mode`. |
| `Mode` | `Idle` (repos), `Walk` (marche) ou `Fly` (vol). Elle décolle et atterrit toute seule quand tu passes de l'un à l'autre. |
| `PlayAction` | Écris `Roar`, `Stretch`, `Look` ou `Shake` (pendant le jeu) pour lancer une action quand elle est au repos. |
| `WalkSpeed`, `FlySpeed` | Vitesse de marche et de vol. |
| `WanderRadius` | Distance maximale autour de son point de départ. |
| `FlyHeight` | Hauteur de vol. |

Kirasa mesure environ 25 studs de haut (`SCALE = 2`). Pour un dragon plus grand ou plus petit, change `SCALE` en haut de `KirasaBuilder.lua` avant de le coller.

## Fichiers

- `KirasaBuilder.lua` : le fichier à coller, généré à partir des sources (`python3 make.py`).
- `src/build.lua` : construction du modèle.
- `src/brain.server.lua` : script serveur, il choisit où elle va, quand elle vole et quelle action elle fait.
- `src/pose.client.lua` : script client, il calcule les animations chez chaque joueur pour qu'elles soient fluides.
