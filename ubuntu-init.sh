###
# Initialisation du module pour indiquer ou se trouve le fichier de config
# ==============================================================================
# @package olixsh
# @module ubuntu
# @action init
# @author Olivier <sabinus52@gmail.com>
##

function ubuntu_init__main()
{
    logger_debug "ubuntu_init__main ($@)"

    local FORCE=false
    while [[ $# -ge 1 ]]; do
        case $1 in
            --force|-f) FORCE=true;;
        esac
        shift
    done

    local FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})

    # Test si la configuration existe
    logger_info "Test si la configuration est déjà effectuée"
    if config_isModuleExist ${OLIX_MODULE_NAME} && [[ ${FORCE} == false ]] ; then
        logger_warning "Le fichier de configuration existe déjà"
        if [[ ${OLIX_OPTION_VERBOSE} == true ]]; then
            echo "----------"
            cat ${FILECONF}
            echo "----------"
        fi
        logger_warning "Pour reinitialiser la configuration, utiliser : ${OLIX_CORE_SHELL_NAME} ubuntu init -f|--force"    
        core_exit 0
    fi

    # Test si c'est le propriétaire
    logger_info "Test si c'est le propriétaire"
    core_checkIfOwner
    [[ $? -ne 0 ]] && logger_error "Seul l'utilisateur \"$(core_getOwner)\" peut exécuter ce script"

    if config_isModuleExist ${OLIX_MODULE_NAME}; then
        logger_info "Chargement du fichier de configuration ${FILECONF}"
        source ${FILECONF}
    fi

    # Demande du fichier de paramètre
    stdin_readFile "Chemin complet du fichier contenant la configuration de l'installation du serveur" "${OLIX_MODULE_UBUNTU_CONFIG}"
    logger_debug "module_ubuntu__olixmod__init RESPONSE=${OLIX_STDIN_RETURN}"
   
    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${FILECONF}"
    logger_debug "OLIX_MODULE_UBUNTU_CONFIG=${OLIX_STDIN_RETURN}"
    echo "# Fichier de configuration pour l'install d'Ubuntu" > ${FILECONF}
    echo "OLIX_MODULE_UBUNTU_CONFIG=${OLIX_STDIN_RETURN}" >> ${FILECONF}
}