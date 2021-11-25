%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	struct node
	{
		struct node* left;
		struct node* right;
		char* token;
	};
	struct node* mknode(struct node* left,struct node* right,char* token);
	void printtree(struct node* tree);
	#define YYSTYPE struct node*
	extern FILE *yyin, *yyout;
%}

%token IDENTIFIER NUM HEADER REAL CHARVALUE
%token CHAR INT FLOAT DOUBLE VOID
%token IF ELSE SWITCH BREAK WHILE CASE DEFAULT RETURN
%left ADD SUB MUL DIV INC DEC
%right EQ LE GE AND OR XOR ASSIGN L G NEQ
%token SEMICOLON COMMA
%token OP CP OB CB

%start program

%%
program
	: header body {printf("Input accepted\n");exit(0);}
	| body
	;
header
	: HEADER
	| header HEADER
	;
body
	: declarations functions
	| functions
	;
returnstatement
	: RETURN expressions SEMICOLON
	| {;}
	;
declarations
	: type assignmentlist SEMICOLON
	;
assignmentlist
	: variable ASSIGN number
	| variable COMMA assignmentlist
	| variable
	;
number
	: NUM
	| REAL
	| CHARVALUE
	;
type
	: INT
	| CHAR
	| FLOAT
	| DOUBLE
	| VOID
	;
functions
	: functions function
	| {;}
	;
function
	: type IDENTIFIER OP argumentlist CP OB statements returnstatement CB
	;
variable
	: IDENTIFIER
	;
argument
	: type variable
	;
argumentlist
	: argument
	| argumentlist COMMA argument
	| {;}
	;
id
	: IDENTIFIER
	;
statements
	: id ASSIGN expressions SEMICOLON {printtree($3);fprintf(yyout,"\n");}
	| type variable ASSIGN expressions SEMICOLON {printtree($4);fprintf(yyout,"\n");}
	| ifstatements
	| switchstatements
	| whilestatements
	| statements statements
	;
ifstatements
	: IF OP conditionalexpressions CP OB statements CB ELSE OB statements CB
	;
switchstatements
	: SWITCH OP id CP OB casestatements CB
	;
whilestatements
	: WHILE OP conditionalexpressions CP OB statements CB
	;
casestatements
	: CASE NUM ':' statements BREAK SEMICOLON casestatements
	| DEFAULT ':' statements BREAK SEMICOLON
	| {;}
	;
expressions
	: conditionalexpressions {$$=$1;}
	| expressions ADD expressions {$$=mknode($1,$3,"+");}
	| expressions SUB expressions	{$$=mknode($1,$3,"-");}
	| expressions MUL expressions {$$=mknode($1,$3,"*");}
	| expressions DIV expressions {$$=mknode($1,$3,"/");}
	| expressions XOR expressions {$$=mknode($1,$3,"^");}
	| IDENTIFIER {$$=mknode(0,0,(char*)yylval);}
	| NUM {$$=mknode(0,0,(char*)yylval);}
	| OP expressions CP {$$=$2;}
	| INC IDENTIFIER {$$=mknode($2,0,"++");}
	| DEC IDENTIFIER {$$=mknode($2,0,"--");}
	| REAL {$$=mknode(0,0,(char*)yylval);}
	| CHARVALUE {$$=mknode(0,0,(char*)yylval);}
	;
conditionalexpressions
	: expressions AND expressions {$$=mknode($1,$3,"AND");}
	| expressions OR expressions {$$=mknode($1,$3,"OR");}
	| expressions LE expressions {$$=mknode($1,$3,"LE");}
	| expressions L expressions {$$=mknode($1,$3,"L");}
	| expressions G expressions {$$=mknode($1,$3,"G");}
	| expressions NEQ expressions {$$=mknode($1,$3,"NEQ");}
	| expressions GE expressions  {$$=mknode($1,$3,"GE");}
	| expressions EQ expressions {$$=mknode($1,$3,"EQ");}
	| OP conditionalexpressions CP {$$=$2;}
	;
%%

struct node* mknode(struct node* left,struct node* right,char* token)
{
	struct node* new=(struct node*)malloc(sizeof(struct node));
	char* newstr=(char*)malloc(strlen(token)+1);
	strcpy(newstr,token);
	new->left=left;
	new->right=right;
	new->token=newstr;
	return new;
}

void printtree(struct node* tree)
{
	if(tree->left||tree->right)
		fprintf(yyout,"(");
	fprintf(yyout," %s ",tree->token);
	if(tree->left)
		printtree(tree->left);
	if(tree->right)
		printtree(tree->right);
	if(tree->left||tree->right)
		fprintf(yyout,")");
}

int main()
{
	yyin  = fopen("input.c","r");
	yyout = fopen("output.txt","w");
	fprintf(yyout,"Abstract Syntax Tree\n");
	yyparse();
	fclose(yyout);
	fclose(yyin);
	return 0;
}

void yyerror(char* s)
{
	extern int yylineno;
    fprintf(yyout,"\nError (line %d) : %s\n",yylineno,s);
}
