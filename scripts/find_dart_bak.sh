#!/bin/bash
# Find all files containing "dart.bak" in their filename
find . -type f -name "*dart.bak*" -not -path '*/.*'
