%{
  #include <stdio.h>
  #include "tree.h"
  int yylex(void);
  int alctoken(int i);
  void yyerror(char const * h);
%}
%union {
  struct tree *treeptr;
}

%token <treeptr> BREAK DOUBLE ELSE FOR IF INT RETURN VOID WHILE
%token <treeptr> IDENTIFIER CLASSNAME CLASS STRING BOOL
%token <treeptr> LINT LDOUBLE LSTRING LBOOL LCHAR NULLVAL
%token <treeptr> LESSEQUAL GREATEREQUAL GREATER LESS
%token <treeptr> EQUALEQUAL NOTEQUAL ANDAND OROR EQUAL
%token <treeptr> ADDADD SUBSUB MULMUL DIVDIV MODMOD PUBLIC STATIC HEX OCT

%token <treeptr> OPENCLOSE

%token <treeptr> CASE CHAR CONTINUE DEFAULT FLOAT INSTANCEOF LONG NEW SWITCH
%token <treeptr> ADDEQUAL SUBEQUAL INCREMENT DECREMENT ISEQUALTO NOTEQUALTO
%token <treeptr> GREATHERTHANOREQUAL GREATERTHANOREQUAL LESSTHANOREQUAL LOGICALAND LOGICALOR CAST

%token <treeptr> MULT DIVIDE MOD


%type <treeptr> ClassDecl ClassBody ClassBodyDecls ClassBodyDecl FieldDecl Type
%type <treeptr> Name QualifiedName
%type <treeptr> VarDecls VarDeclarator
%type <treeptr> MethodReturnVal MethodDecl MethodHeader MethodDeclarator FormalParmListOpt FormalParmList FormalParm
%type <treeptr> ConstructorDecl ConstructorDeclarator ArgListOpt
%type <treeptr> Block BlockStmts BlockStmt
%type <treeptr> LocalVarDeclStmt LocalVarDecl
%type <treeptr> Stmt ExprStmt StmtExpr
%type <treeptr> IfThenStmt IfThenElseStmt IfThenElseIfStmt
%type <treeptr> ElseIfSequence ElseIfStmt WhileStmt
%type <treeptr> ForStmt ForInit ExprOpt ForUpdate
%type <treeptr> StmtExprList
%type <treeptr> BreakStmt ReturnStmt
%type <treeptr> Primary Literal
%type <treeptr> InstantiationExpr ArgList FieldAccess MethodCall
%type <treeptr> PostFixExpr UnaryExpr MulExpr AddExpr RelOp RelExpr
%type <treeptr> EqExpr CondAndExpr CondOrExpr
%type <treeptr> Expr Assignment LeftHandSide AssignOp
%type <treeptr> SpecialName
%type <treeptr> SwitchBlock CaseBlock CaseList CaseHead
%type <treeptr> ArrayDec ArrayLeft ArrayRight LiteralList ArrayInit InstncExpr ObjectInt
%type <treeptr> Cast NumBase StaticStatus PublicStatus

/* Lowest*/

%right '=' ADDADD SUBSUB MULMUL DIVDIV MODMOD
%left ':'
%left OROR
%left ANDAND
%left EQUALEQUAL NOTEQUAL
%left '<' '>' LESSEQUAL GREATEREQUAL INSTANCEOF
%left '+' '-'
%left '*' '/' '%'
%left '!'
%left INCREMENT DECREMENT
/* Highest*/

%%


ClassDecl: PUBLIC CLASS IDENTIFIER ClassBody {/*tree_print($3, 4);*/ $$ = bingo($1, $2, $3, $4); };
ClassBody: '{' ClassBodyDecls '}' { $$ = $2; } 
	|  '{' '}' { $$ = NULL;} ;
ClassBodyDecls: ClassBodyDecl { $$ = $1; } 
	|  ClassBodyDecls ClassBodyDecl  { $$ = alcTreeTwoKids($1, $2, 1003); } ;
ClassBodyDecl: FieldDecl  { $$ = $1; }  
	|  MethodDecl { $$ = $1; } 
	|  ConstructorDecl { $$ = $1; } ;
FieldDecl: Type VarDecls ';' { $$ = alcTreeTwoKids($1, $2, 1007); };
Type: INT  { $$ = $1; } 
	|  DOUBLE  { $$ = $1; } 
	|  BOOL  { $$ = $1; } 
	|  STRING  { $$ = $1; } 
	|  CHAR { $$ = $1; } 
	|  FLOAT  { $$ = $1;} 
	|  LONG { $$ = $1;} 
	|  IDENTIFIER  { $$ = $1; } ;

