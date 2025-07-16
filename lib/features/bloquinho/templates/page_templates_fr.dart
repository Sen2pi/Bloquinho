/*
 * Copyright (c) 2025 Karim Hussen Patatas Hassam dos Santos
 * 
 * This file is part of Bloquinho.
 * 
 * Licensed under CC BY-NC-SA 4.0
 * Commercial use prohibited without permission.
 */

class PageTemplatesFr {
  static const String rootPageTemplate = '''# 📊 Document Markdown Complet avec Toutes les Fonctionnalités

## 🎨 Démonstration de Couleurs et Formatage

Ce document illustre **toutes les principales fonctionnalités** du Markdown, incluant <span style="color:red; background-color:#ffeeee; padding:2px 5px; border-radius:3px">**couleurs personnalisées**</span> et formatage avancé

### Exemples de Texte <span style="background-color:#0000FF; color:#FFFFFF">Coloré</span>

Voici différents styles de texte :

- <span style="color:red">**Texte rouge en gras**</span>
- <span style="color:blue; font-style:italic">Texte bleu en italique</span>
- <span style="color:white; background-color:green; padding:3px 8px; border-radius:5px">✅ Succès</span>
- <span style="color:white; background-color:red; padding:3px 8px; border-radius:5px">❌ Erreur</span>
- <span style="color:orange; background-color:#fff3cd; padding:3px 8px; border-radius:5px">⚠️ Avertissement</span>


## 📝 Hiérarchie des Titres

# Titre Niveau 1

## Titre Niveau 2

### Titre Niveau 3

#### Titre Niveau 4

##### Titre Niveau 5

###### Titre Niveau 6

### Titres Alternatifs

Titre Principal
===============

Sous-titre
----------

## 💻 Exemples de Code

### Code Python

```python
def calculer_fibonacci(n):
    """Calcule la séquence de Fibonacci jusqu'à n termes"""
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    elif n == 2:
        return [0, 1]
    
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    
    return fib

# Exemple d'utilisation
resultat = calculer_fibonacci(10)
print(f"Fibonacci(10): {resultat}")
```


### Code JavaScript

```javascript
// Classe pour gérer les utilisateurs
class GestionnaireUtilisateur {
    constructor() {
        this.utilisateurs = [];
    }
    
    ajouterUtilisateur(nom, email) {
        const utilisateur = {
            id: Date.now(),
            nom: nom,
            email: email,
            actif: true
        };
        this.utilisateurs.push(utilisateur);
        return utilisateur;
    }
    
    rechercherUtilisateur(id) {
        return this.utilisateurs.find(u => u.id === id);
    }
}

// Utilisation de la classe
const gestionnaire = new GestionnaireUtilisateur();
const nouvelUtilisateur = gestionnaire.ajouterUtilisateur("Pierre", "pierre@email.com");
console.log(nouvelUtilisateur);
```


### Code SQL

```sql
-- Création de table et requêtes avancées
CREATE TABLE ventes (
    id SERIAL PRIMARY KEY,
    produit VARCHAR(100) NOT NULL,
    prix DECIMAL(10,2),
    date_vente DATE,
    vendeur_id INTEGER
);

-- Requête avec agrégations
SELECT 
    vendeur_id,
    COUNT(*) as total_ventes,
    SUM(prix) as recette_totale,
    AVG(prix) as prix_moyen,
    MAX(date_vente) as derniere_vente
FROM ventes 
WHERE date_vente >= '2025-01-01'
GROUP BY vendeur_id
HAVING SUM(prix) > 1000
ORDER BY recette_totale DESC;
```


### Code en Ligne

Pour exécuter le script, utilisez la commande <span style="color:white; background-color:black; padding:2px 5px; border-radius:3px; font-family:monospace">python app.py</span> dans le terminal.

## 🔢 Formules Mathématiques (LaTeX)

### Formules en Ligne

La célèbre équation d'Einstein : \$E = mc^2\$

La formule quadratique : \$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\$

### Formules en Bloc

Intégrale définie :

\$
\\int_a^b f(x) \\, dx = F(b) - F(a)
\$

Sommation :

\$
\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}
\$

### Matrices

\$\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}\$

## 📊 Tableaux Avancés

### Tableau des Ventes Mensuelles

| Mois | Ventes | Objectif | <span style="color:green">%Atteint</span> | Statut |
| :-- | :-- | :-- | :-- | :-- |
| Janvier | €15.000 | €12.000 | <span style="color:green; font-weight:bold">125%</span> | <span style="color:white; background-color:green; padding:2px 6px; border-radius:3px">✅ Dépassé</span> |
| Février | €10.500 | €12.000 | <span style="color:orange; font-weight:bold">87.5%</span> | <span style="color:white; background-color:orange; padding:2px 6px; border-radius:3px">⚠️ En dessous</span> |
| Mars | €14.200 | €12.000 | <span style="color:green; font-weight:bold">118%</span> | <span style="color:white; background-color:green; padding:2px 6px; border-radius:3px">✅ Dépassé</span> |

## 📋 Listes et Tâches

### Liste de Tâches du Projet

- [x] <span style="color:green">**Analyse des exigences**</span> ✅
- [x] <span style="color:green">**Conception de l'interface**</span> ✅
- [ ] <span style="color:orange">**Développement backend**</span> 🔄
    - [x] Configuration de la base de données
    - [x] API d'authentification
    - [ ] API des utilisateurs
    - [ ] API des rapports
- [ ] <span style="color:red">**Tests**</span> ⏳
- [ ] <span style="color:red">**Déploiement**</span> ⏳

## 📈 Diagrammes

### Diagramme de Flux du Processus

```mermaid
graph TD
    A[Début] --> B{Connexion valide?}
    B -->|Oui| C[Tableau de bord]
    B -->|Non| D[Écran d'erreur]
    C --> E{Type d'utilisateur?}
    E -->|Admin| F[Panneau Admin]
    E -->|Utilisateur| G[Panneau Utilisateur]
    F --> H[Rapports]
    G --> I[Profil]
    H --> J[Fin]
    I --> J
    D --> A
```

## 💬 Citations et Mises en Évidence

### Citation Simple

> "La meilleure façon de prédire l'avenir est de le créer."
> — Peter Drucker

### Boîte de Mise en Évidence

<span style="background-color:#e1f5fe; border-left:4px solid #0277bd; padding:10px; display:block; margin:10px 0;">
<strong>💡 Conseil Important:</strong><br>
Toujours sauvegarder vos données avant d'effectuer des mises à jour importantes du système.
</span>

## 🔗 Liens et Références

### Liens de Base

- [Documentation Markdown](https://www.markdownguide.org)
- [Diagrammes Mermaid](https://mermaid.js.org/)
- [Mathématiques LaTeX](https://katex.org/)

## 📝 Paragraphes et Formatage

### Texte avec Formatage Mixte

Ce paragraphe démontre **texte en gras**, *texte en italique*, ***texte en gras et italique***, ~~texte barré~~, et `code en ligne`.

Nous pouvons aussi avoir <span style="color:blue; text-decoration:underline">texte souligné bleu</span>, <span style="background-color:yellow">texte surligné</span>, et <span style="color:red; font-weight:bold">texte rouge en gras</span>.

## 🏁 Conclusion

Ce document démontre la polyvalence et la puissance du Markdown lorsqu'il est combiné avec HTML et d'autres technologies. Avec ces techniques, il est possible de créer une documentation riche, colorée et interactive qui va bien au-delà du texte simple.

<span style="background-color:#e8f5e8; border:1px solid #4caf50; border-radius:5px; padding:15px; display:block; margin:20px 0;">
<strong style="color:#2e7d32;">✅ Document Complet</strong><br>
Cet exemple inclut toutes les principales fonctionnalités du Markdown moderne, servant de référence complète pour la création de documents professionnels.
</span>

*Document créé le ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year} - Guimarães, Portugal* 🇵🇹
''';

  static const String newPageTemplate = '''# Nouvelle Page

## Introduction

Bienvenue sur votre nouvelle page ! Ici vous pouvez commencer à écrire votre contenu.

### Ce que vous pouvez faire :

- Écrire du texte en **gras** et *italique*
- Créer des listes
- Ajouter du code
- Insérer des formules mathématiques
- Créer des tableaux
- Et bien plus encore !

### Exemple de Code

```dart
void main() {
  print('Bonjour, monde !');
}
```

### Liste de Tâches

- [ ] Première tâche
- [ ] Deuxième tâche
- [ ] Troisième tâche

> **Conseil :** Utilisez le menu de formatage pour ajouter plus d'éléments à votre page.
''';

  static String _getMonthName(int month) {
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return months[month];
  }
}