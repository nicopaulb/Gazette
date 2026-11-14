# Déploiement Docker derrière Caddy

L'app (Flutter web) et l'API PocketBase sont servies sur **le même domaine** :
`https://gazette.example.com/` → app, `https://gazette.example.com/api/` → PocketBase.

```
Internet ──HTTPS──> Caddy (hôte) ──> 127.0.0.1:8080  web (Flutter build, caddy statique)
                                 └─> 127.0.0.1:8090  pocketbase (/api uniquement)
```

## 1. Construire et lancer

```bash
cp .env.example .env        # puis mettre la vraie URL dans GAZETTE_URL
docker compose up -d --build
```

Pour un serveur ARM (Raspberry Pi…), le `TARGETARCH` est fourni automatiquement par BuildKit.

## 2. Caddy

Copier le bloc de `docker/Caddyfile.example` dans le Caddyfile de l'hôte, adapter le domaine,
puis `caddy reload`.

Si Caddy tourne lui-même dans Docker, remplacer `127.0.0.1:8090` / `127.0.0.1:8080` par
`pocketbase:8090` / `web:80` et mettre Caddy sur le même réseau Docker que ce compose.

## 3. Configurer PocketBase (via tunnel SSH, le dashboard n'est pas exposé)

```bash
ssh -L 8090:127.0.0.1:8090 user@serveur
```

Puis ouvrir http://localhost:8090/_/ :

1. Créer le compte superuser (lien affiché dans `docker compose logs pocketbase` au premier démarrage).
2. **Settings → Import collections** : coller `pocketbase/pb_schema.json`.
   - Installation **neuve** : décocher **« Merge with existing collections »**. Sinon le champ `avatar` par
     défaut d'un PocketBase neuf est conservé et reste public.
   - Instance **existante** avec l'ancien schéma : faire une sauvegarde, puis importer avec « Merge » coché
     (les données sont conservées).
3. **Settings → Application** :
   - Application URL = `GAZETTE_URL`
   - *User IP proxy headers* : `X-Forwarded-For` (sinon toutes les requêtes semblent venir de Caddy)
   - Activer le **rate limiting** (protège la page de connexion contre le brute force)
4. **Settings → Mail** : configurer un SMTP, ou désactiver *Auth alert* dans la collection `users`.
5. **Settings → Backups** : activer les sauvegardes automatiques (et/ou sauvegarder le volume `pb_data`).
6. Créer les comptes de la famille dans la collection `users` (l'inscription publique est fermée).

## Ce qui a été durci

| Élément | Avant | Après |
|---|---|---|
| Vue `anecdotes_current` | publique sans connexion | admins (`priviliged`) uniquement |
| Vue `editionStats` | publique | utilisateurs connectés |
| Fichiers (photos, avatars, PDF) | accessibles par URL sans connexion | `protected` : token de fichier requis (valide 6 h) |
| Types de fichiers | tous types acceptés pour les anecdotes / SVG pour les avatars | images uniquement ; PDF uniquement pour les éditions |
| Lecture des anecdotes | tout membre voit les anecdotes non publiées des autres | publiées + les siennes (admins : tout) |
| Création | le client pouvait se créer une anecdote déjà publiée | forcée à `published = false`, sans édition |
| Modification | tout membre pouvait modifier ou publier l'anecdote d'un autre | admin, ou l'auteur tant qu'elle n'est pas publiée |
| Suppression | admin seulement (le bouton de l'app échouait pour l'auteur) | admin, ou l'auteur tant qu'elle n'est pas publiée |
| Dashboard `/_/` et login superuser | exposés | bloqués par Caddy, accès via tunnel SSH |
| Ports des conteneurs | — | liés à `127.0.0.1` uniquement |