Name: IDENTIFIER { $$ = $1; } 
	|  QualifiedName { $$ = $1; /*todo maybe this is where I do ++ and [1], ect*/} ;
QualifiedName: Name '.' IDENTIFIER { $$ = alcTreeTwoKids($1, $3, 1018); } 
	|  SpecialName {$$ = $1;};

VarDecls: VarDeclarator { $$ = $1; } 
	|  VarDecls ',' VarDeclarator { $$ = alcTreeTwoKids($1, $3, 1021); };
VarDeclarator: Name { $$ = $1; };

MethodReturnVal : Type { $$ = $1; } 
	|  VOID { $$ = $1; } ;
MethodDecl: MethodHeader Block { $$ = alcTreeTwoKids($1, $2, 1025); };
MethodHeader: PublicStatus StaticStatus MethodReturnVal MethodDeclarator { $$ = alcTreeFourKids($1, $2, $3, $4, 1026); };
StaticStatus: STATIC { $$ = $1; } 
	|  {$$ = NULL;} ;
PublicStatus: PUBLIC { $$ = $1; } 
	|  {$$ = NULL;} ;
MethodDeclarator: IDENTIFIER '(' FormalParmListOpt ')' { $$ = alcTreeTwoKids($1, $3, 1027); };
FormalParmListOpt: FormalParmList { $$ = $1; }
	|  {$$ = NULL;};
FormalParmList: FormalParm { $$ = $1; }
	|  FormalParmList ',' FormalParm { $$ = alcTreeTwoKids($1, $3, 1030); };
FormalParm: Type VarDeclarator { $$ = alcTreeTwoKids($1, $2, 1031); };

ConstructorDecl: PublicStatus ConstructorDeclarator Block { $$ = alcTreeThreeKids($1, $2, $3, 1032);}  
	|  ConstructorDeclarator Block { $$ = alcTreeThreeKids(NULL, $1, $2, 1032);};
ConstructorDeclarator: IDENTIFIER '(' FormalParmListOpt ')' { $$ = alcTreeTwoKids($1, $3, 1033); };
ArgListOpt:  ArgList { $$ = $1; } 
	|  {$$ = NULL;};

Block: '{' BlockStmts '}' { $$ = $2 ;}
	|  '{' '}' {$$ = NULL;};
BlockStmts:  BlockStmt { $$ = $1; }
	|  BlockStmts BlockStmt { $$ = alcTreeTwoKids($1, $2, 1037); };
BlockStmt:   LocalVarDeclStmt { $$ = $1; }
	|  Stmt { $$ = $1; };

LocalVarDeclStmt: LocalVarDecl ';' { $$ = $1; };
LocalVarDecl: Type VarDecls { $$ = alcTreeTwoKids($1, $2, 1041); /*TODO make sure we can do "int i = 0;" here, ect*/};

Stmt: Block { $$ = $1; }
	|  ';' {$$ = NULL;}
	|  ExprStmt { $$ = $1; }
	|  BreakStmt { $$ = $1; }
	|  ReturnStmt { $$ = $1; }
      
	|  IfThenStmt { $$ = $1; }
	|  IfThenElseStmt { $$ = $1; }
	|  IfThenElseIfStmt { $$ = $1; }
      
	|  WhileStmt { $$ = $1; }
	|  ForStmt { $$ = $1;} 
	|  SwitchBlock { $$ = $1;} 
	|  ArrayDec { $$ = $1;} ;

ExprStmt: StmtExpr ';' { $$ = $1; };

StmtExpr: Assignment { $$ = $1; }
	|  MethodCall { $$ = $1; }
	|  InstantiationExpr { $$ = $1; } 
	|  SpecialName {$$ = $1;};

IfThenStmt: IF '(' Expr ')' Block { $$ = alcTreeThreeKids($1, $3, $5, 1059); };
IfThenElseStmt: IF '(' Expr ')' Block ELSE Block { $$ = alcTreeFiveKids($1, $3, $5, $6, $7, 1060); };
IfThenElseIfStmt: IF '(' Expr ')' Block ElseIfSequence { $$ = alcTreeFourKids($1, $3, $5, $6, 1061); }
       
	|   IF '(' Expr ')' Block ElseIfSequence ELSE Block { $$ = alcTreeSixKids($1, $3, $5, $6, $7, $8, 1062); };

