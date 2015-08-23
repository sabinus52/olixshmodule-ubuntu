###
# Installation et configuration de POSTFIX
# ==============================================================================
# - Installation des paquets POSTFIX
# - Changement de la configuration
# ------------------------------------------------------------------------------
# postfix:
#   enabled:    (OLIX_MODULE_UBUNTU_POSTFIX__ENABLED)
#   relay:
#     host:     (OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST) Host du relais SMTP
#     port:     (OLIX_MODULE_UBUNTU_POSTFIX__RELAY__PORT) Port du relais SMTP
#  auth:
#     login:    (OLIX_MODULE_UBUNTU_POSTFIX__AUTH__LOGIN)    Login de l'authentification
#     password: (OLIX_MODULE_UBUNTU_POSTFIX__AUTH__PASSWORD) Mot de passe FACULTATIF de l'authentification
# ------------------------------------------------------------------------------
# @modified 11/05/2014
# Plus besoin de changer le hostname du postfix : utilisation du FQDN du système
# @modified 16/06/2014
# sendmail obselete -> postfix obligatoire
# Permettre un relai SMTP avec authentification
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
            echo -e "${CBLANC} Installation de POSTFIX ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de POSTFIX ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de POSTFIX ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (postfix, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_POSTFIX__ENABLED}" != true ]]; then
        logger_warning "Service 'postfix' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/postfix"

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
    logger_debug "ubuntu_include_install (postfix)"

    logger_info "Installation des packages POSTFIX"
    apt-get --yes install mailutils postfix libsasl2-modules sasl2-bin
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages POSTFIX"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (postfix)"

    # Changement du relais
    logger_info "Changement du relais SMTP"
    logger_debug "relayhost = ${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST}:${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__PORT}"
    postconf -e "relayhost = ${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST}:${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__PORT}"

    # Authentification
    if [[ ! -z ${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__LOGIN} ]]; then
        ubuntu_include_postfix_authentification
    fi
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (postfix)"

    logger_info "Redémarrage du service POSTFIX"
    service postfix restart
    [[ $? -ne 0 ]] && logger_error "Service POSTFIX NOT running"
}


###
# Modification de la conf en mode authentification
##
function ubuntu_include_postfix_authentification()
{
    logger_debug "ubuntu_include_postfix_authentification ()"

    logger_info "Modification de la conf postfix"
    postconf -e 'smtpd_sasl_auth_enable = no'
    postconf -e 'smtp_sasl_auth_enable = yes'
    postconf -e 'smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd'
    postconf -e 'smtpd_sasl_local_domain = $myhostname'
    postconf -e 'smtp_sasl_security_options = noanonymous'
    postconf -e 'smtp_sasl_tls_security_options = noanonymous'

    logger_info "Création du fichier d'authentification sasl_passwd"
    if [[ -z ${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__PASSWORD} ]]; then
        stdin_readPassword "Mot de passe au serveur SMTP ${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST} en tant que ${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__LOGIN}"
        OLIX_MODULE_UBUNTU_POSTFIX__AUTH__PASSWORD=${OLIX_STDIN_RETURN}
    fi
    logger_debug "${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST}:${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__PORT}    ${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__LOGIN}:${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__PASSWORD} > /etc/postfix/sasl_passwd"
    echo "${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST}:${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__PORT}    ${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__LOGIN}:${OLIX_MODULE_UBUNTU_POSTFIX__AUTH__PASSWORD}" > /etc/postfix/sasl_passwd
    logger_debug "postmap /etc/postfix/sasl_passwd"
    postmap /etc/postfix/sasl_passwd > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    rm -f /etc/postfix/sasl_passwd
    echo -e "Authentification sur ${CCYAN}${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__HOST}:${OLIX_MODULE_UBUNTU_POSTFIX__RELAY__PORT}${CVOID} : ${CVERT}OK ...${CVOID}"
}
