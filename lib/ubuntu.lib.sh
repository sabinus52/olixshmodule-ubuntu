###
# Librairies de la gestion des serveurs d'Ubuntu
# ==============================================================================
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##



###
# Vérifie et charge le fichier de conf de la configuration du serveur
##
function module_ubuntu_loadConfiguration()
{
    logger_debug "module_ubuntu_loadConfiguration ()"
    local FILECFG="${OLIX_MODULE_UBUNTU_CONFIG}"

    if [[ ! -r ${FILECFG} ]]; then
        logger_warning "${FILECFG} absent"
        logger_critical "Impossible de charger le fichier de configuration du serveur"
    fi

    logger_info "Chargement du fichier '${FILECFG}'"
    yaml_parseFile "${FILECFG}" "OLIX_MODULE_UBUNTU_"
}


###
# Excute une action sur le service
# @param $1 : action (install|config|save)
# @param $2 : nom du package
##
function module_ubuntu_executeService()
{
    logger_debug "module_ubuntu_executeService ($1, $2)"
    local FILEEXEC=${OLIX_MODULE_DIR}/${OLIX_MODULE_NAME}/${OLIX_MODULE_UBUNTU_VERSION_RELEASE}/$2.inc.sh

    logger_info "Chargement du fichier '$2.inc.sh' pour l'exécution de la tâche"
    if [[ ! -r ${FILEEXEC} ]]; then
        logger_critical "Fichier introuvable : ${FILEEXEC}"
    fi
    source ${FILEEXEC}
    
    if ! type "ubuntu_include_$1" >/dev/null 2>&1; then
        logger_warning "Pas de tâche '$1' pour le service '$2'"
        return 1
    else
        ubuntu_include_title $1
        ubuntu_include_main $1
        return $?
    fi
}


###
# Sauvegarde le fichier de configuration original
# @param $1 : Fichier à conserver
##
function module_ubuntu_backupFileOriginal()
{
    logger_debug "module_ubuntu_backupFileOriginal ($1)"
    local ORIGINAL="$1.original"

    if [[ ! -f ${ORIGINAL} ]]; then
        logger_info "Sauvegarde de l'original '$1'"
        cp $1 ${ORIGINAL} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical "Impossible de sauvegarder '$1'"
    fi

    logger_info "Effacement de l'ancien fichier '$1'"
    rm -f $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical "Impossible d'effacer '$1'"

    logger_info "Remise de l'original du fichier '$1'"
    cp ${ORIGINAL} $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical "Impossible de remettre l'original '$1'"
}


###
# Installe un fichier de configuration dans son emplacement
# @param $1 : Fichier de configuration à lier
# @param $2 : Lien de destination
# @param $3 : Message
##
function module_ubuntu_installFileConfiguration()
{
    logger_debug "module_ubuntu_installFileConfiguration ($1, $2, $3)"

    # Si on ne choisit pas le mode par lien symbolique
    if [[ "${OLIX_MODULE_UBUNTU_PARAMETERS__MODE_CONFIG}" == "symlink" ]]; then
        filesystem_linkNodeConfiguration "$1" "$2"
    else
        filesystem_copyFileConfiguration "$1" "$2"
    fi
    [[ ! -z $3 ]] && echo -e "$3 : ${CVERT}OK ...${CVOID}"
    return 0
}


###
# Sauvegarde d'un fichier de configuration dans son emplacement d'origine
# @param $1 : Fichier de configuration à sauvegarder
# @param $2 : Fichier ou dossier d'origine
##
function module_ubuntu_backupFileConfiguration()
{
    logger_debug "module_ubuntu_backupFileConfiguration ($1, $2)"
    [[ ! -f $1 ]] && logger_critical "Le fichier '$1' n'existe pas"
    if [[ -L $1 ]]; then
        logger_warning "Sauvegarde inutile $1 : lien symbolique"
        return 0
    fi
    logger_debug "cp $1 $2"
    cp $1 $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    local OWNER=$(stat -c %U ${OLIX_MODULE_UBUNTU_CONFIG})
    local GROUP=$(stat -c %G ${OLIX_MODULE_UBUNTU_CONFIG})
    logger_debug "chown -R ${OWNER}.${GROUP} $2"
    chown -R ${OWNER}.${GROUP} $2 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    echo -e "Sauvegarde de $1 : ${CVERT}OK ...${CVOID}"
    return 0
}
