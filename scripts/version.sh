#!/bin/bash

az vm image list -p MicrosoftWindowsDesktop -s RS3-Pro -f Windows-10 --all -o tsv --query '[].version' | sort -u | tail -n 1
