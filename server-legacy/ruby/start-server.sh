#!/bin/bash
cd "$(dirname "$0")"
ruby -run -e httpd . -p 3000