###
# Mise à jour du système
# ==============================================================================
# - Update des sources
# - Upgrade des packages
# ------------------------------------------------------------------------------
# @package olixsh
# @module ubuntu
# @action install update
# @author Olivier <sabinus52@gmail.com>
##


ubuntu_include_main()
{
    logger_info "Mise à jour des dépôts"
    apt-get update
    [[ $? -ne 0 ]] && logger_error "Update des dépôts"

    logger_info "Mise à jour des packages"
    apt-get --yes upgrade
    [[ $? -ne 0 ]] && logger_error "Update des packages"
}
