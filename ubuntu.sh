###
# Module d'installation et de configuration d'un serveur Ubuntu
# ==============================================================================
# OLIX_MODULE_UBUNTU_CONFIG : Emplacement du fichier de configuration des paramètres
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="ubuntu"

OLIX_MODULE_UBUNTU_VERSION_RELEASE=$(lsb_release -sr)



###
# Usage de la commande
##
olixmod_usage()
{
    logger_debug "module_ubuntu__olixmod_usage ()"
    stdout_printVersion
    echo
    echo -e "Installation, configuration et gestion d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID}"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}[ACTION]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du bundle"
    echo -e "${Cjaune} install ${CVOID}  : Installation d'un package"
    echo -e "${Cjaune} config  ${CVOID}  : Installation des fichiers de configuration d'un package"
    echo -e "${Cjaune} update  ${CVOID}  : Mise à jour du système"
    echo -e "${Cjaune} savecfg ${CVOID}  : Sauvegarde de la configuration actuelle"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
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

    if ! type "ubuntu_action__$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi

    # Librairies necessaires
    source lib/stdin.lib.sh
    source lib/system.lib.sh
    source lib/filesystem.lib.sh
    source lib/file.lib.sh
    source modules/ubuntu/lib.sh

    logger_debug "module_ubuntu VERSION_RELEASE=${OLIX_MODULE_UBUNTU_VERSION_RELEASE}"
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME} version ${OLIX_MODULE_UBUNTU_VERSION_RELEASE}"
    shift
    ubuntu_action__$ACTION $@
}


###
# Initialisation du module en créant le fichier de configuration
##
function ubuntu_action__init()
{
    logger_debug "ubuntu_action__init ($@)"

    source modules/ubuntu/ubuntu-init.sh
    ubuntu_init__main $@

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Installation des différents services
##
function ubuntu_action__install()
{
    logger_debug "ubuntu_action__install ($@)"

    source modules/ubuntu/ubuntu-install.sh
    ubuntu_install__main $@

    [[ $? -eq 0 ]] && echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Configuration des différents services
##
function ubuntu_action__config()
{
    logger_debug "ubuntu_action__config ($@)"

    source modules/ubuntu/ubuntu-config.sh
    ubuntu_config__main $@

    [[ $? -eq 0 ]] && echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Mise à jour du système
##
function ubuntu_action__update()
{
    logger_debug "ubuntu_action__update ($@)"

    echo -e "${CBLANC}Mise à jour du serveur Ubuntu${CVOID}"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

    module_ubuntu_executeService main apt-update

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}
