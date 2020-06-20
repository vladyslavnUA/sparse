code = <<-CODE
if 1:
    print "..."
    if false:
        pass
    print "done!"
print "Program End"
CODE
tokens = [
    [:IF, "if"], [:NUMBER, 1],
    [:INDENT, 2],
        [:INDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
        [:IF, "if"], [:FALSE, "false"],
        [:INDENT, 4],
            [:INDENTIFIER, "pass"],
        [:DEDENT, 2], [:NEWLINE, "\n"],
        [:INDENTIFIER, "print"],
        [:STRING, "done!"],
    [:DEDENT, 0], [:NEWLINE, "\n"],
    [:INDENTIFIER, "print"], [:STRING, "Program End"]
]
assert_equal tokens, Lexer.new.tokenize(code)