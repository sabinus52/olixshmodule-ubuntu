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
    echo
    echo -e "${CBLANC} Installation et Configuration de MONIT ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
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
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages MONIT"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (monit)"

    logger_info "Effacement des fichiers déjà présents dans /etc/monit/conf.d"
    rm -f /etc/monit/conf.d/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
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
    [[ $? -ne 0 ]] && logger_error "Service MONIT NOT running"
}
