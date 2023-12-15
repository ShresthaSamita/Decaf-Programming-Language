/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner for the compiler.
 * 
 * Submitted by: Samita Shresth, UTSA ID: qkp232
 * Decaf Compiler Project, Phase 1 (Scanner)
 *
 */

/* Definition Section */

%{
/* The text within this first region delimited by %{ and %} is assumed to
 * be C/C++ code and will be copied verbatim to the lex.yy.c file ahead
 * of the definitions of the yylex() function.*/
#include <ctype.h>
#include <string.h>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"

//Global Variables

YYSTYPE yylval;  // manually declared for pp1, later Yacc provides
struct yyltype yylloc; // manually dclared for pp1, later Yacc provides

//Macro
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();

//Adding Row and Column number for counter
int rowNum = 1;
int colNum = 1;

%}

/* Definition Section */
%x CMT
IDENTIFIER          ([A-Za-z][A-Za-z0-9_]*)
OPERATOR            ([-+/*%=.,;!<>()[\]{}:])
INTEGER				([0-9]+)
DOUBLE              (([0-9]+\.[0-9]*)(("E"|"e")(\+|\-)?[0-9]+)?)
HEX					(0("X"|"x")([0-9]|[a-fA-F])+)
STRG 				(\"[^"\n]*\")
WRNG_STR            (["][^"\n]*)
DELIM				([ \t]+)
COM_BEG             "/*"
COM_END            "*/"


   /* RULES SECTION */

%% //Beginning of Rule Section
       
{COM_BEG}           {BEGIN(CMT);}                
<CMT>{COM_END}      {BEGIN(INITIAL);}           
<CMT>.              {/* skip any charactor */}   
<CMT><<EOF>>        {/*printf("wrong_comment");*/
                        ReportError::UntermComment();}
  
{DELIM}				;
<*>[\n]             {rowNum++;colNum=1;}

"void"	{ return T_Void; }
"int"	{ return T_Int; }
"double"	{ return T_Double; }
"bool"	{ return T_Bool; }
"string"	{ return T_String; }
"class"	{ return T_Class; }
"interface"	{ return T_Interface; }
"null"	{ return T_Null; }
"this"	{ return T_This; }
"extends"	{ return T_Extends; }
"implements"	{ return T_Implements; }
"for"	{ return T_For; }
"while"	{ return T_While; }
"if"	{ return T_If; }
"else"	{ return T_Else; }
"return"	{ return T_Return; }
"break"	{ return T_Break; }
"New"	{ return T_New; }
"NewArray"	{ return T_NewArray; }

\<\=	{ return T_LessEqual; }
\>\=	{ return T_GreaterEqual; }
\=\=	{ return T_Equal; }
(\!\=)|(\<\>)	{ return T_NotEqual; }
\&\&	{ return T_And; }
\|\|	{ return T_Or; }
\[\]    {return T_Dims;}


{INTEGER}	{ yylval.integerConstant = atol(yytext); return T_IntConstant; }
{HEX}	    { yylval.integerConstant = strtol(yytext, NULL, 16); return T_IntConstant; }
{DOUBLE}	{ yylval.doubleConstant = atof(yytext); return T_DoubleConstant; }
"true"      { yylval.boolConstant = true; return T_BoolConstant;}
"false"     { yylval.boolConstant = false; return T_BoolConstant;}
{WRNG_STR}	{ ReportError::UntermString(&yylloc, yytext); }
{STRG}	    { yylval.stringConstant = strdup(yytext); return T_StringConstant; }
{OPERATOR}         { return yytext[0]; }
{IDENTIFIER}       { if(strlen(yytext)>MaxIdentLen)
                        ReportError::LongIdentifier(&yylloc, yytext);
                     strncpy(yylval.identifier, yytext, MaxIdentLen);
                     yylval.identifier[MaxIdentLen] = '\0';
                     return T_Identifier; }
.                   { 
                        ReportError::UnrecogChar(&yylloc, yytext[0]); 
                    }

%% //End of RULE SECTION

/*Code Section*/

/* Function: InitScanner
 * ---------------------
 * This function will be called before any calls to yylex().  It is designed
 * to give us an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.)*/

void InitScanner()
{
	  PrintDebug("lex", "Initializing scanner");
      yy_flex_debug = false;
      rowNum = 1;
      colNum = 1;
}

/* Function: DoBeforeEachAction()
 * ------------------------------
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */

static void DoBeforeEachAction()
{
      yylloc.first_line = rowNum;
      yylloc.first_column = colNum;
      yylloc.last_column = colNum + yyleng - 1;
      colNum += yyleng;
}
