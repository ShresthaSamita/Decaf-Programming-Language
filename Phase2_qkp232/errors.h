/**
 * File: errors.h
 * --------------
 * Defines an error-reporting class with a set of already
 * implemented static methods for reporting the standard Decaf errors.
 */

#ifndef ERRORS_H
#define ERRORS_H

#include <string>
#include "location.h"
using namespace std;

class ReportError {
 public:

  // Errors used by scanner
  static void UntermComment(); 
  static void LongIdentifier(yyltype *loc, const char *ident);
  static void UntermString(yyltype *loc, const char *str);
  static void UnrecogChar(yyltype *loc, char ch);

  // Generic method to report a printf-style error message
  static void Formatted(yyltype *loc, const char *format, ...);


  // Returns number of error messages printed
  static int NumErrors() { return numErrors; }
  
 private:
  static void UnderlineErrorInLine(const char *line, yyltype *pos);
  static void OutputError(yyltype *loc, string msg);
  static int numErrors;
};
#endif
