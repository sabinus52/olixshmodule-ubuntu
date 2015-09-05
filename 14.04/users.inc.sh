###
# Création des utilisateurs
# ==============================================================================
# - Modification de l'utilisateur root
# - Création ou modification de l'utilisateur
# - Changement du prompt
# - Création des clés public et privée
# ------------------------------------------------------------------------------
# users:
#    user_1:
#        name:  (OLIX_MODULE_UBUNTU_USERS__USER_1__NAME)  Nom de l'utilisateur
#        param: (OLIX_MODULE_UBUNTU_USERS__USER_1__PARAM) Paramètres de l'utilisateur pour la création
#    user_N:
#        name:  (OLIX_MODULE_UBUNTU_USERS__USER_N__NAME)
#        param: (OLIX_MODULE_UBUNTU_USERS__USER_N__PARAM)
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Création et configuration du profile des utilisateurs ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (users, $1)"

    case $1 in
        install)
            ubuntu_include_install
            ;;
        config)
            ubuntu_include_config
            ;;
    esac
}


###
# Installation du service
##
ubuntu_include_install()
{
    logger_debug "ubuntu_include_install (users)"

    ubuntu_include_users_root
    echo -e "Configuration de l'utilisateur ${CCYAN}root${CVOID} : ${CVERT}OK ...${CVOID}"

    local USERLOCAL USERPARAM
    for (( I = 1; I < 10; I++ )); do
        eval "USERLOCAL=\${OLIX_MODULE_UBUNTU_USERS__USER_${I}__NAME}"
        [[ -z ${USERLOCAL} ]] && break
        eval "USERPARAM=\${OLIX_MODULE_UBUNTU_USERS__USER_${I}__PARAM}"

        ubuntu_include_users_user "${USERLOCAL}" "${USERPARAM}"
        echo -e "Configuration de l'utilisateur ${CCYAN}${USERLOCAL}${CVOID} : ${CVERT}OK ...${CVOID}"
    done
}


###
# Configuration du service
##
ubuntu_include_config()
{
    logger_debug "ubuntu_include_config (users)"

    ubuntu_include_install
}


###
# Configuration de l'utilisateur root
##
function ubuntu_include_users_root()
{
    logger_debug "ubuntu_include_users_root ()"

    logger_info "Couleur du prompt de root"
    sed -i "s/\#force_color_prompt/force_color_prompt/g" /root/.bashrc
    sed -i "s/\;32m/;31m/g" /root/.bashrc

    if [ ! -f /root/.ssh/id_dsa ]; then
        logger_info "Génération des clés publiques de root"
        ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -N ""
        [[ $? -ne 0 ]] && logger_critical "Génération des clés publiques de root"
    fi
    return 0
}


###
# Création et configuration de l'utilisateur
# @param $1 : Nom de l'utilisateur
# @param $2 : Paramètres de création
##
function ubuntu_include_users_user()
{
    logger_debug "ubuntu_include_users_user ($1)"
    local UTILISATEUR=$1
    local USERPARAMS=$2
    [[ -z $1 ]] && return 1

    # Test si l'utilisateur existe deja
    if cut -d : -f 1 /etc/passwd | grep ^${UTILISATEUR}$ > /dev/null; then
        logger_info "Modification de l'utilisateur '${UTILISATEUR}'"
        logger_debug "usermod ${USERPARAMS} ${UTILISATEUR}"
        usermod ${USERPARAMS} ${UTILISATEUR} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical "Modification de l'utilisateur '${UTILISATEUR}'"
    else
        logger_info "Création de l'utilisateur '${UTILISATEUR}'"
        logger_debug "useradd ${USERPARAMS} ${UTILISATEUR}"
        useradd ${USERPARAMS} ${UTILISATEUR} > ${OLIX_LOGGER_FILE_ERR} 2>&1
        [[ $? -ne 0 ]] && logger_critical "Création de l'utilisateur '${UTILISATEUR}'"
        echo -e "Mode de passe pour ${CCYAN}${UTILISATEUR}${CVOID}"
        passwd ${UTILISATEUR}
   fi
   
   # Customisation
   if su ${UTILISATEUR} -c "ls ~/.bashrc" > /dev/null 2>&1 ; then

       logger_info "Couleur du prompt de '${UTILISATEUR}'"
       su - ${UTILISATEUR} -c "sed -i 's/\#force_color_prompt/force_color_prompt/g' ~/.bashrc" > ${OLIX_LOGGER_FILE_ERR} 2>&1
       [[ $? -ne 0 ]] && logger_critical "Couleur du prompt de '${UTILISATEUR}'"
       
       if [ ! -f /home/${UTILISATEUR}/.ssh/id_dsa ]; then
            logger_info "Génération de la clé publique et privée de '${UTILISATEUR}'"
            su - ${UTILISATEUR} -c "ssh-keygen -q -t dsa -f ~/.ssh/id_dsa -N ''" > ${OLIX_LOGGER_FILE_ERR} 2>&1
            [[ $? -ne 0 ]] && logger_critical "Génération de la clé publique et privée de '${UTILISATEUR}'"
        fi

    fi
}
