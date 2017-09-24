#!/bin/sh

# Install aspell
ASPELL=`which aspell`
if [ $? != 0 ]; then
  brew install aspell
fi

# Generate the custom dictionary.
aspell --lang=en create master /tmp/en-develogger.pws < develogger_wordlist.txt
cp /tmp/en-develogger.pws /usr/local/lib/aspell*
