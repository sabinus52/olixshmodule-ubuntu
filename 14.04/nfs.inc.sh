###
# Installation et configuration de NFS
# ==============================================================================
# - Installation des paquets NFS
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# apache:
#    enabled: (OLIX_MODULE_UBUNTU_NFS__ENABLED)
#    filecfg: (OLIX_MODULE_UBUNTU_NFS__FILECFG) Fichier exports à utiliser
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation et Configuration de NFS ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (nfs, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_NFS__ENABLED}" != true ]]; then
        logger_warning "Service 'nfs' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/nfs"

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
    logger_debug "ubuntu_include_install (nfs)"

    logger_info "Installation des packages NFS"
    apt-get --yes install nfs-common nfs-kernel-server
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages NFS"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (nfs)"

    module_ubuntu_backupFileOriginal "/etc/exports"
    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_NFS__FILECFG}" "/etc/exports" \
        "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_NFS__FILECFG}${CVOID} vers /etc/exports"
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (nfs)"

    logger_info "Redémarrage du service NFS"
    service nfs-kernel-server restart
    [[ $? -ne 0 ]] && logger_error "Service NFS NOT running"
}
