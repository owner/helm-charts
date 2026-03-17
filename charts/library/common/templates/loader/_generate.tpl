{{/*
Secondary entrypoint and primary loader for the common chart
*/}}
{{- define "bjw-s.common.loader.generate" -}}
  {{- $rootContext := $ -}}

  {{- /* Run global chart validations */ -}}
  {{- include "bjw-s.common.lib.chart.validate" $rootContext -}}

  {{- /* Build the templates */ -}}
  {{- include "bjw-s.common.render.pvcs" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.serviceAccount" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.configMaps.fromFolder" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.configMaps" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.secrets.fromFolder" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.controllers" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.services" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.ingresses" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.serviceMonitors" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.routes" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.secrets" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.networkpolicies" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.externalSecrets" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.certificates" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.certificateIssuers" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.certificateClusterIssuers" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioVirtualServices" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioGateways" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioAuthorizationPolicies" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioDestinationRules" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioServiceEntries" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioPeerAuthentications" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioRequestAuthentications" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.istioSidecars" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.rawResources" $rootContext | nindent 0 -}}
  {{- include "bjw-s.common.render.rbac" $rootContext | nindent 0 -}}
{{- end -}}
