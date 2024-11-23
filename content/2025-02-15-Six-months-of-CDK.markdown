---
title: Six months of CDK
---

Last August I started a new job.  I joined a team of engineers building cloud
infrastructure using the Amazon Web Services (AWS) Cloud Development Kit (CDK)
TypeScript library.  I have had extensive experience building on AWS, but I
haven't used this tool professionally.

In this article I describe my experience with the CDK and I will argue that, if
you can, you should prefer the CDK to any other tool when building cloud
infrastructure on AWS.

# Infrastructure as code

Cloud providers such as AWS expose thousands of management endpoints to
programmatically interact with compute, storage and networking resources.  In
particular, AWS groups related endpoints into _services_, such as EC2, S3, just
to name two out of more than 400 from their offering.

I remember learning AWS back in 2018: I felt swamped by all the three letter
acronyms.  I didn't know if I needed EC2, ECS or EKS, or if EBS made more sense
for an instance inside a VPC.

Initially, I studied the most commonly used services using the AWS web console
used services.  For example, I clicked on the "Launch new instance" button on
the EC2 console, answered a series of questions — often just accepting the
proposed default values —, then I watched the instance booting.  I traced the
details of the running instance to other resources to understand how they
interact.  This way I learned that running a single virtual machine instance
requires an machine image, a launch template, a volume, a network, and a bunch
of permissions.

While I appreciate the interactive and visual nature of the web console,
especially for learning, I can't build large systems by clicking around in my
web browser.

I specify the system's blueprint in plain text files, as source code, which a
computer can translate into programmatic calls to the cloud provider's API.  I
prefer this approach, commonly called [infrastructure as code][WikiIac],
because the blueprint mirrors the engineering _intent_ and, using a version
control system, I can track how the intent changes as the project evolves.

I still use the web console every day, but mainly in "read-only" mode.  I
rarely use it to create or change resources, but I inspect and study the
resources the blueprint creates.

# CloudFormation

AWS CloudFormation, [announced][CFAnnouncement] in 2011, takes infrastructure
blueprints, called _templates_, and provisions the required resources in the
right sequence taking into account any dependencies between resources.
CloudFormation can [automatically deploy][CFDelivery] infrastructure into
[different regions][CFStackSet] using templates stored in [Git
repository][CFGit].

Despite its advanced capabilities CloudFormation gathered a bad reputation.  I
used to judge it based on the syntax of its specification language: a verbose
YAML configuration file sprinkled with awkward [built-in
functions][CFFunctions].

I had to look beyond the syntax to realize that a CloudFormation template
represents a simple _data structure_, built up from numbers, strings, lists and
maps.  You can generate, analyze and transform templates using any programming
tool.

I believe AWS never wanted developers to write giant CloudFormation templates
by hand, but it didn't guide users what to do instead.  AWS engineers, while
working on an internal project, [searched for a more expressive way][CDKBlog]
of writing infrastructure specifications.  Their ideas seeded the development
of the CDK which AWS announced in 2019 as their official CloudFormation
template generator.

# Cloud Development Kit (CDK)

The AWS Cloud Development Kit (CDK) library, written in TypeScript, generates
CloudFormation templates.  AWS developed [JSii][JSii], a technology to expose
the TypeScript CDK modules to other popular programming languages such as
Python, Go and Java to attract developers from all these communities.  But,
instead of the programming languages, I suggest to study the CDK's programming
model to generate CloudFormation templates.

## Constructs

The [Construct library][Constructs] forms the core of the CDK.  The library has
no dependencies and it defines the `Construct` interface modeling a piece of
system state.  A construct may contain other constructs, forming a tree
representing the infrastructure blueprint.

The CDK build process automatically generates large part of the CDK library
from [CloudFormation resource specifications][CloudFormationSpec].  For
example, the [CfnBucket][CfnBucket] construct represents a mechanical
translation of the [AWS::S3::Bucket][AWS::S3::Bucket] CloudFormation resource
to TypeScript.  The AWS documentation refers to these objects as [Layer 1][L1]
constructs.

