###
# Installation et configuration de PHP
# ==============================================================================
# - Installation des paquets PHP
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# php:
#    enabled: (OLIX_MODULE_UBUNTU_PHP__ENABLED)
#    modules: (OLIX_MODULE_UBUNTU_PHP__MODULES) Liste des modules php à installer
#    filecfg: (OLIX_MODULE_UBUNTU_PHP__FILECFG) Fichier php.ini à utiliser
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation et Configuration de PHP ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (php, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_PHP__ENABLED}" != true ]]; then
        logger_warning "Service 'php' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/php"

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
    logger_debug "ubuntu_include_install (php)"

    logger_info "Installation des packages PHP"
    apt-get --yes install libapache2-mod-php5 php5 ${OLIX_MODULE_UBUNTU_PHP__MODULES}
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages PHP"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (php)"

    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_PHP__FILECFG}" "/etc/php5/apache2/conf.d/"
    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_PHP__FILECFG}" "/etc/php5/cli/conf.d/"
    echo -e "Activation de la conf ${CCYAN}${OLIX_MODULE_UBUNTU_PHP__FILECFG}${CVOID} : ${CVERT}OK ...${CVOID}"
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (php)"

    logger_info "Redémarrage du service APACHE"
    service apache2 restart
    [[ $? -ne 0 ]] && logger_error "Service APACHE NOT running"
}
