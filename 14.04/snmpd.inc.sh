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
    case $1 in
        install)
            echo
            echo -e "${CBLANC} Installation de SNMPD ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de SNMPD ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de SNMPD ${CVOID}"
            ;;
    esac
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
    logger_debug "ubuntu_include_install (snmpd)"

    logger_info "Installation des packages SNMPD"
    apt-get --yes install snmp snmpd
    [[ $? -ne 0 ]] && logger_critical "Impossible d'installer les packages SNMPD"
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
    [[ $? -ne 0 ]] && logger_critical "Service SNMPD NOT running"
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (snmpd)"

    module_ubuntu_backupFileConfiguration "/etc/snmp/snmpd.conf" "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_SNMPD__FILECFG}"
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (snmpd)"

    echo "snmpd"
    echo "snmpd/${OLIX_MODULE_UBUNTU_SNMPD__FILECFG}"
}
