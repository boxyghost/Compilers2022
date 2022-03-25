#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symtabentry.h"
#include "j0gram.tab.h"
#include "defines.h"

struct sym_table * table;
int unchecked_classes = 0;
char to_be_checked_classes[512][128];
int unchecked_constructors = 0;
char to_be_checked_constructors[512][128];
int unchecked_methods = 0;
char to_be_checked_methods[512][128]; // I know 512 is a lot but we could have some funky programs

extern int symtab;

int check_class(char * name, struct sym_table * t) {
  if (strcmp(name, "int") == 0) {// brynn: this is a workaround. Better to add to the table later, this is just so I have something to test lol
    return 0;
  }
  if (t == NULL) {
    return 3;
  }
  struct sym_entry * e;
  for (size_t tb = 0; tb < t->nBuckets; tb++) {
    e = t->tbl[tb];
    while (e != NULL) {
      if (strcmp(e->s, name) == 0 && e->declaration_type == 3) {
        return 0; // got it -- is it table already and it is proper type
      } else if (e->table != NULL) {

        if (check_class(name, e->table) == 0) {
          return 0; // we got it in a sub class
        }
      }
      e = e->next;
    }
  }
  return 3;
}

int check_constructor(char * name, struct sym_table * t) {
  if (t == NULL) {
    return 3;
  }
  struct sym_entry * e;
  for (size_t tb = 0; tb < t->nBuckets; tb++) {
    e = t->tbl[tb];
    while (e != NULL) {
      if (strcmp(e->s, name) == 0 && e->declaration_type == 4) {
        return 0; // got it -- is it table already and it is proper type
      } else if (e->table != NULL) {

        if (check_constructor(name, e->table) == 0) {
          return 0; // we got it in a sub class
        }
      }
      e = e->next;
    }
  }
  return 3;
}

int check_method(char * name, struct sym_table * t, int level) {
  if (t == NULL) {
    return 3;
  }
  struct sym_entry * e;
  for (size_t tb = 0; tb < t->nBuckets; tb++) {
    e = t->tbl[tb];
    while (e != NULL) {
      if (strcmp(e->s, name) == 0 && e->declaration_type == 2) {
        return 0; // got it -- is it table already and it is proper type
      } else if (e->table != NULL) {
        if (check_method(name, e->table, level + 1) == 0) {
          return 0; // we got it in a sub class
        }
      }
      e = e->next;
    }
  }
  return 3;
}


int check_all_unchecked(struct sym_table * table) { // if all good, return 0. Else 2??? or 3?? brynn can you check teh hw4 doc and make sure these numbers are right -- last line
  for (size_t i = 0; i < unchecked_classes; i++) {
    if (check_class(to_be_checked_classes[i], table) != 0) {
      printf("Class not defined: %s\n", to_be_checked_classes[i]);
      return 3;
    }
  }
  for (int i = 0; i < unchecked_constructors; i++) { // may not have to check, as we don't have to match overloading, and there is a default new object() that just makes the new object
    if (check_constructor(to_be_checked_constructors[i], table) != 0) {
      printf("Constructor not defined: %s %d\n", to_be_checked_constructors[i], unchecked_constructors);
      // return 3;
    }
  }
  for (size_t i = 0; i < unchecked_methods; i++) {
    if (check_method(to_be_checked_methods[i], table, 0) != 0) {
      printf("Method not defined: %s\n", to_be_checked_methods[i]);
      return 3;
    }
  }
  return 0;
}


struct sym_table * mksymtab(struct sym_table * parent) {
  struct sym_table * t = calloc(1, sizeof(struct sym_table));

  t->parent = parent;

  t->nEntries = 0;
  t->nBuckets = 5; // if change this change the line in symtabentry.h *tbl[x] where x matches this...
  //t->tbl = calloc(t->nBuckets, sizeof(struct sym_entry *) + t->nBuckets * sizeof(struct sym_entry));
  for (int i = 0; i < t->nBuckets; i++) {
    t->tbl[i] = calloc(1, sizeof(struct sym_entry));
    t->tbl[i]->s = "HEAD";
    t->tbl[i]->next = NULL;
  }
  return t;
}

