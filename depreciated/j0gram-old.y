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
%type <treeptr> ArrayDec ArrayLeft ArrayRight LiteralList ArrayInit InstncExpr
%type <treeptr> Cast NumBase

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


ClassDecl: PUBLIC CLASS IDENTIFIER ClassBody {tree_print($3, 4); $$ = bingo($1, $2, $3, $4); };
ClassBody: '{' ClassBodyDecls '}' { $$ = alcTreeOneKids($2, 1001); } | '{' '}' { $$ = NULL;} ;
ClassBodyDecls: ClassBodyDecl { $$ = alcTreeOneKids($1, 1002); } | ClassBodyDecls ClassBodyDecl  { $$ = alcTreeTwoKids($1, $2, 1003); } ;
ClassBodyDecl: FieldDecl  { $$ = alcTreeOneKids($1, 1004); }  | MethodDecl { $$ = alcTreeOneKids($1, 1005); } | ConstructorDecl { $$ = alcTreeOneKids($1, 1006); } ;
FieldDecl: Type VarDecls ';' { $$ = alcTreeTwoKids($1, $2, 1007); };
Type: INT  { $$ = alcTreeOneKids($1, 1008); } | DOUBLE  { $$ = alcTreeOneKids($1, 1009); } | BOOL  { $$ = alcTreeOneKids($1, 1010); } | STRING  { $$ = alcTreeOneKids($1, 1011); } | CHAR { $$ = alcTreeOneKids($1, 1012); } | FLOAT  { $$ = alcTreeOneKids($1, 1013);} | LONG { $$ = alcTreeOneKids($1, 1014);} | Name  { $$ = alcTreeOneKids($1, 1015); } ;

Name: IDENTIFIER { $$ = alcTreeOneKids($1, 1016); } | QualifiedName { $$ = alcTreeOneKids($1, 1017); /*todo maybe this is where I do ++ and [1], ect*/} ;
QualifiedName: Name '.' IDENTIFIER { $$ = alcTreeTwoKids($1, $3, 1018); } | SpecialName {$$ = alcTreeOneKids($1, 1019);};

VarDecls: VarDeclarator { $$ = alcTreeOneKids($1, 1020); } | VarDecls ',' VarDeclarator { $$ = alcTreeTwoKids($1, $3, 1021); };
VarDeclarator: Name { $$ = alcTreeOneKids($1, 1022); };

MethodReturnVal : Type { $$ = alcTreeOneKids($1, 1023); } | VOID { $$ = alcTreeOneKids($1, 1024); } ;
MethodDecl: MethodHeader Block { $$ = alcTreeTwoKids($1, $2, 1025); };
MethodHeader: PUBLIC STATIC MethodReturnVal MethodDeclarator { $$ = alcTreeFourKids($1, $2, $3, $4, 1026); } | STATIC MethodReturnVal MethodDeclarator { $$ = alcTreeThreeKids($1, $2, $3, 1063); } | PUBLIC MethodReturnVal MethodDeclarator { $$ = alcTreeThreeKids($1, $2, $3,1062); } | MethodReturnVal MethodDeclarator { $$ = alcTreeTwoKids($1, $2, 1061); };
MethodDeclarator: IDENTIFIER '(' FormalParmListOpt ')' { $$ = alcTreeTwoKids($1, $3, 1027); };
FormalParmListOpt: FormalParmList { $$ = alcTreeOneKids($1, 1028); }| {$$ = NULL;};
FormalParmList: FormalParm { $$ = alcTreeOneKids($1, 1029); }| FormalParmList ',' FormalParm { $$ = alcTreeTwoKids($1, $3, 1030); };
FormalParm: Type VarDeclarator { $$ = alcTreeTwoKids($1, $2, 1031); };

ConstructorDecl: ConstructorDeclarator Block { $$ = alcTreeTwoKids($1, $2, 1032); };
ConstructorDeclarator: IDENTIFIER '(' FormalParmListOpt ')' { $$ = alcTreeTwoKids($1, $3, 1033); };
ArgListOpt:  ArgList { $$ = alcTreeOneKids($1, 1034); } | {$$ = NULL;};

