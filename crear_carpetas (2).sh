#!/bin/bash

# Define el directorio principal
main_dir="devspaces"

# Crea el directorio principal si no existe
mkdir -p "$main_dir"

# Cambia al directorio principal
cd "$main_dir"

# Crea las subcarpetas de los planetas
mkdir -p "Mercury🚀-Quick_experiments_and_prototypes"
mkdir -p "Venus🎨-Personal_creative_projects"
mkdir -p "Earth🌍-Primary_work_project"
mkdir -p "Mars🔴-Secondary_work_project"
mkdir -p "Jupiter🪐-Large_personal_project"
mkdir -p "Saturn🪐-New_skills_and_courses"
mkdir -p "Pluton👻-git_clones"

# Crea la carpeta para organizaciones de GitHub
mkdir "Orion✨-Github_Organizations"

# Navega a la nueva carpeta
cd "Orion✨-Github_Organizations"

# Crea subcarpetas de ejemplo para las organizaciones
# Modifica estos nombres según tus organizaciones
mkdir "Omarchy📂-Internal_Projects"
mkdir "Omarchy🌐-Open_Source_Repos"


echo "¡Estructura de carpetas actualizada exitosamente!"
