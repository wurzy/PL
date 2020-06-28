a=toml2json

$a : $a.y $a.l
	flex $a.l
	yacc -d $a.y
	cc -o $a y.tab.c lex.yy.c -lm

teste: $a exemplo
	paste -d: exemplo <($a  < exemplo ) | column -t -s:

install: $a
	cp $a /usr/local/bin/

clean:
	rm -f lex.yy.c y.tab.*
