# 📰 Hacker News Flutter App

## 🎯 Objectif

Application Flutter complète avec design Hacker News qui affiche les articles, permet de lire les commentaires (et sous-commentaires) avec navigation fluide, de gérer les favoris persistants et de stocker les articles localement, même si ceux-ci disparaissent de l'API. **Nouveau : Affichage du contenu complet des articles et parsing HTML des commentaires !**

## 🚀 Fonctionnalités principales

- **Affichage dynamique** des articles Hacker News (titre, auteur, nombre de commentaires, score)
- **Navigation fluide** vers la page de détail d'un article
- **Lecture des commentaires** avec scroll global et affichage récursif/arborescent
- **🆕 Contenu complet des articles** : Récupération et affichage du contenu web des articles
- **🆕 Parsing HTML des commentaires** : Affichage formaté avec liens cliquables, gras, italique, code
- **Ouverture des liens** d'articles dans le navigateur avec design attractif
- **Gestion des favoris** : ajout/suppression avec persistance même si l'article disparaît de l'API
- **Page dédiée** pour consulter les favoris
- **Sauvegarde locale** automatique des articles (SQLite)
- **Lecture prioritaire** depuis la base locale pour limiter les appels API
- **Nettoyage automatique** des articles non favoris disparus de l'API
- **Architecture robuste** : MVVM + Repository avec Riverpod
- **Design responsive** : thème Hacker News (rouge foncé, noir, blanc) sans overflow

## ⭐ **Nouvelles fonctionnalités avancées**

### **🆕 Contenu des articles web**

- **Récupération intelligente** : Parsing HTML avec sélecteurs multiples (Open Graph, Twitter Cards, meta tags)
- **Extraction automatique** : Titre, description, image principale, contenu, liens, images
- **Headers réalistes** : Évite les blocages avec User-Agent et headers de navigateur
- **Gestion d'erreurs robuste** : Timeout, retry, fallback vers le texte original
- **URLs relatives** : Résolution automatique vers URLs absolues
- **Nettoyage intelligent** : Suppression des scripts, navigation, commentaires HTML

### **🆕 Parsing HTML des commentaires**

- **Conversion HTML → Markdown** : Liens, gras, italique, code, listes, citations
- **Liens cliquables** : Ouverture dans le navigateur externe avec haptic feedback
- **Formatage visuel** : **Gras**, _italique_, `` `code` ``, `blocs de code`
- **URLs directes** : Détection et ouverture automatique des liens
- **Listes et citations** : Affichage formaté avec puces et indentation
- **Gestion d'erreurs** : Fallback vers le texte original en cas d'échec

### **Gestion d'état avancée**

- **State persistence** : Sauvegarde automatique de l'état entre les sessions
- **Optimistic updates** : Mise à jour immédiate de l'UI pour les favoris
- **Error boundaries** : Gestion robuste des erreurs avec retry

### **Performance et UX**

