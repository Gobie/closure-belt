regex = /([.*+?^=!:${}()|\[\]\/\\])/g

module.exports = (str) ->
  (str + "").replace regex, "\\$1"