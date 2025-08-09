{{/*
Expand the name of the chart or use nameOverride
*/}}
{{- define "helloworld.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart label (name-version)
*/}}
{{- define "helloworld.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
fullname that returns only the extracted app name (e.g. cluster1-helloworld -> helloworld)
Use fullnameOverride if provided.
*/}}
{{- define "helloworld.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "helloworld.appName" . | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Standard labels used across resources
*/}}
{{- define "helloworld.labels" -}}
helm.sh/chart: {{ include "helloworld.chart" . }}
app.kubernetes.io/name: {{ include "helloworld.appName" . }}
app.kubernetes.io/instance: {{ include "helloworld.appName" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Selector labels (must match pod template labels)
*/}}
{{- define "helloworld.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helloworld.appName" . }}
app.kubernetes.io/instance: {{ include "helloworld.appName" . }}
{{- end -}}

{{/*
ServiceAccount name
*/}}
{{- define "helloworld.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "helloworld.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

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