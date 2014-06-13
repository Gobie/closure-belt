module.exports = do ->
  regex = /([.*+?^=!:${}()|\[\]\/\\])/g
  (str) ->
    (str + "").replace regex, "\\$1"