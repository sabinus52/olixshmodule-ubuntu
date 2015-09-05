###
# Installation des Tools pour VirtualBox
# ==============================================================================
# - Installation du noyau
# - Installation des tools
# ------------------------------------------------------------------------------
# virtualbox:
#    enabled: (OLIX_MODULE_UBUNTU_VIRTUALBOX__ENABLED)
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation des Tools pour VirtualBox ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_install (virtualbox, $1)"
    local ACTION=$1

    if [[ "${OLIX_MODULE_UBUNTU_VIRTUALBOX__ENABLED}" != true ]]; then
        logger_warning "Service 'virtualbox' non activé"
        return 1
    fi

    # Vérifie si les tools ont été déjà installé
    if [[ -f /etc/init.d/vboxadd ]]; then ACTION=config; else ACTION=install; fi

    case ${ACTION} in
        install)
            ubuntu_include_install
            ;;
        config)
            ubuntu_include_config
            ;;
    esac
}


###
# Installation du service
##
ubuntu_include_install()
{
    logger_debug "ubuntu_include_install (virtualbox)"

    logger_info "Installation des packages necessaires à VirtualBox"
    apt-get --yes install dkms build-essential linux-headers-$(uname -r)
    [[ $? -ne 0 ]] && logger_critical "Impossible d'installer tous les packages"

    umount /dev/cdrom
    echo -en "${CBLANC}Activer l'installation de ClientTools depuis le menu ${CJAUNE}[ENTER pour continuer] ?${CVOID} "
    read REP
    logger_info "Montage du CDROM"
    mount /dev/cdrom /media/cdrom
    cd /media/cdrom

    logger_info "Installation des Tools"
    sh ./VBoxLinuxAdditions.run
    cd ${OLIX_ROOT}

    echo -en "Activer le partage automatique ${CJAUNE}[ENTER pour continuer] ?${CVOID} "; read REP
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (virtualbox)"

    logger_info "Reconfiguration des Tools"
    /etc/init.d/vboxadd setup
}
