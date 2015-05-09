###
# Configuration du réseau
# ==============================================================================
# - Changement de l'adresse IP
# ------------------------------------------------------------------------------
# network:
#    addrip:     (OLIX_MODULE_UBUNTU_NETWORK__ADDRIP)    Valeur de l'adresse IP à ajouter
#    netmask:    (OLIX_MODULE_UBUNTU_NETWORK__NETMASK)   Masque réseau de cette IP
#    network:    (OLIX_MODULE_UBUNTU_NETWORK__NETWORK)   Adresse du réseau
#    broadcast:  (OLIX_MODULE_UBUNTU_NETWORK__BROADCAST) Adresse du broadcast
#    gateway:    (OLIX_MODULE_UBUNTU_NETWORK__GATEWAY)   Adresse de la passerelle
#    resolv:     (OLIX_MODULE_UBUNTU_NETWORK__RESOLV)    Liste des serveurs DNS
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @author Olivier <sabinus52@gmail.com>
# @version 14.04
##


ubuntu_include_title()
{
    echo
    echo -e "${CBLANC} Configuration réseau ${CVOID}"
    echo -e "-------------------------------------------------------------------------------"
}


###
# Fonction principal
# @param $1 : action à faire
##
ubuntu_include_main()
{
    logger_debug "ubuntu_include_main (network, $1)"

    case $1 in
        install)
            ubuntu_include_install
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
    logger_debug "ubuntu_include_install (network)" 

    # Affichage des infos
    echo -en "Adresse IP courante : "
    IP=`ifconfig eth0 | sed -n '/^[A-Za-z0-9]/ {N;/dr:/{;s/.*dr://;s/ .*//;p;}}'`
    IP=`ifconfig eth0 | awk 'NR==2 {print $2}'| awk -F: '{print $2}'`
    echo -e "${CBLEU}${IP}${CVOID}"

    if [[ ${OLIX_MODULE_UBUNTU_NETWORK__ADDRIP} == ${IP} ]]; then
        logger_warning "Configuration du réseau déjà effectué"
        return 1
    fi

    if [[ -z ${OLIX_MODULE_UBUNTU_NETWORK__ADDRIP} ]]; then
        logger_warning "Pas de configuration du réseau : conservation de l'IP actuelle"
        return 1
    else
        echo -e "Adresse IP à modifier : ${CCYAN}${OLIX_MODULE_UBUNTU_NETWORK__ADDRIP}${CVOID}"
    fi

    # Modifie si OK
    stdin_readYesOrNo "Confirmer pour la modification de la conf réseau" false
    if [[ ${OLIX_STDIN_RETURN} == true ]]; then
        ubuntu_include_network_config
        echo -e "Adresse ${CCYAN}${OLIX_MODULE_UBUNTU_NETWORK__ADDRIP}${CVOID} à modifier : ${CVERT}OK ...${CVOID}"
        ubuntu_include_restart
    fi
    return 0
}


###
# Redemarrage du service
##
ubuntu_include_restart()
{
    logger_debug "ubuntu_include_restart (network)"

    logger_info "Arrêt de eth0"
    ifdown eth0 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
    logger_info "Démarrage de eth0"
    ifup eth0 > ${OLIX_LOGGER_FILE_ERR} 2>&1
    [[ $? -ne 0 ]] && logger_error
}


###
#  Ecrit dans le fichier de configuration /etc/network/interfaces
##
function ubuntu_include_network_config()
{
    logger_debug "ubuntu_include_network_config ()"

    module_ubuntu_backupFileOriginal "/etc/network/interfaces"

    logger_info "Ecriture de l'IP '${OLIX_MODULE_UBUNTU_NETWORK__ADDRIP}' dans le fichier /etc/network/interfaces"
    cat > /etc/network/interfaces 2>${OLIX_LOGGER_FILE_ERR} <<EOT
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
  address ${OLIX_MODULE_UBUNTU_NETWORK__ADDRIP}
  netmask ${OLIX_MODULE_UBUNTU_NETWORK__NETMASK}
  network ${OLIX_MODULE_UBUNTU_NETWORK__NETWORK}
  broadcast ${OLIX_MODULE_UBUNTU_NETWORK__BROADCAST}
  gateway ${OLIX_MODULE_UBUNTU_NETWORK__GATEWAY}
  dns-nameservers ${OLIX_MODULE_UBUNTU_NETWORK__RESOLV}
EOT
    [[ $? -ne 0 ]] && logger_error
}