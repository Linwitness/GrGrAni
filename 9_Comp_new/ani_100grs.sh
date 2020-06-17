#!/bin/sh

#SBATCH --job-name=newC++
#SBATCH --nodes=8                   #Number of nodes (servers, 32 proc/node)
#SBATCH --ntasks=128                  #How many parallel jobs to run
#SBATCH --ntasks-per-node=16         #How many parallel jobs in one node
#SBATCH --ntasks-per-socket=8       #Tasks per node
#SBATCH --cpus-per-task=1           #32/ntasks-per-node
#SBATCH --mem-per-cpu=2gb         #Memory (120GB/node) 120/cpus-per-task/ntasks-per-node
#SBATCH --time=72:00:00             #Walltime hh:mm:ss
#SBATCH --distribution=cyclic:cyclic #not actually sure
#SBATCH --constraint=infiniband       #Connect between tasks
#SBATCH --output=new-%j.out          #Console output file name
#SBATCH --mail-type=END             #When to email user: NONE,BEGIN,END,FAIL,REQUEUE,ALL
#SBATCH --mail-user=lin.yang@ufl.edu #Email address to send mail to
##SBATCH --qos=michael.tonks        #Allocation group name, add -b for burst job
##SBATCH --array=1-200%10                 #Used to submit multiple jobs with one submit

Grain=/home/lin.yang/projects/gb_ani
Group=/ufrc/michael.tonks/lin.yang
OUTPUT=/ufrc/michael.tonks/lin.yang/output         #desired output file path

echo "Date              = $(date)"
echo "Hostname          = $(hostname -s)"
echo "Working Directory = $(pwd)"
echo ""
echo "Number of Nodes Allocated      = $SLURM_JOB_NUM_NODES"
echo "Number of Tasks Allocated      = $SLURM_NTASKS"
echo "Number of Cores/Task Allocated = $SLURM_CPUS_PER_TASK"               

cd $OUTPUT
srun --mpi=pmix_v2 $Grain/gb_ani-opt -i $Group/9_Comp_new/AniL_14ops.i 
