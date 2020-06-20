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
    | Expression '>' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '>=' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '<' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '<=' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '+' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '-' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '*' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    | Expression '/' Expression { result = CallNode.new(val[0], val[1], [val[2]]) }
    ;


    Constant:
      CONSTANT              { result = GetConstantNode.new(val[0]) }
    ;


    # Assignment to variable or constant
    Assign:
      IDENTIFIER "=" Expression     { result = SetLocalNode.new(val[0], val[2]) }
    | CONSTANT "=" Expression       { result = SetConstantNode.new(val[0], val[2]) }
    ;


    # method definition
    Process:
      PROCESS IDENTIFIER Block      { result = ProcessNode.new(val[1], [], val[2]) }
    | PROCESS IDENTIFIER
        "(" ParamList ")" Block     { result = ProcessNode.new(val[1], val[3], val[5]) }
    ;


    ParamList:
      /* nothing */                 { result = [] }
    | IDENTIFIER                    { result = val }
    | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
    ;


    # Class definition
    Class:
      CLASS CONSTANT Block          { result = ClassNode.new(val[1], val[2]) }
    ;


    # if Block
    If:
      IF Expression Block           { result = IfNode.new(val[1], val[2]) }
    ;


    # A block of indented code. Work done by lexer.
    Block:
      INDENT Expressions DEDENT     { result = val[1] }
    # If you don't like indentation you could replace the previous rule with the
    # following one to separate blocks w/ curly brackets. You'll also need to remove the
    # indentation magic section in the lexer.
    # "{" Expressions "}"       { replace = val[1] }
    ;
end


---- header
  require "lexer"
  require "nodes"

---- inner

  # code will be put as is in the Parser class
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code)
    puts @tokens.inspect if show_tokens
    do_parse    # parsing process
  end


  def next_token
    @tokens.shift
  end