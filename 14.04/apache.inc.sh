###
# Installation et configuration d'APACHE
# ==============================================================================
# - Installation des paquets APACHE
# - Installation de la clé privée
# - Activation des modules
# - Installation des fichiers de configuration
# ------------------------------------------------------------------------------
# apache:
#    enabled: (OLIX_MODULE_UBUNTU_APACHE__ENABLED)
#    modules: (OLIX_MODULE_UBUNTU_APACHE__MODULES) Liste des modules apache à activer
#    configs: (OLIX_MODULE_UBUNTU_APACHE__CONFIGS) Liste des fichiers de configuration
#    default: (OLIX_MODULE_UBUNTU_APACHE__DEFAULT) Site par défaut
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
            echo -e "${CBLANC} Installation de APACHE ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de APACHE ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de APACHE ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (apache, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_APACHE__ENABLED}" != true ]]; then
        logger_warning "Service 'apache' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/apache"

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
    logger_debug "ubuntu_include_install (apache)"

    logger_info "Installation des packages APACHE"
    apt-get --yes install apache2-mpm-prefork ssl-cert
    [[ $? -ne 0 ]] && logger_critical "Impossible d'installer les packages APACHE"
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (apache)"

    # Activation des modules Apache
    ubuntu_include_apache_modules
    # Installation des fichiers de configuration
    ubuntu_include_apache_configs
    # Activation du site par défaut
    ubuntu_include_apache_default
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (apache)"

    logger_info "Redémarrage du service APACHE"
    service apache2 restart
    [[ $? -ne 0 ]] && logger_critical "Service APACHE NOT running"
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (apache)"

    for I in ${OLIX_MODULE_UBUNTU_APACHE__CONFIGS}; do
        module_ubuntu_backupFileConfiguration "/etc/apache2/conf-available/$I.conf" "${__PATH_CONFIG}/conf/$I.conf"
    done
    module_ubuntu_backupFileConfiguration "/etc/apache2/sites-available/000-default.conf" "${__PATH_CONFIG}/default/${OLIX_MODULE_UBUNTU_APACHE__DEFAULT}"
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (apache)"

    echo "apache apache/conf apache/default"
    for I in ${OLIX_MODULE_UBUNTU_APACHE__CONFIGS}; do
       echo "apache/conf/$I.conf"
    done
    echo "apache/default/${OLIX_MODULE_UBUNTU_APACHE__DEFAULT}"
}


###
# Activation des modules Apache
##
function ubuntu_include_apache_modules()
{
    logger_debug "ubuntu_include_apache_modules ()"

    for I in ${OLIX_MODULE_UBUNTU_APACHE__MODULES}; do
        logger_info "Activation du module $I"
        a2enmod $I > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical
        echo -e "Activation du module ${CCYAN}$I${CVOID} : ${CVERT}OK ...${CVOID}"
    done
}


###
# Installation des fichiers de configuration
##
function ubuntu_include_apache_configs()
{
    logger_debug "ubuntu_include_apache_configs ()"

    logger_info "Suppression de la conf actuelle"
    rm -rf /etc/apache2/conf-enabled/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    rm -rf /etc/apache2/conf-available/olix* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    for I in $(ls ${__PATH_CONFIG}/conf/olix*); do
        module_ubuntu_installFileConfiguration "$I" "/etc/apache2/conf-available/"
    done
    for I in ${OLIX_MODULE_UBUNTU_APACHE__CONFIGS}; do
        logger_info "Activation de la conf $I"
        a2enconf $I > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical
        echo -e "Activation de la conf ${CCYAN}$I${CVOID} : ${CVERT}OK ...${CVOID}"
    done
}


###
# Activation du site par défaut
##
function ubuntu_include_apache_default()
{
    logger_debug "ubuntu_include_apache_default ()"

    if [[ -z ${OLIX_MODULE_UBUNTU_APACHE__DEFAULT} ]]; then
        logger_warning "Pas de site par défaut défini"
        return 1
    fi

    module_ubuntu_backupFileOriginal "/etc/apache2/sites-available/000-default.conf"

    logger_info "Effacement de /etc/apache2/sites-enabled/000-default.conf"
    rm -rf /etc/apache2/sites-enabled/000-default.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical

    module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/default/${OLIX_MODULE_UBUNTU_APACHE__DEFAULT}" "/etc/apache2/sites-available/000-default.conf"

    logger_info "Activation du site 000-default.conf"
    a2ensite 000-default.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    echo -e "Activation du site ${CCYAN}default.conf${CVOID} : ${CVERT}OK ...${CVOID}"
}
