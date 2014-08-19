## CloudFoundry PHP Build Pack Binary Build Scripts

This is a set of scripts that can be used to build the binary files required by the [CF PHP Build Pack]:

 * Apache httpd 2.4.x
 * Nginx 1.5.x, Nginx 1.6.x, Nginx 1.7.x, 
 * PHP 5.4.x, PHP 5.5.x
 * a full set of extensions for both version of PHP.

The scripts are configured with variables at the top and can be used to build different versions of each project and modules for the projects.  The scripts were originally designed to be run on Ubuntu 10.04, which is the current stack used by CF.  It has been expanded to support Ubuntu 12.04 and Ubuntu 14.04 as well.  Different OS & Version combinations are supported through different branches of the repository.

The builds are performed inside virtual machines managed by Vagrant. You can run the builds on your local machine using
VirtualBox or VMware Fusion, or remotely on DigitalOcean.

### Usage (VirtualBox)

 1. Install [Vagrant](http://www.vagrantup.com/) on your local machine.
 1. Install [VirtualBox](https://www.virtualbox.org/) on your local machine.
 1. Clone this repository.
 1. Change directories to your newly-cloned repository (`cd cf-php-buildpack-binary-build-scripts`) and run `vagrant up`. This will download and boot 3 Ubuntu virtual machines: 10.04 Lucid, 12.04 Precise, and 14.04 Trusty
 1. Run `vagrant ssh lucid -c /vagrant/build/run_local.sh` to start the build. Instead of `lucid` you may use the same command with `precise` or `trusty`.

This will run the build script, which handles everything else.  See the `run_local.sh` script below for more details.

### Usage (VMware Fusion)

 1. Install [Vagrant](http://www.vagrantup.com/) on your local machine.
 1. Install [VMware Fusion](http://www.vmware.com/products/fusion/) on your local machine.
 1. Install the [VMware provider for Vagrant](http://www.vagrantup.com/vmware) by following [these instructions](http://docs.vagrantup.com/v2/vmware/installation.html).
 1. Clone this repository.
 1. Change directories to your newly-cloned repository (`cd cf-php-buildpack-binary-build-scripts`) and run `vagrant up --provider=vmware_fusion`. This will download and boot 3 Ubuntu virtual machines: 10.04 Lucid, 12.04 Precise, and 14.04 Trusty
 1. Run `vagrant ssh lucid -c /vagrant/build/run_local.sh` to start the build. Instead of `lucid` you may use the same command with `precise` or `trusty`.

This will run the build script, which handles everything else.  See the `run_local.sh` script below for more details.

### Usage (DigitalOcean)

 1. Install [Vagrant](http://www.vagrantup.com/) on your local machine.
 1. Install the [Digital Ocean provider for Vagrant](https://github.com/smdahlen/vagrant-digitalocean): `vagrant plugin install vagrant-digitalocean`
 1. Clone this repository.
 1. Change directories to your newly-cloned repository (`cd cf-php-buildpack-binary-build-scripts`).
 1. Edit `Vagrantfile` to configure your private key path (`override.ssh.private_key_path`) and add your Digital Ocean API token. This is described in detail on the [Digital Ocean Vagrant Provider page](https://github.com/smdahlen/vagrant-digitalocean)
 1. Run `vagrant up lucid --provider=digital_ocean`. This will create a new Digital Ocean droplet for use by Vagrant. You can use the same command with `precise` or `trusty`.
 1. Run `vagrant ssh -c /vagrant/build/run_local.sh lucid` to start the build.
 1. When the build is finished, run `scp -r root@<digitaloceandropletip> /vagrant/output/` and the `output` folder will contain all the build artifacts.
 1. Run `vagrant destory` to destroy the Digital Ocean droplets and stop charges.

This will run the build script, which handles everything else.  See the `run_local.sh` script below for more details.

### Scripts

Here's a listing of the scripts and what they do.

#### Build Directory

This is the main directory for the scripts, and contains the following scripts.

|   Script Name   |   Explanation                                                 |
| --------------- | --------------------------------------------------------------|
|  run_local.sh    | Runs the full build suite.  This will install git, clone or update the repository, install and update all required dependencies and run all of the build scripts. |
|  build-all.sh    | Builds all of the local packages.  This calls the individual build scripts in each of the component directories.  This script is called by `run_local.sh`. |
|  upload.sh       | Upload binaries to DropBox. |

#### Component Build Scripts

Each supported OS & Version combination has it's own branch.  These are largely similar, but each combination has it's own differences.  When you run the `run_local.sh` script, your OS and Version are determined by looking at `/etc/issue` and the correct branch is checked out.

The OS & Version specific branches contain the individual scripts which compile the various components.  These are stored in project subdirectories with a name and major version number and contain the build script.  The build script is responsible for building that individual component.  Most of the time this boils down to running `./configure && make && make install`, but some components are more complicated than that.  Regardless, this script is responsible for building and packaging the component.

Generally you should run the `run_local.sh` script to build the full suite of components, but you can run the individual `<component-version>/build.sh` script if you want to build just a single component.

#### Upload Script

If hosting files on DropBox, this script can be used to walk the `output` directory (i.e. where built files are downloaded) and automatically upload files to DropBox.

This script relies on the [Dropbox-Uploader] to handle the work of actually uploading files to DropBox.  To use the upload script, you must first run the `./dropbox/dropbox_uploader.sh` script.  The first time it's run, it will walk you through setting up your DropBox account to allow it to connect and upload files.  This creates a config file with your DropBox API credentials and OAuth token info.  It's stored in `~/.dropbox_uploader`.


[CF PHP Build Pack]:https://github.com/dmikusa-pivotal/cf-php-build-pack
[ssh key]:https://www.debian.org/devel/passwordlessssh
[Dropbox-Uploader]:https://github.com/andreafabrizi/Dropbox-Uploader
