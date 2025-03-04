{{- define "separator.connector" -}}
  {{- $ := .mainContext }}
  {{- $connectorName := .name }}
  {{- with .instanceContext }}
    {{- $_ := required "target.cluster.bootstrap.servers not defined" ( index . "target.cluster.bootstrap.servers" ) }}

    {{- if index . "transforms.Filter.condition" | empty }}
      {{- $_ := set . "transforms.Filter.condition" ( tpl ( index . "message.filter" ) $ ) }}
    {{- end }}

    {{- if index . "topics.include" | empty | not }}
      {{- $_ := set . "topics" ( tpl ( index . "topics.include" ) $ ) }}
    {{- else }}
      {{- $_ := set . "topics" ( tpl ( index . "topics" ) $ ) }}
    {{- end }}

    {{- $topicPrefix := "" }}
    {{- if index . "topic.prefix" | empty | not }}
      {{- $topicPrefix = print ( tpl ( index . "topic.prefix" ) $ ) "-" }}
    {{- else if eq ( tpl ( index . "source.cluster.bootstrap.servers" ) $  ) ( tpl ( index . "target.cluster.bootstrap.servers" ) $  ) }}
      {{- $topicPrefix = print ( tpl ( index . "source.cluster.alias" ) $ ) "-" }}
    {{- end }}

    {{- if index . "transforms.AddPrefix.replacement" | empty }}
      {{- $_ := set . "transforms.AddPrefix.replacement" ( print $topicPrefix "$1" ) }}
    {{- end }}

    {{- $topicCreationGroup := index . "topic.creation.group" }}
    {{- $topicCreationGroups := index . "topic.creation.groups" }}
    {{- $topicCreationGroupInclude := "" }}
    {{- $topicIncludeList := "" }}
    {{- $instanceContext := . }}
    {{- $regex := "" }}

    {{- range append ( $topicCreationGroups | replace "heartbeat" "" | nospace | splitList "," ) "default" | compact | uniq }}
      {{- $topicCreationGroupInclude = print "topic.creation." . ".include" }}
      {{- if and ( hasKey $instanceContext $topicCreationGroupInclude ) ( index $instanceContext $topicCreationGroupInclude | empty | not ) }}
        {{- $regex = "" }}
        {{- range index $instanceContext $topicCreationGroupInclude | nospace | splitList "," }}
          {{- $regex = print $topicPrefix . | replace "." "\\." | list $regex | join "|" | trimAll "|" | trim }}
        {{- end }}
        {{- $topicIncludeList = ( index $instanceContext $topicCreationGroupInclude | list $topicIncludeList | join ", " | trimAll "," | trim ) }}
        {{- $_ := set $instanceContext $topicCreationGroupInclude $regex }}
      {{- end }}
    {{- end }}

    {{- if $topicIncludeList | empty | not }}
      {{- $_ := set . "topics" $topicIncludeList }}
      {{- $_ := unset . "topic.creation.default.include" }}
    {{- else if ne $topicCreationGroup "default" }}
      {{- range index . "topics" | nospace | splitList "," }}
        {{- $regex = print $topicPrefix . | replace "." "\\." | list $regex | join "|" | trimAll "|" | trim }}
      {{- end }}
      {{- $_ := set . ( print "topic.creation." $topicCreationGroup ".include" ) $regex }}
    {{- end }}

    {{- $_ := set . "topics" ( index . "topics" | replace "." "\\." | replace "," "|" | nospace ) }}
    {{- $_ := unset . "topic.creation.group" }}
    {{- $_ := unset . "message.filter" }}
    {{- $_ := unset . "topic.prefix" }}
    {{- $_ := unset . "topics.include" }}
  {{- end }}
{{- end -}}
