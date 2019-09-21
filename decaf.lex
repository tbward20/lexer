  /* definitions */

%{

#include <iostream>

using namespace std;

#include "tokentype.h"

string resultString;
int startline;
Token* myTok;

int lineno = 1;

int error(string msg, int line)
{
  cout << msg << " on line " << line << endl;
  return -1;
}

TokenType makeToken(TokenType type) {
    myTok = new Token(type, yytext, lineno);
    return type;
}

int ident_error(char * txt, int line) {
  cout << "identifier " << txt << " too long on line " << line << endl;
  return -1;
}

%}

  /* %option yylineno */
%x STRING
%x ESC_CHAR
%x BCOMM
follow [[:space:]]+[A-Za-z]|[[:space:]]*\[[[:space:]]*\]
anything .

%%

  /* rules */

  /* block comment machine */
\/\* { BEGIN(BCOMM); startline = lineno; }
<BCOMM>\*\/ { BEGIN(INITIAL); }
<BCOMM>.  { }
<BCOMM>\n { lineno++; }
<BCOMM><<EOF>> { return error("Missing */ for block comment starting", startline); }
 
  /* Single line comment */
\/\/.*$ {}


  /* keywords */

void/{follow}?        { return makeToken(T_Void); }
int/{follow}?         { return makeToken(T_Int); }
double/{follow}?      { return makeToken(T_Double); }
bool/{follow}?        { return makeToken(T_Bool); }
string/{follow}?      { return makeToken(T_String); }
class/{follow}?       { return makeToken(T_Class); }
interface/{follow}?   { return makeToken(T_Interface); }
null/{follow}?        { return makeToken(T_Null); }
this/{follow}?        { return makeToken(T_This); }
extends/{follow}?     { return makeToken(T_Extends); }
implements/{follow}?  { return makeToken(T_Implements); }
for/{follow}?         { return makeToken(T_For); }
while/{follow}?       { return makeToken(T_While); }
if/{follow}?          { return makeToken(T_If); }
else/{follow}?        { return makeToken(T_Else); }
return/{follow}?      { return makeToken(T_Return); }
break/{follow}?       { return makeToken(T_Break); }
New/{follow}?         { return makeToken(T_New); }
NewArray/{follow}?    { return makeToken(T_NewArray); }
Print/{follow}?       { return makeToken(T_Print); }
ReadInteger/{follow}? { return makeToken(T_ReadInteger); }
ReadLine/{follow}?    { return makeToken(T_ReadLine); }

  /* Int constant */
[0-9]+|0[xX][a-fA-F0-9]+ { return makeToken(T_IntConstant); }

  /* Boolean constant */
true/{follow}?  { return makeToken(T_BoolConstant); }
false/{follow}? { return makeToken(T_BoolConstant); }

  /* Double Constant */
[0-9]+.[0-9]*([eE][+-]?[0-9]+)? { return makeToken(T_DoubleConstant); }

  /* identifier */
[A-Za-z][A-Za-z0-9_]* { if (yyleng > 31) return ident_error(yytext, lineno); return makeToken(T_Identifier); }


  /* type ident */
([A-Za-z][A-Za-z0-9_]*|int|double|bool|string)/{follow} { return makeToken(T_TypeIdentifier); }

  /* string literal */
  /* \"(.|\\.)*\"  { return makeToken(T_StringConstant); }  */
  /* \"([^\"][\\.])*\"$ { return makeToken(T_StringConstant); } */

\" { BEGIN(STRING); resultString = "\"";  }
<STRING>[^\n"]* { resultString += yytext; }
<STRING>\n      {lineno++; return error("missing \" at end of string constant", 
		lineno-1); }
<STRING><<EOF>>  {return error("missing \" at end of string constant", 
		lineno); } 
<STRING>\"     { BEGIN(INITIAL); 
	         myTok = new Token(T_StringConstant,resultString + "\"", 
                                  lineno);
		 return T_StringConstant; }

  /* Operator tokens */
\+   { return makeToken(T_Plus); }
\-   { return makeToken(T_Minus); } 
\*   { return makeToken(T_Times); }
\/   { return makeToken(T_Div); }
\%   { return makeToken(T_Mod); }
\<   { return makeToken(T_Less); }
\<\= { return makeToken(T_LessEqual); }
\>   { return makeToken(T_Greater); }
\>\= { return makeToken(T_GreaterEqual); }
\=   { return makeToken(T_Assign); }
\=\= { return makeToken(T_Equal); }
\!\= { return makeToken(T_NotEqual); }
\&\& { return makeToken(T_And); }
\|\| { return makeToken(T_Or); }
\!   { return makeToken(T_Not); }

  /* Other tokens */
\;  { return makeToken(T_Semicolon); }
\,  { return makeToken(T_Comma); }
\. { return makeToken(T_Dot); }
\[ { return makeToken(T_LBracket); }
\] { return makeToken(T_RBracket); }
\( { return makeToken(T_LParen); }
\) { return makeToken(T_RParen); }
\{ { return makeToken(T_LBrace); }
\} { return makeToken(T_RBrace); }

  /* Increment line no */
\n { lineno++; }

  /* Ignore whitespace */
[[:space:]] {}

  /* DELETE THIS EVENTUALLY OR THROW ERROR STRAY CHAR */
.  { std::string s = "stray '"; return error(s + yytext + '\'', lineno); }



<<EOF>> { return -1; }

%%

  /* subroutines */

int yywrap(void) {
    return 1;  // makes it stop at EOF.
} 

int main(int argc, char **argv) {
    int tok;
    /* Make sure there's a given file name */
    if (argc != 2) {
        cout << "USAGE: " << argv[0] << " FILE" << endl;
        exit(1);
    }       
    yyin = fopen(argv[1], "r");
    /* and that it exists and can be read */
    if (!yyin) {
        cout << argv[1] << ": No such file or file can't be opened for reading." 
             << endl;
        exit(1);
    }
    /* Read tokens until finished */
    while ((tok=yylex()) != -1)
        myTok->print();

    /* there's a warning without this */
    if (false)
      yyunput(0, 0);
}
