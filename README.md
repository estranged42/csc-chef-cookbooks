# CSC 337 Cookbooks

This set of cookbooks for setting up AWS OpsWorks instances for use by students in UA CSC 337: Web Programming.

The first use of this will be for the Spring 2016 semester for the University of Arizona.

## csc337 cookbook

### Assumptions

  * An AWS OpsWorks stack was set up, and instances created where the instance  name is a unique identifier for each student. For my case it is the UA NetID.
  * Instances are started with Amazon Linux for the OS.
  * An SSH Key is set for further access.

### Recipes

#### instance_setup

The instance_setup recipe is intended to be run as part of the OpsWorks Setup phase in the layer.

![Image of OpsWorks Layer Recipes](https://github.com/estranged42/csc-chef-cookbooks/blob/master/images/layer-recipes.png)

The instance setup recipe does the following things:

  * Installs PHP 5.6
  * Apache 2 is installed also as a dependency for PHP
  * The name of the instance is stored for the username
  * sshd config is updated to allow for SSH logsin via password. By default Amazon linux allows only key based authentication.
  * A local user is created for the username
  * The main apache directory is set to be owned by the username, and a symbolic link created in the user's home directory
  * A placeholder index.php file is placed in the main web directory.

#### Post setup 

The user's password must be set somehow.  This can be done remotely with the following command:

    ssh -i "your_key.pem" ec2-user@x.x.x.x 'echo newpassword | sudo passwd username --stdin'

