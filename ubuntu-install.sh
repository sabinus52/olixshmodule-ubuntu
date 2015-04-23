###
# Installation d'un serveur ubuntu et de ses packages
# ==============================================================================
# @package olixsh
# @module ubuntu
# @action install
# @author Olivier <sabinus52@gmail.com>
##



OLIX_MODULE_UBUNTU_PACKAGES_INSTALL="network virtualbox vmware users apache php mysql nfs samba ftp postfix collectd logwatch monit snmpd tools"


###
# Usage de la commande
##
ubuntu_install__usage()
{
    logger_debug "ubuntu_install__usage ()"
    stdout_printVersion
    echo
    echo -e "Installation d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID} et ses packages"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}install${CVOID} ${CBLANC}[PACKAGES] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -e "${CBLANC} --all|-a   ${CVOID} : Pour installer le serveur complet avec tous ses packages"
    echo
    echo -e "${CJAUNE}Liste des PACKAGES disponibles${CVOID} :"
    echo -e "${Cjaune} network    ${CVOID} : Configuration du réseau"
    echo -e "${Cjaune} users      ${CVOID} : Création des utilisateurs"
    echo -e "${Cjaune} virtualbox ${CVOID} : Installation et configuration des Tools Virtualbox"
    echo -e "${Cjaune} vmware     ${CVOID} : Installation et configuration des VMware Tools"
    echo -e "${Cjaune} apache     ${CVOID} : Installation et configuration d'Apache"
    echo -e "${Cjaune} php        ${CVOID} : Installation et configuration des modules PHP"
    echo -e "${Cjaune} mysql      ${CVOID} : Installation et configuration du MySQL"
    echo -e "${Cjaune} nfs        ${CVOID} : Installation et configuration du partage NFS"
    echo -e "${Cjaune} samba      ${CVOID} : Installation et configuration du partage Samba"
    echo -e "${Cjaune} ftp        ${CVOID} : Installation et configuration du serveur FTP"
    echo -e "${Cjaune} postfix    ${CVOID} : Installation et configuration du transport de mail"
    echo -e "${Cjaune} collectd   ${CVOID} : Installation et configuration des stats serveur"
    echo -e "${Cjaune} logwatch   ${CVOID} : Installation et configuration d'analyseur de log"
    echo -e "${Cjaune} monit      ${CVOID} : Installation et configuration du monitoring"
    echo -e "${Cjaune} snmpd      ${CVOID} : Installation et configuration du protocol de gestion du réseau"
    echo -e "${Cjaune} tools      ${CVOID} : Installation d'outils supplémentaire"
    echo -e "${Cjaune} help       ${CVOID} : Affiche cet écran"
}


###
# Fonction principale
# @param $1 : package ou option (--all|-a)
##
function ubuntu_install__main()
{
    logger_debug "ubuntu_install__main ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && ubuntu_install__usage && core_exit 1
    [[ "$1" == "help" ]] && ubuntu_install__usage && core_exit 0

    # Vérification de la saisie du nom du package
    logger_info "Vérification de la saisie du nom du package '$1'"
    local COMPLETE=false
    if [[ "$1" == "--all" || "$1" == "-a" ]]; then
        COMPLETE=true
    elif ! $(core_contains $1 "${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}"); then
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

    if [[ $COMPLETE == true ]]; then
        # Installation complete
        module_ubuntu_executeService main apt-update with-title
        for I in ${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}; do
            logger_info "Installation de '${I}'"
            module_ubuntu_executeService install ${I} with-title
        done
    else
        # Installation des services demandés
        for I in $@; do
            logger_info "Installation de '${I}'"
            if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_INSTALL}"); then
                logger_warning "Apparement le package '${I}' est inconnu !"
            else
                if [[ $# == 1 ]]; then
                    module_ubuntu_executeService install ${I}
                else
                    module_ubuntu_executeService install ${I} with-title
                fi
            fi
        done
        return $?
    fi
}