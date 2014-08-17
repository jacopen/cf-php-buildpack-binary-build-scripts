# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # DIGITAL OCEAN CONFIG
  config.vm.provider "digital_ocean" do |digitalocean, override|
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    digitalocean.token            = 'YOUR API TOKEN'
  end



#######################################################################################
######################### DO NOT EDIT ANYTHING BELOW ##################################
#######################################################################################


#######################################################################################
######################### UBUNTU 10.04 LUCID ##########################################

  config.vm.define "lucid" do |lucid|

    # VIRTUALBOX
    lucid.vm.provider "virtualbox" do |virtualbox|
      lucid.vm.box    = "f500/ubuntu-lucid64"
      virtualbox.name = "Ubuntu 10.04 Lucid - CF PHP Buildpack Binary Builder (vagrant)"
    end

    # DIGITAL OCEAN
    lucid.vm.provider "digital_ocean" do |digitalocean, override|
      digitalocean.image  = 'Ubuntu 10.04 x64'
      lucid.vm.hostname = 'ubuntu-10.04-cf-php-buildpack-binary-builder'
    end
  end

#######################################################################################
######################### UBUNTU 12.04 PRECISE ########################################

  # UBUNTU 12.04 PRECISE
  config.vm.define "precise" do |precise|

    # VIRTUALBOX
    precise.vm.provider "virtualbox" do |virtualbox|
      precise.vm.box  = "ubuntu/precise64"
      virtualbox.name = "Ubuntu 12.04 Precise - CF PHP Buildpack Binary Builder (vagrant)"
    end

    # DIGITAL OCEAN
    precise.vm.provider "digital_ocean" do |digitalocean, override|
      digitalocean.image  = 'Ubuntu 12.04.5 x64'
      precise.vm.hostname = 'ubuntu-12.04.5-cf-php-buildpack-binary-builder'
    end
  end

#######################################################################################
######################### UBUNTU 14.04 TRUSTY##########################################

  # UBUNTU 14.04 TRUSTY
  config.vm.define "trusty" do |trusty|

    # VIRTUALBOX
    trusty.vm.provider "virtualbox" do |virtualbox|
      trusty.vm.box   = "ubuntu/trusty64"
      virtualbox.name = "Ubuntu 14.04 Trusty - CF PHP Buildpack Binary Builder (vagrant)"
    end

    # DIGITAL OCEAN
    trusty.vm.provider "digital_ocean" do |digitalocean, override|
      digitalocean.image = 'Ubuntu 14.04 x64'
      trusty.vm.hostname = 'ubuntu-14.04-cf-php-buildpack-binary-builder'
    end
  end

#######################################################################################
######################### DIGITAL OCEAN GLOBAL CONFIG #################################

  config.vm.provider "digital_ocean" do |digitalocean, override|

    override.vm.box     = 'digital_ocean'
    override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

    digitalocean.region = 'nyc2'
    digitalocean.size   = '1GB'
  end

#######################################################################################
######################### VIRTUALBOX GLOBAL CONFIG ####################################

  config.vm.provider "virtualbox" do |virtualbox, override|
      virtualbox.cpus = 4
  end
end