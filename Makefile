all: nira

nira: Nira.tab.c lex.yy.c
	gcc -g -o nira Nira.tab.c lex.yy.c

Nira.tab.c: Nira.y
	bison -dv Nira.y

lex.yy.c: Nira.l
	flex Nira.l

clean:
	rm -f lex.yy.c Nira.tab.c Nira.output Nira.tab.h nira

.PHONY: all clean

