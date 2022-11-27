{{- define "env.java.tool.options" }}
{{- $springProfile := .Values.rollouts.java_tool_options.springProfile }}
{{- $elastic_apm_server := "" }}
{{- range $phase, $apm_server_url := .Values.rollouts.java_tool_options.elastic_apm_server }}
    {{- if eq $phase $springProfile }}
        {{- $elastic_apm_server = $apm_server_url }}
    {{- end }}
{{- end }}
- name: JAVA_TOOL_OPTIONS
  value:
    -Dspring.profiles.active={{ .Values.rollouts.java_tool_options.springProfile }}
    -Dvpc={{ .Values.rollouts.java_tool_options.vpc }}
    -javaagent:{{ .Values.rollouts.java_tool_options.elastic_apm_agent }}
    -Delastic.apm.service_name={{ .Values.global.name }}
    -Delastic.apm.server_urls={{ $elastic_apm_server }}
    -Delastic.apm.environment={{ .Values.rollouts.java_tool_options.springProfile }}
    -Delastic.apm.application_packages=kcl
    -Delastic.apm.enable_experimental_instrumentations=true
{{- end }}


{{- define "service.annotations" }}
{{- if .Values.service.healthCheck }}
alb.ingress.kubernetes.io/healthcheck-path: {{ .Values.service.healthCheck | quote }}
{{- end }}
{{- end }}

{{- define "ingress.annotations" }}
{{- if .Values.ingress.annotation }}
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/conditions.{{ .Values.service.canaryStrategy.root }}: |
  [{"field":"host-header","hostHeaderConfig":{"values":[{{ join ", " .Values.ingress.annotation.domains }}]}}]
alb.ingress.kubernetes.io/load-balancer-attributes: routing.http.drop_invalid_header_fields.enabled=true,deletion_protection.enabled=true
alb.ingress.kubernetes.io/scheme: internal
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/security-groups: {{ .Values.ingress.annotation.securityGroups }}
alb.ingress.kubernetes.io/subnets: {{ join ", " .Values.ingress.annotation.subnets }}
{{- end }}
{{- end }}


{{- define "externalIngress.annotations" }}
{{- if .Values.externalIngress.annotation }}
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/load-balancer-attributes: routing.http.drop_invalid_header_fields.enabled=true,deletion_protection.enabled=true
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/certificate-arn: {{ .Values.externalIngress.annotation.cert }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/ssl-redirect: '443'
alb.ingress.kubernetes.io/security-groups: {{ .Values.externalIngress.annotation.securityGroups }}
alb.ingress.kubernetes.io/subnets: {{ join ", " .Values.externalIngress.annotation.subnets }}
{{- end }}
{{- end }}


{{- define "deployment.selectorLabels" }}
app: {{ .Values.global.name }}
{{- end }}

{{- define "rollouts.steps" }}
{{- if eq .Values.global.bluegreen true -}}
- setCanaryScale:
    replicas: {{ .Values.rollouts.replicaCount }}
- pause: {}
- setWeight: 20
- pause: {}
- setWeight: 40
- pause: {duration: 10}
- setWeight: 60
- pause: {duration: 10}
- setWeight: 80
- pause: {duration: 10}
{{- else -}}
- setWeight: 20
- pause: {}
- setWeight: 40
- pause: {duration: 10}
- setWeight: 60
- pause: {duration: 10}
- setWeight: 80
- pause: {duration: 10}
{{- end }}
{{- end }}