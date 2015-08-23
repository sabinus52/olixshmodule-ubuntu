###
# Librairies des actions du module UBUNTU
# ==============================================================================
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##



###
# Initialisation du module en créant le fichier de configuration
# @var OLIX_MODULE_UBUNTU_*
##
function module_ubuntu_action_init()
{
    logger_debug "module_ubuntu_action_init ($@)"

    if [[ ! -f ${OLIX_MODULE_FILECONF} ]]; then
        echo -e "${CJAUNE}Avant l'initialisation, il faut que la configuration du serveur soit présente${CVOID}"
        echo -e " 1. Installer les fichiers de configuration"
        echo -e "        via la commande ${Ccyan}olixsh ubuntu synccfg pull [ADDRESS] [DESTINATION]${CVOID}"
        echo -e " 2. Initialiser le module"
        echo -e "        avec la commande ${Ccyan}olixsh ubuntu init${CVOID}"
        stdin_readYesOrNo "Continuer l'initialisation du module" false
        [[ ${OLIX_STDIN_RETURN} == false ]] && return 0
    fi

    # Demande du fichier de paramètre
    stdin_readFile "Chemin complet du fichier contenant la configuration de l'installation du serveur" "${OLIX_MODULE_UBUNTU_CONFIG}"
    logger_debug "OLIX_MODULE_UBUNTU_CONFIG=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_UBUNTU_CONFIG=${OLIX_STDIN_RETURN}
    stdin_read "Adresse du serveur source de la configuration [user]@[host]:/[path]" "${OLIX_MODULE_UBUNTU_SYNC_SERVER}"
    logger_debug "OLIX_MODULE_UBUNTU_SYNC_SERVER=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_UBUNTU_SYNC_SERVER=${OLIX_STDIN_RETURN}
    stdin_read "Port du serveur source de la configuration" "${OLIX_MODULE_UBUNTU_SYNC_PORT}"
    logger_debug "OLIX_MODULE_UBUNTU_SYNC_PORT=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_UBUNTU_SYNC_PORT=${OLIX_STDIN_RETURN}
   
    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${OLIX_MODULE_FILECONF}"
    echo "# Fichier de configuration pour l'install d'Ubuntu" > ${OLIX_MODULE_FILECONF}
    [[ $? -ne 0 ]] && logger_critical
    echo "OLIX_MODULE_UBUNTU_CONFIG=${OLIX_MODULE_UBUNTU_CONFIG}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_UBUNTU_SYNC_SERVER=${OLIX_MODULE_UBUNTU_SYNC_SERVER}" >> ${OLIX_MODULE_FILECONF}
    echo "OLIX_MODULE_UBUNTU_SYNC_PORT=${OLIX_MODULE_UBUNTU_SYNC_PORT}" >> ${OLIX_MODULE_FILECONF}

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
    return 0
}


###
# Installation des packages
##
function module_ubuntu_action_install()
{
    logger_debug "module_ubuntu_action_install ($@)"
    local I

    # Affichage de l'aide
    [ $# -lt 1 ] && module_ubuntu_usage_install && core_exit 1

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfiguration
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]] && OLIX_MODULE_UBUNTU_PACKAGES=${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}

    # Mise à jour si installation complète
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]] && module_ubuntu_executeService main apt-update

    for I in ${OLIX_MODULE_UBUNTU_PACKAGES}; do
        logger_info "Installation de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            module_ubuntu_executeService install ${I}
        fi
    done

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Configuration des packages
##
function module_ubuntu_action_config()
{
    logger_debug "module_ubuntu_action_config ($@)"
    local I

    # Affichage de l'aide
    [ $# -lt 1 ] && module_ubuntu_usage_config && core_exit 1
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]]  && module_ubuntu_usage_config && core_exit 1

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfiguration

    # Configuration des services demandés
    for I in ${OLIX_MODULE_UBUNTU_PACKAGES}; do
        logger_info "Configuration de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_CONFIG}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            module_ubuntu_executeService config ${I}
        fi
    done

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Mise à jour du système
##
function module_ubuntu_action_update()
{
    logger_debug "module_ubuntu_action_update ($@)"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    module_ubuntu_executeService main apt-update

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Sauvegarde de la configuration des packages
##
function module_ubuntu_action_savecfg()
{
    logger_debug "module_ubuntu_action_savecfg ($@)"
    local I

    # Affichage de l'aide
    [ $# -lt 1 ] && module_ubuntu_usage_savecfg && core_exit 1

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfiguration
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]] && OLIX_MODULE_UBUNTU_PACKAGES=${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}

    # Configuration des services demandés
    for I in ${OLIX_MODULE_UBUNTU_PACKAGES}; do
        logger_info "Sauvegarde de la configuration de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            module_ubuntu_executeService savecfg ${I}
        fi
    done

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}


