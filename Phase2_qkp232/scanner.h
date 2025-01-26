/* File: scanner.h
 * Modified from phase I, deleted unnecessary lines for 
 * redeability
 */

#ifndef SCANNER_H
#define SCANNER_H

#include <stdio.h>

#define MaxIdentLen 31    // Maximum length for identifiers

  
extern char *yytext;      // Text of lexeme just scanned


int yylex();              // Defined in the generated lex.yy.c file

void InitScanner();                 // Defined in scanner.l user subroutines
const char *GetLineNumbered(int n); 
#endif
