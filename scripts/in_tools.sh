#!/bin/bash

# Fichier installation des outils sous opensuse


echo "======================================================="
echo "INSTALLATION DES OUTILS"
echo "======================================================="

# Installation de VSCode
log "INFO" "Installation de VSCode"
if sudo zypper in code; then
    log "SUCCESS" "Installation de VSCode réussie"
else 
    log "ERROR" "Installation échoué"
fi

# Installation de Godot
log "INFO" "Installation de Godot"
if sudo zypper in godot; then 
    log "SUCCESS" "Installation de Godot réussie"
else 
    log "ERROR" "Installation de Godot échoué"
fi

echo "INSTALLATIONS FINITS"