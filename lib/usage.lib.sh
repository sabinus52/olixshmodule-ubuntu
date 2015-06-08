###
# Usage du module UBUNTU
# ==============================================================================
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##



###
# Usage principale du module
##
function module_ubuntu_usage_main()
{
    logger_debug "module_ubuntu_usage_main ()"
    stdout_printVersion
    echo
    echo -e "Installation, configuration et gestion d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID}"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}action${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des ACTIONS disponibles${CVOID} :"
    echo -e "${Cjaune} init    ${CVOID}  : Initialisation du bundle"
    echo -e "${Cjaune} install ${CVOID}  : Installation d'un package"
    echo -e "${Cjaune} config  ${CVOID}  : Installation des fichiers de configuration d'un package"
    echo -e "${Cjaune} update  ${CVOID}  : Mise à jour du système"
    echo -e "${Cjaune} savecfg ${CVOID}  : Sauvegarde de la configuration actuelle"
    echo -e "${Cjaune} help    ${CVOID}  : Affiche cet écran"
}


###
# Usage de l'action INSTALL
##
function module_ubuntu_usage_install()
{
    logger_debug "module_ubuntu_usage_install ()"
    stdout_printVersion
    echo
    echo -e "Installation d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID} et ses packages"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}install${CVOID} ${CBLANC}packages [OPTIONS]${CVOID}"
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
    echo -e "${Cjaune} postgres   ${CVOID} : Installation et configuration de PostgreSQL"
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
# Usage de l'action CONFIG
##
function module_ubuntu_usage_config()
{
    logger_debug "module_ubuntu_usage_config ()"
    stdout_printVersion
    echo
    echo -e "Configuration des packages d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID}"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}config${CVOID} ${CBLANC}packages${CVOID}"
    echo
    echo -e "${CJAUNE}Liste des PACKAGES disponibles${CVOID} :"
    echo -e "${Cjaune} apache     ${CVOID} : Configuration d'Apache"
    echo -e "${Cjaune} php        ${CVOID} : Configuration des modules PHP"
    echo -e "${Cjaune} mysql      ${CVOID} : Configuration du MySQL"
    echo -e "${Cjaune} postgres   ${CVOID} : Configuration de PostgreSQL"
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
# Usage de l'action SAVECFG
##
function module_ubuntu_usage_savecfg()
{
    logger_debug "module_ubuntu_usage_savecfg ()"
    stdout_printVersion
    echo
    echo -e "Sauvegarde de la configuration des services d'un serveur Ubuntu ${CBLANC}${OLIX_MODULE_UBUNTU_VERSION_RELEASE}${CVOID}"
    echo
    echo -e "${CBLANC} Usage : ${CVIOLET}$(basename ${OLIX_ROOT_SCRIPT}) ${CVERT}ubuntu ${CJAUNE}savecfg${CVOID} ${CBLANC}packages [OPTIONS]${CVOID}"
    echo
    echo -e "${Ccyan}OPTIONS${CVOID}"
    echo -e "${CBLANC} --all|-a   ${CVOID} : Pour sauvegarder toutes les configuration des packages"
    echo
    echo -e "${CJAUNE}Liste des PACKAGES disponibles${CVOID} :"
    echo -e "${Cjaune} apache     ${CVOID} : Sauvegarde de la configuration d'Apache"
    echo -e "${Cjaune} php        ${CVOID} : Sauvegarde de la configuration des modules PHP"
    echo -e "${Cjaune} mysql      ${CVOID} : Sauvegarde de la configuration de MySQL"
    echo -e "${Cjaune} postgres   ${CVOID} : Sauvegarde de la configuration de PostgreSQL"
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
# Retourne les paramètres de la commandes en fonction des options
# @param $@ : Liste des paramètres
##
function module_ubuntu_usage_getParams()
{
    logger_debug module_ubuntu_usage_getParams
    local PARAM

    while [[ $# -ge 1 ]]; do
        case $1 in
            --all)
                OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE=true
                ;;
            *)
                OLIX_MODULE_UBUNTU_PACKAGES="${OLIX_MODULE_UBUNTU_PACKAGES} $1"
                ;;
        esac
        shift
    done
    logger_debug "OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE=${OLIX_MODULE_UBUNTU_PACKAGES_COMPLETE}"
    logger_debug "OLIX_MODULE_UBUNTU_PACKAGES=${OLIX_MODULE_UBUNTU_PACKAGES}"
}