Block: '{' BlockStmts '}' { $$ = alcTreeOneKids($2, 1035); }| '{' '}' {$$ = NULL;};
BlockStmts:  BlockStmt { $$ = alcTreeOneKids($1, 1036); }| BlockStmts BlockStmt { $$ = alcTreeTwoKids($1, $2, 1037); };
BlockStmt:   LocalVarDeclStmt { $$ = alcTreeOneKids($1, 1038); }| Stmt { $$ = alcTreeOneKids($1, 1039); };

LocalVarDeclStmt: LocalVarDecl ';' { $$ = alcTreeOneKids($1, 1040); };
LocalVarDecl: Type VarDecls { $$ = alcTreeTwoKids($1, $2, 1041); /*TODO make sure we can do "int i = 0;" here, ect*/};

Stmt: Block { $$ = alcTreeOneKids($1, 1043); }| ';' {$$ = NULL;}| ExprStmt { $$ = alcTreeOneKids($1, 1044); }| BreakStmt { $$ = alcTreeOneKids($1, 1045); }| ReturnStmt { $$ = alcTreeOneKids($1, 1046); }
      | IfThenStmt { $$ = alcTreeOneKids($1, 1047); }| IfThenElseStmt { $$ = alcTreeOneKids($1, 1048); }| IfThenElseIfStmt { $$ = alcTreeOneKids($1, 1049); }
      | WhileStmt { $$ = alcTreeOneKids($1, 1050); }| ForStmt { $$ = alcTreeOneKids($1, 1051);} | SwitchBlock { $$ = alcTreeOneKids($1, 1052);} | ArrayDec { $$ = alcTreeOneKids($1, 1053);} ;

ExprStmt: StmtExpr ';' { $$ = alcTreeOneKids($1, 1054); };

StmtExpr: Assignment { $$ = alcTreeOneKids($1, 1055); }| MethodCall { $$ = alcTreeOneKids($1, 1056); }| InstantiationExpr { $$ = alcTreeOneKids($1, 1057); } | SpecialName {$$ = alcTreeOneKids($1, 1058);};

IfThenStmt: IF '(' Expr ')' Block { $$ = alcTreeThreeKids($1, $3, $5, 1059); };
IfThenElseStmt: IF '(' Expr ')' Block ELSE Block { $$ = alcTreeFiveKids($1, $3, $5, $6, $7, 1060); };
IfThenElseIfStmt: IF '(' Expr ')' Block ElseIfSequence { $$ = alcTreeFourKids($1, $3, $5, $6, 1061); }
       |  IF '(' Expr ')' Block ElseIfSequence ELSE Block { $$ = alcTreeSixKids($1, $3, $5, $6, $7, $8, 1062); };

ElseIfSequence: ElseIfStmt { $$ = alcTreeOneKids($1, 1063); }| ElseIfSequence ElseIfStmt { $$ = alcTreeTwoKids($1, $2, 1064); };
ElseIfStmt: ELSE IfThenStmt { $$ = alcTreeTwoKids($1, $2, 1065); };
WhileStmt: WHILE '(' Expr ')' Stmt { $$ = alcTreeThreeKids($1, $3, $5, 1066); };

ForStmt: FOR '(' ForInit ';' ExprOpt ';' ForUpdate ')' Block {$$ = alcTreeFiveKids($1, $3, $5, $7, $9, 1067); };
ForInit: StmtExprList { $$ = alcTreeOneKids($1, 1068); }| LocalVarDecl { $$ = alcTreeOneKids($1, 1069); }| {$$ = NULL;};
ExprOpt: Expr { $$ = alcTreeOneKids($1, 1070); }| {$$ = NULL;};
ForUpdate: StmtExprList { $$ = alcTreeOneKids($1, 1071); }| {$$ = NULL;};

StmtExprList: StmtExpr { $$ = alcTreeOneKids($1, 1072); }| StmtExprList ',' StmtExpr { $$ = alcTreeTwoKids($1, $3, 1073); };

