code = <<-CODE
process method(a, b):
  true
CODE

nodes = Nodes.new([
    ProcessNode.new("method", ["a", "b"],
        Nodes.new([TrueNode.new])
    )
])

assert_equal nodes, Parser.new.parse(code)