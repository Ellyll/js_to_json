require 'rkelly'
require 'json'
require 'open-uri'

# Add a deep (i.e. recursive) merge to the Hash class class Hash
class Hash
  # Merges self with another hash, recursively.
  # From: http://dzone.com/snippets/hashdeepmerge 

  def deep_merge(hash)
    target = dup
    
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      
      target[key] = hash[key]
    end
    
    target
  end
end

def get_var_values(node)
  case node
    when RKelly::Nodes::StringNode
      node.value
    when RKelly::Nodes::NumberNode
      node.value
    when RKelly::Nodes::FalseNode
      node.value
    when RKelly::Nodes::TrueNode
      node.value
    when RKelly::Nodes::ArrayNode
      values = node.value.map { |element| get_var_values(element.value) }
      "[ #{values.join(', ')} ]"
    when RKelly::Nodes::ObjectLiteralNode
      values = node.value.map { |property| "\"#{property.name.gsub(/^"/, '').gsub(/"$/, '')}\": #{get_var_values(property.value)}" }
      "{ #{values.join(', ')} }"
    when RKelly::Nodes::FunctionExprNode
      "null"
    when RKelly::Nodes::NullNode
      "null"
    when RKelly::Nodes::DotAccessorNode
      "null"
    else
      raise "Unknown node type #{node.class}"
  end
end

def get_var_data(node)
  case node
    when RKelly::Nodes::VarStatementNode
      name = node.value.first.name
      value = get_var_values(node.value.first.value.value)
      json = "{ \"#{name}\": #{value} }"
      JSON::parse(json)
    when RKelly::Nodes::ExpressionStatementNode
      # name2.name1 = value; -> { "name2": { "name1": value } }
      name1 = node.value.left.accessor
      name2 = node.value.left.value.value
      value = get_var_values(node.value.value)
      json = "{ \"#{name2}\": { \"#{name1}\": #{value} } }"
      JSON::parse(json)
    else
      raise "Unknown node type #{node.class}"
  end
end



# Load the javascript from website/file
javascript = open('https://raw.githubusercontent.com/tinyspeck/glitch-GameServerJS/master/items/cheese_very_very_stinky.js').read

# Parse the javascript to build an Abstract Syntax Tree
parser = RKelly::Parser.new
ast    = parser.parse javascript


# Select only nodes that are var or =, e.g. var moo = "boo" or pie = true
nodes = ast.value.select do |node|
  node.is_a?(RKelly::Nodes::VarStatementNode) or
  ( node.is_a?(RKelly::Nodes::ExpressionStatementNode) and node.value.is_a?(RKelly::Nodes::OpEqualNode) )
end

# Turn each node into a ruby hash
values = nodes.map { |node| get_var_data(node) }

# Merge the hashes into a single one
merged = values.reduce({}) { |memo, value| memo.deep_merge(value) }
#values.each {|value| value.each { |k,v| puts "#{k}=#{v} #{v.class}" } }

# Output the meged hash as JSON
puts JSON::generate(merged)
