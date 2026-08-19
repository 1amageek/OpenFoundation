#include "COpenFoundationEmbeddedMath.h"

#include <math.h>

double open_foundation_sin(double value) { return sin(value); }
double open_foundation_cos(double value) { return cos(value); }
double open_foundation_tan(double value) { return tan(value); }
double open_foundation_atan2(double y, double x) { return atan2(y, x); }
double open_foundation_sqrt(double value) { return sqrt(value); }
double open_foundation_hypot(double x, double y) { return hypot(x, y); }
double open_foundation_pow(double base, double exponent) { return pow(base, exponent); }
double open_foundation_exp(double value) { return exp(value); }
double open_foundation_log(double value) { return log(value); }
double open_foundation_log2(double value) { return log2(value); }
double open_foundation_log10(double value) { return log10(value); }
double open_foundation_acos(double value) { return acos(value); }
double open_foundation_floor(double value) { return floor(value); }
double open_foundation_ceil(double value) { return ceil(value); }
