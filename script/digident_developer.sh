###################################################
####   Configurazioni
###################################################

# User
UTENTE_LOGGATO=$(oc whoami)

# Progetto
PRJ_NOME='digident-developer'
PRJ_TITOLO='Digital Identity - Developer'
PRJ_DESCRIZIONE='Progetto per lo sviluppo dei microservizi di Digital Identity'

# Template
TEMPLATE_URI='https://raw.githubusercontent.com/sabafusco/Digital_Identity_openshift/master/template/digident_developer_template.yaml'

# Log
LOG_FILE='openshift_script.log'
DATA='date +%Y/%m/%d:%H:%M:%S'



####################################################
#    Parametri Template
####################################################

#Ip dei servizi rest esterni da invocare
PARAM_IP_REST_ESTERNI='192.168.13.73'

#Url html statico delle sezioni di pagina
PARAM_URL_HEADER='http://192.168.43.94/POC/html/header.html'
PARAM_URL_FOOTER='http://192.168.43.94/POC/html/footer.html'
PARAM_URL_ATTI='http://192.168.43.94/POC/html/atti.html'
PARAM_URL_FORMAZIONE='http://192.168.43.94/POC/html/formazione.html'
PARAM_URL_NEWSEVENTI='http://192.168.43.94/POC/html/newsEventi.html'
PARAM_URL_MENUINTRANET='http://192.168.43.94/POC/html/menuintranet.html'



####################################################
####  Funzioni
####################################################

function echo_log(){
        #$1 messaggio da stampare
        echo `$DATA`" $1" >> $LOG_FILE
        echo `$DATA`" $1"
}

function crea_progetto(){
        #$1 nome progetto
        #$2 titolo progetto
        #$3 descrizione progetto
        echo_log "Creazione progetto $1 ..."
        oc new-project $1 --display-name="$2" --description="$3" >> $LOG_FILE
}

function usa_progetto(){
        #$1 nome progetto
        echo_log "Progetto: $1 ."
        oc project $1 >> $LOG_FILE
}

function deploy_template(){
        #$1 uri template
        #$2 parametri da passare al template
        echo_log "Deploy del template $1 ..."
        oc new-app $1 $2 >> $LOG_FILE
}


###################################################
#### Logica
###################################################

echo_log "****INIT SCRIPT****"

crea_progetto "$PRJ_NOME" "$PRJ_TITOLO" "$PRJ_DESCRIZIONE"
sleep 5

usa_progetto "$PRJ_NOME"
sleep 5

deploy_template "$TEMPLATE_URI" "--param=IP_REST_ESTERNI=$PARAM_IP_REST_ESTERNI --param=URL_HEADER=$PARAM_URL_HEADER --param=URL_FOOTER=$PARAM_URL_FOOTER --param=URL_ATTI=$PARAM_URL_ATTI --param=URL_FORMAZIONE=$PARAM_URL_FORMAZIONE --param=URL_NEWSEVENTI=$PARAM_URL_NEWSEVENTI --param=URL_MENUINTRANET=$PARAM_URL_MENUINTRANET"
sleep 5

echo_log "****FINE SCRIPT****"