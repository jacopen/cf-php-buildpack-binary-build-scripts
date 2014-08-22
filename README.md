## CloudFoundry PHP Build Pack Binary Build Scripts

This is a set of scripts that can be used to build the binary files required by the [CF PHP Build Pack]:

 * Apache httpd 2.4.x
 * Nginx 1.5.x, Nginx 1.6.x, Nginx 1.7.x, 
 * PHP 5.4.x, PHP 5.5.x
 * a full set of extensions for both version of PHP.

The scripts are configured with variables at the top and can be used to build different versions of each project and modules for the projects.  The scripts were originally designed to be run on Ubuntu 10.04, which is the current stack used by CF.  It has been expanded to support Ubuntu 12.04 and Ubuntu 14.04 as well.  Different OS & Version combinations are supported through different branches of the repository.

The builds are performed inside virtual machines managed by Vagrant. You can run the builds on your local machine using
VirtualBox or VMware Fusion, or remotely on DigitalOcean.

### Usage

#### VirtualBox / VMware Fusion

 1. Install [Vagrant](http://www.vagrantup.com/) on your local machine.
 1. Install [VirtualBox](https://www.virtualbox.org/) or [VMware Fusion](http://www.vmware.com/products/fusion) on your local machine.
 1. If using VMware Fusion, also install the [Vagrant provider](https://www.vagrantup.com/vmware) for it.
 1. Clone this repository.
 1. Change directories to your newly-cloned repository (`cd cf-php-buildpack-binary-build-scripts`) and run `./build/run_vagrant.sh all`. This will cycle through three Ubuntu virtual machines: 10.04 Lucid, 12.04 Precise, and 14.04 Trusty.  On each machine, it will build the binaries and copy them to a sub-folder of the `output` directory.  
 1. When the build is complete, the packages will all reside in the `output` directory on the local machine.

To see what happens on each vm, refer to the `run_local.sh` script below.

#### DigitalOcean

 1. Install [Vagrant](http://www.vagrantup.com/) on your local machine.
 1. Install the [Digital Ocean provider for Vagrant](https://github.com/smdahlen/vagrant-digitalocean): `vagrant plugin install vagrant-digitalocean`
 1. Clone this repository.
 1. Change directories to your newly-cloned repository (`cd cf-php-buildpack-binary-build-scripts`).
 1. Run `VAGRANT_DEFAULT_PROVIDER=digital_ocean DO_API_TOKEN=<your-api-token> ./build/run_vagrant.sh all`.  This assumes the default settings will be used.  For different options, see the configuration section below.
 1. When the build is complete, files will be scp'd down to the local machine and placed in an OS/Version specific sub-folder of the `output` directory.
 1. Please note that the script will halt your DO instance when it is finished.  This allows you to run subsequent builds on the same instance without having to completely rebuild and re-initialize the system.  When you are finished, run `./vagrant/<platform>/vm_ctl destroy` to delete the instance or delete it through the DO console.

To see what happens on each vm, refer to the `run_local.sh` script below.

##### DigitalOcean Config Options

The Vagrant scripts that start your DO instances attempts to use good default options, however there are a few settings that you can change to alter the behavior.  The following list documents the environment variables that you can set to change the script's behaviour.

|      Variable     |   Explanation                                        |
------------------- | -----------------------------------------------------|
|   DO_API_TOKEN    | This sets the API Token that is required by the DO API.  This value is required. |
|   DO_REGION       | This sets the DO Region where your instance will be created.  This defaults to `nyc2`. |
|   DO_DROPLET_SIZE | This sets the size of the DO instance that is created.  It defaults to `1GB`, which is the minimal useful size for running these scripts.  Other valid options are `2GB`, `4GB` and `8GB`.  You can go larger, but you probably won't see any performance improvements from doing so. |
|   SSH_KEY_NAME    | The name of your SSH Key in the DO API.  It defaults to `Vagrant`.  If you already have a key set in DO, use the name that you gave for that key. |
|   SSH_PRIVATE_KEY_PATH | The path to the private key for the SSH key that you have configured in DO.  This defaults to `~/.ssh/id_rsa` which should work for most people. |

#### Local Machine

 1. Install the base OS.  Currently Ubuntu 10.04, 12.04 or 14.04.
 2. In a terminal in the OS, run `bash <( curl -s https://raw.githubusercontent.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts/master/build/run_local.sh )`.  

This will download and run the local install script, which handles everything else.  See the `run_local.sh` script below for more details.

#### Remote Machine

 1. Install the base OS.  Currently Ubuntu 10.04, 12.04 or 14.04.
 2. Setup an SSH Server on the base OS.  Add your [ssh key] to the `.ssh/authorized_keys` file on the base OS.
 3. Run `bash <( curl -s https://raw.githubusercontent.com/dmikusa-pivotal/cf-php-buildpack-binary-build-scripts/master/build/run_remote.sh ) [user]@<baseos-ip>`.

### Scripts

Here's a listing of the scripts and what they do.

#### Build Directory

This is the main directory for the scripts, and contains the following scripts.

|   Script Name   |   Explanation                                                 |
| --------------- | --------------------------------------------------------------|
|  run_local.sh    | Runs the full build suite locally.  This will install git, clone or update the repository, install and update all required dependencies and run all of the build scripts. |
|  run_remote.sh   | Runs the full build suite on a local host.  This will install git, clone or update the repository, install and update all required dependencies, run all of the build script and copy the build files from the remote server to your local machine. |
|  run_vagrant.sh  | Runs the full build suite on a Vagrant run VM.  This functions the same as `run_local.sh`, but it will also handle starting the VMs for you. |
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
