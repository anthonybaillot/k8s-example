{{/*
Expand the name of the chart.
*/}}
{{- define "k8s-example.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s-example.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s-example.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s-example.labels" -}}
helm.sh/chart: {{ include "k8s-example.chart" . }}
{{ include "k8s-example.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s-example.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s-example.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Database labels
*/}}
{{- define "k8s-example.database.labels" -}}
{{ include "k8s-example.labels" . }}
app.kubernetes.io/component: database
{{- end }}

{{/*
Database selector labels
*/}}
{{- define "k8s-example.database.selectorLabels" -}}
{{ include "k8s-example.selectorLabels" . }}
app.kubernetes.io/component: database
app: database
{{- end }}

{{/*
Backend labels
*/}}
{{- define "k8s-example.backend.labels" -}}
{{ include "k8s-example.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "k8s-example.backend.selectorLabels" -}}
{{ include "k8s-example.selectorLabels" . }}
app.kubernetes.io/component: backend
app: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "k8s-example.frontend.labels" -}}
{{ include "k8s-example.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "k8s-example.frontend.selectorLabels" -}}
{{ include "k8s-example.selectorLabels" . }}
app.kubernetes.io/component: frontend
app: frontend
{{- end }}