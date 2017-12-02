#!/bin/bash
#!/bin/bash

##### INPUT #####
##Modify this accordingly
main="main" #main source file
bib="biblio" #bib file
fig_f="figures/" #folder with figures

##### OUTPUT #####
##Modify this with your preferred file names
upload="no_comments" #tex file without comments
archive="all.tar" #compress files so you can upload a single tar

##If only minor changes to main
minor=0

#Removing all comments from the source
perl -pe 's/(^|[^\\])%.*/\1%/' < $main.tex > $upload.tex

##Compiling source and bibliography
pdflatex $upload.tex
bibtex $upload

s='\\bibliography{'$bib'}'
r='%'$s'\n\\input{'$upload.bbl'}'
echo $s
echo $r
perl -pi -e "s/$s/$r/g" $upload.tex

##Remove Copyright
perl -pi -e 's/\\begin{document}/\\makeatletter\n\\def\\\@copyrightspace{\\relax}\n\\makeatother\n\\begin{document} /g' $upload

##Print the list of figures
if [ "$minor" -ne 1 ]
then
cat $upload.tex | grep includegraphics | awk -F"[{}]" '{print $2}' | tar -cvf temp.tar -T -
tar cf - $fig_f/ | xz -9 -zf - > _figs_backup.tar.xz
rm -rf $fig_f
tar xf temp.tar
rm -rf temp.tar
fi

##Compiling again
pdflatex $upload.tex
pdflatex $upload.tex

if [ "$minor" -ne 1 ]
then
tar -cvzf $archive $upload.tex $upload.bbl *.cls $fig_f
fi

##Cleaning up
rm -f *~
rm -f *.log
rm -f *.blg
rm -f $main.bbl
rm -f *.aux
rm -f *.lof
rm -f *.toc
rm -f *.loa
rm -f *.lot
rm -f *.lot
rm -f *.out
rm -f *.ps
rm -f *.dvi
rm -f *.dep
rm -f *.synctex.gz

