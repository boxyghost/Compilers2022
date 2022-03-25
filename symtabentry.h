#include "tree.h"
typedef struct sym_entry {
    /*   SymbolTable table;			 what symbol table do we belong to*/
    char *s;				/* string */
    int declaration_type;
    struct sym_table *table;
    /* more symbol attributes go here for code generation */
    struct sym_entry *next;
 } *SymbolTableEntry;

 typedef struct sym_table {
    int nEntries;			/* # of symbols in the table */
    int nBuckets;
    struct sym_table *parent;
    /*   struct sym_table *parent;		 enclosing scope, superclass etc. */
    struct sym_entry *tbl[5]; //this changes with the number of buckets in mksymtab()
    /* more per-scope/per-symbol-table attributes go here */
} *SymbolTable;

struct sym_table * mksymtab(struct sym_table *);
void cleanup_tree(struct tree *);
void add_sym_entry(struct tree *, struct sym_table *);
struct sym_table *fill_sym_entry(int decl_type, char *name, struct sym_table *table);
void printtable(struct sym_table *, int);
int hash(SymbolTable st, char *s);
int check_all_unchecked(struct sym_table *);
