---
title: Six months of CDK
---

Last August I started a new job.  I joined a team of engineers building cloud
infrastructure using the Amazon Web Services (AWS) Cloud Development Kit (CDK)
TypeScript library.  I have had extensive experience building on AWS, but I
haven't used this tool professionally.  The following six months I learned not
only how to use the CDK but also how AWS thinks about infrastructure as code in
general.

In this article, I describe my experience with the CDK and I will argue that,
if you can, you should prefer the CDK to any other tool when building cloud
infrastructure on AWS.

# Infrastructure as code

Cloud providers such as AWS expose thousands of management endpoints to
programmatically interact with compute, storage and networking resources.  In
particular, AWS groups related endpoints into _services_, such as EC2, S3, just
to name two out of more than 400 from their offering.

I remember starting working with AWS in 2018: I felt lost among the three
letter acronyms; I didn't know if I wanted EC2, ECS or EKS, or if I should
choose EBS or EFS when running an instance in VPC.

At the beginning I used a lot the AWS web console to study the most commonly
used services.  For example, I clicked on the "Launch new instance" button,
answered a series of questions — often just accepting the proposed default
values —, then I watched the instance booting.  I traced the details of the
running instance to other resources to understand how they interact.  This way
I learned that running a single virtual machine instance requires an machine
image, a launch template, a volume, a network, and a bunch of permissions.

While I appreciate the interactive and visual nature of the web console,
especially for learning, I can't build large systems by clicking around in my
web browser.

I specify the system's blueprint in plain text files, as source code, which a
computer can translate into programmatic calls to the cloud provider's API.  I
prefer this approach, commonly called [infrastructure as code][WikiIac],
because the blueprint mirrors the engineering _intent_ and, using a source
control system, I can track how the intent changes as the project evolves.

I still use the web console every day, but mainly in "read-only" mode.  I
rarely use it to create or change resources, but I inspect and monitor the
resources the blueprint creates.

![Figure1]({static}/images/cloudformation-cdk-terraform.svg "Comparing CloudFormation, CDK and Terraform interacting with AWS services")

# CloudFormation

AWS CloudFormation, [announced][CFAnnouncement] in 2011, takes infrastructure
blueprints, called _templates_, and provisions the required resources in the
right sequence taking into account any dependencies between resources.
CloudFormation can [automatically deploy][CFDelivery] infrastructure into
[multiple regions][CFStackSet] using templates stored in [Git
repository][CFGit].

Despite its advanced capabilities CloudFormation gathered a bad reputation.  I
used to judge it exclusively based on the syntax of its specification language:
a verbose YAML configuration file sprinkled with awkward [built-in
functions][CFFunctions].

I had to look beyond the syntax to realize that a CloudFormation template
represents a simple _data structure_, built up from numbers, strings, lists and
maps.  You can generate, analyze and transform templates using any programming
tool.

I believe AWS never wanted developers to write giant CloudFormation templates
by hand, but it didn't guide users what to do instead.  As Amazon CTO Werner
Vogels [explains in this video][CDKAnnouncement], the idea of expressing
infrastructure speification using an object-oriended component model grew in an
internal project.  Then, in 2019, they announced the CDK, their offical
CloudFormation template generator.

# Cloud Development Kit (CDK)

The AWS Cloud Develpment Kit (CDK) library, written in TypeScript, generates
CloudFormation templates.  AWS developed [JSii][JSii], a technology to expose
the TypeScript CDK modules to other popular programming languages such as
Python, Go and Java to attract developers from all these communities.  But,
instead of the programming languages, I suggest to study the CDK's programming
model to generate CloudFormation templates.

The [Construct library][Constructs] forms the core of the CDK.  The library has
no dependencies and it defines the `Construct` interface to represent a piece
of system state.  A construct may contain other constructs, forming a tree to
represent the infrastructure blueprint.

The CDK build process automatically generates large part of the CDK library
from [CloudFormation resource specifications][CloudFormationSpec].  For
example, the [CfnBucket][CfnBucket] construct represents a mechanical
translation the [AWS::S3::Bucket][AWS::S3::Bucket] CloudFormation resource.
The AWS documentation refers to these objects as [Layer 1][L1] constructs.

You rarely use these generated objects because CDK engineers also created
[Layer 2][L2] constructs which equip Layer 1 constructs with reasonable
defaults, convenience methods and other syntactic sugar.  For example, the
Layer 2 [Bucket][Bucket] construct allows you to create an S3 bucket that
follows security best practices by configuring only a few parameters.

Finally, your own constructs modeling a application specific patterns of your
infrastructure live at [Layer 3][L3].

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

[CFAnnouncement]: https://aws.amazon.com/about-aws/whats-new/2011/02/25/introducing-aws-cloudformation/
[CDKAnnouncement]: https://youtu.be/AYYTrDaEwLs
[CFDelivery]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-basic-walkthrough.html
[CFFunctions]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html
[CFGit]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/git-sync.html
[CFStackSet]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
[CFRegistry]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/registry.html
[CFSamples]: https://aws.amazon.com/cloudformation/templates/aws-cloudformation-templates-us-west-1/
[WikiIac]: https://en.wikipedia.org/wiki/Infrastructure_as_code
[Constructs]: https://github.com/aws/constructs/tree/10.x
[L1]: https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-cdk-layers/layer-1.html
[L2]: https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-cdk-layers/layer-2.html
[L3]: https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-cdk-layers/layer-3.html
[JSii]: https://github.com/aws/jsii

[AWS::S3::Bucket]: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-s3-bucket.html
[CfnBucket]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_s3.CfnBucket.html
[Bucket]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_s3.Bucket.html
[BucketSrc]: https://github.com/aws/aws-cdk/blob/v2.199.0/packages/aws-cdk-lib/aws-s3/lib/bucket.ts#L1995
[CloudFormationSpec]: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-template-resource-type-ref.html
