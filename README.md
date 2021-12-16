# Deployment experiments with Docker Containers on Azure

Examining the properties of the various ways to run containers on Azure, as they
were available in Dec. 2021.

## Goals

My goal was to find a reliable way to deploy a small containerized web application,
somewhat comparable to a "Kubernetes deployment", just without the overhead of managing a
Kubernetes cluster.

The image that's being deployed is a simple, stateless, "rest-like" service that can be found at
[github/easimon/simple-rest-service](https://github.com/easimon/simple-rest-service),
or [ghcr.io/easimon/simple-rest-service:latest](ghcr.io/easimon/simple-rest-service:latest).

I wanted to define everything "as code" using terraform, the (unpolished) code is in this repository.

Features tested (where available):

- Run a single HTTP service
- Inject environment variables (plain and secret)
- Mount storage (Azure Blobs or files)
- Capabilities for autoscaling, monitoring
- Continuous deployment (without downtime)
- Custom DNS name and valid TLS certificate

Not tested:

- VNET integration
- Combination with Load Balancers, App Gateway, API mgmt

## Services under consideration

- Azure Container Instances
- Azure Container Apps (Preview)
- Azure App Services (with Docker containers)

## TL;DR

I did not find a service to run container deployments that I would consider for production use
cases. While the "App Service" is the most mature and feature-rich service, it lacks consistence,
reliability and observability. The other two are too simple (Container Instance) or too early (Container App).

Disclaimer: I might have misunderstood one or the other service, and I might have "used it wrong".
If that's the case, feel free to point this out.

## Findings

### Azure Container Instances

Container instances are a simple way to spin up a *single* container group, similar to a Kubernetes Pod.

- Single instance, no replicas / scaling, but a restart policy (never, always, on-failure).
- Environment variables can be be injected, specified literally
- No external storage mounts
- Exposed ports are exposed as is. No mapping (e.g. 8080->80), no integrated TLS offloading
- Custom DNS names are possible, e.g. via CNAME
- (Networking can be configure to be either connected to a VNET or public IP (not both))

This might be a valid use case for running headless jobs or other simple single container use cases, but I did not look further into this, since "no scaling", "no port mapping" was too restricting for what I was looking for.

### Azure Container Apps (Preview)

Container apps seem to be based on Kubernetes internally, with Dapr and Keda, serverless, and are similar to
a "Kubernetes Deployment". They do not have (real) terraform support yet, instead I used terraform to deploy
an ARM template.

- You create one environment, and then many apps on that environment that can communicate with each other
- One single exposed HTTP port can be mapped to 443 behind TLS terminating ingress
- No storage mounts (yet?)
- No custom DNS name, instead something like https://$CONTAINER_APP_NAME.$RANDOM_FOO.$REGION.azurecontainerapps.io/
- Environment variables can be be injected, specified literally (no support key vault references)
- Very early stage, incomplete, e.g.
  - Available only in two regions (north europe and canada central)
  - No monitoring, only stdout and stderr logs
  - Autoscaling based on everything Keda can scale upon, but no observability whatsoever. You cannot see
    how many instances you have, when scaling occurs
  - No terraform support yet (other than deploying ARM templates with terraform)
  - While Ingress can be set to be VNET-internal, it's effectivly "Container-App-Environment"-internal at best, since there's no way to define the VNET (yet)

I did not look further into this, mainly because it's in a such early stage and far from production ready. Since this service is in preview, there's probably more to come and it might evolve to a more complete solution.

### Azure App Service

App Services are the oldest / most mature service. Docker containers are only one of deploying to an App Service, you can also
choose to build/deploy source code to a supported runtime (e.g. Java, Node.js, .NET, ...).

- There's usually a 1:1 relationship between an App Service Plan and an App. The plan specifies instance size and count,
  each "plan instance" is one VM running a single container
  - You can run multiple apps on a plan, they are always scaled equally and share CPU and memory. For container case, this
    might make sense for running something like sidecar containers (but then again, for this, there's docker-compose support in preview)
- Supports environment variables either literally or as "key vault references"
- Supports custom DNS Names, features TLS offloading with (free) managed certificates
- Autoscaling is supported, e.g. based on request count, memory and CPU
- You can mount blobs or file shares to a folder on each instance
- Additional features I did not test
  - Deployment of non-containers
  - Authentication: you can easily offload authentication to your app to e.g. Azure AD to provide non-public apps.
  - VNET integration, available in higher (more expensive) tiers, starting at > $100/month per replica
  - isolated App Service environments
  - ...

#### But ...

During my experiments I ran into multiple issues, grave enough that I would not deploy anything important to this service. Some points might be the result of "using it wrong", or the imperfect terraform support (see below), but even then I would have expected clear error messages instead of the mostly silent/hidden failures. Also, I am not a total newbie in the cloud world, and if it's so easy to "use it wrong", it might be too complex and thus miss the goal of providing a tool to "Quickly create powerful cloud apps for web and mobile".

The worst was, after around a day, my first App Service Plan became unresponsive at some point and I was not able to fix it for hours. The service was stuck, not responding to web requests, non-deletable on the portal, and during that time my custom DNS name (or was it the certificate?) was blocked from being assigned to another App Service. It seems there was a partial, regional outage on my region for that service. I was able to mitigate this by creating a second App Service in a different region and selecting a different host name -- but imagine your app service serving `www.mysmallwebshop.com` dies this way and you're not able to fix it because the DNS name is blocked by the dead service. And running into an outage of a service during the first few hours of using it is also not reassuring.

Observability: is there, but quite limited, especially because UI and monitoring always lag behind considerably. Questions like "why do I have 3 VMs, but only two app replicas?" or "how is scaling progressing?" are hard to find answers for. Also "how is individual CPU usage?", "how are requests balanced?" is something the App Service seems to keep secret -- all metrics are aggregated across replicas.

High availability: At least with terraform and docker containers, I did not find an automatable(!) way to do a zero-downtime rolling deployment from one version to another. There's the concept of a "deployment slot" that lets you create a complete second version of your service, wait for it to become ready -- but that's about where it ends. "Waiting for it to become ready and then switch" is something *you* need to do manually, using the (laggy) portal as the tool to monitor deployment progress. With terraform there's no way to wait for a slot to be fully up before activating it, so irrespective of using slots or not, every change makes the application unhealthy for a period of time, unless you split it into multiple steps with manual watching in between. Also when swapping slots, the UI lags behind and gives a quite inconsistent picture about instance count and health. There are times when the portal considers your application completely "unhealthy" while being perfectly reachable via HTTP for minutes, and also the other way around, when the portal sees your instance as healthy, but the service URL gives you an Azure-generated error message -- and it's never clear if you're looking at the old or the new slot when there are more than one.

The key vault references feature (to pass in secret variables) seems unreliable as well -- sometimes they work, sometimes they don't, even with the very same definition (that's why I do IaC). The problem starts IMHO with the design of the definition format. Instead of clearly defining a value as a "literal value" or a "vault reference", you need to set the _value_ of the environment variable to a special format, `@Microsoft.Keyvault(VaultName=...;SecretName=...)`. And to get it successfully replaced,

- you need to get this syntax right, otherwise it might not be detected as a reference at all
- you need to specify an existing vault
- you need specify an existing secret
- your app needs to have an identity with permissions to read from that vault
- and your app needs to select the correct identity (you need to specify this identity twice)

And in addition to that, the feature needs to be in a good mood. If any of these points fail, your environment variable contains the unreplaced key vault reference definition (`@Microsoft.Keyvault(...)`) without any indication of the cause. It does not fail the deployment, it does not raise an alert, it just boots your app with an invalid configuration. If it is at least recognized as a key vault reference, but fails to load for some reason, there is a small red indicator in the portal next to the variable definition, but that's it. When using this feature, make very sure to validate your environment variables on application start, and crash when they seem invalid -- then at least you know. I sometimes lost the value assignment by just switching between two identical deployment slots.

Blob storage is flaky, too. I mounted a blob storage to a folder, serving three files, and my service just served them as static content. At some point I received incomplete / truncated files through that mount, and this condition took multiple requests / minutes to resolve. As if the app service caches the blobs -- even if they're incomplete. Also the latency for requests to the mounted blob storage was inconsistent, from milliseconds up to multiple seconds for a single request to one of these static resources.

Scaling takes a lot of time. Partly understandable, since for a scale-out, the App Service needs to provision a new VM first, and then deploy the app service to it. Both steps take multiple minutes each, during which you have little idea about the progress. If you define your scaling cooldown (pause between two scaling actions) too eager, scale-out often over-shoots by an instance or two before the first instance is actually ready to serve requests -- while this is the case with every autoscaler, a latency of 5-10 minutes to scale out a simple container is not great, especially if you're flying blind during that time.

Last but not least, also terraform support is incomplete: While you can define storage mounts on `azurerm_app_service`, the propery is missing on `azurerm_app_service_slot`. Slot activation is inconsistent, if you define properties on one but not the other. Properties defined on the service, but not specified on a new slot sometimes survive a slot switch, sometimes they do not. E.g. I lost external storage (defined in the app service, but not in the slots) only after swapping slots *a few times* -- or maybe I am wrong and the slot switch took so long that I noticed the missing mount only multiple switches later? I don't know, since there's no clear way to determine which slot is really active.

#### Unclear points

There are also a few points I do not understand about App Services. Especially the destinction between App Service Plan and App Service, which seems to be a 1:1 mapping in most (recommended) cases. This also means, there's a 1:1 relation in scaling between plan and app. I wonder why there is this distinction, why does Azure not get rid of one of the layers?

Also unclear is, how "slot replicas" and "plan replicas/VMs" map when having multiple (active) slots? Do I get the additional VMs for free when having multiple slots, or does every VM then run multiple (all?) slots in parallel? Can I run into OOM, when running too many slots? How would I see this? [The documentation](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots) is not 100% clear on this, though it *seems* that a slot boots additional VMs.

Unless you go for "high density deployment", which seems to loosen the strict 1:1 dependency between VMs and containers, but at the loss of being able to autoscale an app. Also I have not seen any affinity rules to spread my app across the VMs. It's unclear how Azure packs apps on VMs in this mode.

## Summary

Maybe the comparison to "Kubernetes deployment" is somewhat unfair. To have the wanted features with Kubernetes, it usually takes more components, like at least

- Kubernetes to start with (e.g. AKS)
- Prometheus + Loki / EFK for logging and monitoring
- Certmanager + External-DNS for TLS certificates
- Some ingress for TLS offloading
- Some deployment magic to resolve secrets ([or maybe this AKS addon](https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver))

All of which need to be configured, installed and maintained in addition to your container app. Exactly for this reason I was searching for something simpler, especially for small use-cases.
