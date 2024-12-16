{{- define "debezium.cmd" -}}
{{- $heartbeatTable := tpl ( index $.Values.connectorConfig.debezium.config "heartbeat.action.table" ) $ }}
{{- $signalTable := tpl ( index $.Values.connectorConfig.debezium.config "signal.data.collection" ) $ }}
{{- $cmd := cat "CREATE TABLE IF NOT EXISTS" $heartbeatTable "(slot_name text, heartbeat_ts timestamp, CONSTRAINT slot_id PRIMARY KEY (slot_name));" }}
{{- $signalCmd := cat "CREATE TABLE IF NOT EXISTS" $signalTable "(id VARCHAR(42) PRIMARY KEY, type VARCHAR(32) NOT NULL, data VARCHAR(2048) NULL);" }}
{{- $schemaCmd := cat "CREATE SCHEMA IF NOT EXISTS" ( regexFind ".*\\." $heartbeatTable | trimSuffix "." ) }}
{{- $script := "" }}
{{- range $.Values.connectorConfig.debezium.instances }}
  {{- with merge .config $.Values.connectorConfig.debezium.config }}
    {{- $script = cat "psql -d" ( index . "database.dbname" ) "-c" ( $schemaCmd | quote ) "|| exit 1;" | list $script | join " \n" | trim }}
    {{- $script = cat "psql -d" ( index . "database.dbname" ) "-c" ( $cmd | quote ) "|| exit 1;" | list $script | join " \n" | trim }}
    {{- if ( index . "signal.enabled" ) }}
      {{- $script = cat "psql -d" ( index . "database.dbname" ) "-c" ( $signalCmd | quote ) "|| exit 1;" | list $script | join " \n" | trim }}
    {{- end }}
  {{- end }}
{{- end }}
{{- print $script }}
{{- end -}}

{{- define "debezium.connector" -}}
  {{- $ := .mainContext }}
  {{- $connectorName := .name }}
  {{- $heartbeatTable := tpl ( index $.Values.connectorConfig.debezium.config "heartbeat.action.table" ) $ }}
  {{- with .instanceContext }}
    {{- if index . "publication.name" | empty }}
      {{- $_ := set . "publication.name" ( regexReplaceAll "-|\\." ( tpl $connectorName $ ) "_" ) }}
    {{- end }}
    {{- if index . "slot.name" | empty }}
      {{- $_ := set . "slot.name" ( regexReplaceAll "-|\\." ( tpl $connectorName $ ) "_" ) }}
    {{- end }}
    {{- if index . "topic.heartbeat.prefix" | empty }}
      {{- $_ := set . "topic.heartbeat.prefix" ( print ( tpl $connectorName $ ) "-heartbeat" ) }}
    {{- end }}
    {{- if index . "heartbeat.action.query" | empty }}
      {{- $_ := set . "heartbeat.action.query" ( print "INSERT INTO " $heartbeatTable " (slot_name, heartbeat_ts) VALUES ('" ( tpl $connectorName $ ) "', NOW()) ON CONFLICT (slot_name) DO UPDATE SET heartbeat_ts = EXCLUDED.heartbeat_ts;" ) }}
    {{- end }}
    {{- $topicPrefix := "" }}
    {{- if tpl ( index . "namespace" ) $ | empty | not }}
      {{- $topicPrefix = ( tpl ( index . "namespace" ) $ ) }}
      {{- $_ := set . "topic.prefix" $topicPrefix }}
    {{- else }}
      {{- $topicPrefix = ( tpl ( index . "topic.prefix" ) $ ) }}
    {{- end }}

    {{- $topicCreationGroup := index . "topic.creation.group" }}
    {{- $topicCreationGroups := index . "topic.creation.groups" }}
    {{- $topicCreationGroupInclude := "" }}
    {{- $databaseName := ( tpl ( index . "database.dbname" ) $ ) }}
    {{- $tableIncludeList := "" }}
    {{- $instanceContext := . }}
    {{- $regex := "" }}

    {{- range $topicCreationGroups | replace "heartbeat" "" | nospace | splitList "," | compact }}
      {{- $topicCreationGroupInclude = print "topic.creation." . ".include" }}
      {{- if and ( hasKey $instanceContext $topicCreationGroupInclude ) ( index $instanceContext $topicCreationGroupInclude | empty | not ) }}
        {{- $regex = "" }}
        {{- range index $instanceContext $topicCreationGroupInclude | nospace | splitList "," }}
          {{- $regex = . | trimPrefix ( regexFind ".*\\." . ) | print $topicPrefix "-connect." $databaseName "." | replace "." "\\." | list $regex | join "|" | trimAll "|" | trim }}
        {{- end }}
        {{- $tableIncludeList = ( index $instanceContext $topicCreationGroupInclude | list $tableIncludeList | join ", " | trimAll "," | trim ) }}
        {{- $_ := set $instanceContext $topicCreationGroupInclude $regex }}
        {{- $topicCreationGroup = "default" }}
      {{- end }}
    {{- end }}

    {{- if ne $topicCreationGroup "default" }}
      {{- $tableIncludeList = index . "table.include.list" }}
      {{- range $tableIncludeList | nospace | splitList "," }}
        {{- $regex = . | trimPrefix ( regexFind ".*\\." . ) | print $topicPrefix "-connect." $databaseName "." | replace "." "\\." | list $regex | join "|" | trimAll "|" | trim }}
      {{- end }}
      {{- $_ := set . ( print "topic.creation." $topicCreationGroup ".include" ) $regex }}
    {{- end }}
  
    {{- if index . "transforms.RemoveString.replacement" | empty | not }}
      {{- $_ := set . "transforms.RemoveString.replacement" ( replace "__db_name_placeholder__" ( tpl ( index . "database.dbname" ) $ ) ( index . "transforms.RemoveString.replacement" )) }}
    {{- end }}

    {{- $_ := set . "custom.metric.tags" ( print "connector=" ( tpl $connectorName $ )) }}
    {{- $_ := unset . "namespace" }}
    {{- $_ := unset . "topic.creation.group" }}
    {{- $_ := unset . "signal.enabled" }}
    {{- $_ := unset . "heartbeat.action.table" }}
  {{- end }}
{{- end -}}