BreakStmt: BREAK ';' { $$ = alcTreeOneKids($1, 1074); }| BREAK IDENTIFIER ';' { $$ = alcTreeTwoKids($1, $2, 1075); };
ReturnStmt: RETURN ExprOpt ';' { $$ = alcTreeTwoKids($1, $2, 1076); };

Primary:  Literal { $$ = alcTreeOneKids($1, 1077); }| '(' Expr ')' { $$ = alcTreeOneKids($2, 1078); }| FieldAccess { $$ = alcTreeOneKids($1, 1079); }| MethodCall { $$ = alcTreeOneKids($1, 1080); };
Literal: LINT | LDOUBLE | LBOOL | LSTRING | LCHAR | HEX | OCT | NULLVAL ;

InstantiationExpr: PUBLIC Name '(' ArgListOpt ')' { $$ = alcTreeThreeKids($1, $2, $4, 1081); };
ArgList: Expr { $$ = alcTreeOneKids($1, 1082); }| ArgList ',' Expr { $$ = alcTreeTwoKids($1, $3, 1083); };
FieldAccess: Primary '.' IDENTIFIER { $$ = alcTreeTwoKids($1, $3, 1084); };

MethodCall: Name '(' ArgListOpt ')' { $$ = alcTreeTwoKids($1, $3, 1085); }
	| Name '{' ArgListOpt '}' { $$ = alcTreeTwoKids($1, $3, 1086); }
	| Primary '.' IDENTIFIER '(' ArgListOpt ')' { $$ = alcTreeThreeKids($1, $3, $5, 1087); }
	| Primary '.' IDENTIFIER '{' ArgListOpt '}' { $$ = alcTreeThreeKids($1, $3, $5, 1088); };

PostFixExpr: Primary { $$ = alcTreeOneKids($1, 1089); }| Name { $$ = alcTreeOneKids($1, 1090); };
UnaryExpr:  '-' UnaryExpr { $$ = alcTreeOneKids($2, 1091); /* TODO make this work lol */}| '!' UnaryExpr { $$ = alcTreeOneKids($2, 1092); /* TODO make this work lol */}| PostFixExpr { $$ = alcTreeOneKids($1, 1093); };
MulExpr: UnaryExpr { $$ = alcTreeOneKids($1, 1094); }| MulExpr '*' UnaryExpr { $$ = alcTreeThreeKids($1, kido(MULT), $3, 1095); /* TODO make this work and below*/}
    | MulExpr '/' UnaryExpr { $$ = alcTreeThreeKids($1, kido(DIVIDE), $3, 1096); }| MulExpr '%' UnaryExpr { $$ = alcTreeThreeKids($1, kido(MOD), $3, 1097); };
AddExpr: MulExpr { $$ = alcTreeOneKids($1, 1098); }| AddExpr '+' MulExpr { $$ = alcTreeThreeKids($1, kido('+'), $3, 1099); }| AddExpr '-' MulExpr { $$ = alcTreeThreeKids($1, kido(SUBSUB), $3, 1101); };
RelOp: LESSEQUAL { $$ = alcTreeOneKids($1, 1102); }| GREATEREQUAL { $$ = alcTreeOneKids($1, 1103); }| '<' { $$ = alcTreeOneKids(kido(LESS), 1104); }| '>' { $$ = alcTreeOneKids(kido(GREATER), 1105); /* TODO this too*/};
RelExpr: AddExpr { $$ = alcTreeOneKids($1, 1106); }| RelExpr RelOp AddExpr { $$ = alcTreeThreeKids($1, $2, $3, 1107); };

EqExpr: RelExpr { $$ = alcTreeOneKids($1, 1108); }| EqExpr EQUALEQUAL RelExpr { $$ = alcTreeThreeKids($1, $2, $3, 1109); }| EqExpr NOTEQUAL RelExpr { $$ = alcTreeThreeKids($1, $2, $3, 1110); };
CondAndExpr: EqExpr { $$ = alcTreeOneKids($1, 1111); }| CondAndExpr ANDAND EqExpr { $$ = alcTreeThreeKids($1, $2, $3, 1112); };
CondOrExpr: CondAndExpr { $$ = alcTreeOneKids($1, 1113); }| CondOrExpr OROR CondAndExpr { $$ = alcTreeThreeKids($1, $2, $3, 1114); };

