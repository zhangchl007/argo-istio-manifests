# argo-istio-manifests

Declarative GitOps layer for Istio traffic management, progressive delivery (Argo Rollouts), and application exposure managed by Argo CD.

## Repository Scope
- Istio traffic objects (Gateway / VirtualService / DestinationRule) delivered via Helm (traffic chart) or future Kustomize overlays.
- Example application rollout (helloworld) with canary strategy.
- Environment‑scoped values for image versioning and routing.

## Layout
- Root kustomization: [argo-istio-manifests/argo-istio/kustomization.yaml](argo-istio-manifests/argo-istio/kustomization.yaml)
- Helm charts:
  - helloworld app: [argo-istio-manifests/argo-istio/helm-helloworld](argo-istio-manifests/argo-istio/helm-helloworld)
  - traffic (Istio CRDs): [argo-istio-manifests/argo-istio/helm-traffic](argo-istio-manifests/argo-istio/helm-traffic)
- Env values (sample dev image override): [argo-istio-manifests/argo-istio/values/env/dev/common/version.yaml](argo-istio-manifests/argo-istio/values/env/dev/common/version.yaml)

## Key Components
### Istio Traffic (Helm)
Gateway + VirtualService templates live in the traffic chart (e.g. gateway.yaml / virtualservice.yaml). Sync ordering uses Argo CD sync waves to ensure Gateway precedes VirtualService.

### Progressive Delivery
Argo Rollouts canary strategy defined in the helloworld chart (rollout template). Weighted steps (20/40/60/80) with timed pauses auto‑promote unless a manual indefinite pause is added.

### Image Versioning
Per‑environment image (repository + tag) controlled under values/env/<env>/common, enabling promotion via PR changing only a small YAML.

## Typical Flow
1. Update image tag in env values (e.g. bump tag in version.yaml).
2. Commit and push; Argo CD detects change.
3. Argo Rollout performs staged traffic shift.
4. Observe metrics / Kiali during each step; rollback via `kubectl argo rollouts undo`.

## Commands (Local Preview)
Render helloworld chart (example):
```sh
helm template demo ./argo-istio/helm-helloworld -f [version.yaml](http://_vscodecontentref_/0)

## Conventions
```bash
Sync waves: lower wave = foundational (Gateway), higher = dependents (VirtualService, Rollout).
Labeling & naming centralized in _helpers.tpl files inside each chart.
Canary steps must match VirtualService route name referenced in rollout trafficRouting.
Migration Option (Kustomize)
If traffic updates become frequent (weight tweaks, header rules), render current Helm traffic manifests once and move to a Kustomize base + environment overlays for clearer diffs.

Extending
Add DestinationRule subsets to enable header or version-based splitting.
Introduce manual approval by appending - pause: {} as final rollout step.
Add policy controls (OPA / Conftest) in a PreSync hook before applying traffic changes.
Prerequisites
Istio control plane installed (ingressgateway label must match Gateway selector).
Argo CD running with access to this repo.
Argo Rollouts CRDs installed when using Rollout objects.
Troubleshooting
100% traffic to canary early: verify VirtualService still lists both subsets with intended weights.
Rollout auto‑finishes: no indefinite pause step present.
Kiali shows only one edge: confirm both stable & canary Services have matching selectors and pods.
Next Steps
Add automated conftest policies for allowed host domains.
Introduce TLS for Gateway in production values.
Transition traffic chart to Kustomize overlays if review noise grows.

## Migration Option (Kustomize)
If traffic updates become frequent (weight tweaks, header rules), render current Helm traffic manifests once and move to a Kustomize base + environment overlays for clearer diffs.
