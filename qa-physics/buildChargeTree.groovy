import groovy.json.JsonSlurper
import groovy.json.JsonOutput
import Tools
Tools T = new Tools()

//----------------------------------------------------------------------------------
// ARGUMENTS:
def dataset = 'rga_inbending'
if(args.length>=1) dataset = args[0]
//----------------------------------------------------------------------------------

def tok
int r=0
def runnum, filenum, eventNumMin, eventNumMax, sector
def nElec, nElecFT
def fcStart, fcStop
def ufcStart, ufcStop
def livetime
def fcCharge
def ufcCharge
def chargeTree = [:] // [runnum][filenum] -> charge

// open data_table.dat
def dataFile = new File("outdat.${dataset}/data_table.dat")
if(!(dataFile.exists())) throw new Exception("data_table.dat not found")
dataFile.eachLine { line ->

  // tokenize
  tok = line.tokenize(' ')
  r=0
  runnum = tok[r++].toInteger()
  filenum = tok[r++].toInteger()
  eventNumMin = tok[r++].toInteger()
  eventNumMax = tok[r++].toInteger()
  sector = tok[r++].toInteger()
  nElec = tok[r++].toBigDecimal()
  nElecFT = tok[r++].toBigDecimal()
  fcStart = tok[r++].toBigDecimal()
  fcStop = tok[r++].toBigDecimal()
  ufcStart = tok[r++].toBigDecimal()
  ufcStop = tok[r++].toBigDecimal()
  livetime = tok.size()>11 ? tok[r++].toBigDecimal() : -1
  
  // fill tree
  if(sector==1) {
    println "add $runnum $filenum"
    T.addLeaf(chargeTree,[runnum,filenum],
      {[
        'fcChargeMin':fcStart,
        'fcChargeMax':fcStop,
        'ufcChargeMin':ufcStart,
        'ufcChargeMax':ufcStop,
        'livetime':livetime
      ]}
    )
  }
  T.addLeaf(chargeTree,[runnum,filenum,'nElec',sector],{nElec})
}

chargeTree.each { chargeRun, chargeRunTree -> chargeRunTree.sort{it.key.toInteger()} }
chargeTree.sort()
new File("outdat.${dataset}/chargeTree.json").write(JsonOutput.toJson(chargeTree))
