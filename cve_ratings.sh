#!/usr/bin/env bash

# Error checks
if [[ "$#" != "1" ]]; then
  echo "ERROR: Specify report file."
  echo "$0 report.tex"
  echo
  exit 1
fi

# Determine risk rating for CVE
cat $1 | grep CVE | grep textcolor | choose -f '&' 0 1 > /tmp/cve_ratings

# Identify all files with CVE subsubsection
CVE_FILES=`grep -E "subsubsect.*CVE" output/ -lR`

# Insert vulntext placeholder
for f in $CVE_FILES
do
  # Determine what CVE we're after for this file
  CVE=`cat $f | grep subsubsect | gawk '{ print $NF }' | sed 's/}//g'`
  # Get the CVE rating
  CVE_RATING=`grep $CVE /tmp/cve_ratings | choose 1`
  echo "$CVE $CVE_RATING $f"
  # Apply rating for CVE to issue
  sed -i "2i \\\\\vulntext{$CVE_RATING}\n\\\color{black}{}\n" $f
done
