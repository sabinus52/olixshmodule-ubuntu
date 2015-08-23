###
# Installation et configuration de COLLECTD
# ==============================================================================
# - Installation des paquets COLLECTD
# - Installation des fichiers de configuration
# - Reset des données
# ------------------------------------------------------------------------------
# collectd:
#    enabled: (OLIX_MODULE_UBUNTU_COLLECTD__ENABLED)
#    plugins: (OLIX_MODULE_UBUNTU_COLLECTD__PLUGINS) Liste des plugins à activer
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
            echo -e "${CBLANC} Installation de COLLECTD ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de COLLECTD ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de COLLECTD ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (collectd, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_COLLECTD__ENABLED}" != true ]]; then
        logger_warning "Service 'collectd' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/collectd"

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
    logger_debug "ubuntu_include_install (collectd)"

    logger_info "Installation des packages COLLECTD"
    apt-get --yes install collectd librrds-perl libconfig-general-perl libhtml-parser-perl libregexp-common-perl
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages COLLECTD"

    # Activation des Plugins obligatoire
    ubuntu_include_collectd_plugins_required

    # Reset des données
    ubuntu_include_collectd_reset
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (collectd)"

    ubuntu_include_collectd_plugins
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (collectd)"

    logger_info "Redémarrage du service COLLECTD"
    service collectd restart
    [[ $? -ne 0 ]] && logger_error "Service COLLECTD NOT running"
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (collectd)"

    for I in ${OLIX_MODULE_UBUNTU_COLLECTD__PLUGINS}; do
        module_ubuntu_backupFileConfiguration "/etc/collectd/collectd.conf.d/$I.conf" "${__PATH_CONFIG}/$I.conf"
    done
   
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (collectd)"

    echo "collectd"
    for I in ${OLIX_MODULE_UBUNTU_COLLECTD__PLUGINS}; do
       echo "collectd/$I.conf"
    done
}


###
# Activation des Plugins obligatoire
##
function ubuntu_include_collectd_plugins_required()
{
    logger_debug "ubuntu_include_collectd_plugins_required ()"
    local PLUGINS="syslog rrdtool df cpu load memory processes swap users"

    module_ubuntu_backupFileOriginal "/etc/collectd/collectd.conf"
    logger_info "Commentaire sur les LoadPlugin"
    sed -i "s/^LoadPlugin/\#LoadPlugin/g" /etc/collectd/collectd.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    for I in ${PLUGINS}; do
        logger_info "Activation du plugin '${I}'"
        sed -i "s/^\#LoadPlugin $I/LoadPlugin $I/g" /etc/collectd/collectd.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error
    done
}


###
# Mise en place de la conf pour chaque plugin
##
function ubuntu_include_collectd_plugins()
{
    logger_debug "ubuntu_include_collectd_plugins"

    logger_info "Effacement des anciennes configurations"
    rm -f /etc/collectd/collectd.conf.d/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    for I in ${OLIX_MODULE_UBUNTU_COLLECTD__PLUGINS}; do
        module_ubuntu_installFileConfiguration "${__PATH_CONFIG}/${I}.conf" "/etc/collectd/collectd.conf.d" \
            "Activation du plugin ${CCYAN}${I}${CVOID}"
    done
}


###
# Reset des données
##
function ubuntu_include_collectd_reset()
{
    logger_debug "ubuntu_include_collectd_reset"

    echo -en "${Cjaune}ATTENTION !!! Ecrasement des fichiers de données RTM.${CVOID} : "
    stdin_readYesOrNo "Confirmer" false
    if [ ${OLIX_STDIN_RETURN} == true ]; then
        logger_info "Effacement des fichiers de données RRD"
        rm -rf /var/lib/collectd/rrd/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error
        echo -e "Effacement des fichiers de données RRD : ${CVERT}OK ...${CVOID}"
    fi
}
