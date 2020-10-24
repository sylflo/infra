local base = import "../base.libsonnet";
local k = import "k.libsonnet";
local prometheus = import "prometheus-ksonnet/prometheus-ksonnet.libsonnet";

base + {
  // Insert user-specified overrides here. For example if a component is named "nginx-deployment", you might have something like:
  //   "nginx-deployment"+: k.deployment.mixin.metadata.labels({foo: "bar"})
}

prometheus {
  _config+:: {
    namespace: "monitoring",
  },
}
