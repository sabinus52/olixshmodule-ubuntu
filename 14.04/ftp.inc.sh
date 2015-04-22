###
# Installation et configuration de FTP
# ==============================================================================
# - Installation des paquets PUREFTPD
# - Modification de base de pureftpd
# - Modification de la configuration de pureftpd
# - Création des utilisateurs virtuels
# ------------------------------------------------------------------------------
# ftp:
#    enabled: (OLIX_MODULE_UBUNTU_FTP__ENABLED)
#    configs: (OLIX_MODULE_UBUNTU_FTP__CONFIGS) Configuration de pure-ftpd avec les fichiers de parametre = valeur
#   users:
#     user_1:                                   Création des utilisateurs virtuels Exemple : "otop -u otop -g users -d /home/otop"
#        name:  (OLIX_MODULE_UBUNTU_FTP__USERS__USER_1__NAME)
#        grant: (OLIX_MODULE_UBUNTU_FTP__USERS__USER_1__PARAM)
#     user_N:
#        name:  (OLIX_MODULE_UBUNTU_FTP__USERS__USER_N__NAME)
#        grant: (OLIX_MODULE_UBUNTU_FTP__USERS__USER_n__PARAM)
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation et Configuration de FTP ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (ftp, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_FTP__ENABLED}" != true ]]; then
        logger_warning "Service 'ftp' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/ftp"

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
    logger_debug "ubuntu_include_install (ftp)"

    logger_info "Installation des packages FTP"
    apt-get --yes install pure-ftpd
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages FTP"

    logger_info "Modification du VirtualChRoot dans /etc/default/pure-ftpd-common"
    sed -i "s/^VIRTUALCHROOT=.*$/VIRTUALCHROOT=true/g" /etc/default/pure-ftpd-common > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error

    # Activation de PureDB
    logger_info "Suppression de /etc/pure-ftpd/auth/75puredb"
    rm -f /etc/pure-ftpd/auth/75puredb > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    logger_info "Activation de la base puredb pour les utilisateurs virtuels"
    cd /etc/pure-ftpd/auth
    ln -sf ../conf/PureDB 75puredb > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    cd ${OLIX_ROOT}
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (ftp)"

    # Mise en place des paramètres de configuration
    ubuntu_include_ftp_configs

    # Création des utilisateurs
    ubuntu_include_ftp_users
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (ftp)"

    logger_info "Redémarrage du service FTP"
    service pure-ftpd restart
    [[ $? -ne 0 ]] && logger_error "Service FTP NOT running"
}


###
# Mise en place des paramètres de configuration
##
function ubuntu_include_ftp_configs()
{
    logger_debug "ubuntu_include_ftp_configs"
    local VALUE

    for I in ${OLIX_MODULE_UBUNTU_FTP__CONFIGS}; do
        [[ -r ${__PATH_CONFIG}/${I} ]] && VALUE=$(cat ${__PATH_CONFIG}/${I})
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${I}" "/etc/pure-ftpd/conf" \
            "Mise en place de ${CCYAN}${I}${CVOID} = ${CCYAN}${VALUE}${CVOID} vers /etc/pure-ftpd/conf"
    done
}


###
# Création des utilisateurs
##
function ubuntu_include_ftp_users()
{
    logger_debug "ubuntu_include_ftp_users ()"
    local USERNAME USERPARAM

    for (( I = 1; I < 10; I++ )); do
        eval "USERNAME=\${OLIX_MODULE_UBUNTU_FTP__USERS__USER_${I}__NAME}"
        [[ -z ${USERNAME} ]] && break
        eval "USERPARAM=\${OLIX_MODULE_UBUNTU_FTP__USERS__USER_${I}__PARAM}"
        logger_info "Création de l'utilisateur '${USERNAME}'"

        # Création de l'utilisateur si celui-ci n'existe pas
        logger_debug "pure-pw show ${USERNAME}"
        if pure-pw show ${USERNAME} > /dev/null 2>&1; then
            logger_debug "pure-pw usermod ${USERPARAM}"
            pure-pw usermod ${USERPARAM} -m 2> ${OLIX_LOGGER_FILE_ERR}
            [[ $? -ne 0 ]] && logger_error
            echo -e "Création de l'utilisateur ${CCYAN}${USERNAME}${CVOID} : ${CBLEU}Déjà créé ...${CVOID}"
        else
            logger_debug "pure-pw useradd ${USERNAME} ${USERPARAM}"
            echo -e "Initialisation du mot de passe de ${CCYAN}${USERNAME}${CVOID}"
            pure-pw useradd ${USERNAME} ${USERPARAM} -m 2> ${OLIX_LOGGER_FILE_ERR}
            [[ $? -ne 0 ]] && logger_error
            echo -e "Création de l'utilisateur ${CCYAN}${USERNAME}${CVOID} : ${CVERT}OK ...${CVOID}"
        fi
    done
}