ElseIfSequence: ElseIfStmt { $$ = $1; }
	|  ElseIfSequence ElseIfStmt { $$ = alcTreeTwoKids($1, $2, 1064); };
ElseIfStmt: ELSE IfThenStmt { $$ = alcTreeTwoKids($1, $2, 1065); };
WhileStmt: WHILE '(' Expr ')' Stmt { $$ = alcTreeThreeKids($1, $3, $5, 1066); };

ForStmt: FOR '(' ForInit ';' ExprOpt ';' ForUpdate ')' Block {$$ = alcTreeFiveKids($1, $3, $5, $7, $9, 1067); };
ForInit: StmtExprList { $$ = $1; }
	|  LocalVarDecl { $$ = $1; }
	|  {$$ = NULL;};
ExprOpt: Expr { $$ = $1; }
	|  {$$ = NULL;};
ForUpdate: StmtExprList { $$ = $1; }
	|  {$$ = NULL;};

StmtExprList: StmtExpr { $$ = $1; }
	|  StmtExprList ',' StmtExpr { $$ = alcTreeTwoKids($1, $3, 1073); };

BreakStmt: BREAK ';' { $$ = $1; }
	|  BREAK IDENTIFIER ';' { $$ = alcTreeTwoKids($1, $2, 1075); };
ReturnStmt: RETURN ExprOpt ';' { $$ = alcTreeTwoKids($1, $2, 1076); };

Primary:  Literal { $$ = $1; }
	|  '(' Expr ')' { $$ = $2; }
	|  FieldAccess { $$ = $1; }
	|  MethodCall { $$ = $1; };
Literal: LINT 
	|  LDOUBLE 
	|  LBOOL 
	|  LSTRING 
	|  LCHAR 
	|  HEX 
	|  OCT 
	|  NULLVAL ;

InstantiationExpr: PUBLIC Name '(' ArgListOpt ')' { $$ = alcTreeThreeKids($1, $2, $4, 1081); };
ArgList: Expr { $$ = $1; }
	|  ArgList ',' Expr { $$ = alcTreeTwoKids($1, $3, 1083); };
FieldAccess: Primary '.' IDENTIFIER { $$ = alcTreeTwoKids($1, $3, 1084); };

MethodCall: Name '(' ArgListOpt ')' { $$ = alcTreeTwoKids($1, $3, 1085); }
	
	|  Name '{' ArgListOpt '}' { $$ = alcTreeTwoKids($1, $3, 1086); }
	
	|  Primary '.' IDENTIFIER '(' ArgListOpt ')' { $$ = alcTreeThreeKids($1, $3, $5, 1087); }
	
	|  Primary '.' IDENTIFIER '{' ArgListOpt '}' { $$ = alcTreeThreeKids($1, $3, $5, 1088); };

PostFixExpr: Primary { $$ = $1; }
	|  Name { $$ = $1; };
UnaryExpr:  '-' UnaryExpr { $$ = $2; /* TODO make this work lol */}
	|  '!' UnaryExpr { $$ = $2; /* TODO make this work lol */}
	|  PostFixExpr { $$ = $1; };
MulExpr: UnaryExpr { $$ = $1; }
	|  MulExpr '*' UnaryExpr { $$ = alcTreeThreeKids($1, kido(MULT), $3, 1095); /* TODO make this work and below*/}
    
	|  MulExpr '/' UnaryExpr { $$ = alcTreeThreeKids($1, kido(DIVIDE), $3, 1096); }
	|  MulExpr '%' UnaryExpr { $$ = alcTreeThreeKids($1, kido(MOD), $3, 1097); };
AddExpr: MulExpr { $$ = $1; }
	|  AddExpr '+' MulExpr { $$ = alcTreeThreeKids($1, kido('+'), $3, 1099); }
	|  AddExpr '-' MulExpr { $$ = alcTreeThreeKids($1, kido(SUBSUB), $3, 1101); };
RelOp: LESSEQUAL { $$ = $1; }
	|  GREATEREQUAL { $$ = $1; }
	|  '<' { $$ = alcTreeOneKids(kido(LESS), 1104); }
	|  '>' { $$ = alcTreeOneKids(kido(GREATER), 1105); /* TODO this too*/};
RelExpr: AddExpr { $$ = $1; }
	|  RelExpr RelOp AddExpr { $$ = alcTreeThreeKids($1, $2, $3, 1107); };

EqExpr: RelExpr { $$ = $1; }
	|  EqExpr EQUALEQUAL RelExpr { $$ = alcTreeThreeKids($1, $2, $3, 1109); }
	|  EqExpr NOTEQUAL RelExpr { $$ = alcTreeThreeKids($1, $2, $3, 1110); };
