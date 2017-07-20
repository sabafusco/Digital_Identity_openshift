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
TEMPLATE_URI='https://gist.githubusercontent.com/sabafusco/c135e7a1cb92c2d20dbf901eae72c413/raw/3815cb66b47c95da16c3e35e41f9961d305aca64/digident_developer_template.yaml'

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


###################################################
#### Logica
###################################################

echo_log "****INIT SCRIPT****"

crea_progetto "$PRJ_NOME" "$PRJ_TITOLO" "$PRJ_DESCRIZIONE"
usa_progetto "$PRJ_NOME"
deploy_template "$TEMPLATE_URI"

echo_log "****FINE SCRIPT****"