###################################################
####   Configurazioni
###################################################

# User
UTENTE_LOGGATO=$(oc whoami)

# Progetto DevOps
PRJ_NOME_DEVOPS='dev-ops'
PRJ_TITOLO_DEVOPS='DevOps'
PRJ_DESCRIZIONE_DEVOPS='Strumenti di DevOps'
SERVICE_ACCOUNT_JENKINS='system:serviceaccount:dev-ops:jenkins'
RUOLO_SERVICE_ACCOUNT='admin'

# Progetto Sviluppo
PRJ_NOME_SVIL='digital-identity-sviluppo'
PRJ_TITOLO_SVIL='Digital Identity - Sviluppo'
PRJ_DESCRIZIONE_SVIL='Progetto Digital Identity ambiente di SVILUPPO'

# Progetto Collaudo
PRJ_NOME_COLL='digital-identity-collaudo'
PRJ_TITOLO_COLL='Digital Identity - Collaudo'
PRJ_DESCRIZIONE_COLL='Progetto Digital Identity ambiente di COLLAUDO'

# Progetto Produzione
PRJ_NOME_PROD='digital-identity-produzione'
PRJ_TITOLO_PROD='Digital Identity - Produzione'
PRJ_DESCRIZIONE_PROD='Progetto Digital Identity ambiente di PRODUZIONE'

# Template
TEMPLATE_URI_DEVOPS='https://raw.githubusercontent.com/sabafusco/Digital_Identity_openshift/master/template/devops_template.yaml'
TEMPLATE_URI_DIGIDENT='https://raw.githubusercontent.com/sabafusco/Digital_Identity_openshift/master/template/digident_template.yaml'

# Log
LOG_FILE='openshift_script.log'
DATA='date +%Y/%m/%d:%H:%M:%S'



####################################################
#    Parametri Template
####################################################

#Route assegnata al progetto apache 
HOSTNAME_APACHE_SVILUPPO=openshift.sviluppo.inail.it
HOSTNAME_APACHE_COLLAUDO=openshift.collaudo.inail.it
HOSTNAME_APACHE_PRODUZIONE=openshift.produzione.inail.it

#Ip dei servizi rest esterni da invocare da sviluppo
PARAM_IP_REST_ESTERNI_SVIL='192.168.13.73'

#Ip dei servizi rest esterni da invocare da collaudo
PARAM_IP_REST_ESTERNI_COLL='192.168.13.73'

#Ip dei servizi rest esterni da invocare da produzione
PARAM_IP_REST_ESTERNI_PROD='192.168.13.73'

#Url html statico delle sezioni di pagina da sviluppo
PARAM_URL_HEADER_SVIL='http://192.168.43.94/POC/html/header.html'
PARAM_URL_FOOTER_SVIL='http://192.168.43.94/POC/html/footer.html'
PARAM_URL_ATTI_SVIL='http://192.168.43.94/POC/html/atti.html'
PARAM_URL_FORMAZIONE_SVIL='http://192.168.43.94/POC/html/formazione.html'
PARAM_URL_NEWSEVENTI_SVIL='http://192.168.43.94/POC/html/newsEventi.html'
PARAM_URL_MENUINTRANET_SVIL='http://192.168.43.94/POC/html/menuintranet.html'


#Url html statico delle sezioni di pagina da collaudo
PARAM_URL_HEADER_COLL='http://192.168.43.94/POC/html/header.html'
PARAM_URL_FOOTER_COLL='http://192.168.43.94/POC/html/footer.html'
PARAM_URL_ATTI_COLL='http://192.168.43.94/POC/html/atti.html'
PARAM_URL_FORMAZIONE_COLL='http://192.168.43.94/POC/html/formazione.html'
PARAM_URL_NEWSEVENTI_COLL='http://192.168.43.94/POC/html/newsEventi.html'
PARAM_URL_MENUINTRANET_COLL='http://192.168.43.94/POC/html/menuintranet.html'


#Url html statico delle sezioni di pagina da produzione
PARAM_URL_HEADER_PROD='http://192.168.43.94/POC/html/header.html'
PARAM_URL_FOOTER_PROD='http://192.168.43.94/POC/html/footer.html'
PARAM_URL_ATTI_PROD='http://192.168.43.94/POC/html/atti.html'
PARAM_URL_FORMAZIONE_PROD='http://192.168.43.94/POC/html/formazione.html'
PARAM_URL_NEWSEVENTI_PROD='http://192.168.43.94/POC/html/newsEventi.html'
PARAM_URL_MENUINTRANET_PROD='http://192.168.43.94/POC/html/menuintranet.html'



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

function assegna_ruolo_a_serviceaccount(){
        #$1 ruolo da assoociare
        #$2 service account a cui associare il ruolo
	echo_log "assegnazione del ruolo $1 al service account $2 ..."
	oc policy add-role-to-user $1 $2
}