CondAndExpr: EqExpr { $$ = $1; }
	|  CondAndExpr ANDAND EqExpr { $$ = alcTreeThreeKids($1, $2, $3, 1112); };
CondOrExpr: CondAndExpr { $$ = $1; }
	|  CondOrExpr OROR CondAndExpr { $$ = alcTreeThreeKids($1, $2, $3, 1114); };

Expr: CondOrExpr { $$ = $1; }
	|  Assignment { $$ = $1;} 
	|  ArrayInit { $$ = $1;} 
	|  InstncExpr {$$ = $1;} 
	|  Cast {$$ = $1;} 
	|  ObjectInt {$$ = $1;} ;
Assignment: LeftHandSide AssignOp Expr {$$ = alcTreeThreeKids($1, $2, alcTreeOneKids($3, 6900), 1120); };
LeftHandSide: Name {$$ = alcTreeOneKids($1, 6913); } 
	|  Type Name {$$ = alcTreeTwoKids($1, alcTreeOneKids($2, 6909), 1122); } 
	|  FieldAccess { $$ = $1; };
AssignOp: '=' {$$ = alcTreeOneKids(kido(EQUAL), 1124); }
	|  ADDADD { $$ = $1; }
	|  SUBSUB { $$ = $1;}
	|  MULMUL { $$ = $1;}
	|  DIVDIV { $$ = $1;}
	|  MODMOD { $$ = $1; };

SpecialName: Name INCREMENT {$$ = alcTreeTwoKids($1, $2, 1130); } 
	|  Name DECREMENT {$$ = alcTreeTwoKids($1, $2, 1131); } 
	|  Name OPENCLOSE {$$ = alcTreeTwoKids($1, $2, 1132); } 
	|  Name '[' Expr ']' {$$ = alcTreeTwoKids($1, $3, 1133); };

SwitchBlock: SWITCH '(' Name ')' '{' CaseBlock '}' {  $$ =  alcTreeThreeKids($1, $3, $6, 1134); };
CaseBlock: CaseList Stmt BREAK ';' {$$ = alcTreeThreeKids($1, $2, $3, 1135);} 
	|  CaseBlock CaseList Stmt BREAK ';' {$$ = alcTreeFourKids($1, $2, $3, $4, 1136);} 
	|  CaseBlock DEFAULT ':' Stmt {$$ = $1;} ;
CaseList: CaseHead {$$ = $1; } 
	|  CaseList CaseHead {$$ = alcTreeTwoKids($1, $2, 1139); };
CaseHead: CASE NumBase ':' {$$ = alcTreeTwoKids($1, $2, 1140); };

ArrayDec: ArrayLeft ArrayRight { $$ = alcTreeTwoKids($1, $2, 1141); };
ArrayLeft: IDENTIFIER OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  INT OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  DOUBLE OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  BOOL OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  STRING OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  CHAR OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  FLOAT OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); } 
	|  LONG OPENCLOSE IDENTIFIER {$$ = alcTreeThreeKids($1, $2, $3, 1142); };
ArrayRight:  '=' NEW ArrayInit ';' {  $$ =  alcTreeTwoKids($2, $3, 1143); } 
	| '=' '{' LiteralList '}' ';' { $$ = $3; } 
	|  ';' {$$ = NULL;};
LiteralList: Literal ',' { $$ = $1; } 
	|  Literal { $$ = $1; } 
	|  LiteralList Literal {$$ = alcTreeTwoKids($1, $2, 1147); } 
	|  LiteralList Literal ',' {$$ = alcTreeTwoKids($1, $2, 1148); } 
	|  {$$ = NULL;};
ArrayInit: NEW IDENTIFIER '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW INT '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW DOUBLE '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW BOOL '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW STRING '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW CHAR '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW FLOAT '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);} 
	|  NEW LONG '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149);};

InstncExpr: Name INSTANCEOF Name {$$ =  alcTreeThreeKids($1, $2, $3, 1150);};
ObjectInt: NEW Name '(' ')' { $$ = alcTreeTwoKids($1, $2, 1158); }
Cast: CAST Name { $$ = alcTreeTwoKids($1, $2, 1151); };
NumBase: LINT { $$ = $1; } 
	|  HEX { $$ = $1; } 
	|  OCT { $$ = $1; };

%%

const char *yyname(int sym) {
return yytname[sym - BREAK + 3];
}
