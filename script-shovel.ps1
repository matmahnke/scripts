$sourcehost = ""
$sourceusername = ""
$sourcepassword = ""
$sourcevhost = ""

$desthost = ""
$destusername = ""
$destpassword = ""
$destvhost = ""

$pythonfilelocation= "python"
$rabbitmqadminfilelocation= '"C:\Program Files\RabbitMQ Server\rabbitmq_server-3.8.2\sbin\rabbitmqadmin"'


function create-queue-and-bind-to-exchange([string]$ExchangeName = "")
{
    $Queuename = $ExchangeName + "-canaa"
    echo "##[debug]CREATING QUEUE - $Queuename"
    execute-rabbitmqadmin-command "declare queue name=$Queuename"
    echo "##[debug]BINDING QUEUE TO EXCHANGE $ExchangeName"
    execute-rabbitmqadmin-command "declare binding source=$ExchangeName destination=$Queuename"
}

function execute-rabbitmqadmin-command([string]$command = ""){
    $command = "$pythonfilelocation $rabbitmqadminfilelocation --host $sourcehost --username $sourceusername --password $sourcepassword --vhost $sourcevhost ", $command
    cmd /c "$command"
}

function create-shovel([string]$ExchangeName = "", [string]$DestQueueName = ""){
    $Queuename = "${ExchangeName}-canaa"

    $srcuri = "amqp://${sourcehost}:5672"
    $desturi = "amqp://${desthost}:5672"

    $params = 
        "`"{`"`"src-protocol`"`" = `"`"amqp091`"`",
        `"`"src-uri`"`" = `"`"${sourceusername}:${sourcepassword}@${srcuri}:5672/${sourcevhost}`"`",
        `"`"src-queue`"`" = `"`"${Queuename}`"`",
        `"`"dest-protocol`"`" = `"`"amqp091`"`",
        `"`"dest-uri`"`" =`"`"${destusername}:${destpassword}@${desturi}:5672/${destvhost}`"`",
        `"`"dest-queue`"`" = `"`"${DestQueueName}`"`"}`""

    $shovelname = "${DestQueueName}-shovel"
    $shovel = "rabbitmqctl set_parameter shovel $shovelname ^", $params

    cmd /c "$shovel"
}

#cmd /c "rabbitmq-plugins enable rabbitmq_shovel"

## Carregamento
create-queue-and-bind-to-exchange "EventoTarefaCarregamentoPaleteFechadoAssociada"
create-shovel "EventoTarefaCarregamentoPaleteFechadoAssociada" "WMS_LOADING_ASSOCIATED_CLOSED_PALLET"

create-queue-and-bind-to-exchange "EventoTarefaCarregamentoPaleteMistoAssociada"
create-shovel "EventoTarefaCarregamentoPaleteMistoAssociada" "WMS_LOADING_ASSOCIATED_MIXED_PALLET"

create-queue-and-bind-to-exchange "EventoTarefaCarregamentoPaleteFechadoDesassociada"
create-shovel "EventoTarefaCarregamentoPaleteFechadoDesassociada" "WMS_LOADING_DISASSOCIATED_CLOSED_PALLET"

create-queue-and-bind-to-exchange "EventoTarefaCarregamentoPaleteMistoDesassociada"
create-shovel "EventoTarefaCarregamentoPaleteMistoDesassociada" "WMS_LOADING_DISASSOCIATED_MIXED_PALLET"

## Conferencia
#create-queue-and-bind-to-exchange "AssociatedCheckTaskEvent"
#create-shovel "AssociatedCheckTaskEvent" "WMS_ASSOCIATED_CHECK_TASK_EVENT"
#
#create-queue-and-bind-to-exchange "CompletedCheckTaskEvent"
#create-shovel "CompletedCheckTaskEvent" "WMS_COMPLETED_CHECK_TASK_EVENT"
#
#create-queue-and-bind-to-exchange "CreatedCheckOccurrenceEvent"
#create-shovel "CreatedCheckOccurrenceEvent" "WMS_CREATED_CHECK_OCCURRENCE_EVENT"
#
#create-queue-and-bind-to-exchange "DisassociatedCheckTaskEvent"
#create-shovel "DisassociatedCheckTaskEvent" "WMS_DISASSOCIATED_CHECK_TASK_EVENT"
#
### Fechar carga
#create-queue-and-bind-to-exchange "EventoTarefaFecharCargaAssociada"
#create-shovel "EventoTarefaFecharCargaAssociada" "WMS_CLOSE_ASSOCIATED_LOAD_TASK_EVENT"
#
#create-queue-and-bind-to-exchange "EventoTarefaFecharCargaDesassociada"
#create-shovel "EventoTarefaFecharCargaDesassociada" "WMS_CLOSE_DISASSOCIATED_LOAD_TASK_EVENT"
#
#create-queue-and-bind-to-exchange "FechamentoCargaFinalizado"
#create-shovel "FechamentoCargaFinalizado" "WMS_CLOSING_FINALIZED_LOAD"
#
#create-queue-and-bind-to-exchange "CargaCarregada"
#create-shovel "CargaCarregada" "WMS_LOAD_LOADED"
#
### Geral
#create-queue-and-bind-to-exchange "OcorrenciaLancada"
#create-shovel "OcorrenciaLancada" "WMS_LAUNCHED_OCCURRENCE"
#
### Liberação
#create-queue-and-bind-to-exchange "CargaLiberada"
#create-shovel "CargaLiberada" "WMS_LOAD_RELEASED"
#
### Reimportação
#create-queue-and-bind-to-exchange "EventChangeLicensePlateLoadImport"
#create-shovel "EventChangeLicensePlateLoadImport" "WMS_CHANGE_LICENCE_PLATE_LOAD_IMPORT_EVENT"
#
## Separação
#create-queue-and-bind-to-exchange "EventoPaleteFinalizado"
#create-shovel "EventoPaleteFinalizado" "WMS_FINALIZED_PALLET_EVENT"
#
#create-queue-and-bind-to-exchange "EventoUsuarioDesassociadoPalete"
#create-shovel "EventoUsuarioDesassociadoPalete" "WMS_USER_PALLET_DISASSOCIATED_EVENT"