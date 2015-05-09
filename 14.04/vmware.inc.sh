###
# Installation des Tools pour VMware
# ==============================================================================
# - Installation du noyau
# - Installation des tools
# ------------------------------------------------------------------------------
# vmware:
#    enabled: (OLIX_MODULE_UBUNTU_VMWARE__ENABLED)
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation des Tools pour VMware ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_install (vmware, $1)"
    local ACTION=$1

    if [[ "${OLIX_MODULE_UBUNTU_VMWARE__ENABLED}" != true ]]; then
        logger_warning "Service 'vmware' non activé"
        return 1
    fi

    # Vérifie si les tools ont été déjà installé
    if [[ -f /usr/bin/vmware-config-tools.pl ]]; then
        logger_warning "VMware Tools déjà installés"
    fi

    ubuntu_include_install
}


###
# Installation du service
##
ubuntu_include_install()
{
    logger_debug "ubuntu_include_install (vmware)"

    logger_info "Installation des packages necessaires à VMware"
    apt-get --yes install dkms build-essential linux-headers-$(uname -r)
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer tous les packages"

    umount /dev/cdrom
    echo -en "${CBLANC}Activer l'installation de VMware Tools depuis le menu ${CJAUNE}[ENTER pour continuer] ?${CVOID} "
    read REP
    logger_info "Montage du CDROM"
    mount /dev/cdrom /media/cdrom

    logger_info "Décompression des Tools"
    tar xzf /media/cdrom/VMwareTools-*.tar.gz -C /tmp

    cd /tmp/vmware-tools-distrib
    logger_info "Installation des Tools"
    ./vmware-install.pl
    cd ${OLIX_ROOT}
}
