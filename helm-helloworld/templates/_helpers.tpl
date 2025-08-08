{{/*
Extract application name from ArgoCD application name
Usage: {{ include "helloworld.appName" . }}
*/}}
{{- define "helloworld.appName" -}}
{{- if contains "-" .Release.Name -}}
{{- $parts := splitList "-" .Release.Name -}}
{{- if gt (len $parts) 1 -}}
{{- last $parts -}}
{{- else -}}
{{- .Release.Name -}}
{{- end -}}
{{- else -}}
{{- .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
Extract cluster name from ArgoCD application name
Usage: {{ include "helloworld.clusterName" . }}
*/}}
{{- define "helloworld.clusterName" -}}
{{- if contains "-" .Release.Name -}}
{{- $parts := splitList "-" .Release.Name -}}
{{- if gt (len $parts) 1 -}}
{{- first $parts -}}
{{- else -}}
{{- "unknown" -}}
{{- end -}}
{{- else -}}
{{- "unknown" -}}
{{- end -}}
{{- end -}}

{{/*
Azure-optimized fullname that uses extracted app name
*/}}
{{- define "helloworld.azureFullname" -}}
{{- $appName := include "helloworld.appName" . -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name $appName -}}
{{- $appName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" $appName $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Azure selector labels with extracted app name
*/}}
{{- define "helloworld.azureSelectorLabels" -}}
app.kubernetes.io/name: {{ include "helloworld.appName" . }}
app.kubernetes.io/instance: {{ include "helloworld.appName" . }}
{{- end }}