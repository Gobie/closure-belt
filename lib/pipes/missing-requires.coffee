module.exports = ->
  (data, cb) ->
    filterOut = (namespace) ->
      data['provides'][namespace] or data['requires'][namespace]

    data['missing'] = {}
    for namespace, coords of data['namespaces']
      namespaceParts = namespace.split '.'
      continue if namespaceParts.length is 2 and namespaceParts[0] is 'goog'
      continue if namespaceParts[0] is 'goog' and namespaceParts[1] is 'global'
      data['missing'][namespace] = coords unless createNamespaces(namespaceParts).some filterOut

    cb null, data

createNamespaces = (parts) ->
  namespaces = []
  parts.map (part) ->
    namespaces.push part
    namespaces.join '.'