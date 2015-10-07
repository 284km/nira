all: nira

nira: Nira.tab.o lex.yy.o
	g++ -g -o nira Nira.tab.o lex.yy.o

lex.yy.o: lex.yy.c
	g++ -g -o lex.yy.o -c lex.yy.c

Nira.tab.o: Nira.tab.cc
	g++ -g -o Nira.tab.o -c Nira.tab.cc

Nira.tab.cc: Nira.yy
	bison -dv Nira.yy

lex.yy.c: Nira.l
	flex Nira.l

clean:
	rm -f lex.yy.cc lex.yy.o Nira.tab.cc Nira.output Nira.tab.hh nira Nira.tab.o lex.yy.c

.PHONY: all clean

