###
# Module d'installation et de configuration d'un serveur Ubuntu
# ==============================================================================
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

    # Librairies necessaires
    source lib/stdin.lib.sh
    source lib/system.lib.sh
    source lib/filesystem.lib.sh

    logger_debug "module_ubuntu VERSION_RELEASE=${OLIX_MODULE_UBUNTU_VERSION_RELEASE}"
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME} version ${OLIX_MODULE_UBUNTU_VERSION_RELEASE}"
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


###
# Mise à jour du système
## 
olixmod__update()
{
    logger_debug "module_ubuntu__olixmod__update ($@)"

    echo -e "${CBLANC}Mise à jour du serveur Ubuntu${CVOID}"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

    source modules/ubuntu/${OLIX_MODULE_UBUNTU_VERSION_RELEASE}/apt-update.inc.sh
    ubuntu_include_main $@

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}