struct sym_entry * getnextentry(struct sym_table * table, int hash) {
  struct sym_entry * e = table->tbl[hash];
  // printf("\t\t%d ", hash);
  while (e->next != NULL) {
    // printf("nn ");
    e = e->next;
  }
  // printf("\n");
  return e;
}


void cleanup_tree(struct tree *t) {
  if (t != NULL) {
    for (int i = 0; i < t->nkids; i++) {
      if (t->kids[i] != NULL) {
        t->kids[i]->parent = t;
        cleanup_tree(t->kids[i]);
      }
    }
  }
}

int is_sym_entered(char * text, struct sym_table * table) { // brynn this is the part I was talking about below -- can you have this check parent and *possibly* sibling scopes for the declaration? (I am not 100% on sibling)
  struct sym_entry * e = table->tbl[hash(table, text)];
  // printf("\t\t%d ", hash);
  while (e != NULL) {
    if (strcmp(e->s, text) == 0) {
      //printf("\t   \\__ found: %s on hash:%d\n", text, hash(table, text));
      return e->declaration_type; // got it -- is it table already
    } else {
      //printf("%s != %s\n", e->s, text);
    }
    e = e->next;
  }

  if (table->parent == NULL) {
    // printf("\t Parent null: %s\n", text);
    return 0;
  }
  // printf("\t Parent not null\n");
  return is_sym_entered(text, table->parent);
      //printf("\t   \\_ missed: %s on hash:%d\n", text, hash(table, text));
  //return 0; // not in table yet
}

int is_decl_var(struct tree *t) {
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (t->prodrule == FIELD_DECL || t->prodrule == FORMAL_PARM || t->prodrule == LOCAL_VAR_DECL || t->prodrule == 6909) { // variable declaration. TODO: Determine if there are more.
                      // maybe should return a different number for class and for function declaration?
      return 1; // it is a declaration
    }
    t = t->parent;
  }
  return 0; // not a declaration
}

int is_use_var(struct tree *t) {// this is not for declaring, just using a variable. -- without this, they will be classified as missing classes lol
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (t->prodrule == 6913) { // variable declaration. TODO: Determine if there are more.
      return 1; // it is a declaration
    }
    t = t->parent;
  }
  return 0; // not a use
}

int is_decl_method(struct tree *t) {
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (t->prodrule == METHOD_DECL) { // method declaration
      return 2;
    }
    t = t->parent;
  }
  return 0; // not a declaration
}

int is_decl_class(struct tree *t) {
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (t->prodrule == 1000) { // class declaration
      return 3;
    }
    t = t->parent;
  }
  return 0; // not a declaration
}

int is_decl_constructor(struct tree *t) {
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (t->prodrule == 1033) { // class declaration
      return 4;
    }
    t = t->parent;
  }
  return 0; // not a declaration
}

int is_decl_right_side_of_assignment(struct tree *t) {
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (t->prodrule == 1122) {
      return 3;
    }
    if (t->prodrule == 1158) {
      return 6;
    }
    if (t->prodrule == 6900) { // class declaration change this
      return 5;
    }
    t = t->parent;
  }
  return 0; // not a declaration
}

int is_decl(struct tree * t) { // returns 0 if not declared, 1 if declared as a variable, 2 if declared as a method, or 3 if declared as a class.
  while (t != NULL) {
    // printf("%d\n", t->prodrule);
    if (is_decl_var(t) == 1) {
          //t->prodrule == FIELD_DECL || t->prodrule == FORMAL_PARM || t->prodrule == LOCAL_VAR_DECL || t->prodrule == 1122) { // variable declaration. TODO: Determine if there are more.
                      // maybe should return a different number for class and for function declaration?
      return 1; // it is a declaration
    } else if (is_use_var(t) == 1) {
      return 7;
    } else if (is_decl_right_side_of_assignment(t) == 3) {
      return 3; // use, not declaration of a class
    } else if (is_decl_right_side_of_assignment(t) == 6) {
      return 5; // use, not declaration of a class
    } else if (is_decl_right_side_of_assignment(t) == 5) {
      return 1;
    } else if (is_decl_method(t) == 2) { // method declaration
      return 2;
    } else if (is_decl_constructor(t) == 4) { // constructor declaration
      return 4;
    } else if (is_decl_class(t) == 3) { // class declaration
      return 3;
    }
    t = t->parent;
  }
  return 0; // not a declaration
}

