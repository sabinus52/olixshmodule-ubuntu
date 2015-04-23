###
# Sauvegarde de la configuration des différents services d'un serveur Ubuntu
# ==============================================================================
# @package olixsh
# @module ubuntu
# @action savecfg
# @author Olivier <sabinus52@gmail.com>
##



OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG="apache php mysql nfs samba ftp postfix collectd logwatch monit snmpd tools"


###
# Usage de la commande
##
ubuntu_savecfg__usage()
{
    logger_debug "ubuntu_savecfg__usage ()"
    stdout_printVersion
    echo
    echo -e "Sauvegarde de la configuration des services d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID}"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}savecfg${CVOID} ${CBLANC}[PACKAGES] [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -e "${CBLANC} --all|-a   ${CVOID} : Pour sauvegarder toutes les configuration des packages"
    echo
    echo -e "${CJAUNE}Liste des PACKAGES disponibles${CVOID} :"
    echo -e "${Cjaune} apache     ${CVOID} : Sauvegarde de la configuration d'Apache"
    echo -e "${Cjaune} php        ${CVOID} : Sauvegarde de la configuration des modules PHP"
    echo -e "${Cjaune} mysql      ${CVOID} : Sauvegarde de la configuration de MySQL"
    echo -e "${Cjaune} nfs        ${CVOID} : Sauvegarde de la configuration du partage NFS"
    echo -e "${Cjaune} samba      ${CVOID} : Sauvegarde de la configuration du partage Samba"
    echo -e "${Cjaune} ftp        ${CVOID} : Sauvegarde de la configuration du serveur FTP"
    echo -e "${Cjaune} postfix    ${CVOID} : Sauvegarde de la configuration du transport de mail"
    echo -e "${Cjaune} collectd   ${CVOID} : Sauvegarde de la configuration des stats serveur"
    echo -e "${Cjaune} logwatch   ${CVOID} : Sauvegarde de la configuration d'analyseur de log"
    echo -e "${Cjaune} monit      ${CVOID} : Sauvegarde de la configuration du monitoring"
    echo -e "${Cjaune} snmpd      ${CVOID} : Sauvegarde de la configuration du protocol de gestion du réseau"
    echo -e "${Cjaune} tools      ${CVOID} : Sauvegarde de la configuration des outils supplémentaires"
    echo -e "${Cjaune} help       ${CVOID} : Affiche cet écran"
}


###
# Fonction principale
# @param $1 : package ou option (--all|-a)
##
function ubuntu_savecfg__main()
{
    logger_debug "ubuntu_savecfg__main ($@)"

    # Affichage de l'aide
    [ $# -lt 1 ] && ubuntu_savecfg__usage && core_exit 1
    [[ "$1" == "help" ]] && ubuntu_savecfg__usage && core_exit 0

    # Vérification de la saisie du nom du package
    logger_info "Vérification de la saisie du nom du package '$1'"
    local COMPLETE=false
    if [[ "$1" == "--all" || "$1" == "-a" ]]; then
        COMPLETE=true
    elif ! $(core_contains $1 "${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}"); then
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

    echo -e "${CJAUNE}ATTENTION !!! Cela va écraser les fichiers d'origine dans $(dirname ${OLIX_MODULE_UBUNTU_CONFIG}) ${CVOID}"
    stdin_readYesOrNo "Confirmer" false
    [[ ${OLIX_STDIN_RETURN} == false ]] && return 0

    if [[ $COMPLETE == true ]]; then
        #Sauvegarde complete
        for I in ${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}; do
            logger_info "Sauvegarde de la configuration de '${I}'"
            module_ubuntu_executeService savecfg ${I} with-title
        done
    else
        # Sauvegarde des services demandés
        for I in $@; do
            logger_info "Sauvegarde de la configuration de '${I}'"
            if ! $(core_contains ${I} "${OLIX_MODULE_UBUNTU_PACKAGES_SAVECFG}"); then
                logger_warning "Apparement le package '${I}' est inconnu !"
            else
                if [[ $# == 1 ]]; then
                    module_ubuntu_executeService savecfg ${I}
                else
                    module_ubuntu_executeService savecfg ${I} with-title
                fi
            fi
        done
        return $?
    fi
}
