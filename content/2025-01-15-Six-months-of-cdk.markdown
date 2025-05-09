---
title: Six months of CDK
---

Last year in August I started a new job.  I joined a team of engineers building
cloud infrastructure using the Amazon Web Services (AWS) Cloud Development Kit
(CDK) TypeScript library.  I have had extensive experience building on AWS, but
I haven't used this tool professionally.  The following six months I learned
not only how to use the CDK but also how AWS thinks about infrastructure as
code in general.

In this article, I describe my experience with the CDK and I will argue that,
if you can, you should prefer the CDK to any other tool when building cloud
infrastructure on AWS.

# Infrastructure as code

Cloud computing platforms providers such as AWS expose thousands of management
endpoints to programmatically interact with compute, storage and networking
resources.  In particular, AWS groups related endpoints into _services_, such
as EC2, S3, just to name two out of the 400+.

I remember when I started learning AWS in 2018 I felt lost among the three
letter acronyms; I didn't know if I wanted EC2, ECS or EKS, or if I should
choose EBS or EFS when running an instance in VPC.

At the beginning I used a lot the AWS web console to study the most commonly
used services.  For example, I clicked on the "Launch new instance" button,
answered a series of questions — often just accepting the proposed default
values —, then I watched the instance booting.  I traced the details of the
running instance to other services to understand how they interact.  This way I
learned that running a single virtual machine instance requires an machine
image, a launch template, a volume, a network, and a bunch of permissions.

While I appreciate the interactive and visual nature of the web console,
especially for learning, I can't build large systems by clicking around in my
web browser. I specify the system's blueprint in plain text files, as source
code, which a computer can translate into programmatic calls to the cloud
provider API.  I prefer this approach, commonly called [infrastructure as
code][WikiIac], because the blueprint mirrors the engineering _intent_ and,
using a source control system, I can track how the intent changes as the
project evolves.

I still use the web console every day, but mainly in "read-only" mode.  I
rarely create or change resources, but I inspect and monitor the resources the
blueprint creates.

The following diagram compares the AWS CloudFormation and AWS CDK to Hashicorp's Terraform tool.

![Figure1]({static}/images/cloudformation-cdk-terraform.svg "Comparing CloudFormation, CDK and Terraform interacting with AWS services")

In the next section I focus on AWS ClouFormation and the CDK.

# CloudFormation

* Surface language is YAML, looks like LISP

CloudFormation's story for:

* Continous delivery: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-basic-walkthrough.html
* Deployment to multiple accounts StackSets: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
* Deployment from source code Git sync: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/git-sync.html
* Extending and sharing: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/registry.html


# Cloud Development Kit (CDK)

* Architecture Diagram

Story for:

* Deploy to multiple accounts with a pipeline: https://aws.amazon.com/blogs/devops/best-practices-for-developing-cloud-applications-with-aws-cdk/

# Terraform and co.

# Outline

Good:

* Excellent integration with CloudFormation
* CloudAssembly has a formal definition
* Leaning on excellent npm tooling: package management, build, test, pipelines
* CustomAwsResource (the documentation explains it well, it serves as a bridge between CloudFormation and raw API calls. I used it to solve the missing multitenant flag in CloudFormation)
* CDK pipelines module: especially the multi-region, multi-account bootstrapping capability.
* Great defaults most of the time: S3 bucket follows automatically AWS recommendations
* Possible to use raw CloudFormation
* Constructs and Stacks are solid modeling concepts
* No promise that you're doing "multi-platform". You focus on your problem, that is getting your application run in AWS. Period.

Advise:

* Take account-level separation seriously. For example, stack names are global in a region. Follow the recommendations in the multi-account whitepaper.
* Read and understand https://aws.amazon.com/blogs/devops/best-practices-for-developing-cloud-applications-with-aws-cdk/

Mixed:

* The concepts L2/L3 constructs are unclear (perhaps even unnecessary)
* VPC resource, pretty flexible, but not always clear what's going on under the hood. It's definitely good for quick tests, as every compute recourse requires a VPC. The defaults are pretty generous: it creates two AZs (to check), NAT gateways in both of them. These resources are pricey. Often, you don't need them for quick tests.
* Syntactically unclear what happens synth/deploy/run time (writing your lambda and infrastructure definitions in the same language makes them easier to mix up)
* CloudFormation is raw, but it's more reusable because it's pure data, much simpler, less "abstractions".
* Choosing the logical ids is by convention, but it's unclear what's the convention. Example: construct has an id and its sub-constructs' names are prefixed with id.
* Token[xxx], Object values may slip in the rendered CloudFormation
* The Construct hierarchy is visible in the UI
* Default update policy is create-before-destroy: when you move constructs provisioning may fail.
* Changing infrastructure code is hard. Create-before-destroy behavior is the default, but I don't know how to change this.

Avoid:

* Blueprints repository: async? own dependency management, dependency magnet
* Wrapping other stuff (find reference: "providing safe defaults is not enough")
* Temptation to write "reusable" modules.
* If you're an AWS shop, go all-in AWS: avoid Terraform, Pulumi and suchlike. The surface language is the least important thing. The CloudFormation engine and its integration with the whole AWS ecosystem is the big thing.

Example HelmChart validation in the Blueprints repository:

* https://github.com/aws-quickstart/cdk-eks-blueprints/blob/main/lib/addons/helm-addon/index.ts#L16

# Summary

If you build on AWS, I suggest to use the Cloud Development Kit.  You may have reasons to choose something else, but I believe you should consider the CDK first and think really hard if you need something else.

[WikiIac]: https://en.wikipedia.org/wiki/Infrastructure_as_code