void add_all_variables(struct tree * t, struct sym_table * table) {
  if (t == NULL) {
    return;
  }

  if (t->leaf != NULL && t->leaf->text != NULL) {
    // printf("Adding: %s\n", t->leaf->text);
    struct sym_entry * next_sym_entry = getnextentry(table, hash(table, t->leaf->text));
    next_sym_entry->next = calloc(1, sizeof(struct sym_entry));
    next_sym_entry = next_sym_entry->next;
    next_sym_entry->declaration_type = is_decl(t);
    next_sym_entry->next = NULL;
    //printf("%s\n", t->leaf->text);
    next_sym_entry->s = calloc(128, sizeof(char));
    strncpy(next_sym_entry->s, t->leaf->text, 128);
    table->nEntries++;
  }
  for (int i = 0; i < t->nkids; i++) {
      add_all_variables(t->kids[i], table);
  }
}

// Helpter function for add_sym_entry -B
struct sym_table *fill_sym_entry(int decl_type, char *name, struct sym_table *table) {
    struct sym_entry *next_sym_entry = getnextentry(table, hash(table, name));
    next_sym_entry->next = calloc(1, sizeof(struct sym_entry));
    next_sym_entry = next_sym_entry->next;
    next_sym_entry->declaration_type = decl_type;
    next_sym_entry->next = NULL;
    next_sym_entry->s = calloc(128, sizeof(char));
    strncpy(next_sym_entry->s, name, 128);
    table->nEntries++;
    next_sym_entry->table = mksymtab(table);
    return(next_sym_entry->table);
}

int sortoutmultivar(struct tree *t, struct sym_table * table) {
  // printf("here\n");
  if (t->prodrule == 267) {
    //declare the variable name here
    if (checkifdef(t, table) == 1) {
      printf("Double defined variable: %s\n", t->symbolname); // return with error?
      return 1;
    }
    // printf("Adding: %s\n", t->symbolname);
    struct sym_entry * next_sym_entry = getnextentry(table, hash(table, t->symbolname));
    next_sym_entry->next = calloc(1, sizeof(struct sym_entry));
    next_sym_entry = next_sym_entry->next;
    next_sym_entry->declaration_type = is_decl(t);
    next_sym_entry->next = NULL;
    //printf("%s\n", t->leaf->text);
    next_sym_entry->s = calloc(128, sizeof(char));
    strncpy(next_sym_entry->s, t->symbolname, 128);
    table->nEntries++;
  }
  if (t->prodrule == 1021) {
    //just 2 name declarations
    int x = sortoutmultivar(t->kids[0], table);
    x += sortoutmultivar(t->kids[1], table);
    if (x != 0) {
      return 1;
    }
  }
  if (t->prodrule == 6915) {
    //name and Assignment
    //kid at t->0->0
    if(sortoutmultivar(t->kids[0]->kids[0], table) != 0) {
      return 1;
    }
  }
  return 0;
}

int checkifdef(struct tree *t, struct sym_table *table) {
  if (t->leaf != NULL && t->leaf->text != NULL && is_sym_entered(t->leaf->text, table) != 0) {// checking for variables
    // printf("%s is defined, Just check for double defining now!\n", t->leaf->text);
    if (t->parent->prodrule == 1085) { // false alarm, re-use of variable
      return 0;
    }
    // printf("%d, %d\n", t->parent->prodrule, is_sym_entered(t->leaf->text, table));
    if (t->parent->prodrule == 1027 && is_sym_entered(t->leaf->text, table) != 2) { // false alarm, re-use of variable
      return 0;
    }
    if (t->parent->prodrule == 6913) { // false alarm, re-use of variable
      return 0;
    }
    if (t->parent->prodrule == 1130) { // false alarm, ++ of variable
      return 0;
    }
    if (t->parent->prodrule == 1085) { // false alarm, use of constructor
      return 0;
    }
    if (t->parent->prodrule == 1033) { // making of constructor
      return 0;
    }
    if (t->parent->prodrule == 1007 && t->parent->kids[0] == t) { // checking the type of a variable
      return 0;
    }
    if (t->parent->prodrule == 1041 && t->parent->kids[0] == t) { // checking the type of a variable
      return 0;
    }
    if (t->parent->prodrule == 1158 && t->parent->kids[1] == t) { // checking the type of a new const()
      return 0;
    }
    // printf("ERROR ERROR ERROR ^^^\n");
    return 1;
  }
  return 0; // no problem
}