You rarely use these generated objects because CDK engineers also created
[Layer 2][L2] constructs which equip Layer 1 constructs with reasonable
defaults, convenience methods and other syntactic sugar.  For example, the
Layer 2 [Bucket][Bucket] construct by default creates an S3 bucket that follows
[AWS's security recommendations][S3BestPractices].  Also, you can just write

```
bucket.grantRead(ec2-instance)
```

which creates the necessary IAM policies so that the EC2 instance can read
objects from the bucket.

Finally, constructs modeling application specific patterns live at [Layer
3][L3].  For example, [CDK Pipelines][CDKPipelines] construct library
coordinates many AWS services to create a deployment pipeline for a CDK
application.  This library showed me the leverage the CDK offers: in just a few
lines of code, I could create a continuous deployment pipeline that deploys my
infrastructure into three regions using two AWS accounts.

I admit, the first few times I read the documentation, I didn't pay close
attention to this layering.  When I develop with the CDK, I don't have to think
about this stratification: constructs at each layer present the same uniform
interface, allowing me to freely combine any constructs I need.  But,
understanding the difference between these layers shaped my expectations
towards specific constructs.

I view Layer 1 constructs as the platform's primitive operations.  Because
every AWS service integrates with CloudFormation, often from the day of its
public release, the corresponding Layer 1 construct quickly becomes available
in the CDK via automatic translation process I mentioned earlier.  In contrast,
the hand-written Layer 2 constructs, if they exist,  often introduce
higher-level abstractions which may or may not work for your use case.

Take the [VPC][VPC] Layer 2 construct, for instance.  It comes with generous
defaults setting up two Availability Zones and NAT gateways in both. These make
sense when you design for high availability, but feels like overkill if you
just need to launch a few development machines.  Or, sometimes you want to
assign secondary IP addresses to instances running in a VPC but this construct
doesn't allow for that; you'd have to build the missing bits using Layer 1
constructs.

Even with these caveats, I've found Layer 2 constructs generally effective in
my projects.  I always try to use them first before I consider Layer 1
constructs, or even raw CloudFormation.

## Escape hatches

You can import existing CloudFormation templates, written in YAML or JSON, and
treat them as CDK Constructs:  I had used a small CloudFormation template in my
project; it worked seamlessly, but after a few days I just rewrote it in
TypeScript.

Rarely, you may [find][CFRoadmap] that a CloudFormation resource doesn't cover
all configuration options of a resource.  In this case you can fall back to AWS
SDK calls triggered on CloudFormation stack operation events such as Create,
Delete, or Update.  The CDK's [AwsCustomResource][AWSCustomResource] construct
allows you to bridge any gap in the CloudFormation coverage.

## Tooling

The CDK's availability across many programming languages always intrigued me.
Advocates often present this as a key benefit: a team developing a TypeScript
application, for example, can now write its infrastructure definition in
TypeScript as well.  This eliminates the need to learn a new domain-specific
language.  An argument I'll call "appeal to familiarity" and one I certainly
don't disagree with.  But, looking again beyond the language syntax, I think
leveraging an existing programming library ecosystem provides the most benefit.

When I started using the CDK I didn't know TypeScript.  I had used JavaScript
and many other programming languages, so learning the basics of TypeScript
didn't pose a problem for me: the web community produced an incredible amount
of learning material, libraries, package managers and other tools.  After a few
hours I already studied the "CDK world", because the TypeScript scaffolding
just worked.

# Difficulties

I praised the CDK's construct-based component model and its integration with
other AWS tools and with existing programming language ecosystems.  But during
my six months journey I faced a also few difficulties which I describe next.

## Moving resources

I like maintaining code which groups resource definitions into high-level,
application-specific modules like "storage layer" or an "compute cell" because
the structure provides me context about a particular resource's role in the
application.  As I mentioned before, constructs provide a great modeling tool
for building up these modules.

The CDK computes a resource's unique identity based on its [path within the
construct
tree](https://docs.aws.amazon.com/cdk/v2/guide/identifiers.html#identifiers-unique-ids).
Hence, when you move a resource from one high-level construct to another,
CloudFormation interprets this change as an instruction to recreate that
resource under a new identity.  Depending on the resource, this might cause
service interruption, data loss, or both.

A technique I learned from the CDK documentation protects against accidental
resource destruction:  I add a unit test that asserts the stability of the
critical resource's logical identifier.

## Using deferred values

In a CloudFormation template a [Ref][CFRef] refers an another resource's
property.  During deployment, the CloudFormation service orders resource
creation such that it can substitute the `Ref` with the property's actual
value.

The CDK models references using [tokens][CDKToken]. These tokens present as
regular TypeScript strings, but their values use a special encoding.  This
design choice lets you write code that looks like direct property access, which
the CDK translates into `Ref`s when needed.  On the flip slide, you lack a
clear signal when you handle one of these deferred values.

Fortunately, most of the code I write avoids inspecting or manipulating tokens.
If you develop a construct library I suggest to study [how to check for
unresolved tokens in your constructs][CDKToken].

## EKS Blueprints

The final point I want to make doesn't concern the CDK itself; it highlights a
self-inflicted problem that can surface in any project.  At work we use the
[EKS Blueprints library][EKSBlueprints] which to me creates more issues than it
solves.  Instead of using plain constructs, this library layers a bespoke
dependency injection system on top of the CDK's existing construct programming
model. And, this implementation heavily relies on async/await, which makes
escaping its patterns incredibly difficult.

# Summary

If you build on AWS, I suggest using the Cloud Development Kit.  You may have
reasons to choose something else, but I believe you should consider the CDK
first before anything else.  For learning, I recommend the [official
documentation][CDKHome], and especially the [best practices][CDKBestPractices]
section which offers many useful tips on structuring your AWS accounts,
deployment pipelines, and CDK code.  Finally, use any constructs from CDK, but
think twice before importing other construct libraries.

[AWS::S3::Bucket]: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-s3-bucket.html
[AWSCustomResource]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.custom_resources.AwsCustomResource.html
[Bucket]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_s3.Bucket.html
[BucketSrc]: https://github.com/aws/aws-cdk/blob/v2.199.0/packages/aws-cdk-lib/aws-s3/lib/bucket.ts#L1995
[CDKBestPractices]: https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html
[CDKBlog]: https://aws.amazon.com/blogs/opensource/working-backwards-the-story-behind-the-aws-cloud-development-kit/
[CDKHome]: https://docs.aws.amazon.com/cdk/v2/guide/home.html
[CDKPipelines]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.pipelines-readme.html
[CFAnnouncement]: https://aws.amazon.com/about-aws/whats-new/2011/02/25/introducing-aws-cloudformation/
[CFDelivery]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-basic-walkthrough.html
[CFFunctions]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html
[CFGit]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/git-sync.html
[CfnBucket]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_s3.CfnBucket.html
[CFRoadmap]: https://github.com/aws-cloudformation/cloudformation-coverage-roadmap/issues/1979
[CFRegistry]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/registry.html
[CFSamples]: https://aws.amazon.com/cloudformation/templates/aws-cloudformation-templates-us-west-1/
[CFStackSet]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
[CFRef]: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/intrinsic-function-reference-ref.html
[CloudFormationSpec]: https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-template-resource-type-ref.html
[Constructs]: https://github.com/aws/constructs/tree/10.x
[EKSBlueprints]: https://github.com/awslabs/cdk-eks-blueprints
[JSii]: https://github.com/aws/jsii
[L1]: https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-cdk-layers/layer-1.html
[L2]: https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-cdk-layers/layer-2.html
[L3]: https://docs.aws.amazon.com/prescriptive-guidance/latest/aws-cdk-layers/layer-3.html
[S3BestPractices]: https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html
[VPC]: https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.aws_ec2.Vpc.html
[WikiIac]: https://en.wikipedia.org/wiki/Infrastructure_as_code
[CDKToken]: https://docs.aws.amazon.com/cdk/v2/guide/tokens.html
