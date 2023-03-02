---
title: Functions in disguise
summary:
    I argue that we should use functions to simplify configuration files.
---

Mainstream programming languages support [structured
programming][StructuredProgramming].  Functions, subroutines and methods make
code more expressive and reduce repetition.

Pure functions, constructs that produce values by using only their input
arguments and _nothing else_, are of particular importance.

Pure functions express intent explicitly because, by definition, they don't
rely on side effects.  Pure functions are easier to test and reason about than
those which have observable side-effects.  This post is only about pure
functions, so I'm dropping the "pure" qualifier.

In [functional programming][FunctionalProgramming] programs are composed of
expressions and declarations of functions.  In this niche domain the utility of
functions is well studied and understood.  Ideas from purely functional
programming languages percolate into mainstream programming languages, but
functional programming is far from mainstream.

There is, however, a form of functional programming practiced by every
developer every day.  They write configuration files.  This is the hardest form
of functional programming where _functions are not used at all_.

# Functional configuration

Every non-trivial software requires some configuration.  When a program reads
its configuration it executes a small, often trivial functional program.  Let
me show you what I mean with an example.

Consider the following, INI-style, configuration file:

``` ini
[staging]
url=staging.example.com

[production]
url=example.com
```

Let's say that this is a configuration file of a simple service which is
deployed into a specific environment.  First, we deploy it to staging and, when
all the tests pass,  we promote the application to production.  Naturally, the
service's address is different in these two environments.

This is pretty standard, we see similar configuration blocks everywhere.
Where's the functional programming here?

With the configuration blocks we implicitly created a simple function.  Its
imaginary type signature is:

``` haskell
configuration :: Environment -> Url
```

This reads: the configuration is a function from an environment to a URL.
If we saw such a function signature in an application, we could implement it
like this:

``` python
def configuration(environment):
   return {
     url: 'example.com' if environment == 'production' else 'staging.example.com'
   }
```

For clarity I used Python's familiar syntax, but this is not important.

Conceptually we can think that after the configuration file is parsed, this
function is evaluated.  In practice, we usually don't see this function written
out, but it's hidden somewhere between the configuration format parser library
and our application's initialization.

What we see is that a function, a universally useful concept in programming, is
_not_ being used explicitly to define the program's configuration.

# But the configuration is simple

Let's continue on the previous example and add more configuration parameters:

``` ini
[staging]
url=staging.example.com
db_backend=postres
db_address=%(db_backend).db.example.com

[production]
url=example.com
db_backend=rds
db_address=%(db_backend).amazon.com
```

Here I made the database backend of our service configurable.  It's a contrived
example, but not completely unrealistic: in staging we use our own Postgres
database engine as opposed to production where we wish to store our data in
Amazon's database-as-service offering called Relational Database Service (RDS).

