## CloudFoundry PHP Build Pack Binary Build Scripts

This is a set of scripts that can be used to build the binary files required by the [CF PHP Build Pack].

This repo contains a set of bash scripts that can be used to build HTTPD 2.4.x, Nginx 1.5.x, Nginx 1.6.x, Nginx 1.7.x, PHP 5.4.x, PHP 5.5.x and a full set of extensions for both version of PHP.  

The scripts are configured with variables at the top and can be used to build different versions of each project and modules for the projects.  The scripts were originally designed to be run on Ubuntu 10.04, which is the current stack used by CF.  It has been expanded to support Ubuntu 12.04 and will soon support Ubuntu 14.04 as well.

### Scripts

Here's a listing of the scripts and what they do.

#### Build Directory

This is the main directory for the scripts, and contains the following scripts.

|   Script Name   |   Explanation                                                 |
| --------------- | --------------------------------------------------------------|
|  run_local.sh    | Runs the full build suite locally.  This will install git, clone or update the repository, install and update all required dependencies and run all of the build scripts. |
|  run_remote.sh   | Runs the full build suite on a local host.  This will install git, clone or update the repository, install and update all required dependencies, run all of the build script and copy the build files from the remote server to your local machine. |
|  install-deps.sh | Installs all of the required dependencies for your given OS.  Will attempt to determine the OS by looking at the `/etc/issue` file.  Used by `run_local.sh` and `run_remote.sh`. |
|  build-all.sh    | Builds all of the local packages.  This calls the individual build scripts in each of the component directories.  This script is called by `run_local.sh` and `run_remote.sh`. |

#### Component Build Scripts

Each component, the project subdirectories with a name and major version number, contains a build script.  The build script is responsible for building that individual component.  Most of the time this boils down to running `./configure && make && make install`, but some components are more complicated than that.  Regardless, this script is responsible for building and packaging the component.

Generally you should run the `run_local.sh` or `run_remote.sh` script to build the full suite of components, but you can run the individual `<component-version>/build.sh` script if you want to build just a single component.

[CF PHP Build Pack]:https://github.com/dmikusa-pivotal/cf-php-build-pack
