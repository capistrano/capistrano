---
title: What is Harrow?
layout: default
---

### Harrow is a web-based platform for continuous integration and deployment built by the Capistrano team.

There are many continuous integration tools in the world already, Harrow is
ours. It is designed to "feel" familiar to Capistrano users.

![Harrow, web-based Capistrano](/images/capistrano-logo-harrow-logo-c-primary-darker-w640.png)

Although Harrow is designed to work well for Capistrano-style use-cases, it is
by no means limited to only being used for Capistrano, or even for deployment.

Some of the features which make Harrow ideal for automating tools such as
Capistrano:

* A discrete concept of scripts and environments, allowing reuse of scripts in
  different settings using different configurations
* A pure JSON-HAL API allowing integrations and tools
* Powerful triggers and notifications allowing the construction of pipelines
  starting with git changes

Harrow, much like Capistrano can also be used to:

* To automate common tasks in software teams
* To drive infrastructure provisioning tools such as *chef-solo*, *Ansible* or similar

Again, like Capistrano, Harrow is also *very* scriptable, and can be integrated
with any other software to form part of a larger tool.

#### How To Use Harrow

1. Sign up for a Harrow [account](https://www.app.harrow.io/#/a/signin)
2. Connect your Git repository using our setup wizard
3. Choose "Capistrano" as the project template

#### What does it cost, and how does that affect Capistrano

Harrow has very reasonable [pricing](https://harrow.io/pricing/). As a
comparison with other continuous integration tools, some of our customers have
cut their monthly outgoing by a factor of 5 or more.

For individual users, it's free to use forever. To work with collaborators in
your projects, paid plans start at just $29/mo.

Capistrano is unaffected by Harrow. Capistrano will remain liberally licensed
(currently MIT) and will include discrete hooks offering Harrow to users
without being intrusive.
