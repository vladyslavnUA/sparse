class Lexer
    KEYWORDS = ["def", "class", "if", "true", "false", "nil"]

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