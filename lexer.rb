# Lexer - a tokenizer, the part of Sparse that converts the input, 
# into tokens for the parser.

class Lexer
    KEYWORDS = ["def", "class", "if", "true", "false", "nil", "while"]

    # create a token for each element
    def tokenize(code):
        code.chomp!     # removing extra line breaks

        # current index
        i = 0

        tokens = []

        # starting variable
        current_indent = 0
        indent_stack = []

        # scanner implementation
        while i < code.size:
            chunk = code[i..-1]

            # matching standard tokens
            if identifier = chunk[/\A([a-z]\w*)/, 1]
                # keywords will be identifiers to the tokens they're assigned to
                if KEYWORDS.include?(identifier)
                    tokens << [identifier.upcase.to_sym, identifier]    # creating a token according to identifier
                # variable names
                else 
                    tokens << [:IDENTIFIER, identifier]
                end

                i += identifiers.size

            # class names and consts with capital letter
            elsif constant = chunk[/\A([A-Z]\w*)/, 1]
                tokens << [:CONSTANT, constant]
                i += constant.size
            
            # account for numbers
            elsif number = chunk[/\A([0-9]+)/, 1]
                tokens << [:NUMBER, number.to_i]
                i += number.size

            # account for strings
            elsif string = chunk[/\A"(.*?)"/, 1]
                tokens << [:STRING, string]
                i += string.size + 2

        #######################################
            # Indentation Concept
            
            # if true: the block is created
            #     line 1
            #     line 2 ne indented line
            # continue dedent
        #######################################
        
        elsif indent = chunk[/\A\:\n( +)/m, 1]  # Matches: "<newline> <spaces>"
            # error case, trace indentation level
            if indent.size <= current_indent
                raise "Bad indent level. Program has #{indent.size} indents. " +
                "expected > #{current_indent}"
            end

            current_indent = indent.size
            indent_stack.push(current_indent)
            tokens << [:INDENT, indent.size]
            i += indent.size + 2
        
        # Case: code is in the same block if the indent level is the same as current_indent
        # Case: if indent level is lower than current_indent. close the block
        elsif indent = chunk[/\A\n( *)/m, 1]
            if indent.size == current_indent
                tokens << [:NEWLINE, "\n"]
        elsif indent.size < current_indent
            while indent.size < current_indent
                indent_stack.pop
                current_indent = indent_stack.first || 0
                tokens << [:DEDENT, indent.size]
            end
            tokens << [:NEWLINE, "\n"]
        else
            raise "Missing ':' indentation"
        end
        i += indent.size + 1

        # Dealing with operators: ||, &&, ==, !=. <= and >=
        elsif operator = chunk[/\A(\|\||&&|==|!=|<=|>=)/, 1]
            tokens << [operator, operator]
            i += operator.size
        
        # whitespace
        elsif chunk.match(/\A /)
            i += 1

            # single characters: ( ) , . ! + - < > =
            else
                value = chunk[0,1]
                tokens << [value, value]
                i += 1
            end
        end

        # close open blocks
        while indent = indent_stack.pop
            tokens << [:DEDENT, indent_stack.first || 0]
        end

        tokens
    end
end