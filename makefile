decafl: lex.yy.c
	g++ -o decafl lex.yy.c

lex.yy.c: decaf.lex
	lex decaf.lex

clean:
	rm -f *.o lex.yy.c decafl *~ EVAL