- **Pagination** : Chargement par pages de 20 articles (évite de charger 500 articles d'un coup)
- **Pull-to-refresh** : Actualisation de la liste avec geste de swipe
- **Skeleton loading** : Animations de chargement élégantes au lieu des spinners
- **Animations fluides** : Transitions entre pages avec CupertinoPageTransitionsBuilder
- **Haptic feedback** : Retour tactile sur les actions importantes
- **Cache d'images** : Chargement optimisé avec CachedNetworkImage

### **Interface utilisateur**

- **Tri intelligent** : Par score, date, nombre de commentaires
- **Navigation intuitive** : Boutons de tri et favoris dans l'AppBar
- **Design moderne** : Cards avec bordures arrondies et ombres
- **Responsive design** : S'adapte à toutes les tailles d'écran

## 🎨 Design & UX

- **Thème Hacker News** : Rouge foncé (#8B0000), noir, blanc
- **Interface moderne** : Cards avec bordures arrondies et ombres
- **Navigation intuitive** : Boutons et icônes cohérents
- **Responsive design** : S'adapte à toutes les tailles d'écran
- **États visuels** : Loading, erreurs, vides avec icônes et messages
- **Commentaires** : Affichage arborescent avec timestamps et formatage HTML
- **Favoris** : Étoiles rouge foncé avec feedback visuel
- **Skeleton loading** : Animations de chargement élégantes
- **Haptic feedback** : Retour tactile sur les interactions

## 🏗️ Architecture

- **MVVM + Repository** : séparation claire des responsabilités
- **Riverpod** : gestion d'état moderne et performante
- **SQLite** : stockage local des articles et favoris
- **API Hacker News** : récupération des données via l'API officielle Firebase
- **🆕 ArticleContentService** : Récupération et parsing du contenu web
- **🆕 HtmlParser** : Conversion HTML vers texte formaté
- **State persistence** : Sauvegarde automatique avec SharedPreferences
- **Optimistic updates** : Mise à jour immédiate de l'UI

## 📦 Packages principaux

- flutter_riverpod
- http
- sqflite
- path_provider
- shared_preferences
- url_launcher
- **🆕 html** : Parsing HTML
- **🆕 cached_network_image** : Cache d'images
- **🆕 webview_flutter** : Affichage web (pour usage futur)

## 📁 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée avec thème et persistance
├── core/
│   └── app_state.dart           # Gestion d'état global avec persistance
├── data/
│   ├── api/
│   │   ├── hacker_news_api.dart # API Hacker News optimisée
│   │   └── article_content_service.dart # 🆕 Service de récupération de contenu web
│   ├── db/
│   │   └── database_helper.dart # SQLite avec pagination et tri
│   └── repositories/
│       └── article_repository.dart # Logique métier avec pagination
├── models/
│   ├── article.dart             # Modèle Article avec sérialisation
│   └── comment.dart             # Modèle Comment avec arborescence
├── utils/
│   └── html_parser.dart         # 🆕 Parser HTML pour commentaires
├── viewmodels/
│   └── article_list_vm.dart     # Gestion des articles avec pagination
├── views/
│   ├── home_page.dart           # Liste des articles + favoris (responsive)
│   ├── article_detail_page.dart # Détail + commentaires + contenu web
│   ├── comment_detail_page.dart # Page de détail des commentaires
│   └── favorites_page.dart      # Page des favoris (cohérente)
└── widgets/
    ├── article_content_view.dart # 🆕 Affichage du contenu des articles
    ├── comment_tree.dart        # Affichage récursif des commentaires
    ├── formatted_text.dart      # 🆕 Widget de texte formaté avec HTML
    └── skeleton_loading.dart    # Animations de chargement élégantes
```

## ⚡ Installation et lancement

1. Clone le repository
2. Lance `flutter pub get`
3. Lance l'application : `flutter run`
4. **Note** : Si tu as déjà lancé une ancienne version, désinstalle l'app pour réinitialiser la base locale

## ✅ Statut final

- ✅ **Toutes les fonctionnalités** demandées sont implémentées et testées
- ✅ **🆕 Contenu des articles** : Récupération et affichage complet du contenu web
- ✅ **🆕 Parsing HTML** : Commentaires formatés avec liens cliquables
- ✅ **Code propre** : pas de TODO, imports nettoyés, gestion d'erreurs
- ✅ **Performance optimisée** : pagination, cache local, appels API parallélisés
- ✅ **UX fluide** : navigation, pull-to-refresh, skeleton loading, haptic feedback
- ✅ **Design moderne** : thème Hacker News cohérent et attractif
- ✅ **Responsive** : pas d'overflow, s'adapte à tous les écrans
- ✅ **Robustesse** : gestion des erreurs, persistance d'état, optimistic updates
- ✅ **Prêt pour production** ou soutenance

## 🎉 Fonctionnalités validées

- Affichage de la liste des articles avec métadonnées (auteur, score, commentaires)
- Navigation vers le détail d'un article avec design card moderne
- **🆕 Contenu complet des articles** : Titre, description, image, contenu, liens, images
- **🆕 Parsing HTML des commentaires** : Liens cliquables, gras, italique, code, listes
- Lecture complète des commentaires avec scroll global et hiérarchie visuelle
- Ouverture des liens d'articles dans le navigateur avec design attractif
- Ajout/suppression d'articles favoris avec feedback visuel et haptic
- Persistance des favoris même si l'article disparaît de l'API
- Sauvegarde locale automatique des articles
- Nettoyage automatique des articles obsolètes non favoris
- Interface responsive sans overflow sur tous les écrans
- **Pagination** : Chargement par pages de 20 articles
- **Pull-to-refresh** : Actualisation avec geste de swipe
- **Skeleton loading** : Animations de chargement élégantes
- **Tri intelligent** : Par score, date, nombre de commentaires
- **State persistence** : Sauvegarde automatique de l'état
- **Optimistic updates** : Mise à jour immédiate de l'UI
- **Haptic feedback** : Retour tactile sur les interactions

## 🎨 Palette de couleurs

- **Rouge foncé Hacker News** : #8B0000 (actions principales, accents)
- **Noir** : #000000 (arrière-plan principal)
- **Gris sombre** : #1A1A1A (cards, conteneurs)
- **Blanc** : #FFFFFF (texte principal)
- **Blanc 70%** : #FFFFFF avec 0.7 opacity (texte secondaire)

## 🔧 Améliorations techniques implémentées

### **🆕 Récupération de contenu web**

- **Sélecteurs intelligents** : Open Graph, Twitter Cards, meta tags, classes communes
- **Headers réalistes** : User-Agent, Accept, Accept-Language pour éviter les blocages
- **Parsing robuste** : Gestion des erreurs, timeout, fallback
- **Nettoyage automatique** : Suppression scripts, navigation, commentaires HTML
- **URLs relatives** : Résolution automatique vers URLs absolues

### **🆕 Parsing HTML des commentaires**

- **Conversion HTML → Markdown** : Liens, gras, italique, code, listes, citations
- **Liens cliquables** : Ouverture dans le navigateur avec haptic feedback
- **Formatage visuel** : **Gras**, _italique_, `` `code` ``, `blocs de code`
- **URLs directes** : Détection et ouverture automatique
- **Gestion d'erreurs** : Fallback vers le texte original

### **Performance**

- Pagination pour éviter le chargement de 500 articles
- Cache local avec SQLite
- Appels API optimisés avec Future.wait
- Skeleton loading pour une UX fluide
- **🆕 Cache d'images** avec CachedNetworkImage

### **UX/UI**

- Pull-to-refresh pour actualiser la liste
- Haptic feedback sur les interactions
- Animations de transition fluides
- Tri intelligent des articles
- Design responsive et moderne
- **🆕 États de chargement** pour le contenu web

### **Robustesse**

- Gestion d'erreurs avec retry
- State persistence entre sessions
- Optimistic updates pour les favoris
- Validation des données
- **🆕 Timeout et fallback** pour la récupération de contenu

## 🚀 Exemples de fonctionnalités

### **Contenu d'article récupéré :**

```dart
ArticleContent(
  title: "Titre de l'article",
  description: "Description de l'article",
  mainImage: "https://example.com/image.jpg",
  content: "Contenu principal de l'article...",
  images: ["https://example.com/image.jpg", "https://example.com/image2.jpg"],
  links: ["https://example.com/link1", "https://example.com/link2"],
  url: "https://example.com/article"
)
```

### **Commentaire HTML parsé :**

```html
<!-- HTML original -->
<p>
  Voici un <a href="https://example.com">lien</a> et du <strong>gras</strong>.
</p>

<!-- Texte formaté -->
Voici un [lien](https://example.com) et du **gras**.
```

---

**Application complète, moderne et professionnelle avec contenu web et parsing HTML, prête pour la livraison !** 🚀
