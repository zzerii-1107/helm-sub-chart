# helm-chart

## release

### base v0.0.8
- Values.ingress , Values.externalIngress에 `exist: true` 추가해서 type 별 Ingress 생성
- Values.externalIngress의 경우 annotation 에 `cert:` 설정 필요
- Values.rollouts.env 값 추가 / env를 자유롭게 설정 가능
- Values.rollouts 에 java_env: false / true 설정 추가
  JAVA_TOOL_OPTIONS 환경 변수를 사용하지 않는 경우 false로 설정 하고
  Values.rollouts.env에 key: value 형태로 환경변수 작성(key는 소문자로 작성 ex) test_env)
- Values.rollouts.imagePullSecrets 추가

