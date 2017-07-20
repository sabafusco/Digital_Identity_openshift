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
PRJ_NOME_SVIL='digident-sviluppo'
PRJ_TITOLO_SVIL='Digital Identity - Sviluppo'
PRJ_DESCRIZIONE_SVIL='Progetto Digital Identity ambiente di SVILUPPO'

# Progetto Collaudo
PRJ_NOME_COLL='digident-collaudo'
PRJ_TITOLO_COLL='Digital Identity - Collaudo'
PRJ_DESCRIZIONE_COLL='Progetto Digital Identity ambiente di COLLAUDO'

# Progetto Produzione
PRJ_NOME_PROD='digident-produzione'
PRJ_TITOLO_PROD='Digital Identity - Produzione'
PRJ_DESCRIZIONE_PROD='Progetto Digital Identity ambiente di PRODUZIONE'

# Template
TEMPLATE_URI_DEVOPS='https://gist.githubusercontent.com/sabafusco/c135e7a1cb92c2d20dbf901eae72c413/raw/3815cb66b47c95da16c3e35e41f9961d305aca64/digident_developer_template.yaml'
TEMPLATE_URI_DIGIDENT='https://gist.githubusercontent.com/sabafusco/c135e7a1cb92c2d20dbf901eae72c413/raw/3815cb66b47c95da16c3e35e41f9961d305aca64/digident_developer_template.yaml'

# Log
LOG_FILE='openshift_script.log'
DATA='date +%Y/%m/%d:%H:%M:%S'


####################################################
####  Funzioni
####################################################

function echo_log(){
        echo `$DATA`" $1" >> $LOG_FILE
        echo `$DATA`" $1"
}

function crea_progetto(){
        echo_log "Creazione progetto $1 ..."
        oc new-project $1 --display-name="$2" --description="$3" &> $LOG_FILE
}

function usa_progetto(){
        echo_log "Progetto: $1 ."
        oc project $1 &> $LOG_FILE
}

function deploy_template(){
        echo_log "Deploy del template $1 ..."
        oc new-app $1 &> $LOG_FILE
}

function assign_role_to_serviceaccount(){
		echo_log "assegnazione del ruolo $1 al service account $2 ..."
		oc policy add-role-to-user $1 $2
}


###################################################
#### Logica
###################################################

echo_log "****INIT SCRIPT****"

#Dev Ops
crea_progetto "$PRJ_NOME_DEVOPS" "$PRJ_TITOLO_DEVOPS" "$PRJ_DESCRIZIONE_DEVOPS"
usa_progetto "$PRJ_NOME_DEVOPS"
deploy_template "$TEMPLATE_URI_DEVOPS"

#Ambiente SVILUPPO
crea_progetto "$PRJ_NOME_SVIL" "$PRJ_TITOLO_SVIL" "$PRJ_DESCRIZIONE_SVIL"
usa_progetto "$PRJ_NOME_SVIL"
assign_role_to_serviceaccount $RUOLO_SERVICE_ACCOUNT $SERVICE_ACCOUNT_JENKINS
deploy_template "$TEMPLATE_URI_DIGIDENT"

#Ambiente COLLAUDO
crea_progetto "$PRJ_NOME_COLL" "$PRJ_TITOLO_COLL" "$PRJ_DESCRIZIONE_COLL"
usa_progetto "$PRJ_NOME_COLL"
assign_role_to_serviceaccount $RUOLO_SERVICE_ACCOUNT $SERVICE_ACCOUNT_JENKINS
deploy_template "$TEMPLATE_URI_DIGIDENT"

#Ambiente PRODUZIONE
crea_progetto "$PRJ_NOME_PROD" "$PRJ_TITOLO_PROD" "$PRJ_DESCRIZIONE_PROD"
usa_progetto "$PRJ_NOME_PROD"
assign_role_to_serviceaccount $RUOLO_SERVICE_ACCOUNT $SERVICE_ACCOUNT_JENKINS
deploy_template "$TEMPLATE_URI_DIGIDENT"

echo_log "****FINE SCRIPT****"