function attendi_condizione() {
        #$1 nome dell'applicazione da verificare usato solo per i log
        #$2 timeout in sec
        #$3 comando per verificare se l'app � pronta 
        local TIMEOUT=$(($2/5))
        local CONDIZIONE=$3

        echo_log "In attesa che $1 sia pronto..."
        local x=1
        
        while [ -z "$(eval ${CONDIZIONE})" ]
        do
          echo_log "."
          sleep 5
          x=$(( $x + 1 ))
          if [ $x -gt $TIMEOUT ]
          then
            echo_log "$1 non � pronto!"
            exit 255
          fi
        done

        echo_log "$1 � PRONTO."
}


###################################################
#### Logica
###################################################

echo_log "****INIT SCRIPT****"

#Dev Ops
crea_progetto "$PRJ_NOME_DEVOPS" "$PRJ_TITOLO_DEVOPS" "$PRJ_DESCRIZIONE_DEVOPS"
usa_progetto "$PRJ_NOME_DEVOPS"
deploy_template "$TEMPLATE_URI_DEVOPS"
attendi_condizione "Progetto DevOps" 600 "oc get pods -n $PRJ_NOME_DEVOPS | grep 'jenkins.*'"
sleep 5

#Ambiente SVILUPPO
crea_progetto "$PRJ_NOME_SVIL" "$PRJ_TITOLO_SVIL" "$PRJ_DESCRIZIONE_SVIL"
usa_progetto "$PRJ_NOME_SVIL"
assegna_ruolo_a_serviceaccount $RUOLO_SERVICE_ACCOUNT $SERVICE_ACCOUNT_JENKINS
deploy_template "$TEMPLATE_URI_DIGIDENT" "--param=HOSTNAME_APACHE=$HOSTNAME_APACHE_SVILUPPO --param=IP_REST_ESTERNI=$PARAM_IP_REST_ESTERNI_SVIL --param=URL_HEADER=$PARAM_URL_HEADER_SVIL --param=URL_FOOTER=$PARAM_URL_FOOTER_SVIL --param=URL_ATTI=$PARAM_URL_ATTI_SVIL --param=URL_FORMAZIONE=$PARAM_URL_FORMAZIONE_SVIL --param=URL_NEWSEVENTI=$PARAM_URL_NEWSEVENTI_SVIL --param=URL_MENUINTRANET=$PARAM_URL_MENUINTRANET_SVIL"
attendi_condizione "Ambiente sviluppo" 600 "oc get pods -n $PRJ_NOME_SVIL | grep 'postgres.*'"
sleep 5

#Ambiente COLLAUDO
crea_progetto "$PRJ_NOME_COLL" "$PRJ_TITOLO_COLL" "$PRJ_DESCRIZIONE_COLL"
usa_progetto "$PRJ_NOME_COLL"
assegna_ruolo_a_serviceaccount $RUOLO_SERVICE_ACCOUNT $SERVICE_ACCOUNT_JENKINS
deploy_template "$TEMPLATE_URI_DIGIDENT" "--param=HOSTNAME_APACHE=$HOSTNAME_APACHE_COLLAUDO --param=IP_REST_ESTERNI=$PARAM_IP_REST_ESTERNI_COLL --param=URL_HEADER=$PARAM_URL_HEADER_COLL --param=URL_FOOTER=$PARAM_URL_FOOTER_COLL --param=URL_ATTI=$PARAM_URL_ATTI_COLL --param=URL_FORMAZIONE=$PARAM_URL_FORMAZIONE_COLL --param=URL_NEWSEVENTI=$PARAM_URL_NEWSEVENTI_COLL --param=URL_MENUINTRANET=$PARAM_URL_MENUINTRANET_COLL"
attendi_condizione "Ambiente collaudo" 600 "oc get pods -n $PRJ_NOME_COLL | grep 'postgres.*'"
sleep 5

#Ambiente PRODUZIONE
crea_progetto "$PRJ_NOME_PROD" "$PRJ_TITOLO_PROD" "$PRJ_DESCRIZIONE_PROD"
usa_progetto "$PRJ_NOME_PROD"
assegna_ruolo_a_serviceaccount $RUOLO_SERVICE_ACCOUNT $SERVICE_ACCOUNT_JENKINS
deploy_template "$TEMPLATE_URI_DIGIDENT" "--param=HOSTNAME_APACHE=$HOSTNAME_APACHE_PRODUZIONE --param=IP_REST_ESTERNI=$PARAM_IP_REST_ESTERNI_PROD --param=URL_HEADER=$PARAM_URL_HEADER_PROD --param=URL_FOOTER=$PARAM_URL_FOOTER_PROD --param=URL_ATTI=$PARAM_URL_ATTI_PROD --param=URL_FORMAZIONE=$PARAM_URL_FORMAZIONE_PROD --param=URL_NEWSEVENTI=$PARAM_URL_NEWSEVENTI_PROD --param=URL_MENUINTRANET=$PARAM_URL_MENUINTRANET_PROD"
attendi_condizione "Ambiente produzione" 600 "oc get pods -n $PRJ_NOME_PROD | grep 'postgres.*'"
sleep 5

echo_log "****FINE SCRIPT****"