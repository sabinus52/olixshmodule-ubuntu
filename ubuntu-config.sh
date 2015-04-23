###
# Configuration des services des packages Ubuntu
# ==============================================================================
# @package olixsh
# @module ubuntu
# @action config
# @author Olivier <sabinus52@gmail.com>
##



OLIX_MODULE_UBUNTU_PACKAGES_CONFIG="apache php mysql nfs samba ftp postfix collectd logwatch monit snmpd tools"


###
# Usage de la commande
##
ubuntu_config__usage()
{
    logger_debug "ubuntu_config__usage ()"
    stdout_printVersion
    echo
    echo -e "Configuration des packages d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID}"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}config${CVOID} ${CBLANC}[PACKAGES]${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des PACKAGES disponibles${CVOID} :"
    echo -e "${Cjaune} apache     ${CVOID} : Configuration d'Apache"
    echo -e "${Cjaune} php        ${CVOID} : Configuration des modules PHP"
    echo -e "${Cjaune} mysql      ${CVOID} : Configuration du MySQL"
    echo -e "${Cjaune} nfs        ${CVOID} : Configuration du partage NFS"
    echo -e "${Cjaune} samba      ${CVOID} : Configuration du partage Samba"
    echo -e "${Cjaune} ftp        ${CVOID} : Configuration du serveur FTP"
    echo -e "${Cjaune} postfix    ${CVOID} : Configuration du transport de mail"
    echo -e "${Cjaune} collectd   ${CVOID} : Configuration des stats serveur"
    echo -e "${Cjaune} logwatch   ${CVOID} : Configuration d'analyseur de log"
    echo -e "${Cjaune} monit      ${CVOID} : Configuration du monitoring"
    echo -e "${Cjaune} snmpd      ${CVOID} : Configuration du protocol de gestion du réseau"
    echo -e "${Cjaune} tools      ${CVOID} : Configuration d'outils supplémentaires"
    echo -e "${Cjaune} help       ${CVOID} : Affiche cet écran"
}


###
# Fonction principale
# @param $1 : package
##
function ubuntu_config__main()
{
    logger_debug "ubuntu_config__main ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && ubuntu_config__usage && core_exit 1
    [[ "$1" == "help" ]] && ubuntu_config__usage && core_exit 0

    # Vérification de la saisie du nom du package
    logger_info "Vérification de la saisie du nom du package '$1'"
    if ! $(core_contains $1 "${OLIX_MODULE_UBUNTU_PACKAGES_CONFIG}"); then
        logger_error "Apparement le package '$1' est inconnu !"
    fi

    # Charge la configuration du module
    module_ubuntu_loadConfig

    # Charge le fichier de configuration contenant les paramètes necessaires à l'installation
    module_ubuntu_loadConfigFileParams

    # Test si ROOT
    logger_info "Test si root"
    core_checkIfRoot
    [[ $? -ne 0 ]] && logger_error "Seulement root peut executer cette action"


    # Configuration des services demandés
    for I in $@; do
        logger_info "Configuration de '${I}'"
        if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_CONFIG}"); then
            logger_warning "Apparement le package '${I}' est inconnu !"
        else
            if [[ $# == 1 ]]; then
                module_ubuntu_executeService config ${I}
            else
                module_ubuntu_executeService config ${I} with-title
            fi
        fi
    done
    return $?
}
