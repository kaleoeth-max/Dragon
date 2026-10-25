# Kirasa pour Roblox (low poly)

Kirasa est construite uniquement avec des pièces Roblox (Parts et WedgeParts) : pas de mesh à importer.
Elle est animée par un script : **repos**, **marche** et **vol**.

![Aperçu : repos, marche, vol](apercu.png)

Le bloc jaune sur l'aperçu a la taille d'un avatar Roblox (5 studs).

## Installation (Roblox Studio sur ordinateur)

1. Ouvre ton jeu dans **Roblox Studio**.
2. Menu **Affichage** (View), puis **Barre de commande** (Command Bar).
3. Copie tout le contenu de [`KirasaBuilder.lua`](KirasaBuilder.lua), colle-le dans la barre de commande, puis appuie sur **Entrée**.
4. Kirasa apparaît devant la caméra. Clique sur **Jouer** (Play) pour la voir bouger.

## Réglages

Sélectionne le modèle `Kirasa` dans l'Explorer, puis change ses **attributs** dans les Propriétés :

| Attribut | Rôle |
|---|---|
| `AutoWander` | Coché : elle se promène toute seule (pauses, marche, vols). Décoché : elle reste sur place et joue l'animation de `Mode`. |
| `Mode` | `Idle` (repos), `Walk` (marche) ou `Fly` (vol). |
| `WalkSpeed`, `FlySpeed` | Vitesse de marche et de vol. |
| `WanderRadius` | Distance maximale autour de son point de départ. |
| `FlyHeight` | Hauteur de vol. |

Kirasa mesure environ 20 studs de haut (`SCALE = 2`). Pour un dragon plus grand ou plus petit, change `SCALE` en haut de `KirasaBuilder.lua` avant de le coller.

## Fichiers

- `KirasaBuilder.lua` : le fichier à coller, généré à partir des sources (`python3 make.py`).
- `src/build.lua` : construction du modèle.
- `src/animate.server.lua` : animations et promenade.
