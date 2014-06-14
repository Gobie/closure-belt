traverse = (node, func) ->
  if node instanceof Array
    for value, i in node
      unless func.apply this, [i, value, node]
        traverse value, func
  else if node instanceof Object
    for i, value of node
      unless func.apply this, [i, value, node]
        traverse value, func

module.exports = traverse