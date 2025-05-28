# CrossPlane Examples

## Kubernetes Provider

Kubernetes provider is the simplest to use. It requires no integration with external Cloud platforms which makes the tests easy to implement.

References:

1. GitHub Repository: [https://github.com/crossplane-contrib/provider-kubernetes](https://github.com/crossplane-contrib/provider-kubernetes)

### Local Kind k8s cluster

There are two options:

1. Deploy kind and CrossPlane manually from the command line with kubectl.
2. Deploy CNOE CrossPlane implementation. 

### Create `hello-world` namespace manually

Use kubectl to deploy the provider and the `Object` managed resource to provision a k8s namespace.

```sh
> cd crossplane-examples/providers/k8s

# deploy k8s provider, its configuration and RBAC cluster role to provide the required cluster-wide privlieges
> kubectl create -f k8s-provider.yaml

# Verify the deployment
> kubectl get providers
NAME                  INSTALLED   HEALTHY   PACKAGE                                                   AGE
provider-aws          True        True      xpkg.upbound.io/crossplane-contrib/provider-aws:v0.48.0   4d20h
provider-kubernetes   True        True      xpkg.upbound.io/upbound/provider-kubernetes:v0.16.0       3d21h


# Deploy the Object managed resource that should create the hello-world namespace
> kubectl create -f object.yaml

# Verify the deployment
> kubectl describe Object/hello-world
Name:         hello-world
Namespace:
Labels:       <none>
Annotations:  crossplane.io/external-create-pending: 2025-05-15T18:56:57Z
              crossplane.io/external-create-succeeded: 2025-05-15T18:56:57Z
              crossplane.io/external-name: hello-world
              uptest.upbound.io/timeout: 60
API Version:  kubernetes.crossplane.io/v1alpha2
Kind:         Object
Metadata:
  Creation Timestamp:  2025-05-15T18:56:57Z
  Finalizers:
    finalizer.managedresource.crossplane.io
  Generation:        2
  Resource Version:  82477
  UID:               0e1cb457-b367-46dd-902d-9cfbaf5e9231
Spec:
  Deletion Policy:  Delete
  For Provider:
    Manifest:
      API Version:  v1
      Kind:         Namespace
      Metadata:
        Labels:
          Example:  true
  ... ....

# Verify the creation of the k8s namespace
> kubectl describe ns hello-world
Name:         hello-world
Labels:       example=true
              kubernetes.io/metadata.name=hello-world
Annotations:  <none>
Status:       Active

No resource quota.

No LimitRange resource.
```

### Create `my-app-namespace` namespace with Compositions and Claims

In this example, the target namespace is managed through submission of a Claim.

The Claim triggers a Composition to perform patching on the fields of the Claim, and the final results is used to create an Object, a managed resource of the Kubernetes provider.

Create first the `CompositeResourceDefinition` (XRD) for custom `xnamespaces.altimetrik.com` XNamespaces Kind.
```sh
> cd crossplane-examples/providers/k8s

# check if the XRD exists
> k api-resources | grep altimetrik.com
(no result)

# Create the XRD XNamespace
> kubectl create -f ns/CompositeResourceDefinition.yaml
compositeresourcedefinition.apiextensions.crossplane.io/xnamespaces.altimetrik.com created

> kubectl api-resources | grep altimetrik.com
namespaceclaims                                             altimetrik.com/v1                                    true         NamespaceClaim
xnamespaces                                                 altimetrik.com/v1                                    false        XNamespace

# Create the Composition that will be used to transform the Claim into the
# Provider's managed Resource
> kubectl create -f ns/Composition.yaml

# Create the NamespaceClaim in the default namespace. Keep in mind Claims are namespaced.
> kubectl create -f ns/NamespaceClaim.yaml
namespaceclaim.altimetrik.com/my-app-namespace created

> kubectl get NamespaceClaims --all-namespaces
NAMESPACE   NAME               SYNCED   READY   CONNECTION-SECRET   AGE
default     my-app-namespace   True     True                        27m

# Verify the mu-app k8s namespace was created
> kubectl describe ns/my-app
Name:         my-app
Labels:       app=my-application
              environment=production
              kubernetes.io/metadata.name=my-app
Annotations:  <none>
Status:       Active

No resource quota.

No LimitRange resource.

```





