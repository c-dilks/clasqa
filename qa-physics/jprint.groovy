if(args.size()==0) {
  println("\n\nARGUMENTS: jsonfile [tree-path]")
  println("""
  pretty prints a json file
  - if it is a nested map (tree), specify additional arguments
    to restrict printout to a specific sub-tree
  """)
  return
}

import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import Tools
Tools T = new Tools()

def slurper = new JsonSlurper()
def jsonFile = new File(args[0])
def jsonObj = slurper.parse(jsonFile)

def accessPath = []
args.length.times { if(it>=1) accessPath << args[it] }
println("\n\n$accessPath\n\n")
println JsonOutput.prettyPrint(
  JsonOutput.toJson(
    T.jAccess(jsonObj,accessPath)
  )
)
