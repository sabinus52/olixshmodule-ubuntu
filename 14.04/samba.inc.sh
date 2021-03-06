###
# Installation et configuration de SAMBA
# ==============================================================================
# - Installation des paquets SAMBA
# - Installation des fichiers de configuration
# - Activation des utilisateurs
# ------------------------------------------------------------------------------
# samba:
#   enabled: (OLIX_MODULE_UBUNTU_SAMBA__ENABLED)
#   filecfg: (OLIX_MODULE_UBUNTU_SAMBA__FILECFG) Fichier smb.conf à utiliser
#   users:
#     user_1:
#        name:  (OLIX_MODULE_UBUNTU_SAMBA_USERS__USER_1__NAME)  
#     user_N:
#        name:  (OLIX_MODULE_UBUNTU_SAMBA_USERS__USER_N__NAME)
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
            echo -e "${CBLANC} Installation de SAMBA ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de SAMBA ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de SAMBA ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (samba, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_SAMBA__ENABLED}" != true ]]; then
        logger_warning "Service 'samba' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/samba"

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
    logger_debug "ubuntu_include_install (samba)"

    logger_info "Installation des packages SAMBA"
    apt-get --yes install samba smbclient cifs-utils
    [[ $? -ne 0 ]] && logger_critical "Impossible d'installer les packages SAMBA"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (samba)"

    module_ubuntu_backupFileOriginal "/etc/samba/smb.conf"
    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_SAMBA__FILECFG}" "/etc/samba/smb.conf" \
        "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_SAMBA__FILECFG}${CVOID} vers /etc/samba/smb.conf"

    # Déclaration des utilisateurs
    ubuntu_include_samba_users
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (samba)"

    logger_info "Redémarrage du service SAMBA"
    service smbd restart
    [[ $? -ne 0 ]] && logger_critical "Service SAMBA NOT running"
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (samba)"

    module_ubuntu_backupFileConfiguration "/etc/samba/smb.conf" "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_SAMBA__FILECFG}"
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (samba)"

    echo "samba"
    echo "samba/${OLIX_MODULE_UBUNTU_SAMBA__FILECFG}"
}


###
# Déclaration des utilisateurs
##
function ubuntu_include_samba_users()
{
    logger_debug "ubuntu_include_samba_users ()"
    local USERNAME

    for (( I = 1; I < 10; I++ )); do
        eval "USERNAME=\${OLIX_MODULE_UBUNTU_SAMBA__USERS__USER_${I}__NAME}"
        [[ -z ${USERNAME} ]] && break

        logger_info "Activation de l'utilisateur '${USERNAME}'"
        smbpasswd -a ${USERNAME}

        echo -e "Activation de l'utilisateur ${CCYAN}${USERNAME}${CVOID} : ${CVERT}OK ...${CVOID}"
    done
}
