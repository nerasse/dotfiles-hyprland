# ~/.bashrc

# Source .profile si il existe, pour charger les variables d'env et alias communs
if [ -f "${HOME}/.profile" ]; then
  . "${HOME}/.profile"  # ou 'source "${HOME}/.profile"' si vous préférez
fi


[[ $- != *i* ]] && return
PS1='[\u@\h \W]\$ '