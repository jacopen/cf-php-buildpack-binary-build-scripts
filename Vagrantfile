# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "lucid" do |lucid|
    lucid.vm.box = "f500/ubuntu-lucid64"
    lucid.vm.provider "virtualbox" do |v|
      v.name = "Ubuntu 10.04 Lucid - CF PHP Buildpack Binary Builder (vagrant)"
      v.cpus = 4
    end
  end

  config.vm.define "precise" do |precise|
    precise.vm.box = "ubuntu/precise64"
    precise.vm.provider "virtualbox" do |v|
      v.name = "Ubuntu 12.04 Precise - CF PHP Buildpack Binary Builder (vagrant)"
      v.cpus = 4
    end
  end

  config.vm.define "trusty" do |trusty|
    trusty.vm.box = "ubuntu/trusty64"
    trusty.vm.provider "virtualbox" do |v|
      v.name = "Ubuntu 14.04 Trusty - CF PHP Buildpack Binary Builder (vagrant)"
      v.cpus = 4
    end
  end
end
