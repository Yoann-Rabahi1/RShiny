# Interface RShiny : Consommation d'Électricité et de Gaz en France

## Description

Cette application interactive a été développée avec **RShiny** pour visualiser et explorer les données de consommation d’électricité et de gaz en France. L’objectif est de fournir une analyse intuitive et des graphiques dynamiques permettant de mieux comprendre les tendances énergétiques.

👉 [Accéder à l’application](https://yoannrabahi.shinyapps.io/appshiny/)

---

## Fonctionnalités principales

### 1. Exploration des données
- Affichage des consommations d’électricité et de gaz par région ou par période.
- Analyse des tendances énergétiques grâce à des visualisations interactives.

### 2. Filtrage intuitif
- Filtres personnalisés pour ajuster les graphiques selon les critères (type d'énergie, période, etc.).
- Outils permettant de comparer les consommations régionales.

### 3. Visualisations dynamiques
- Graphiques interactifs basés sur les données, conçus avec **ggplot2**.
- Cartes et tableaux qui permettent une visualisation simple et claire des informations clés.

---

## Méthodologie

L'application repose sur des données issues d'un fichier CSV contenant des informations détaillées sur la consommation énergétique en France. Voici les principales étapes de traitement :
- Importation et préparation des données via **Dplyr**.
- Création des graphiques avec **ggplot2**
- Intégration dans une interface développée avec **RShiny**.
---

## Technologies utilisées

- **RShiny** : Framework pour le développement de l’application web interactive.
- **Dplyr** : Manipulation des données pour le filtrage et l’agrégation.
- **ggplot2** : Visualisation avancée des données.

---

## Résultats et impact

Cette interface permet :
- Une meilleure compréhension des consommations énergétiques en France.
- Une analyse claire et interactive pour identifier les tendances importantes.
- Un outil d’aide à la prise de décision basé sur les données.

---

## Instructions d'installation (optionnel)

1. **Prérequis** :
   - Installer **R** et **RStudio**.
   - Ajouter les packages nécessaires : `shiny`, `dplyr`, `ggplot2`, `DT`, `shinyWidgets`.
2. **Exécution locale** :
   - Importer le projet dans RStudio.
   - Lancer le fichier `app.R` pour exécuter l'application localement.

---


### Liens utiles
- RShiny Documentation : [shiny.rstudio.com](https://shiny.rstudio.com/)
- Dplyr Documentation : [dplyr.tidyverse.org](https://dplyr.tidyverse.org/)
- ggplot2 Documentation : [ggplot2.tidyverse.org](https://ggplot2.tidyverse.org/)
