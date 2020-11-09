#!/bin/bash

if [ -z "$CLASQA" ]; then
  echo "ERROR: please source env.sh first"
  exit
fi

if [ $# -ne 1 ];then echo "USAGE: $0 [dataset]"; exit; fi
dataset=$1


runL=$(grep $dataset datasetList.txt | awk '{print $2}')
runH=$(grep $dataset datasetList.txt | awk '{print $3}')
datadir=$(grep $dataset datasetList.txt | awk '{print $4}')
if [ -z "$datadir" ]; then
  echo "ERROR: dataset not foundin datasetList.txt"
  exit
fi

# build list of files, and cleanup outdat and outmon directories
joblist=joblist.${dataset}.slurm
> $joblist
for rundir in `ls -d ${datadir}/*/ | sed 's/\/$//'`; do
  run=$(echo $rundir | sed 's/^.*\/0*//g')
  if [ $run -ge $runL -a $run -le $runH ]; then
    echo "--- found dir=$rundir  run=$run"
    echo "run-groovy $CLASQA_JAVA_OPTS monitorRead.groovy $rundir dst" >> $joblist
    rm -v outdat/*${run}.dat
    rm -v outmon/*${run}.hipo
  fi
done


# write job descriptor
slurm=job.${dataset}.slurm
> $slurm

function app { echo "$1" >> $slurm; }

app "#!/bin/bash"

app "#SBATCH --job-name=clasqa"
app "#SBATCH --account=clas12"
app "#SBATCH --partition=production"

app "#SBATCH --mem-per-cpu=2000"
app "#SBATCH --time=12:00:00"

app "#SBATCH --array=1-$(cat $joblist | wc -l)"
app "#SBATCH --ntasks=1"

app "#SBATCH --output=/farm_out/%u/%x-%j-%N.out"
app "#SBATCH --error=/farm_out/%u/%x-%j-%N.err"

app "srun \$(head -n\$SLURM_ARRAY_TASK_ID $joblist | tail -n1)"


# launch jobs
printf '%70s\n' | tr ' ' -
echo "JOB LIST: $joblist"
cat $joblist
printf '%70s\n' | tr ' ' -
echo "JOB DESCRIPTOR: $slurm"
cat $slurm
printf '%70s\n' | tr ' ' -
echo "submitting to slurm..."
sbatch $slurm
squeue -u `whoami`