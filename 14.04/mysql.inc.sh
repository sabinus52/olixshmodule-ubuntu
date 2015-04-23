###
# Installation et configuration de MySQL
# ==============================================================================
# - Installation des paquets MySQL
# - Déplacement des fichiers de l'instance
# - Installation des fichiers de configuration
# - Configuration des droits
# ------------------------------------------------------------------------------
# mysql:
#   enabled: (OLIX_MODULE_UBUNTU_MYSQL__ENABLED)
#   path:    (OLIX_MODULE_UBUNTU_MYSQL__PATH)     Chemin des bases mysql
#   filecfg: (OLIX_MODULE_UBUNTU_MYSQL__FILECFG)  Fichier my.cnf à utiliser
#   script:  (OLIX_MODULE_UBUNTU_MYSQL__SCRIPT)   Script sql
#   users:
#     user_1:
#        name:  (OLIX_MODULE_UBUNTU_MYSQL__USERS__USER_1__NAME)  
#        grant: (OLIX_MODULE_UBUNTU_MYSQL__USERS__USER_1__GRANT)
#     user_N:
#        name:  (OLIX_MODULE_UBUNTU_MYSQL__USERS__USER_N__NAME)
#        grant: (OLIX_MODULE_UBUNTU_MYSQL__USERS__USER_n__GRANT)
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Installation et Configuration de MYSQL ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (mysql, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_MYSQL__ENABLED}" != true ]]; then
        logger_warning "Service 'mysql' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/mysql"

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
    esac
}


###
# Installation du service
##
ubuntu_include_install()
{
    logger_debug "ubuntu_include_install (mysql)"

    logger_info "Installation des packages MYSQL"
    apt-get --yes install mysql-server
    [[ $? -ne 0 ]] && logger_error "Impossible d'installer les packages MYSQL"

    # Désactivation de AppArmor
    if [ -f /etc/apparmor.d/usr.sbin.mysqld ]; then
        logger_info  "Désactivation du fichier de configuration appArmor"
        ln -sf /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error
        service apparmor reload
        [[ $? -ne 0 ]] && logger_error "Service APPARMOR NOT running"
    fi

    [[ -z ${OLIX_MODULE_UBUNTU_MYSQL__PATH} ]] && return 0
    echo -e "Création de l'instance MySQL dans ${CCYAN}${OLIX_MODULE_UBUNTU_MYSQL__PATH}${CVOID}"
    OLIX_STDIN_RETURN=true
    if [[ -d ${OLIX_MODULE_UBUNTU_MYSQL__PATH} ]]; then
        echo -e "${CJAUNE}ATTENTION !!! L'instance existe déjà dans le répertoire '${OLIX_MODULE_UBUNTU_MYSQL__PATH}'${CVOID}"
        stdin_readYesOrNo "Confirmer pour ECRASEMENT" false
    fi
    # Initialisation du répertoire contenant les données de la base
    [[ ${OLIX_STDIN_RETURN} == true ]] && ubuntu_include_mysql_path
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (mysql)"

    # Mise en place du fichier de configuration
    module_ubuntu_installFileConfiguration \
        "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_MYSQL__FILECFG}" "/etc/mysql/conf.d/" \
        "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_MYSQL__FILECFG}${CVOID} vers /etc/mysql/conf.d"

    ubuntu_include_restart

    # Demande du mot de passe
    stdin_readPassword "Mot de passe du serveur MYSQL en tant que root"
    MYSQL_PASSWORD=${OLIX_STDIN_RETURN}

    # Execution du script
    [[ -n ${OLIX_MODULE_UBUNTU_MYSQL__SCRIPT} ]] && ubuntu_include_mysql_script

    # Déclaration des utilisateurs
    ubuntu_include_mysql_users
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (mysql)"

    logger_info "Redémarrage du service MYSQL"
    service mysql restart
    [[ $? -ne 0 ]] && logger_error "Service MYSQL NOT running"
}


###
# Initialisation du répertoire contenant les données de la base
##
function ubuntu_include_mysql_path()
{
    logger_debug "ubuntu_include_mysql_path ()"
    local MYSQL_PATH=${OLIX_MODULE_UBUNTU_MYSQL__PATH}

    service mysql stop
    logger_info "Initialisation de ${MYSQL_PATH}"
    if [[ -d ${MYSQL_PATH} ]]; then
        logger_debug "rm -rf ${MYSQL_PATH}"
        rm -rf ${MYSQL_PATH}/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error
    else
        logger_debug "mkdir -p ${MYSQL_PATH}"
        mkdir -p ${MYSQL_PATH} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error
    fi
    logger_debug "chown -R mysql.mysql ${MYSQL_PATH}"
    chown -R mysql:mysql /home/mysql > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    logger_debug "cp -rp /var/lib/mysql/ ${MYSQL_PATH}"
    cp -rp /var/lib/mysql/* ${MYSQL_PATH} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Regenération de l'instance MySQL : ${CVERT}OK ...${CVOID}"
    service mysql start
}


###
# Execution du script SQL
##
function ubuntu_include_mysql_script()
{
    logger_debug "ubuntu_include_mysql_script ()"
    local SCRIPT=${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_MYSQL__SCRIPT}

    logger_info "Execution du script ${OLIX_MODULE_UBUNTU_MYSQL__SCRIPT}"
    [[ ! -f ${SCRIPT} ]] && logger_error "Le fichier ${SCRIPT} n'existe pas"
    cat ${SCRIPT} | mysql --user=root --password=${MYSQL_PASSWORD} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    echo -e "Execution du script SQL : ${CVERT}OK ...${CVOID}"
}


###
# Déclaration des utilisateurs et des privilèges
##
function ubuntu_include_mysql_users()
{
    logger_debug "ubuntu_include_mysql_users ()"
    local USERNAME USERGRANT

    for (( I = 1; I < 10; I++ )); do
        eval "USERNAME=\${OLIX_MODULE_UBUNTU_MYSQL__USERS__USER_${I}__NAME}"
        [[ -z ${USERNAME} ]] && break
        eval "USERGRANT=\${OLIX_MODULE_UBUNTU_MYSQL__USERS__USER_${I}__GRANT}"
        USERGRANT=$(echo ${USERGRANT} | sed "s/\\\\//g")
        logger_info "Privilège de l'utilisateur '${USERNAME}'"

        # Création de l'utilisateur si celui-ci n'existe pas
        logger_debug "CONCAT(QUOTE(user), '@', QUOTE(host)) = \"${USERNAME}\""
        if echo "SELECT COUNT(*) FROM mysql.user WHERE CONCAT(QUOTE(user), '@', QUOTE(host)) = \"${USERNAME}\";" \
            | mysql --user=root --password=${MYSQL_PASSWORD} | grep 0 > /dev/null; then
            stdin_readDoublePassword "Choisir un mot de passe pour l'utilisateur ${CCYAN}${USERNAME}${CVOID}"
            logger_debug "CREATE USER ${USERNAME} IDENTIFIED BY '????'"
            mysql --user=root --password=${MYSQL_PASSWORD} \
                --execute="CREATE USER ${USERNAME} IDENTIFIED BY '${OLIX_STDIN_RETURN}'" > ${OLIX_LOGGER_FILE_ERR} 2>&1
            [[ $? -ne 0 ]] && logger_error
        fi

        logger_debug "'${USERGRANT}'"
        mysql --user=root --password=${MYSQL_PASSWORD} --execute="${USERGRANT}" > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_error

        echo -e "Privilèges de l'utilisateur ${CCYAN}${USERNAME}${CVOID} : ${CVERT}OK ...${CVOID}"
    done
}