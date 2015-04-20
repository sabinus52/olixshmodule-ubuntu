###
# Librairie du module UBUNTU
# ==============================================================================
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
##



###
# Vérifie si la configuration du module a été effectuée et la charge
## 
function module_ubuntu_loadConfig()
{
    logger_debug "module_ubuntu_loadConfig ()"

    logger_info "Test si la configuration est déjà effectuée"
    if ! config_isModuleExist ${OLIX_MODULE_NAME}; then
        logger_error "Pour reinitialiser la configuration, utiliser : ${OLIX_CORE_SHELL_NAME} ubuntu init"    
    fi

    local FILECONF=$(config_getFilenameModule ${OLIX_MODULE_NAME})
    logger_info "Charge le fichier de configuration ${FILECONF}"
    source ${FILECONF}
}


###
# Charge le fichier de configuration contenant les paramètes necessaires à l'installation et la configuration du serveur
##
function module_ubuntu_loadConfigFileParams()
{
    logger_debug "module_ubuntu_loadConfigFileParams ()"

    logger_info "Test si le fichier de configuration des paramètres existe"
    logger_debug "module_ubuntu OLIX_MODULE_UBUNTU_CONFIG=${OLIX_MODULE_UBUNTU_CONFIG}"
    if [[ ! -r ${OLIX_MODULE_UBUNTU_CONFIG} ]]; then
        logger_error "Le fichier '${OLIX_MODULE_UBUNTU_CONFIG}' est absent"
    fi
    eval $(file_parseYaml ${OLIX_MODULE_UBUNTU_CONFIG} "OLIX_MODULE_UBUNTU_")
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
        logger_error "Fichier introuvable : ${FILEEXEC}"
    fi
    source ${FILEEXEC}
    
    if ! type "ubuntu_include_$1" >/dev/null 2>&1; then
        logger_warning "Pas de tâche '$1' pour le service '$2'"
        return 1
    else
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
        [[ $? -ne 0 ]] && logger_error "Impossible de sauvegarder '$1'"
    fi

    logger_info "Effacement de l'ancien fichier '$1'"
    rm -f $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error "Impossible d'effacer '$1'"

    logger_info "Remise de l'original du fichier '$1'"
    cp ${ORIGINAL} $1 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error "Impossible de remettre l'original '$1'"
}