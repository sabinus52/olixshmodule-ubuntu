###
# Installation et configuration de MONIT
# ==============================================================================
# - Installatio des paquets MONIT
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# monit:
#    enabled: (OLIX_MODULE_UBUNTU_MONIT__ENABLED)
#    confd:   (OLIX_MODULE_UBUNTU_MONIT__CONFD)   Liste des fichiers de conf des check
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
            echo -e "${CBLANC} Installation de MONIT ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de MONIT ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de MONIT ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (monit, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_MONIT__ENABLED}" != true ]]; then
        logger_warning "Service 'monit' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/monit"

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
    logger_debug "ubuntu_include_install (monit)"

    logger_info "Installation des packages MONIT"
    apt-get --yes install monit
    [[ $? -ne 0 ]] && logger_critical "Impossible d'installer les packages MONIT"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (monit)"

    logger_info "Effacement des fichiers déjà présents dans /etc/monit/conf.d"
    rm -f /etc/monit/conf.d/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    logger_info "Mise en place des fichiers de conf dans /etc/monit/conf.d"
    for I in ${OLIX_MODULE_UBUNTU_MONIT__CONFD}; do
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${I}" "/etc/monit/conf.d/" \
            "Mise en place de ${CCYAN}${I}${CVOID} vers /etc/monit/conf.d"
    done
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (monit)"

    logger_info "Redémarrage du service MONIT"
    service monit restart
    [[ $? -ne 0 ]] && logger_critical "Service MONIT NOT running"
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (monit)"

    for I in ${OLIX_MODULE_UBUNTU_MONIT__CONFD}; do
        module_ubuntu_backupFileConfiguration "/etc/monit/conf.d/${I}" "${__PATH_CONFIG}/${I}"
    done
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (monit)"

    echo "monit"
    for I in ${OLIX_MODULE_UBUNTU_MONIT__CONFD}; do
       echo "monit/$I.conf"
    done
}
