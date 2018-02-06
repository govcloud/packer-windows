# Packer templates for Windows

## Overview

This repository contains Packer templates for creating Windows virtual machines.

## Environment Variables

To properly run packer the following environment variables will need to be set:

* ARM_CLIENT_ID
* ARM_CLIENT_SECRET
* ARM_SUBSCRIPTION_ID
* ARM_OBJECT_ID
* ARM_MANAGED_IMAGE_NAME
* ARM_MANAGED_IMAGE_RESOURCE_GROUP

## Exporting Provisioned Virtual Machine to Azure

Generate your virtual machines to be compatible with Azure.

```sh
packer build -var-file=windows10.json windows.json
```

## Acknowledgements

Based on the [Packer guide to VM creation][microsoft] provided by Microsoft

<!-- Links Referenced -->

[microsoft]:               https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer
