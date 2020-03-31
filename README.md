# Shopware 6

This is a mix of a selfbuild and the shopware own container for the shopware 6 platform.

## Setup
This container is already initialized with an install.lock file, so the installer will not run. You're supposed to import an existing database dump. If you don't have one, or you are that person who has to create one for an upcoming project, start the container, remove the install.lock file (in the /sw6 folder) and run the graphical or CLI installer.

Shopware 6 is mainly configured by environment variables, so you need to create one. But this project already provides an example config where you have to replace the `%s` fields. But you can also get one by running the shopware installer.

So or so you will have to run this container with all required variables set. This works best by using the .env file in combination with dockers `--env-file` option.

## Troubleshooting

You get the error, that a public.pem or private.pem file is missing, enter the container and run the `bin/console system:generate-jwt-secret` command. It will generate the required certificates for you.

