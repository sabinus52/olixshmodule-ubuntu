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

MODULE_UBUNTU_POSTGRES_VERSION="9.3"


ubuntu_include_title()
{
    case $1 in
        install)
            echo
            echo -e "${CBLANC} Installation de PostgreSQL ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        config)
            echo
            echo -e "${CBLANC} Configuration de PostgreSQL ${CVOID}"
            echo -e "-------------------------------------------------------------------------------"
            ;;
        savecfg)
            echo -e "${CBLANC} Sauvegarde de la configuration de PostgreSQL ${CVOID}"
            ;;
    esac
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (postgres, $1)"

    if [[ "${OLIX_MODULE_UBUNTU_POSTGRES__ENABLED}" != true ]]; then
        logger_warning "Service 'postgres' non activé"
        return 1
    fi

    __PATH_CONFIG="$(dirname ${OLIX_MODULE_UBUNTU_CONFIG})/postgres"

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
    logger_debug "ubuntu_include_install (postgres)"

    logger_info "Installation des packages PostgreSQL"
    apt-get --yes install postgresql postgresql-contrib
    [[ $? -ne 0 ]] && logger_critical "Impossible d'installer les packages PostgreSQL"

    # Désactivation de AppArmor
    #if [ -f /etc/apparmor.d/usr.sbin.mysqld ]; then
    #    logger_info  "Désactivation du fichier de configuration appArmor"
    #    ln -sf /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld > ${OLIX_LOGGER_FILE_ERR} 2>&1
    #    [[ $? -ne 0 ]] && logger_critical
    #    service apparmor reload
    #    [[ $? -ne 0 ]] && logger_critical "Service APPARMOR NOT running"
    #fi

    [[ -z ${OLIX_MODULE_UBUNTU_POSTGRES__PATH} ]] && return 0
    echo -e "Création de l'instance PostgreSQL dans ${CCYAN}${OLIX_MODULE_UBUNTU_POSTGRES__PATH}${CVOID}"
    OLIX_STDIN_RETURN=true
    if [[ -d ${OLIX_MODULE_UBUNTU_POSTGRES__PATH} ]]; then
        echo -e "${CJAUNE}ATTENTION !!! L'instance existe déjà dans le répertoire '${OLIX_MODULE_UBUNTU_POSTGRES__PATH}'${CVOID}"
        stdin_readYesOrNo "Confirmer pour ECRASEMENT" false
    fi
    # Initialisation du répertoire contenant les données de la base
    [[ ${OLIX_STDIN_RETURN} == true ]] && ubuntu_include_postgres_path
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (postgres)"

    # Mise en place du fichier de configuration
    if [[ -n "${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}" ]]; then
        module_ubuntu_backupFileOriginal "/etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/postgresql.conf"
        module_ubuntu_installFileConfiguration \
            "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}" "/etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/postgresql.conf" \
            "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}${CVOID} vers /etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/postgresql.conf"
        logger_debug "chown postgres.postgres /etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/postgresql.conf"
        chown postgres.postgres /etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/postgresql.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical
    fi
    if [[ -n "${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}" ]]; then
        module_ubuntu_backupFileOriginal "/etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/pg_hba.conf"
        module_ubuntu_installFileConfiguration \
            "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}" "/etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/pg_hba.conf" \
            "Mise en place de ${CCYAN}${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}${CVOID} vers /etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/pg_hba.conf"
        logger_debug "chown postgres.postgres /etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/pg_hba.conf"
        chown postgres.postgres /etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/pg_hba.conf > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical
    fi
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (postgres)"

    logger_info "Redémarrage du service PostgreSQL"
    service postgresql restart
    [[ $? -ne 0 ]] && logger_critical "Service PostgreSQL NOT running"
}


###
# Sauvegarde de la configuration
##
ubuntu_include_savecfg()
{
    logger_debug "ubuntu_include_savecfg (postgres)"

    [[ -n "${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}" ]] && module_ubuntu_backupFileConfiguration "/etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/postgresql.conf" "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}"
    [[ -n "${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}" ]] && module_ubuntu_backupFileConfiguration "/etc/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/main/pg_hba.conf" "${__PATH_CONFIG}/${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}"
}


###
# Synchronisation de la configuration
##
ubuntu_include_synccfg()
{
    logger_debug "ubuntu_include_synccfg (postgres)"

    echo "postgres"
    [[ -n "${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}" ]] && echo "postgres/${OLIX_MODULE_UBUNTU_POSTGRES__FILECFG}"
    [[ -n "${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}" ]] && echo "postgres/${OLIX_MODULE_UBUNTU_POSTGRES__FILEAUTH}"
}


###
# Initialisation du répertoire contenant les données de la base
##
function ubuntu_include_postgres_path()
{
    logger_debug "ubuntu_include_postgres_path ()"
    local POSTGRES_PATH=${OLIX_MODULE_UBUNTU_POSTGRES__PATH}

    service postgresql stop
    logger_info "Initialisation de ${POSTGRES_PATH}"
    if [[ -d ${POSTGRES_PATH} ]]; then
        logger_debug "rm -rf ${POSTGRES_PATH}"
        rm -rf ${POSTGRES_PATH}/* > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical
    else
        logger_debug "mkdir -p ${POSTGRES_PATH}"
        mkdir -p ${POSTGRES_PATH} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical
    fi
    logger_debug "chown -R postgres.postgres ${POSTGRES_PATH}"
    chown -R postgres:postgres ${POSTGRES_PATH} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    logger_debug "chmod 700 ${POSTGRES_PATH}"
    chmod 700 ${POSTGRES_PATH} > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_critical
    logger_debug "/usr/lib/postgresql/9.3/bin/initdb -D ${POSTGRES_PATH}; exit $?"
    su - postgres --command "/usr/lib/postgresql/${MODULE_UBUNTU_POSTGRES_VERSION}/bin/initdb -D ${POSTGRES_PATH}; exit $?"
    [[ $? -ne 0 ]] && logger_critical
    echo -e "Regenération de l'instance PostgreSQL : ${CVERT}OK ...${CVOID}"
}
