# Hacker News Flutter App

## Objectif

Ce projet consiste à développer une application mobile Flutter inspirée de la plateforme Hacker News. L'application permet d'afficher une liste d'articles, de consulter leur contenu, de lire les commentaires et sous-commentaires, et de gérer une liste de favoris. Elle met en œuvre des fonctionnalités avancées telles que la persistance locale des données et une navigation fluide et responsive.

## Fonctionnalités principales

- Affichage dynamique des articles avec titre, auteur, nombre de commentaires et score.
- Navigation vers la page de détail d’un article.
- Lecture complète des commentaires avec affichage hiérarchique et navigation fluide.
- Possibilité d’ajouter ou de retirer des articles des favoris avec persistance locale.
- Page dédiée aux articles favoris.
- Sauvegarde locale des articles en base SQLite.
- Priorisation des lectures depuis la base locale pour optimiser les appels à l’API.
- Architecture robuste basée sur le modèle MVVM et le pattern Repository avec Riverpod.
- Interface responsive et moderne adaptée à tous les formats d'écran.

## Fonctionnalités avancées

### Affichage du contenu des articles

- Extraction automatisée du titre, de la description, de l’image principale, du contenu textuel et des liens d’un article.
- Mise en forme soignée avec résolutions automatiques des URLs et nettoyage des éléments inutiles.
- Gestion robuste des erreurs réseau (timeout, retry) avec solutions de repli.
- Utilisation d’en-têtes HTTP réalistes pour améliorer la compatibilité avec les serveurs distants.

### Traitement et affichage des commentaires HTML

- Conversion HTML vers un format texte enrichi (liens cliquables, gras, italique, blocs de code).
- Affichage formaté et lisible des sous-commentaires.
- Prise en charge des listes, citations, et structures imbriquées.
- Gestion d’erreurs avec retour au texte brut en cas d’échec de parsing.

## Gestion de l’état

- Persistance automatique de l’état entre les sessions.
- Mise à jour optimiste de l’interface pour une meilleure réactivité.
- Gestion robuste des erreurs dans la logique applicative.

## Expérience utilisateur et performance

- Chargement paginé des articles (par blocs de 20) pour éviter les surcharges mémoire.
- Actualisation par geste (pull-to-refresh).
- Animations fluides (skeleton loading, transitions entre pages).
- Mise en cache des images pour un chargement optimisé.
- Retour tactile sur certaines actions utilisateur (haptic feedback).
- Interface moderne avec tri par date, score ou nombre de commentaires.

## Architecture logicielle

- Architecture MVVM avec séparation claire des responsabilités.
- Utilisation de Riverpod pour la gestion d'état.
- Persistance locale avec SQLite.
- Intégration de l’API officielle Hacker News via Firebase.
- Services spécifiques pour la récupération du contenu web et le traitement HTML.
- Mise en cache et gestion de l’état avec SharedPreferences.

## Packages utilisés

- `flutter_riverpod`
- `http`
- `sqflite`
- `path_provider`
- `shared_preferences`
- `url_launcher`
- `html`
- `cached_network_image`

## Organisation du projet

```
lib/
├── main.dart                    # Point d'entrée avec thème et persistance
├── core/
│   └── app_state.dart           # Gestion d'état global avec persistance
├── data/
│   ├── api/
│   │   ├── hacker_news_api.dart # API Hacker News optimisée
│   │   └── article_content_service.dart #  Service de récupération de contenu web
│   ├── db/
│   │   └── database_helper.dart # SQLite avec pagination et tri
│   └── repositories/
│       └── article_repository.dart # Logique métier avec pagination
├── models/
│   ├── article.dart             # Modèle Article avec sérialisation
│   └── comment.dart             # Modèle Comment avec arborescence
├── utils/
│   └── html_parser.dart         #  Parser HTML pour commentaires
├── viewmodels/
│   └── article_list_vm.dart     # Gestion des articles avec pagination
├── views/
│   ├── home_page.dart           # Liste des articles + favoris (responsive)
│   ├── article_detail_page.dart # Détail + commentaires + contenu web
│   ├── comment_detail_page.dart # Page de détail des commentaires
│   └── favorites_page.dart      # Page des favoris (cohérente)
└── widgets/
    ├── article_content_view.dart #  Affichage du contenu des articles
    ├── comment_tree.dart        # Affichage récursif des commentaires
    ├── formatted_text.dart      #  Widget de texte formaté avec HTML
    └── skeleton_loading.dart    # Animations de chargement élégantes
```


## Installation

1. Cloner le dépôt.
2. Exécuter `flutter pub get` pour récupérer les dépendances.
3. Lancer l’application avec `flutter run`.
4. Aucune configuration manuelle supplémentaire n’est requise : la base de données locale est automatiquement gérée.

## État du projet

Toutes les fonctionnalités spécifiées ont été implémentées et validées :

- Interface fonctionnelle et responsive.
- Sauvegarde et chargement locaux des données.
- Gestion des favoris avec persistance.
- Consultation du contenu enrichi des articles.
- Lecture des commentaires avec mise en forme avancée.
- Architecture modulaire et robuste.
- Code propre et bien structuré, sans dépendances inutiles.

## Améliorations techniques

- Gestion automatique des migrations de la base de données.
- Fallback intelligent en cas de problème lors de la récupération des contenus.
- Chargement optimisé grâce au cache local et à la pagination.
- Nettoyage du code : suppression des imports et variables non utilisés.
- Logs de débogage limités à `debugPrint` pour les erreurs majeures.

## Palette de couleurs

| Élément            | Couleur       | Description                        |
|--------------------|---------------|------------------------------------|
| Accent principal   | #8B0000       | Rouge Hacker News                  |
| Fond principal     | #000000       | Noir                               |
| Conteneurs         | #1A1A1A       | Gris sombre                        |
| Texte principal    | #FFFFFF       | Blanc pur                          |
| Texte secondaire   | #FFFFFF (70%) | Blanc semi-transparent             |
