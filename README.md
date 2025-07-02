# 📰 Hacker News Flutter App

## 🎯 Objectif

Application Flutter qui affiche les articles de Hacker News, permet de lire les commentaires (et sous-commentaires), de gérer les favoris et de stocker les articles localement, même si ceux-ci disparaissent de l'API.

## 🚀 Fonctionnalités principales

- Affichage dynamique des articles Hacker News (titre, auteur, nombre de commentaires)
- Navigation vers la page de détail d'un article
- Affichage récursif/arborescent des commentaires et sous-commentaires
- Ouverture du lien de l'article dans le navigateur
- Ajout/suppression d'articles favoris (persistants même si l'article disparaît de l'API)
- Page dédiée pour consulter les favoris
- Sauvegarde locale automatique des articles (SQLite)
- Lecture prioritaire depuis la base locale pour limiter les appels API
- Suppression automatique des articles non favoris disparus de l'API
- Architecture MVVM + Repository, gestion d'état avec Riverpod

## 🏗️ Architecture

- **MVVM + Repository** : séparation claire des responsabilités
- **Riverpod** : gestion d'état moderne et performante
- **SQLite** : stockage local des articles et favoris
- **API** : récupération des données via l'API officielle Hacker News Firebase

## 📦 Packages principaux

- flutter_riverpod
- http
- sqflite
- path_provider
- shared_preferences
- url_launcher

## 📁 Structure du dossier `lib/`

```
lib/
├── main.dart
├── core/
├── data/
│   ├── api/
│   │   └── hacker_news_api.dart
│   ├── db/
│   │   └── database_helper.dart
│   └── repositories/
│       └── article_repository.dart
├── models/
│   ├── article.dart
│   └── comment.dart
├── viewmodels/
│   ├── article_list_vm.dart
│   └── favorites_vm.dart
├── views/
│   ├── home_page.dart
│   ├── article_detail_page.dart
│   └── favorites_page.dart
└── widgets/
    └── comment_tree.dart
```

## ⚡ Installation rapide

1. Clone le repo
2. Lance `flutter pub get`
3. Lance l'application sur un émulateur ou un appareil réel
4. (Si tu as déjà lancé une ancienne version, désinstalle l'app pour réinitialiser la base locale)

## ✅ Statut

- Toutes les fonctionnalités demandées sont implémentées et testées.
- Code propre, modulaire, prêt pour la production ou la soutenance.

---

Pour toute question, suggestion ou amélioration, n'hésite pas à demander !
