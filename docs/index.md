# Welcome to CrossPlane Examples

All examples are based on a local [CNOE IDP](https://cnoe.io/), which stands for a Cloud Native Operational Excelence Internal Developer Platform.

## Requirements

1. [idpbuilder CLI](https://github.com/cnoe-io/idpbuilder), 0.9.0+
2. CNOE IDP [reference implementation stack](https://github.com/cnoe-io/stacks/tree/main/ref-implementation)
3. Docker Host and CLI.  
   Consider using the excellent and lightweight alternative to Docker Host, [colima](https://github.com/abiosoft/colima)
4. [Kind K8s CLI][defkind] 
5. kubectl 1.31+
6. Mkdocs 1.6.1+ to manage documentation.

## CNOE Implementations Used

The following implementations will be deployed in the local Kind K8S cluster:

1. [Reference Implementation][defref], that deploys the following components
    - Argo Workflows to enable workflow orchestrations.
    - Backstage as the UI for software catalog and templating. Source is available here.
    - External Secrets to generate secrets and coordinate secrets between applications.
    - Keycloak as the identity provider for applications.
    - Spark Operator to demonstrate an example Spark workload through Backstage.
2. [CrossPlain][defcp] integration for Backstage.
3. [Local Stack][deflocal] for testing cloud integrations.

Spark Operator could be removed from the deployment. It fails to start due to a missing requirement, and more importantly it is not needed for the purpose of deploying the examples.


[defkind]: https://kind.sigs.k8s.io/
[defref]: https://github.com/cnoe-io/stacks/tree/main/ref-implementation
[defcp]: https://github.com/cnoe-io/stacks/tree/main/crossplane-integrations
[deflocal]: https://github.com/cnoe-io/stacks/tree/main/localstack-integration
