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
    echo
    echo -e "${CBLANC} Installation et Configuration de SAMBA ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
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
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages SAMBA"
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
    [[ $? -ne 0 ]] && logger_error "Service SAMBA NOT running"
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
