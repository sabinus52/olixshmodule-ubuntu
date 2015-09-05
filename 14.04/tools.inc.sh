###
# Installation et configuration de TOOLS
# ==============================================================================
# - Installation des paquets additionnels
# - Installation des fichiers de crontab
# - Installation des fichiers de logrotate
# ------------------------------------------------------------------------------
# tools:
#   apt:       (OLIX_MODULE_UBUNTU_TOOLS__APT)       Liste des packets à intaller
#   crontab:   (OLIX_MODULE_UBUNTU_TOOLS__CRONTAB)   Fichier de conf pour les taches planifiées
#   logrotate: (OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE) Fichier de conf pour la rotation de log
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    case $1 in
        install)
            echo
            echo -e "${CBLANC} Installation des TOOLS ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration des TOOLS ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration des TOOLS ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (tools, $1)"

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/tools"

    case $1 in
        install)
            ubuntu_include_install
            ubuntu_include_config
            ;;
        config)
            ubuntu_include_config
            ;;
        savecfg)
            ubuntu_include_savecfg
            ;;
        synccfg)
            ubuntu_include_synccfg
            ;;
    esac
}


###
# Installation du service
##
ubuntu_include_install()
{
    logger_debug "ubuntu_include_install (tools)"

    if [[ -n ${OLIX_MODULE_UBUNTU_TOOLS__APT} ]]; then
        logger_info "Installation des packages additionnels"
        apt-get --yes install ${OLIX_MODULE_UBUNTU_TOOLS__APT}
        [[ $? -ne 0 ]] && logger_critical "Impossible d'installer les packages additionnels"
    fi
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (tools)"

    # Installation des fichiers CRONTAB
    if [ -n "${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}" ]; then
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}" "/etc/cron.d/" \
            "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}${CVOID} vers /etc/cron.d"
    fi

    # Installation des fichiers LOGROTATE
    if [ -n "${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}" ]; then
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}" "/etc/logrotate.d/" \
            "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}${CVOID} vers /etc/logrotate.d"
    fi
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (tools)"

    [[ -n "${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}" ]] && module_ubuntu_backupFileConfiguration "/etc/cron.d/${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}" "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}"
    [[ -n "${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}" ]] && module_ubuntu_backupFileConfiguration "/etc/logrotate.d/${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}" "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}"
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (tools)"

    echo "tools"
    [[ -n "${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}" ]] && echo "postgres/${OLIX_MODULE_UBUNTU_TOOLS__CRONTAB}"
    [[ -n "${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}" ]] && echo "postgres/${OLIX_MODULE_UBUNTU_TOOLS__LOGROTATE}"
}