int add_sym_entry(struct tree * t, struct sym_table * table) {
  if (t == NULL) {
    return 0;
  }

  // if (checkifdef(t, table) == 1) {
  //   printf("Problem: \n");
  //   return 1; // error
  // }

  if (t->prodrule == 1000) { // Class declaration
    // printf("CLASS ");
    char * name = t->kids[2]->symbolname;
    // printf("%s\n", name);

    if (checkifdef(t->kids[2], table) == 1) {
      // printf("Problem: \n");
    }

    // printf("\t method declaration: %s\n", t->leaf->text);
    int declaration_type = is_decl(t);
    if (declaration_type != 3) { // not a function ?? need to determine that this is right lol
      // printf("This seems sus, declaration should be a class but doesnt seem to be lol\n");
    }
    // printf("Declaration type is: %d\n", declaration_type);
    // printf("PR: %d\n", t->prodrule);
    // printf("--Bingo--\n");

    struct tree *next = t->kids[3]; // body of class
    for (int i = 0; i < next->nkids; i++) {
      if(add_sym_entry(next->kids[i], fill_sym_entry(declaration_type, name, table)) != 0) {
        return 1;
      }
    }
    return 0;
  }

  if (t->prodrule == CONSTRUCTOR_DECL) { // constructor

    // printf("CONSTRUCTOR ");
    char * name = t->kids[1]->kids[0]->symbolname;
    // printf("%s\n", name);
    if (checkifdef(t->kids[1]->kids[0], table) == 1) {
      printf("Double Defined Construcor: %s\n", name);
    }
    // printf("\t method declaration: %s\n", t->leaf->text);
    int declaration_type = is_decl(t->kids[1]->kids[0]);
    if (declaration_type != 4) { // brynn plz update this so it will detect constructors
      // printf("This seems sus, declaration should be a CONSTRUCTOR but doesnt seem to be lol: %s\n", name);
    }
    // printf("Declaration type is: %d\n", declaration_type);
    // printf("PR: %d\n", t->prodrule);

    struct sym_table *next_table = fill_sym_entry(declaration_type, name, table);

    struct tree *next = t->kids[1]->kids[1]; // parameter list
    if (next != NULL) {//possible that we don't have any inputs in this constructor
      for (int i = 0; i < next->nkids; i++) {
        add_all_variables(next->kids[i], next_table);
      }
    }
    next = t->kids[2];                                //body of constructor
    if (next != NULL) {//possible that we don't have any inputs in this constructor
      for (int i = 0; i < next->nkids; i++) {
        if(add_sym_entry(next->kids[i], next_table) != 0) {
          return 1;
        }
      }
    }
    return 0;
  }

  if (t->prodrule == METHOD_DECL) { // MethodDecl -- this is a method!

    // printf("METHOD ");
    char * name = t->kids[0]->kids[3]->kids[0]->symbolname;
    // printf("%s\n", name);
    if (checkifdef(t->kids[0]->kids[3]->kids[0], table) == 1) {
      printf("Double defined method: %s\n", name);
    }
    // printf("\t method declaration: %s\n", t->leaf->text);
    int declaration_type = is_decl(t->kids[0]->kids[3]->kids[0]);
    if (declaration_type != 2) { // not a function ?? need to determine that this is right lol
      // printf("This seems sus, declaration should be a function but doesnt seem to be lol\n");
    }
    // printf("Declaration type is: %d\n", declaration_type);
    // printf("PR: %d\n", t->prodrule);

    struct sym_table *next_table = fill_sym_entry(declaration_type, name, table);
    //     // printf("%x vs %x\n", (unsigned int) next_sym_entry->table, table);
    //     // next_sym_entry->table->parent = table;
    //     // table = next_sym_entry->table;

    struct tree *next = t->kids[0]->kids[3]->kids[1]; // parameter list
    //TODO make case for no parameters
    if (next) {
        for (int i = 0; i < next->nkids; i++) {
          add_all_variables(next->kids[i], next_table);
        }
        next = t->kids[1];                                //body of function
        for (int i = 0; i < next->nkids; i++) {
          if(add_sym_entry(next->kids[i], next_table) != 0) {
            return 1;
          }
        }
        return 0;
    }
    // end of a block -- might need to change this to scope/class ect... to be more specific and fix for loops lol
    // if (table->parent != NULL) { // todo may be able to get rid of this?
    //   table = table->parent;
    //     printf("\n-------Parented----------\n\n");
    // } else {
    //   printf("\n-------null????----------\n\n");
    // }
  }
  if (t->prodrule == LOCAL_VAR_DECL /*LocalVarDecl*/ || t->prodrule == FIELD_DECL /*FieldDecl*/ || t->prodrule == FORMAL_PARM /*FormalParm*/) { // variables Declarations! -- this is a method!
    if (t->prodrule == 1041 || (t->prodrule == 1007 && t->kids[1]->prodrule == 1021)) {
      // printf("herehreh\n");
      /* code */ // john do this later --  for multi line

      //check type of t->kid[0]
      strcpy(to_be_checked_classes[unchecked_classes], t->kids[0]->symbolname);
      unchecked_classes++;
      if(sortoutmultivar(t->kids[1], table) != 0) {
        return 1;
      }
      return 0;
    }

      // for LeftHandSide (1122) We need to be careful not to be tricked into defining the type of this, but instead just making sure it exists
    // if (t->prodrule == 1122) {
    //   // char * typename = t->kids[0]->symbolname;
    //   // brynn --> please add t->kids[0]->symbolname (above) to the list of things to check the scope of, make sure it is visible and defined. This might be complicated, but the bare minimum is making sure it's defined somewhere. Thanks!
    // }

    // printf("VARIABLE ");
    // char * name = t->kids[1]->symbolname;
    // printf("%s\n", name);

    if (checkifdef(t->kids[1], table) == 1) {
      printf("Problem: \n");
    }

    add_all_variables(t->kids[1], table);
    strcpy(to_be_checked_classes[unchecked_classes], t->kids[0]->symbolname);
    unchecked_classes++;
    return 0;
  }

  if (t != NULL && t->leaf != NULL && t->leaf->text != NULL && t->leaf->category == IDENTIFIER) {
    // printf("\t -- %s  %d\n", t->leaf->text, t->leaf->category);
    if (is_sym_entered(t->leaf->text, table) != 0) {
      // printf("%s is defined, Just check for double defining now!\n", t->leaf->text);
      if (t->parent->prodrule == 1041 || t->parent->parent->prodrule == 1041) {
        // printf("ERROR ERROR ERROR ^^^\n");
      }
              // --- brynn: maybe we should double check that we are not re-defining anything here. Check define rules?
      // TODO check for adding more information, previous declarations, ect... ???
    } else {
        //brynn this could be refactored but I just want to die and this to end so i'm doing it here, im sorry
        if (t->parent->prodrule == 6909) {
          // Type needs to be checked after the fact
          strcpy(to_be_checked_classes[unchecked_classes], t->parent->parent->kids[0]->symbolname);
          unchecked_classes++;

          // add the stuff to the table
          char * name = t->symbolname;
          struct sym_entry * next_sym_entry = getnextentry(table, hash(table, name));
          next_sym_entry->next = calloc(1, sizeof(struct sym_entry));
          next_sym_entry = next_sym_entry->next;
          next_sym_entry->declaration_type = 1;
          next_sym_entry->next = NULL;
          next_sym_entry->s = calloc(128, sizeof(char));
          strncpy(next_sym_entry->s, name, 128);
          table->nEntries++;
          return 0;
        }
        if (t->parent->prodrule == 1122) {
          // Type needs to be checked after the fact
          strcpy(to_be_checked_classes[unchecked_classes], t->parent->kids[0]->symbolname);
          unchecked_classes++;

          // add the stuff to the table
          char * name = t->symbolname;
          struct sym_entry * next_sym_entry = getnextentry(table, hash(table, name));
          next_sym_entry->next = calloc(1, sizeof(struct sym_entry));
          next_sym_entry = next_sym_entry->next;
          next_sym_entry->declaration_type = 1;
          next_sym_entry->next = NULL;
          next_sym_entry->s = calloc(128, sizeof(char));
          strncpy(next_sym_entry->s, name, 128);
          table->nEntries++;
          return 0;
        }
        // add to proper unknown list
        int decl = is_decl(t);
        // printf("decl: %d\n", decl);
        if (decl == 1) {
          // we have a problem, throw an error.
          // printf("UNKNOWN VARIABLE: %s\n", t->leaf->text);
          printf("Error: variable not defined: %s\n", t->leaf->text);
          // printf("%s:: prule: %d parent's prule: %d grandparent's prule: %d, decl:%d\n", t->leaf->text, t->prodrule, t->parent->prodrule, t->parent->parent->prodrule, is_decl(t));

          return 1;// 3; // brynn lets make sure this gets caught at the top, so we can throw the proper exit code
        } else if (decl == 2) {
          strcpy(to_be_checked_methods[unchecked_methods], t->leaf->text);
          unchecked_methods++;
        } else if (decl == 3) {
          strcpy(to_be_checked_classes[unchecked_classes], t->leaf->text);
          unchecked_classes++;
        } else if (decl == 4) {
          // printf("\"CONSTRUCTOR4\" %s\n", t->leaf->text);
          strcpy(to_be_checked_constructors[unchecked_constructors], t->leaf->text);
          unchecked_constructors++;
        } else if (decl == 5) { // used not declared construcor? // is this actually for constructor
          // printf("\"CONSTRUCTOR5\" %s\n", t->leaf->text);
          strcpy(to_be_checked_constructors[unchecked_constructors], t->leaf->text);
          unchecked_constructors++;
        } else if (decl == 7) {
          // we have a variable that is not declared! throw an error.
          printf("Error: variable defined: %s\n", t->leaf->text);
          // printf("\t YUH OH YUH OH YUH OH!!!!!!! NOT declaration: %s\n", t->leaf->text);
          // printf("%s:: prule: %d parent's prule: %d grandparent's prule: %d, decl:%d\n", t->leaf->text, t->prodrule, t->parent->prodrule, t->parent->parent->prodrule, is_decl(t));

          return 0;
        }
    }
  }

  if (t != NULL) { // even if t not a variable, we want to catch the kids!
    for (int i = 0; i < t->nkids; i++) {
      if(add_sym_entry(t->kids[i], table) != 0) {
        return 1;
      }
    }
  }
  return 0;
}

void printtable(struct sym_table * table, int tab) {
  for (int i = 0; i < table->nBuckets; i++) {
    struct sym_entry *e = table->tbl[i]->next; /*TODO fix this to be flexible*/
    while (e != NULL) {
      printf("    %s\n", e->s);
      // if (e->table != NULL) {
      //   printtable(e->table, tab + 2);
      // }
      e = e->next;
    }
  }
  printf("---\n");
  for (int i = 0; i < table->nBuckets; i++) {
    struct sym_entry *e = table->tbl[i]->next; /*TODO fix this to be flexible*/
    while (e != NULL) {
      if (e->table != NULL) {
        printf("--- symbol table for: %s\n", e->s);
        printtable(e->table, tab + 2);
      }
      e = e->next;
    }
  }
}

int hash(SymbolTable st, char *s) {
   // return 0;
   register int h = 0;
   register char c;
   while ((c = *s++)) {
      h += c & 0377;
      h *= 37;
      }
   if (h < 0) h = -h;
   return h % st->nBuckets;
}
