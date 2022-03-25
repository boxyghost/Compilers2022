#include <stdio.h>
struct tree {
   int prodrule;
   char *symbolname;
   int nkids;
   struct tree *kids[9]; /* if nkids >0 */
   struct tree *parent;
   struct token *leaf;   /* if nkids == 0; NULL for ε productions */
   int id;
};
struct token {
   int category;   /* the integer code returned by yylex */
   char *text;     /* the actual string (lexeme) matched */
   int lineno;     /* the line number on which the token occurs */
   char *filename; /* the source file in which the token occurs */
   int ival;       /* for integer constants, store binary value here */
   double dval;    /* for real constants, store binary value here */
   char *sval;     /* for string constants, malloc space, de-escape, store */
                   /*    the string (less quotes and after escapes) here */
};

int alctoken(int);
void printnode(struct tree *t);

void printsyms(struct tree *);

struct tree * kido(int i);
void print_graph(struct tree *t, char * filename);
void print_subgraph(struct tree *t, FILE *f);

struct tree *make_tree(int pr, char *symb, int nkids, ...); // To be implemented later

struct tree * alcTreeOneKids(struct tree * kid, int prule);
struct tree * alcTreeTwoKids(struct tree * kid1, struct tree * kid2, int prule);
struct tree * alcTreeThreeKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, int prule);
struct tree * alcTreeFourKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4, int prule);
struct tree * alcTreeFiveKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4, struct tree * kid5, int prule);
struct tree * alcTreeSixKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4, struct tree * kid5, struct tree * kid6, int prule);

struct tree * bingo(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4);

void tree_print(struct tree *, int);
void str_deescape(char *str, char *new_str);
char *delimiters();
