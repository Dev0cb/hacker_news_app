# 📰 Hacker News Flutter App

## 🎯 Objectif

Application Flutter complète avec design Hacker News qui affiche les articles, permet de lire les commentaires (et sous-commentaires) avec navigation fluide, de gérer les favoris persistants et de stocker les articles localement, même si ceux-ci disparaissent de l'API.

## 🚀 Fonctionnalités principales

- **Affichage dynamique** des articles Hacker News (titre, auteur, nombre de commentaires, score)
- **Navigation fluide** vers la page de détail d'un article
- **Lecture des commentaires** avec scroll global et affichage récursif/arborescent
- **Ouverture des liens** d'articles dans le navigateur avec design attractif
- **Gestion des favoris** : ajout/suppression avec persistance même si l'article disparaît de l'API
- **Page dédiée** pour consulter les favoris
- **Sauvegarde locale** automatique des articles (SQLite)
- **Lecture prioritaire** depuis la base locale pour limiter les appels API
- **Nettoyage automatique** des articles non favoris disparus de l'API
- **Architecture robuste** : MVVM + Repository avec Riverpod
- **Design responsive** : thème Hacker News (orange, noir, blanc) sans overflow

## 🎨 Design & UX

- **Thème Hacker News** : Orange (#FF6600), noir, blanc
- **Interface moderne** : Cards avec bordures arrondies et ombres
- **Navigation intuitive** : Boutons et icônes cohérents
- **Responsive design** : S'adapte à toutes les tailles d'écran
- **États visuels** : Loading, erreurs, vides avec icônes et messages
- **Commentaires** : Affichage arborescent avec timestamps
- **Favoris** : Étoiles orange avec feedback visuel

## 🏗️ Architecture

- **MVVM + Repository** : séparation claire des responsabilités
- **Riverpod** : gestion d'état moderne et performante
- **SQLite** : stockage local des articles et favoris
- **API Hacker News** : récupération des données via l'API officielle Firebase

## 📦 Packages principaux

- flutter_riverpod
- http
- sqflite
- path_provider
- shared_preferences
- url_launcher

## 📁 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée avec thème Hacker News
├── core/                        # Prêt pour futures extensions
├── data/
│   ├── api/
│   │   └── hacker_news_api.dart # API Hacker News optimisée
│   ├── db/
│   │   └── database_helper.dart # SQLite avec gestion des favoris
│   └── repositories/
│       └── article_repository.dart # Logique métier
├── models/
│   ├── article.dart             # Modèle Article avec sérialisation
│   └── comment.dart             # Modèle Comment avec arborescence
├── viewmodels/
│   ├── article_list_vm.dart     # Gestion des articles
│   └── favorites_vm.dart        # Gestion des favoris
├── views/
│   ├── home_page.dart           # Liste des articles + favoris (responsive)
│   ├── article_detail_page.dart # Détail + commentaires (design moderne)
│   └── favorites_page.dart      # Page des favoris (cohérente)
└── widgets/
    └── comment_tree.dart        # Affichage récursif des commentaires (arborescent)
```

## ⚡ Installation et lancement

1. Clone le repository
2. Lance `flutter pub get`
3. Lance l'application : `flutter run`
4. **Note** : Si tu as déjà lancé une ancienne version, désinstalle l'app pour réinitialiser la base locale

## ✅ Statut final

- ✅ **Toutes les fonctionnalités** demandées sont implémentées et testées
- ✅ **Code propre** : pas de TODO, imports nettoyés, gestion d'erreurs
- ✅ **Performance optimisée** : appels API parallélisés, cache local
- ✅ **UX fluide** : navigation, scroll des commentaires, gestion des favoris
- ✅ **Design moderne** : thème Hacker News cohérent et attractif
- ✅ **Responsive** : pas d'overflow, s'adapte à tous les écrans
- ✅ **Robustesse** : gestion des erreurs, logs de debug, persistance des données
- ✅ **Prêt pour production** ou soutenance

## 🎉 Fonctionnalités validées

- Affichage de la liste des articles avec métadonnées (auteur, score, commentaires)
- Navigation vers le détail d'un article avec design card moderne
- Lecture complète des commentaires avec scroll global et hiérarchie visuelle
- Ouverture des liens d'articles dans le navigateur avec design attractif
- Ajout/suppression d'articles favoris avec feedback visuel
- Persistance des favoris même si l'article disparaît de l'API
- Sauvegarde locale automatique des articles
- Nettoyage automatique des articles obsolètes non favoris
- Interface responsive sans overflow sur tous les écrans

## 🎨 Palette de couleurs

- **Orange Hacker News** : #FF6600 (actions principales, accents)
- **Noir** : #000000 (arrière-plan principal)
- **Gris sombre** : #1A1A1A (cards, conteneurs)
- **Blanc** : #FFFFFF (texte principal)
- **Blanc 70%** : #FFFFFF avec 0.7 opacity (texte secondaire)

---

**Application complète, moderne et professionnelle, prête pour la livraison !** 🚀
