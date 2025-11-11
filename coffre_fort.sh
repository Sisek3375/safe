#!/bin/bash

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root (utilisez sudo)."
    exit 1
fi

FILE=data-crypt
DEFAULT_SIZE="5G"

# Fonction pour la création du coffre
function creation_coffre() {

read -p "Entrez la taille de l'environnement (par défaut ${DEFAULT_SIZE}) : " SIZE
SIZE=${SIZE:-$DEFAULT_SIZE}

echo "Création du fichier de $SIZE..."
fallocate -l $SIZE $FILE

echo "Configuration avec LUKS..."
sudo cryptsetup luksFormat $FILE

echo "Ouverture de $FILE..."
sudo cryptsetup open $FILE data_crypt

echo "Formatage en ext4..."
mkfs.ext4 /dev/mapper/data_crypt

echo "Montage du point..."
mkdir -p "/mnt/data_crypt"
mount "/dev/mapper/data_crypt" "/mnt/data_crypt"

}

# Fonction pour l'ouverture du coffre
function ouverture_coffre() {

echo "Ouverture du périphérique LUKS..."
sudo cryptsetup open "$FILE" "data_crypt"

echo "Montage du point..."
mkdir -p "/mnt/data_crypt"
mount "/dev/mapper/data_crypt" "/mnt/data_crypt"

}

# Fonction pour la fermeture du coffre
function fermeture_coffre() {

echo "Démontage du coffre..."
umount "/mnt/data_crypt"

echo "Fermeture du périphérique LUKS..."
sudo cryptsetup close data_crypt

}

# Fonction d'aide
function usage() {
    echo "Usage : $0 [OPTION]"
    echo "Options :"
    echo "  --create    Créer un nouveau coffre chiffré"
    echo "  --open      Ouvrir un coffre existant"
    echo "  --close     Fermer un coffre ouvert"
    echo "  --help      Afficher cette aide"
}

# Analyse des flags
case "$1" in
    --create)
        creation_coffre
        ;;
    --open)
        ouverture_coffre
        ;;
    --close)
        fermeture_coffre
        ;;
    --help)
        usage
        ;;
    *)
esac
