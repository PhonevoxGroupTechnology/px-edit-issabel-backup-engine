#!/bin/bash

CURRDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# LOGGING
LOG_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOGFILE_PATH="."
LOGFILE_NAME="pvx-edited-backupengine" # Nome (prefixo) pro arquivo de log. "<logfile_name>-0000-11-22.log"
LOGFILE="$LOGFILE_NAME-$(date '+%Y-%m-%d').log"
if ! [ -f "$LOGFILE" ]; then # checa se o arquivo de log já existe
        echo -e "[$LOG_TIMESTAMP] Iniciando novo logfile" > $LOGFILE_PATH/$LOGFILE
fi

log () {
    if [ -z $2 ]; then
        local muted=false
    else
        local muted=true
    fi
    echo -e "[$LOG_TIMESTAMP] $1" >> $LOGFILE_PATH/$LOGFILE
    if ! $muted; then
        echo -e "[$LOG_TIMESTAMP] $1" # Comentando pra não atrapalhar nas funções.
    fi
}

# Necessário para não haver erros de duplicação, adicionando mais de uma vez à mesma var.
function add_arg() 
{
  local ARGUMENT=$1
  local VALUE=$2

  if [ -z "$VALUE" ] || [[ $VALUE == -* ]]; then # Conferindo se VALUE está vazio ou começa com "-". Caso seja o segundo caso, provavelmente é uma flag...
    echo "FATAL: Valor obrigatório para '$ARGUMENT'"
    exit 1
  fi
  #echo "[INFO] ADD_ARG: Valor de $1 -> ${args[$ARGUMENT]}"
  if [ ! ${args[$ARGUMENT]} ]; then
    args+=( [$ARGUMENT]=$2 )
    return 0
  else
    #echo "[DEBUG] ADD_ARG: Arg $1 já existe."
    #echo "[INFO] ADDARG: Lista de Args -> ${!args[@]}"
    return 1
  fi
}

# Função de ajuda para exibir a mensagem de ajuda
show_help() {
    echo "Uso: $0"
    echo ""
    echo "Opções:"
    echo "  -h, --help            Exibe este menu."
    exit 0
}

# exibe todos os argumentos repassados pro script.
# echo "<## ARG LIST ##> (ordered)"
# for arg in "$@"; do
#     echo "$arg"
# done
# echo "<##############>"

__ARG_COUNTER=0
# Tratamento dos argumentos usando um loop while
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        *)
            # Opção desconhecida ou argumento não reconhecido
            ((__ARG_COUNTER++))
            add_arg "$__ARG_COUNTER" $1
            shift
            ;;
    esac
done

function colorir() 
{
    declare -A cores
    local cores=(
        [preto]="0;30"
        [vermelho]="0;31"
        [verde]="0;32"
        [amarelo]="0;33"
        [azul]="0;34"
        [magenta]="0;35"
        [ciano]="0;36"
        [branco]="0;37"
        [preto_claro]="1;30"
        [vermelho_claro]="1;31"
        [verde_claro]="1;32"
        [amarelo_claro]="1;33"
        [azul_claro]="1;34"
        [magenta_claro]="1;35"
        [ciano_claro]="1;36"
        [branco_claro]="1;37"
    )

    local cor=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local texto=$2
    local string='${cores['"\"$cor\""']}'
    eval "local cor_ansi=$string"
    local cor_reset="\e[0m"

    if [[ -z "$cor_ansi" ]]; then
        cor_ansi=${cores["branco"]}  # Cor padrão, caso a cor seja inválida
    fi

    # Imprimir o texto com a cor selecionada
    echo -e "\e[${cor_ansi}m${texto}${cor_reset}"
}

function safe_replace() {

    function make_backup()
    {
        local OBJECT=$1
        local YMD_DATE=$(date '+%Y-%m-%d')
        local DESTINATION_FOLDER=$CURRDIR/backup-$YMD_DATE
        local BASENAME=$(basename "$OBJECT")

        #// Criando, caso não exista, a pasta de backup.
        mkdir -p $DESTINATION_FOLDER

        if [ -f $OBJECT ]; then # Arquivo
            cp $OBJECT $DESTINATION_FOLDER/$BASENAME.bkp
        elif [ -d $OBJECT ]; then # Diretório
            cp $OBJECT $DESTINATION_FOLDER/$BASENAME.bkp
            log "make_backup: $(colorir "azul_claro" "INFO") : \"$BASENAME\" backup efetuado"
        elif [ -e $OBJECT ]; then # Não é arquivo nem diretório, mas existe algo ai!
            log "make_backup: $(colorir "amarelo" "WARN") :\"$BASENAME\" tipo desconhecido!"
        else # Desconhecido
            log "make_backup: $(colorir "amarelo" "WARN") :\"$OBJECT\" arquivo não existe!"
        fi
    }

    local FULL_PATH_ARQUIVO_ORIGINAL=$1 # /etc/asterisk/teste.txt
    local PATH_ARQUIVO_ORIGINAL=$(dirname "$FULL_PATH_ARQUIVO_ORIGINAL") # /etc/asterisk
    local ARQUIVO_ORIGINAL=$(basename "$FULL_PATH_ARQUIVO_ORIGINAL") # teste.txt

    local FULL_PATH_ARQUIVO_NOVO=$2
    local PATH_ARQUIVO_NOVO=$(dirname "$FULL_PATH_ARQUIVO_NOVO")
    local ARQUIVO_NOVO=$(basename "$FULL_PATH_ARQUIVO_NOVO")    

    log "safe_replace: INFO : Original -> $FULL_PATH_ARQUIVO_ORIGINAL"
    log "safe_replace: INFO : Novo     -> $FULL_PATH_ARQUIVO_NOVO"

    make_backup $FULL_PATH_ARQUIVO_ORIGINAL
    # >> checagem de erro aqui <<

    log "safe_replace: INFO : Removendo \"$FULL_PATH_ARQUIVO_ORIGINAL\""
    rm -rf $FULL_PATH_ARQUIVO_ORIGINAL

    log "safe_replace: INFO : Substituindo o arquivo"
    cp $FULL_PATH_ARQUIVO_NOVO $PATH_ARQUIVO_ORIGINAL
}

function main() 
{
    PATH_MODULES="/var/www/html/modules"
    PATH_BACKUP_MODULE="$PATH_MODULES/backup_restore"
    PATH_PRIVILEGED="/usr/share/issabel/privileged"
    PATH_SCP_FILES=$CURRDIR/files

    safe_replace "/var/www/html/modules/backup_restore/themes/default/backup.tpl" "$PATH_SCP_FILES/backup.tpl"
    safe_replace "/var/www/html/modules/backup_restore/index.php" "$PATH_SCP_FILES/index.php"
    safe_replace "$PATH_PRIVILEGED/backupengine" "$PATH_SCP_FILES/backupengine"
    cp "$PATH_SCP_FILES/pvx-backupengine-extras" "$PATH_PRIVILEGED/pvx-backupengine-extras"

}

main