#!/usr/bin/env bash

#cp ../report.tex .
dos2unix report.tex

# Delete garbage at start
FINDINGS_START_LINE=`grep "\caption{Findings summary table}" report.tex -n | choose --field-separator ':' 0`
sed -i "1,${FINDINGS_START_LINE}d" report.tex
sed -i '1,3d' report.tex

# Delete label garbage
sed -i '/^\\label.*/d' report.tex

# Delete risk table
sed -i '/\\begin{tabular}.*/d' report.tex
sed -i '/\\end{tabular}$/d' report.tex
sed -i '/^Impact:.*/d' report.tex
sed -i '/^Ease:.*/d' report.tex
sed -i '/^Fix:.*/d' report.tex
sed -i '/^Type:.*/d' report.tex
sed -i '/^Finding ID:.*/d' report.tex

# Delete hlines
sed -i '/\\hline/d' report.tex

# Change chapter to subsubsection
sed -i 's#\\chapter{#\\subsubsection{Firewall/Switch Review: #g' report.tex

# Risk ratings
sed -i 's#^Overall.*{\(.*\)} \\\\#\\vulntext{\1}\n\\color{black}{}#g' report.tex

# Critical conversion
sed -i 's#\\vulntext{Critical}#\\vulntext{10}#g' report.tex
# High conversion
sed -i 's#\\vulntext{High}#\\vulntext{8}#g' report.tex
# Medium conversion
sed -i 's#\\vulntext{Medium}#\\vulntext{5.5}#g' report.tex
# Low conversion
sed -i 's#\\vulntext{Low}#\\vulntext{2}#g' report.tex
# Info conversion
sed -i 's#\\vulntext{Info}#\\vulntext{1}#g' report.tex

# Replace Nipper string
sed -i 's#Nipper#XV Security#g' report.tex

#colspec = {X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j] X[0.05,j]}, \
sed -i 's#\\begin{tabularx}{\\textwidth}.*#\\begin{scriptsize}\n\\begin{longtblr} \
{rowhead=1, \
hlines, vlines, \
colspec = {X[l] X[l] X[l] X[l] X[l] X[l] X[l] X[l] X[l] X[l]}, \
}#g' report.tex

sed -i 's#^\\end{tabularx}#\\end{longtblr}\\end{scriptsize}#g' report.tex

# Insert longtblr end and remove extraneous shit
#sed -i '/^\\end{center}/d' report.tex
#sed -i '/^\\rowcolor{.*}/d' report.tex
#sed -i '/^\\caption{.*}/d' report.tex

# Table testing
#sed -i 's#\\begin{tabularx}{\\textwidth}#\\begin{adjustbox}{width=\\textwidth}\\begin{tabular}#g' report.tex
#sed -i 's#\\end{tabularx}#\\end{tabular}\n\\end{adjustbox}#g' report.tex
#sed -i 's#| X #| l #g' report.tex
#sed -i 's#| l |}#| l |}\n\\hline#g' report.tex

#sed -i 's#\\begin{tabularx}{\\textwidth}#\\begin{\\scriptsize}\n\\begin{longtable}#g' report.tex
#sed -i 's#\\end{tabularx}#\\end{longtable}\n\\end{scriptsize}#g' report.tex
#sed -i 's#| X #| l #g' report.tex
#perl -0pe 's#(.*?) &#\1 \\phantom{\1 XXXX} &#g' report.tex > report_tmp.tex
#mv report_tmp.tex report.tex
#sed -i 's#| l |}#| l |}\n\\hline#g' report.tex

# Delete table references
sed -i 's#~\\ref{table:.*}#below#g' report.tex

# Add hlines
#sed -i 's#\\\\$#\\\\ \\hline#g' report.tex

# Remove extra row in tables
#perl -0pe 's/\\\\ \\hline\n\\rowcolor/\n\\rowcolor/g' report.tex > report_tmp.tex
#mv report_tmp.tex report.tex

# Remove rowcolor
sed -i '/^\\rowcolor{.*/d' report.tex

# Delete caption (need to figure out how to centre)
sed -i '/^\\caption{.*/d' report.tex

# Update headings
sed -i 's#\\section{Affected Devices}#\\textbf{Affected Targets}#g' report.tex
sed -i 's#\\section{Affected Device}#\\textbf{Affected Target}#g' report.tex
#sed -i 's#\\section{#\\textbf{#g' report.tex
sed -i 's#\\section{Finding}#\\textbf{Description}#g' report.tex
sed -i 's#\\section{Findings}#\\textbf{Description}#g' report.tex
sed -i 's#\\section{Check}#\\textbf{Check}#g' report.tex
sed -i 's#\\section{Fix}#\\textbf{Fix}#g' report.tex
sed -i 's#\\section{Impact}#\\textbf{Impact}#g' report.tex
sed -i 's#\\section{Ease}#\\textbf{Ease}#g' report.tex
sed -i 's#\\section{Summary}#\\textbf{Summary}#g' report.tex
sed -i 's#\\section{Description}#\\textbf{Description}#g' report.tex
sed -i 's#\\section{Recommendation}#\\textbf{Recommendations}#g' report.tex

# Replace potentially problematic characters
sed -i 's#???#...#g' report.tex

# Update problematic sentences
sed -i 's#in Table below#in the table below.#g' report.tex

# Remove Impact, Ease, Recommendations etc. for weekly reports
perl -0777pe 's/\\textbf{Impact}.*?\\subsubsection/\\subsubsection/gs' report.tex > report_tmp.tex
perl -0777pe 's/\\textbf{Check}.*?\\subsubsection/\\subsubsection/gs' report_tmp.tex > report.tex
perl -0777pe 's/\\textbf{Recommendations}.*?\\subsubsection/\\subsubsection/gs' report.tex > report_tmp.tex
mv report_tmp.tex report.tex

# Space after \_ , =
sed -i 's#\_#\_ #g' report.tex
sed -i 's#\([A-Z0-9]\),#\1, #g' report.tex
sed -i 's#\([A-Z0-9]\)=#\1 = #g' report.tex
sed -i 's#tEthernet#t\\newline Ethernet#g' report.tex

# Split files
csplit report.tex '/^\\subsubsection{/' '{*}'

# Create findings.txt
rm -rf output
mkdir output
find . -name "xx*" -exec mv {} {}.tex \;
mv xx*.tex output
cd output
grep -E "vulntext\{" xx*.tex | grep -E "\{8|\{9|\{10" | choose --field-separator ':' 0 | sed 's#\(.*\).tex#\\input{tex/findings/high/nipper/\1}\n\\newpage#g' > findings.txt
