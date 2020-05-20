#ifndef SIMPLE_EXPRESSION_PARSER_H
#define SIMPLE_EXPRESSION_PARSER_H


// One-byte integer values, from 0 to 255 or from -128 to 127
#define	TYPE_CHAR	0
// Two-byte integer values, from 0 to 65535 or from -32768 to 32767
#define	TYPE_SHORT	1
// Four-byte integer values, from 0 to 4294967296 or from -2147483648 to 2147483647
#define	TYPE_LONG	2
// Three-byte floating point values
#define	TYPE_FLOAT	3
// Four-byte floating point values
#define	TYPE_DOUBLE	4

#ifndef SIMPLE_EXPRESSION_DATA_TYPE
#define	SIMPLE_EXPRESSION_DATA_TYPE  TYPE_LONG
#endif

unsigned char simple_expression_parser( const unsigned char *s, void *result );

#endif
