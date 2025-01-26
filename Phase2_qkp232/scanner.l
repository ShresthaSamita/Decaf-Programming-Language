/* File:  scanner.l
 * ----------------
 * Lex input file to generate the scanner for the compiler.
 * This file is the extension of scanner.l file of Phase I
 * more rules are added.
 */

%{
#include <string.h>
#include <vector>
#include "scanner.h"
#include "utility.h" // for PrintDebug()
#include "errors.h"
#include "parser.h"  // for yylval

using namespace std;

static int lineNum, colNum;
vector<const char*> savedLines;

//Macro
static void DoBeforeEachAction(); 
#define YY_USER_ACTION DoBeforeEachAction();
#define TAB_SIZE 4
%}


%s N
%x COPY COMM 
%option stack
%option noyywrap

/* Definition Section */
DELIM               ([ \t]+)
NEWLINE             (\r|\n|\r\n)
COM_SIN      	  ("//"[^\r\n]*)
COM_BEG             ("/*")
COM_END             ("*/")
IDENTIFIER          ([A-Za-z][A-Za-z0-9_]*)
DEC_INTEGER         ([0-9]+)
HEX_INTEGER         (0[xX][0-9A-Fa-f]+)
INTEGER             ({DEC_INTEGER}|{HEX_INTEGER})
BEG_STRING          (\"[^"\n]*)
STRING              ({BEG_STRING}\")
EXPONENT            ([Ee][+-]?{DEC_INTEGER})
DOUBLE_NUM          ([0-9]+\.[0-9]*)
DOUBLE_SCI          ({DOUBLE_NUM}{EXPONENT})
OPERATOR            ([-+/*%=.,;!<>()[\]{}:])

%% //Beginning of Rule Section
<COPY>.*           { char line[512]; 
                     savedLines.push_back(strdup(yytext)); 
                     colNum = 1; 
                     yy_pop_state();
                     yyless(0); }
<COPY><<EOF>>      { yy_pop_state(); }                     
<*>{NEWLINE}       { lineNum++; 
                     colNum = 1;
                     if(YYSTATE==COPY)
                        savedLines.push_back("");
                     else
                        yy_push_state(COPY); }
[ ]+               { /* ignore all spaces */ }
<*>[\t]            { colNum += TAB_SIZE-colNum%TAB_SIZE + 1; }      

 /* Comments */
{COM_SIN}            { /* Just ignore */ }
{COM_BEG}               { BEGIN(COMM); }
<COMM>{COM_END}         { BEGIN(N); }
<COMM><<EOF>>               { 
                                ReportError::UntermComment(); 
                                return 0;
                            }
<COMM>.                     { /* Just ignore */ }                            

 /* Keywords, Operators and Separators*/
"int"              { return T_Int; }
"double"           { return T_Double; }
"bool"             { return T_Bool; }
"string"           { return T_String; }
"void"             { return T_Void;}
"break"            { return T_Break; }
"class"            { return T_Class; }
"else"             { return T_Else; }
"extends"          { return T_Extends; }
"for"              { return T_For; }
"if"               { return T_If; }
"new"              { return T_New; }
"null"             { return T_Null; }
"return"           { return T_Return; }
"this"             { return T_This; }
"while"            { return T_While; }
"static"           { return T_Static; }
"Print"            { return T_Print; }
"ReadInteger"      { return T_ReadInteger; }
"ReadLine"         { return T_ReadLine; }
"instanceof"       { return T_InstanceOf; }
"NewArray"         { return T_NewArray; }
"implements"       { return T_Implements; }
"interface"        { return T_Interface; }
"switch"           { return T_Switch; }
"case"             { return T_Case; }
"default"          { return T_Default; }
"<="               { return T_LessEqual; }
">="               { return T_GreaterEqual; }
"=="               { return T_Equal; }
"!="               { return T_NotEqual; }
"&&"               { return T_And; }
"||"               { return T_Or; }
"[]"               { return T_Dims; }
"++"               { return T_Increment; }
"--"               { return T_Decrement; }
{OPERATOR}         { return yytext[0]; }

 /* Constants */
"true"              { yylval.boolConstant = (yytext[0]=='t'); return T_BoolConstant; }
"false"             { yylval.boolConstant = (yytext[0]=='t');  return T_BoolConstant; }
{DEC_INTEGER}       { yylval.integerConstant = strtol(yytext, NULL, 10); return T_IntConstant; }
{HEX_INTEGER}       { yylval.integerConstant = strtol(yytext, NULL, 16); return T_IntConstant; }
{DOUBLE_NUM}        { yylval.doubleConstant = atof(yytext); return T_DoubleConstant; }
{DOUBLE_SCI}        { yylval.doubleConstant = atof(yytext); return T_DoubleConstant; }
{STRING}            { yylval.stringConstant = strdup(yytext); return T_StringConstant; }
{BEG_STRING}        { ReportError::UntermString(&yylloc, yytext); }

 /* Identifier */
{IDENTIFIER}       { if(strlen(yytext)>MaxIdentLen)
                        ReportError::LongIdentifier(&yylloc, yytext);
                     strncpy(yylval.identifier, yytext, MaxIdentLen);
                     yylval.identifier[MaxIdentLen] = '\0';
                     return T_Identifier; }

 /* Default rule (error) */
.                   { 
                        ReportError::UnrecogChar(&yylloc, yytext[0]); 
                    }
%% //End of RULE SECTION

/*Code Section*/

 /* Function: InitScanner
 *=======================
 * This function will be called before any calls to yylex().  It is designed
 * to give you an opportunity to do anything that must be done to initialize
 * the scanner (set global variables, configure starting state, etc.)
 */
void InitScanner()
{
    PrintDebug("lex", "Initializing scanner");
    yy_flex_debug = false;
    BEGIN(N);
    yy_push_state(COPY); // copy first line at start
    lineNum = 1;
    colNum = 1;
}


 /* Function: DoBeforeEachAction()
 * ===============================
 * This function is installed as the YY_USER_ACTION. This is a place
 * to group code common to all actions.
 */
static void DoBeforeEachAction()
{
    yylloc.first_line = lineNum;
    yylloc.first_column = colNum;
    yylloc.last_column = colNum + yyleng - 1;
    colNum += yyleng;
}

/* Function: GetLineNumbered()
 * ===========================
 * This function string with contents of line numbered n or NULL if the
 * contents of that line are not available. 
 */
const char *GetLineNumbered(int num) {
  if (num < 0 || num > savedLines.size()) return NULL;
  return savedLines[num-1];
}