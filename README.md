# go-app-6

A demo of best DevSecOps practices with focus on automation, collaboration, security and documentation.

## Requirements

1. [go v1.24+](https://go.dev/doc/install)
2. [git cli](https://git-scm.com/downloads)
3. [make](https://www.gnu.org/software/make/) - Optional. In case of Windows OS, it is possible to execute the build commands defined in the Makefile from the command line.

4. [Kind Kubernetes](https://kind.sigs.k8s.io/) 

## Build go-app-6 application

Clone go-app-6 repository. 

```sh
> git clone git@github.com:altimetrik-digital-enablement-demo-hub/go-app-6.git
> cd go-app-6
```

Build the binary. TAG env variable sets the application version. If not specified, the default is `dev`

```sh
> TAG=0.0.16 make build
Build availalbe at ./bin/go-app-6

> ./bin/go-app-6 version
go-app-6 version
  version: 0.0.16
  commit: 1de9255
```

## Build go-app-6 container image

```sh
$ make docker-build
docker build \
	--build-arg VERSION="0.0.16" \
	--build-arg COMMIT="1de9255" \
	--build-arg BUILD_UNIX_TIME="174645213735" \
	-f docker/Dockerfile \
	 -t dgeorgievski/go-app-6:0.0.16 .
[+] Building 13.2s (14/14) FINISHED
 => [internal] load build definition from Dockerfile
 ...
 => => naming to docker.io/dgeorgievski/go-app-6:0 
 ....
 => => unpacking to docker.io/dgeorgievski/go-app-6:0.0.16
```

Test the new container image

```sh
$ docker run --rm -ti dgeorgievski/go-app-6:0.0.16 /go-app-6 version
go-app-6 version
  version: 0.0.16
  commit: 1de9255
```

## Kubernetes deployment

### Kind K8S cluster

kind is a tool for running local Kubernetes clusters using Docker container “nodes”.

Create a local `go-app-6` kind cluster.

```sh
$ kind create cluster --name go-app-6
$ kind get clusters
go-app-6
```

Upload the dsocker image to the `go-app-6` kind cluster.

```sh
$ make kind-docker-upload

# or, manually
$ kind --name go-app-6 load docker-image dgeorgievski/go-app-6:0.0.16 
```

Ensure `go-app-6` container image is set to correct version in `deploy/manifests/deployment.yaml` manifest file.

```yaml
 spec:
    serviceAccountName: go-app-6
    containers:
    - name: go-app-6
      image: dgeorgievski/go-app-6:0.0.16
```

Create `go-app-6` namespace

```sh
$ kubectl create ns go-app-6
namespace/go-app-6 created
```

Deploy `go-app-6` app in the newly created namespace

```sh
$ kubectl create -f deploy/manifests
deployment.apps/go-app-6 created
serviceaccount/go-app-6 created
service/go-app-6 created

$ kubectl get all -n go-app-6
NAME                     READY   STATUS    RESTARTS   AGE
kubectl get all -n go-app-6
NAME                         READY   STATUS    RESTARTS   AGE
pod/go-app-6-69c9cf5648-92hc9   1/1     Running   0          52s

NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/go-app-6   ClusterIP   10.96.28.147   <none>        80/TCP    52s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/go-app-6   1/1     1            1           53s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/go-app-6-69c9cf5648   1         1         1       52s
```


### Debugging go-app-6 Pod

```sh
kubectl -n go-app-6 \
debug -it \
--container=debug-container \
--image=alpine \
--target=go-app-6 \
go-app-6-69c9cf5648-92hc9

Targeting container "go-app-6". If you don't see processes from this container it may be because the container runtime doesn't support this feature.
--profile=legacy is deprecated and will be removed in the future. It is recommended to explicitly specify a profile, for example "--profile=general".
If you don't see a command prompt, try pressing enter.
/ # ps axww
PID   USER     TIME  COMMAND
    1 root      0:00 /go-app-6 server
   16 root      0:00 /bin/sh
   26 root      0:00 ps axww
/ #
/ # apk add curl
/ # apk add jq
/ # curl -s localhost:8080/go-app-6 | jq
{
  "message": "go-app-6, World!"
}
/ # curl -s localhost:8080/version | jq
{
  "COMMIT": "1de9255",
  "DATE": "174641174022",
  "VERSION": "0.0.16"
}
```

## CI build and release workflows

### build

This workflow builds the binary, sets the applicatin version and commit hash, and if the branch name is main it creates a git tag using the applicatin version, followed by a dispatch call to the release workflow.

The version is based on the branch type:
1. main - vN.N.N; It keeps the SemVer version from 
2. other branch - The version follows the following format: `<branchname>-<YYYYMMDD>.<github_run_number>`

### release

Release is invoked by a push tag event. The tag value has to have the SemVer format with three parts: `v*.*.*`
The release is automatically called from the build  workflow using a dispatch event call after the build workflow pushes a tag to the main branch.

## Git Hooks scripts

The use of git hooks has been documented in [doc/git-hooks.md](doc/git-hooks.md) file.