Note that I reused the value of `db_backend` in the definition of `db_address`
because I wanted to avoid duplication.  You can parse this configuration file
with [Python's configparser
module](https://docs.python.org/3/library/configparser.html).

Configuration formats with sections and custom interpolation rules are very
common.  Still, there are some interesting questions to ask:

* What is a valid section name?
* What happens if I repeat the same entry in a section?
* What happens if I omit an entry in a section?
* What are the interpolation rules of the percent expressions?

In this specific case, we find the answers in the not so short
[documentation](https://docs.python.org/3/library/configparser.html),  but the
point is that a concept like 'configuration block' looks deceptively simple. It
takes quite some effort to precisely explain what a file like this means.

Now let's see how this configuration file looks if we represent it explicitly
as a function:

``` python
def configuration(environment):
  if environment == 'production':
    url = 'example.com'
    db_backend = 'postgres'
    db_suffix = '.db.example.com'
  else:
    url = 'staging.example.com'
    db_backend = 'rds'
    db_suffix = '.amazon.com'

  return {
    url: url,
    db_backend: db_backend
    db_address: db_backend + db_suffix
  }
```

Is this better than the INI syntax?  Well, not necessarily, but it triggers
different kinds of thoughts:

* Should we avoid repeating the `example.com` domain?
* Should we introduce a richer data type to represent the database configuration?
* Should we split the database configuration in a separate function?

The answers to these questions depend on the specific context.  Note, however,
that these questions are _programming_ questions.  We raise similar questions
when we write the core of our applications.  Why doesn't configuration deserve
the same level of scrutiny?

Again, I gave the example in Python's syntax for simplicity, but the
configuration language doesn't have to be Python, but it could support function
definitions.

# Functions hide everywhere

Let's leave our toy example and look for functions elsewhere.

## Packer

[Packer](https://www.packer.io/) is a tool for building machine images.
Its documentation explains how to write configuration
[templates](https://www.packer.io/docs/templates/legacy_json_templates)
and use
[variables](https://www.packer.io/docs/templates/legacy_json_templates/user-variables)
to further specialize them from the command line.

The appearance of the word 'variable' suggests that some function-related
business may be going on here.  Indeed, Packer templates are functions from
user variables to build instructions.  Interestingly, Packer templates
themselves [can call
functions](https://www.packer.io/docs/templates/hcl_templates/functions) too.

Now Packer is a wonderful tool and I'm not claiming that there's anything wrong
with it.  I just want you to realize that in a Packer configuration there lies
an ad hoc, mini functional program.

Rolling your own implicitly functional configuration language is a lot of
work and it develops some warts.  For example, [there are
restrictions][PackerTemplateVars] where you can or cannot use variables in a
Packer template.  Again, this is not a problem, you can use Packer just fine.
It's just a pity because variable scoping is pretty well understood since the
development of ALGOL in the 1950s.

## Terraform

[Terraform](http://www.terraform.io) allows you to define your cloud
infrastructure as code.  I use Terraform every day and I cannot imagine my work
without it.

Terraform's configuration language already supports [various programming
constructs](https://www.terraform.io/docs/configuration/functions.html), but
remains implicitly functional.  You cannot define a function explicitly, but a
["module"](https://www.terraform.io/docs/configuration/modules.html).  Just
observe the language used to describe them.  These are quotes from the
documentation, the emphasis is mine:

* _Input variables_ to accept values from the calling module.
* _Output values_ to return results to the calling module.
* To _call_ a module means to include the contents of that module into the
  configuration with specific values for its _input variables_.

It's no surprise that modules actually are functions, or they should be.

You could imagine that when you import a module you compute a value which
contains a bunch of other functions, those that are defined in the module.  In
fact, this is exactly how [JavaScript modules worked][JavaScriptModules] before
the language standard introduced the `import` keyword.

## Ansible and Salt

Configuration management systems such as [Ansible](https://www.ansible.com) and
[Salt](https://www.saltstack.com/) allow you to manage a large number of
machines.  You specify your servers' configuration in a YAML file and these
systems make sure that the desired files, software, etc., are deployed on them.

A core feature of these tools is the ability to specify configuration file
templates which are rendered using context specific parameters (for example:
the server's assigned IP address).  These templates are functions which take
user parameters as arguments and return the rendered configuration file as a
string.

Salt and Ansible also support structuring your configuration into separate
files.  Sadly they are not called modules, but [roles][AnsibleRoles] and
[formulas][SaltFormulas].

If you take a look at the documentation of [Ansible roles][AnsibleRoleVars] you
won't be surprised to find word "variable" again.  The [second
paragraph][AnsibleAbout] of Ansible's documentation claims: _Ansible's main
goals are simplicity and ease of use_.  Take a look how "simple" it is to [use
variables][AnsibleUseVars].

# Warm and fuzzy names

What's wrong with the names "template", "role" and "formula"?  Just replace all
their occurrences with the word "function" and we're done.  Well, no.  It's not
at all about linguistics.

The problem is that your preferred warm and fuzzy name is inevitably more
ambiguous than the concept of a _function_.  When you refuse to admit that
you're manipulating functions in your software configuration you're throwing
away 60+ years worth of computer science.  Additionally, you're creating extra
work for yourself to come up with some idiosyncratic rules for your users to
write modular and comprehensible configuration files for your system.

Why not use functions as the core abstraction to build up configuration files?
Functions can be composed using rigorous, well-defined mathematical rules.  A
functional configuration language could provide few, but powerful concepts to
author configuration files for complex software systems.

Of course this not to say _just use Maths and you're done_.  There's a lot more
to a good configuration language than that.  Nevertheless, I firmly believe
that it's possible to provide developer ergonomics, readability on top of solid
concepts borrowed from Mathematics and Computer Science.

# Summary

Today, configuration files are written in ad hoc, implicitly functional
programming languages where functions don't appear explicitly but disguised.
This leads to the proliferation of ill-defined concepts and idiosyncratic rules.

This makes extremely valuable tools, like those mentioned in this article and
many others, unnecessarily hard to understand, configure and use.

It is possible to define a disciplined, functional programming language for
configuration files.  I encourage you to take a look at
[Dhall](https://dhall-lang.org/).  Get over its unusual syntax and devote some
time understanding the fundamental role of functions in software configuration
and in programming in general.

# Acknowledgment

I'm grateful to [Kyle M. Douglass](https://kmdouglass.github.io) for reviewing
an early draft of this article and for providing valuable feedback.

[StructuredProgramming]: https://en.wikipedia.org/wiki/Structured_programming
[FunctionalProgramming]: https://en.wikipedia.org/wiki/Functional_programming
[PackerTemplateVars]: https://www.packer.io/docs/templates/legacy_json_templates/user-variables#environment-variables
[AnsibleRoles]: https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html
[AnsibleRoleVars]: https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#role-default-variables
[AnsibleAbout]: https://docs.ansible.com/ansible/latest/index.html
[AnsibleUseVars]: https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#information-discovered-from-systems-facts
[SaltFormulas]: https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html
[JavaScriptModules]: https://addyosmani.com/resources/essentialjsdesignpatterns/book/#modulepatternjavascript
