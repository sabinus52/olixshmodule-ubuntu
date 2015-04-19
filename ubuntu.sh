###
# Module d'installation et de configuration d'un serveur Ubuntu
# ==============================================================================
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="ubuntu"


###
# Librairies necessaires
##
source lib/stdin.lib.sh
source lib/system.lib.sh
source lib/filesystem.lib.sh



###
# Usage de la commande
##
olixmod_usage()
{
    logger_debug "module_ubuntu__olixmod_usage ()"
    stdout_printVersion
    echo
    echo -e "Installation, configuration et gestion d'un serveur Ubuntu"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}[ACTION]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du bundle"
    echo -e "${Cjaune} install ${CVOID}  : Installation d'un package"
    echo -e "${Cjaune} config  ${CVOID}  : Installation des fichiers de configuration d'un package"
    echo -e "${Cjaune} update  ${CVOID}  : Mise à jour du système"
    echo -e "${Cjaune} savecfg ${CVOID}  : Sauvegarde de la configuration actuelle"
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_ubuntu__olixmod_list ($@)"
    echo
}


###
# Function principale
##
olixmod_main()
{
    logger_debug "module_ubuntu__olixmod_main ($@)"
    local ACTION=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixmod_usage && core_exit 1
    [[ "$1" == "help" ]] && olixmod_usage && core_exit 0

    if ! type "olixmod__$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi

    shift
    olixmod__$ACTION $@
}


###
# Initialisation du module en créant le fichier de configuration
##
olixmod__init()
{
    logger_debug "module_ubuntu__olixmod__init ($@)"

    source modules/ubuntu/ubuntu-init.sh
    olixmod_ubuntu_init $@

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}