@default_files = ('main.tex');
$ENV{'TZ'} = 'Europe/Berlin';
$pdf_mode = 4;
$lualatex = 'lualatex -synctex=1 -interaction=nonstopmode -file-line-error -shell-escape -recorder';