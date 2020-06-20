class Parser

# Declare tokens produced by the lexer
token IF ELSE
token PROCESS
token CLASS
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT


# Precence table
# Based on http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
prechigh
    left '.'
    right '!'
    left '*' '/'
    left '+' '-'
    left '>' '>=' '<' '<='
    left '==' '!='
    left '&&'
    right '='
    left ','
preclow

rule
    # All rules declared in format:

    #   RuleName:
    #       OtherRule TOKEN AnotherRule { code to run when this matches }
    #    |  OtherRule     { ... }
    #    ;
    #  - "Result" will be the value returned by the rule
    #  - Use val[index of expression] to reference expressions on left


    # Parsing Rule, AST (Abstract Syntax Tree)
    Root:
    /* nothing */                   { result = Nodes.new([]) }
    | Expressions                   { result = val[0] }
    ;


    # Any list of expressions, class, or method body, seperated by line breaks
    Expressions:
        Expression                      { result = Nodes.new(val) }
    | Expressions Terminator Expression     { result =  val[0] << val[2] }
        # line breaks
    | Expressions Terminator            { result = val[0] }
    | Terminator                        { result = Nodes.new([]) }
    ;


    # Sparse Expressions
    Expression:
      Literal
    | Call
    | Operator
    | Constant
    | Assign
    | Process
    | Class
    | If
    | '(' Expression ')'    { result = val[1] }


    # Tokens that will terminate expression, NEWLINE
    Terminator:
      NEWLINE
    | ';'
    ;


    # Hard-coded values
    Literal:
      NUMBER                { result = NumberNode.new(val[0]) }
    | STRING                { result = StringNode.new(val[0]) }
    | TRUE                  { result = TrueNode.new }
    | FALSE                 { result = FalseNode.new }
    | NIL                   { result = NilNode.new }


    # A method call, "process"
    Call:
      # method
      IDENTIFIER                    { result = CallNode.new(nil, val[0], []) }
      # method(args) *args=arguments
    | IDENTIFIER "(" ArgList ")"    { result = CallNode.new(nil, val[0], val[2]) }
      # receiver.method
    | Expression "." IDENTIFIER     { result = CallNode.new(val[0], val[2], []) }
      # receiver.method(args)
    | Expression "."
        IDENTIFIER "(" ArgList ")"  { result = CallNode.new(val[0], val[2], val[4]) }
    ;

    ArgList:
      /* nothing */             { result = [] }
    | Expressions               { result = val }
    | ArgList "." Expression    { result = val[0] << val[2] }

    Operator:
    # Binary operators
      Expression '||' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '&&' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '==' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '!=' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }