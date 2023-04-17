# QA Timeline Production Flowchart

## Legend
```mermaid
graph LR
    data{{Data}}:::data
    timeline{{Timeline<br/>HIPO files}}:::timeline
    exeSlurm[Script automated<br/>by exeSlurm.sh]:::exeSlurm
    exeTimeline[Script automated<br/>by exeTimelines.sh]:::exeTimeline
    exeQA[Script automated<br/>by exeQAtimelines.sh]:::exeQA
    manual[Manual step,<br/>not automated]:::manual

    classDef data fill:#ff8,color:black
    classDef exeSlurm fill:#8f8,color:black
    classDef exeTimeline fill:#bff,color:black
    classDef manual fill:#fbb,color:black
    classDef timeline fill:#8af,color:black
    classDef exeQA fill:#f8f,color:black
```

## Automatic QA Procedure

```mermaid
graph TD
    dst{{DSTs}}:::data --> monitorRead[monitorRead.groovy]:::exeSlurm
    monitorRead --> monitorReadOut{{outdat/data_table_$run.dat<br>outmon/monitor_$run.hipo}}:::data
    monitorReadOut --> do[datasetOrganize.sh]:::exeTimeline
    do --> dm{{outmon.$dataset/monitor_$run.hipo}}:::data
    do --> dt{{outdat.$dataset/data_table.dat}}:::data
    
    dm --> monitorPlot[monitorPlot.groovy]:::exeTimeline
    monitorPlot --> tl{{outmon.$dataset/$timeline.hipo}}:::timeline
    
    dt --> qaPlot[qaPlot.groovy]:::exeTimeline
    dt --> man[create/edit<br>epochs.$dataset.txt<br>see mkTree.sh]:::manual
    qaPlot --> monitorElec{{outmon.$dataset/monitorElec.hipo}}:::data
    monitorElec --> qaCut[qaCut.groovy]:::exeTimeline
    man --> qaCut
    qaCut --> tl
    qaCut --> qaTree{{outdat.$dataset/qaTree.json}}:::data
    qaTree --> cd[QA subdirectory]
    dt --> buildCT[buildChargeTree.groovy]:::exeTimeline
    buildCT --> chargeTree{{outdat.$dataset/chargeTree.json}}:::data
    
    tl --> deploy[deployTimelines.sh]:::exeTimeline
    
    classDef data fill:#ff8,color:black
    classDef exeSlurm fill:#8f8,color:black
    classDef exeTimeline fill:#bff,color:black
    classDef manual fill:#fbb,color:black
    classDef timeline fill:#8af,color:black
    classDef exeQA fill:#f8f,color:black
```

# Manual QA
### Note: `cd` to the `QA` subdirectory
- all scripts are run manually here (except `parseQAtree.groovy`, which runs automatically)

```mermaid
graph TD
   cd0[cd QA]:::manual-->qaTree
   qaTree{{../outdat.$dataset/qaTree.json}}:::data --> import[import.sh]:::exeQA
    import --> qaLoc{{qa/ -> qa.$dataset/<br>qa/qaTree.json}}:::data
    qaLoc --> parse[parseQAtree.groovy<br>called automatically<br>whenever needed]:::exeQA
    parse --> qaTable{{qa/qaTable.dat}}:::data
    
    qaLoc --> inspect[manual inspection<br>- view qaTable.dat<br>- view online monitor]:::manual
    inspect --> edit{edit?}
    
    edit -->|yes|modify[modify.sh]:::exeQA
    modify --> qaLoc
    modify --> qaBak{{qa.$dataset/qaTree.json.*.bak}}:::data
    qaBak --> undo[if needed, revert<br>modification with<br>undo.sh]:::exeQA
    
    edit -->|no|cd[cd ..]:::exeQA
    cd --> qa[exeQAtimelines.sh]:::exeQA
    qaLoc --> qa
    qa --> qaTL{{outmon.$dataset.qa/$timeline.hipo}}:::timeline
    qa -->|updates|qaTree
    qaTL --> deploy[deployTimelines.sh]:::exeQA
    deploy --> release[releaseTimelines.sh]:::exeQA
    qaTree --> release
    
    classDef data fill:#ff8,color:black
    classDef manual fill:#fbb,color:black
    classDef timeline fill:#8af,color:black
    classDef exeQA fill:#f8f,color:black
```