Expr: CondOrExpr { $$ = alcTreeOneKids($1, 1115); }| Assignment { $$ = alcTreeOneKids($1, 1116);} | ArrayInit { $$ = alcTreeOneKids($1, 1117);} | InstncExpr {$$ = alcTreeOneKids($1, 1118);} | Cast {$$ = alcTreeOneKids($1, 1119);};
Assignment: LeftHandSide AssignOp Expr {printf("\nbingo\n\n"); $$ = alcTreeThreeKids($1, $2, $3, 1120); };
LeftHandSide: Name {printf("\nhody\n\n"); $$ = alcTreeOneKids($1, 1121); } | Type Name {$$ = alcTreeTwoKids($1, $2, 1122); } | FieldAccess { $$ = alcTreeOneKids($1, 1123); };
AssignOp: '=' { printf("\ntodo\n\n"); $$ = alcTreeOneKids(kido(EQUAL), 1124); }| ADDADD { $$ = alcTreeOneKids($1, 1125); }| SUBSUB { $$ = alcTreeOneKids($1, 1126);}| MULMUL { $$ = alcTreeOneKids($1, 1127);}| DIVDIV { $$ = alcTreeOneKids($1, 1128);}| MODMOD { $$ = alcTreeOneKids($1, 1129); };

SpecialName: Name INCREMENT {$$ = alcTreeTwoKids($1, $2, 1130); } | Name DECREMENT {$$ = alcTreeTwoKids($1, $2, 1131); } | Name OPENCLOSE {$$ = alcTreeTwoKids($1, $2, 1132); } | Name '[' Expr ']' {$$ = alcTreeTwoKids($1, $3, 1133); };

SwitchBlock: SWITCH '(' Name ')' '{' CaseBlock '}' {  $$ =  alcTreeThreeKids($1, $3, $6, 1134); };
CaseBlock: CaseList Stmt BREAK ';' {$$ = alcTreeThreeKids($1, $2, $3, 1135);} | CaseBlock CaseList Stmt BREAK ';' {$$ = alcTreeFourKids($1, $2, $3, $4, 1136);} | CaseBlock DEFAULT ':' Stmt {$$ = alcTreeOneKids($1, 1137);} ;
CaseList: CaseHead {$$ = alcTreeOneKids($1, 1138); } | CaseList CaseHead {$$ = alcTreeTwoKids($1, $2, 1139); };
CaseHead: CASE NumBase ':' {$$ = alcTreeTwoKids($1, $2, 1140); };

ArrayDec: ArrayLeft ArrayRight { $$ = alcTreeTwoKids($1, $2, 1141); };
ArrayLeft: Type OPENCLOSE Name {$$ = alcTreeThreeKids($1, $2, $3, 1142); };
ArrayRight:  '=' NEW Type '[' NumBase ']' ';' {  $$ =  alcTreeThreeKids($2, $3, $5, 1143); } |'=' '{' LiteralList '}' ';' { $$ = alcTreeOneKids($3, 1144); } | ';' {$$ = NULL;};
LiteralList: Literal ',' { $$ = alcTreeOneKids($1, 1145); } | Literal { $$ = alcTreeOneKids($1, 1146); } | LiteralList Literal {$$ = alcTreeTwoKids($1, $2, 1147); } | LiteralList Literal ',' {$$ = alcTreeTwoKids($1, $2, 1148); } | {$$ = NULL;};
ArrayInit: NEW Type '[' NumBase ']' {  $$ =  alcTreeThreeKids($1, $2, $4, 1149); };

InstncExpr: Name INSTANCEOF Name {$$ =  alcTreeThreeKids($1, $2, $3, 1150);};
Cast: CAST Name { $$ = alcTreeTwoKids($1, $2, 1151); };
NumBase: LINT { $$ = alcTreeOneKids($1, 1152); } | HEX { $$ = alcTreeOneKids($1, 1153); } | OCT { $$ = alcTreeOneKids($1, 1154); };
