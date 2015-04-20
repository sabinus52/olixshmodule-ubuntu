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
# Excute une action sur le package
# @param $1 : action (install|config|save)
# @param $2 : nom du package
##
function module_ubuntu_executePackage()
{
    logger_debug "module_ubuntu_executePackage ($1, $2)"
    local FILEEXEC=${OLIX_MODULE_DIR}/${OLIX_MODULE_NAME}/${OLIX_MODULE_UBUNTU_VERSION_RELEASE}/$2.inc.sh

    logger_info "Chargement du fichier '$2.inc.sh' pour l'exécution de la tâche"
    if [[ ! -r ${FILEEXEC} ]]; then
        logger_error "Fichier introuvable : ${FILEEXEC}"
    fi
    source ${FILEEXEC}
    
    if ! type "ubuntu_include_$1" >/dev/null 2>&1; then
        logger_warning "Pas de tâche '$1' pour le package '$2'"
        return 1
    else
        ubuntu_include_$1
        return $?
    fi
}