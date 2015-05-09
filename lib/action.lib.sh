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

    # Demande du fichier de paramètre
    stdin_readFile "Chemin complet du fichier contenant la configuration de l'installation du serveur" "${OLIX_MODULE_UBUNTU_CONFIG}"
    logger_debug "OLIX_MODULE_UBUNTU_CONFIG=${OLIX_STDIN_RETURN}"
    OLIX_MODULE_UBUNTU_CONFIG=${OLIX_STDIN_RETURN}
   
    # Ecriture du fichier de configuration
    logger_info "Création du fichier de configuration ${OLIX_MODULE_FILECONF}"
    echo "# Fichier de configuration pour l'install d'Ubuntu" > ${OLIX_MODULE_FILECONF}
    [[ $? -ne 0 ]] && logger_error
    echo "OLIX_MODULE_UBUNTU_CONFIG=${OLIX_MODULE_UBUNTU_CONFIG}" >> ${OLIX_MODULE_FILECONF}

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
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfiguration
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]] && OLIX_MODULE_UBUNTU_PACKAGES=${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}

    # Mise à jour si installation complète
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]] && module_ubuntu_executeService main apt-update with-title

    for I in ${OLIX_MODULE_UBUNTU_PACKAGES}; do
        logger_info "Installation de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            if [[ $# == 1 ]]; then
                module_ubuntu_executeService install ${I}
            else
                module_ubuntu_executeService install ${I} with-title
            fi
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

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfiguration

    # Configuration des services demandés
    for I in ${OLIX_MODULE_UBUNTU_PACKAGES}; do
        logger_info "Configuration de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_CONFIG}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            if [[ $# == 1 ]]; then
                module_ubuntu_executeService config ${I}
            else
                module_ubuntu_executeService config ${I} with-title
            fi
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

    echo -e "${CBLANC}Mise à jour du serveur Ubuntu${CVOID}"

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

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
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfiguration
    [[ ${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE} == true ]] && OLIX_MODULE_UBUNTU_PACKAGES=${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}

    # Configuration des services demandés
    for I in ${OLIX_MODULE_UBUNTU_PACKAGES}; do
        logger_info "Sauvegarde de la configuration de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            if [[ $# == 1 ]]; then
                module_ubuntu_executeService savecfg ${I}
            else
                module_ubuntu_executeService savecfg ${I} with-title
            fi
        fi
    done

    echo -e "${Cvert}Action terminée avec succès${CVOID}"
}
