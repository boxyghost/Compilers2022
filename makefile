CC=gcc
CFLAGS=-g -Wall
OBJFLAGS= -c

all: bison flex tree main lex.yy j0gram.tab linkall

bison: j0gram.y tree.h symtabentry.h
	bison -v -d -Dparse.trace j0gram.y

flex: j0lex.l tree.h symtabentry.h
	flex j0lex.l

tree: tree.c symtabentry.h symtabentry.c
	$(CC) $(CFLAGS) $(OBJFLAGS) tree.c
	$(CC) $(CFLAGS) $(OBJFLAGS) symtabentry.c

main: main.c tree.h symtabentry.h
	$(CC) $(CFLAGS) $(OBJFLAGS) main.c

lex.yy: lex.yy.c tree.h symtabentry.h
	$(CC) $(CFLAGS) $(OBJFLAGS) lex.yy.c

j0gram.tab: j0gram.tab.c tree.h symtabentry.h
	$(CC) $(CFLAGS) $(OBJFLAGS) j0gram.tab.c

linkall:
	$(CC) -g -Wall main.o j0gram.tab.o lex.yy.o tree.o symtabentry.o -o j0

clean:
	rm lex.yy.c lex.yy.o j0gram.tab.c tree.o j0gram.tab.o main.o symtabentry.o j0