###
# Synchronisation de la configuration des packages
##
function module_ubuntu_action_synccfg()
{
    logger_debug "module_ubuntu_action_synccfg ($@)"
    local ACTION=$1
    local ADDRESS=$2
    local CONFIGDIR=$3

    # Affichage de l'aide
    [ $# -lt 1 ] && module_ubuntu_usage_synccfg && core_exit 1

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_critical "Seulement root peut executer cette action"

    # Charge la configuration du module
    config_loadConfigQuietModule "${OLIX_MODULE_NAME}"
    
    # Test des paramètres saisies
    [[ -z ${ADDRESS} ]] && ADDRESS=${OLIX_MODULE_UBUNTU_SYNC_SERVER}
    if [[ -z ${ADDRESS} ]]; then
        logger_critical "Le paramètre de l'adresse du serveur est manquant"
    fi
    [[ -z ${OLIX_MODULE_UBUNTU_SYNC_PORT} ]] && OLIX_MODULE_UBUNTU_SYNC_PORT=22
    logger_debug "ADDRESS=${ADDRESS}"
    logger_debug "OLIX_MODULE_UBUNTU_SYNC_PORT=${OLIX_MODULE_UBUNTU_SYNC_PORT}"
    
    # En fonction de l'action PUSH ou PULL
    case ${ACTION} in
        push)
            echo "Pousser la config"
            ;;
        pull)
            module_ubuntu_action_synccfg_pull "${ADDRESS}" "${CONFIGDIR}"
            ;;
    esac
    
    case $? in
        0) echo -e "${Cvert}Action terminée avec succès${CVOID}";;
        52) echo -e "${Cjaune}Action abordée${CVOID}";;
        *) echo -e "${Crouge}Action terminée avec des erreurs${CVOID}";;
    esac
}


###
# Synchronisation de la configuration des packages par l'action PULL
##
function module_ubuntu_action_synccfg_pull()
{
    logger_debug "module_ubuntu_action_synccfg_pull ($1, $2)"
    local ADDRESS=$1
    local CONFIGDIR=$2

    # Test le paramètre de chemin de destination
    [[ -z ${CONFIGDIR} ]] && CONFIGDIR=$(dirname ${OLIX_MODULE_UBUNTU_CONFIG} 2> /dev/null)
    if [[ -z ${CONFIGDIR} ]]; then
        logger_critical "Le paramètre du dossier contenant la configuration du serveur"
    fi
    logger_debug "CONFIGDIR=${CONFIGDIR}"

    echo -e "${CBLANC}Récupérer la configuration${CVOID} depuis le serveur ${CCYAN}${ADDRESS}${CVOID} vers ${CCYAN}${CONFIGDIR}${CVOID}"
    stdin_readYesOrNo "Continuer l'initialisation du module" false
    [[ ${OLIX_STDIN_RETURN} == false ]] && return 52

    file_synchronize ${OLIX_MODULE_UBUNTU_SYNC_PORT} ${ADDRESS} ${CONFIGDIR}
    return $?
}
