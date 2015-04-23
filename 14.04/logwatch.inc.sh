###
# Installation et configuration de LOGWATCH
# ==============================================================================
# - Installation des paquets LOGWATCH
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# logwatch:
#   enabled:  (OLIX_MODULE_UBUNTU_LOGWATCH__ENABLED)
#   filecfg:  (OLIX_MODULE_UBUNTU_LOGWATCH__FILECFG)  Fichier logwatch.conf à utiliser
#   logfiles: (OLIX_MODULE_UBUNTU_LOGWATCH__LOGFILES) Liste des fichiers de configuration pour surcharger la conf initiale
#   services: (OLIX_MODULE_UBUNTU_LOGWATCH__SERVICES) Liste des fichiers de services pour surcharger la conf initiale
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation et Configuration de LOGWATCH ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (logwatch, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_LOGWATCH__ENABLED}" != true ]]; then
        logger_warning "Service 'logwatch' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/logwatch"

    case $1 in
        install)
            ubuntu_include_install
            ubuntu_include_config
            ubuntu_include_restart
            ;;
        config)
            ubuntu_include_config
            ubuntu_include_restart
            ;;
        restart)
            ubuntu_include_restart
            ;;
    esac
}


###
# Installation du service
##
ubuntu_include_install()
{
    logger_debug "ubuntu_include_install (logwatch)"

    logger_info "Installation des packages LOGWATCH"
    apt-get --yes install logwatch
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages LOGWATCH"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (logwatch)"

    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_LOGWATCH__FILECFG}" "/etc/logwatch/conf/logwatch.conf" \
        "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_LOGWATCH__FILECFG}${CVOID} vers /etc/logwatch/conf/logwatch.conf"

    # Mise en place du fichier de configuration de "logfiles"
    logger_info "Effacement des fichiers déjà présents dans /etc/logwatch/conf/logfiles"
    rm -f /etc/logwatch/conf/logfiles/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    logger_info "Mise en place des fichiers dans /etc/logwatch/conf/logfiles"
    for I in ${OLIX_MODULE_UBUNTU_LOGWATCH__LOGFILES}; do
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/logfiles/${I}" "/etc/logwatch/conf/logfiles/" \
            "Mise en place de ${CCYAN}logfiles/${I}${CVOID} vers /etc/logwatch/conf/logfiles"
    done

    # Mise en place du fichier de configuration de "services"
    logger_info "Effacement des fichiers déjà présents dans /etc/logwatch/conf/services"
    rm -f /etc/logwatch/conf/services/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    logger_info "Mise en place des fichiers dans /etc/logwatch/conf/logfiles"
    for I in ${OLIX_MODULE_UBUNTU_LOGWATCH__SERVICES}; do
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/services/${I}" "/etc/logwatch/conf/services/" \
            "Mise en place de ${CCYAN}services/${I}${CVOID} vers /etc/logwatch/conf/services"
    done
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (logwatch)"
}
