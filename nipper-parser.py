#!/usr/bin/env python3

from os.path import exists
from pathlib import Path
from string import Template

import argparse
import xmltodict
import os
import re
import sys

class bcolours:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class Range(object):
    def __init__(self, start, end):
        self.start = start
        self.end = end
    def __eq__(self, other):
        return self.start <= other <= self.end

def welcome():
  print("Parse Nipper XML to output issues based on template file.")
  print()

def main():
    parser = argparse.ArgumentParser(description="Parse Nipper XML to output issues based on template file.")
    parser.add_argument("--xml", required=True,
                        help="Nipper XML file")
    parser.add_argument("--template", required=True,
                        help="Template to build issues from")
    parser.add_argument("--cvss", required=False, type=float, default=0, choices=[Range(0.0, 10.0)],
                        help="Only include issues with this rating or above (default: 0)")
    parser.add_argument("--output", required=False, default="nipper",
                        help="Output directory to create issues (default: nipper)")

    parsed = parser.parse_args()

    # Open template
    template_string = Path(parsed.template).read_text()

    # Check / create output directory
    if os.path.exists(parsed.output):
      print("ERROR: Output directory exists, bailing..")
      sys.exit(1)
    os.mkdir(parsed.output)

    # Open XML
    xml_data = Path(parsed.xml).read_text()
    my_dict = xmltodict.parse(xml_data)

    for index, issue in enumerate(my_dict['document']['report']['part'][1]['section']): #[1]['section'] # Security audit
      if index < 2:
        continue

      title = issue['@title']
      line_str = []
      for line_index, line in enumerate(issue['section'][1]['text']):
        line_str.append(line)
      risk_rating = None
      remediation = None

      table_str = []
      # For each table
      for table_index, table in enumerate(issue['section'][1]['table']):
        table_headings = table['headings']['heading']
        table_body = table['tablebody']

        table_str.append("")
        #print("OMG " + str(table_index))
        #sys.exit(1)
        table_str[table_index] = \
"""\\begin{longtblr}[
  caption = {Long Title},
  label = {tab:test},
]{
  colspec = {|XX[1]|},
  rowhead = 1,
  hlines,
  vlines,
  row{even} = {gray9},
  row{1} = {olive9},
}
"""

        heading_str = ""
        for heading in table_headings:
          heading_str = heading_str + heading + " & "
        heading_str = heading_str + "\\\\"
        table_str[table_index] = table_str[table_index] + re.sub("& \\\\\\\\$", "\\\\\\\\\n", heading_str)

        for row in table_body['tablerow']:
          row_str = ""
          for cell in row['tablecell']:
            row_str = row_str + str(cell['item']) + " & "
          row_str = row_str + "\\\\"
          table_str[table_index] = table_str[table_index] + re.sub("& \\\\\\\\$", "\\\\\\\\\n", row_str)

        table_str[table_index] = table_str[table_index] + "\\end{longtblr}\n"

      for element_index, element in enumerate(line_str):
        print(element)
        print(table_str[element_index])
      print(table_str[element_index])
      import pdb; pdb.set_trace()

    # Extract CVEs
    for index, issue in enumerate(my_dict['document']['report']['part'][2]['section']): #[1]['section'] # VULNAUDIT (CVEs)
      if index < 2:
        continue

      hosts = "todo"
      try:
        title = issue.get('section',None)[0]['@ref'].split('.')[1]
      except:
        continue
      try:
        description = issue.get('section',None)[0]['text']
      except:
        continue

      risk_rating = issue['infobox']['infodata'][0]['#text']
      #remediation = issue['section'][2]['text'] + '\n\n' + str(issue['section'][2]['list']['listitem']['weblink']) # Multiple web links?
      remediation = issue['section'][2]['text']

      # Don't include issue if CVSS score too low
      if float(risk_rating) < parsed.cvss:
        continue
      temp_obj = Template(template_string)

      issue_file = open(parsed.output + "/" + title + ".tex", "w")
      issue_file.write(
        temp_obj.substitute(
          #plugin_id=dedupe_dict[issue]['Plugin ID'],
          risk_rating=risk_rating,
          #risk=dedupe_dict[issue]['Risk'],
          title=title,
          #plugin_output=dedupe_dict[issue]['Plugin Output'],
          description=description.replace("_","\_"),
          remediation=remediation.replace("_","\_"),
          # There must be a better way..
          #cve="        \item \\href{{https://cve.mitre.org/cgi-bin/cvename.cgi?name={0}}}{{{0}}}\n".format("".join(cve for cve in dedupe_dict[issue]['CVE'].split())),
          host=''.join('        \item %s\n' % host for host in hosts),
        )
      )

      #issue_file.close()

if __name__ == "__main__":
    main()
