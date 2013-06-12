---
title: Introductory Demo Video
layout: default
---

The video below was filmed on Mac OSX 10.8 using a more-or-less standard shell
without much previous setup.

It covers using Capistrano to install an example Rails project on a previously
unprepared server, covering all aspects of Github access, as well as
privisioning the server using *Chef Solo* and Capistrano with *Rake*.



#### Show Notes

The *Chef Solo* recipes can be reached at [this repository at
Github][capistrano-chef-solo-example-recipes], they rely on a fairly new
version of *Chef Solo*, spefically any including the results of [this
ticket][chef-issue-3365]. The aforementioned *Chef* issue adds environment
support to *Chef Solo*.

The provisioning can also be done using any other mechanism, it's generally
accepted however that there's not much point in automising your deploys,
unless you are also automating provisioning of your servers for a known,
consistent state.

Using `sudo` with any deployment can be tricky, so it's better to avoid it.
Rebooting services without `sudo` is typically the first place people run into
trouble using Capistrano. The [trouble shooting page for `sudo`
problems][troubleshooting-sudo-password] may help.

**Note:** Some long sequences have been shortened (nobody needs to sit and watch me
sitting and watching Ruby compile, for example!)

--
[chef-issue-3365]: https://github.com/opscode/chef/pull/359
[troubleshooting-sudo-password]: /troubleshooting/sudo-password/
