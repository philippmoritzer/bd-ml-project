pandoc --listings -H ./docs/latex/listings-setup.tex --toc -V geometry:"left=1cm, top=1cm, right=1cm, bottom=2cm" -V fontsize=12pt README.md -o test.pdf
