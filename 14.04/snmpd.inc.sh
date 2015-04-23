###
# Installation et configuration de SNMPD
# ==============================================================================
# - Installation des paquets SNMPD
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# snmpd:
#    enabled: (OLIX_MODULE_UBUNTU_SNMPD__ENABLED)
#    filecfg: (OLIX_MODULE_UBUNTU_SNMPD__FILECFG) Fichier snmpd.conf à utiliser
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation et Configuration de SNMPD ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (snmpd, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_SNMPD__ENABLED}" != true ]]; then
        logger_warning "Service 'snmpd' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/snmpd"

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
    logger_debug "ubuntu_include_install (snmpd)"

    logger_info "Installation des packages SNMPD"
    apt-get --yes install snmp snmpd
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages SNMPD"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (snmpd)"

    module_ubuntu_backupFileOriginal "/etc/snmp/snmpd.conf"
    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_SNMPD__FILECFG}" "/etc/snmp/snmpd.conf" \
        "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_SNMPD__FILECFG}${CVOID} vers /etc/snmp/snmpd.conf"
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (snmpd)"

    logger_info "Redémarrage du service SNMPD"
    service snmpd restart
    [[ $? -ne 0 ]] && logger_error "Service SNMPD NOT running"
}
