###
# Module d'installation et de configuration d'un serveur Ubuntu
# ==============================================================================
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##

OLIX_MODULE_NAME="ubuntu"

OLIX_MODULE_UBUNTU_VERSION_RELEASE=$(lsb_release -sr)
OLIX_MODULE_UBUNTU_SYNC_PORT=22

OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE=false
OLIX_MODULE_UBUNTU_PACKAGES_INSTALL="network virtualbox vmware users apache php mysql postgres nfs samba ftp postfix collectd logwatch monit snmpd tools"
OLIX_MODULE_UBUNTU_PACKAGES_CONFIG="apache php mysql postgres nfs samba ftp postfix collectd logwatch monit snmpd tools"
OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG="apache php mysql postgres nfs samba ftp postfix collectd logwatch monit snmpd tools"


###
# Retourne la liste des modules requis
##
olixmod_require_module()
{
    echo -e ""
}


###
# Retourne la liste des binaires requis
##
olixmod_require_binary()
{
    echo -e ""
}


###
# Usage de la commande
##
olixmod_usage()
{
    logger_debug "module_ubuntu__olixmod_usage ()"

    source modules/ubuntu/lib/usage.lib.sh
    module_ubuntu_usage_main
}


###
# Fonction de liste
##
olixmod_list()
{
    logger_debug "module_ubuntu__olixmod_list ($@)"
    echo
}


###
# Initialisation du module
##
olixmod_init()
{
    logger_debug "module_ubuntu__olixmod_init (null)"
    source modules/ubuntu/lib/action.lib.sh
    module_ubuntu_action_init $@
}


###
# Function principale
##
olixmod_main()
{
    logger_debug "module_ubuntu__olixmod_main ($@)"
    local ACTION=$1

    # Affichage de l'aide
    [ $# -lt 1 ] && olixmod_usage && core_exit 1
    [[ "$1" == "help" ]] && olixmod_usage && core_exit 0

    # Librairies necessaires
    source modules/ubuntu/lib/ubuntu.lib.sh
    source modules/ubuntu/lib/usage.lib.sh
    source modules/ubuntu/lib/action.lib.sh
    source lib/stdin.lib.sh
    source lib/file.lib.sh
    source lib/yaml.lib.sh
    source lib/filesystem.lib.sh

    if ! type "module_ubuntu_action_$ACTION" >/dev/null 2>&1; then
        logger_warning "Action inconnu : '$ACTION'"
        olixmod_usage 
        core_exit 1
    fi
    logger_info "Execution de l'action '${ACTION}' du module ${OLIX_MODULE_NAME} version ${OLIX_MODULE_UBUNTU_VERSION_RELEASE}"

    # Affichage de l'aide de l'action
    [[ "$2" == "help" && "$1" != "init" ]] && module_ubuntu_usage_$ACTION && core_exit 0

    # Charge la configuration du module
    [[ "$1" != "synccfg" ]] && config_loadConfigModule "${OLIX_MODULE_NAME}"

    shift
    module_ubuntu_usage_getParams $@
    module_ubuntu_action_$ACTION $@
}
