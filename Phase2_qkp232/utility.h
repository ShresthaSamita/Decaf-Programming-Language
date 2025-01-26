/* File: utility.h
 * ---------------
 * This file just includes a few support functions you might find
 * helpful in writing the projects (error handling, debug printing)
 */

#ifndef UTILITY_H
#define UTILITY_H

#include <stdlib.h>
#include <stdio.h>

/**
 * Function: Failure()
 * Usage: Failure("Out of memory!");
 * --------------------------------
 */

void Failure(const char *format, ...);

/**
 * Macro: Assert()
 * Usage: Assert(num > 0);
 */ 

#define Assert(expr)  \
  ((expr) ? (void)0 : Failure("Assertion failed: %s, line %d:\n    %s", __FILE__, __LINE__, #expr))

/**
 * Function: PrintDebug()
 * Usage: PrintDebug("parser", "found ident %s\n", ident);
 */

void PrintDebug(const char *key, const char *format, ...);

/**
 * Function: SetDebugForKey()
 * Usage: SetDebugForKey("scope", true);
 */

void SetDebugForKey(const char *key, bool val);

/**
 * Function: IsDebugOn()
 * Usage: if (IsDebugOn("scope")) ...
 */

bool IsDebugOn(const char *key);

/**
 * Function: ParseCommandLine
 */

void ParseCommandLine(int argc, char *argv[]);
     
#endif
