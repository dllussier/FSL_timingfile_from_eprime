##!/bin/bash

#initial input for this is an eprime generated .txt file which has been renamed to eprime.txt
#may be run in same file as eprime.txt as is
#to run multiple subjects in loop, uncomment section indicated below titled "for loop"

echo "this script is intended to create 3 column timing files in the format required by fsl for feat fmri analysis"
echo "for use when paradigm is in "fixation, condition A, fixation, condition B..." format"
echo "written by Desiree Lussier"
echo "https://github.com/dllussier/"

#indicate the name of the stimulus conditions as specified by eprime in the lines that read "StimType" using exact spelling, including any numbers and capitalization
#condition_A=
#condition_B=

#for loop, uncomment section below down to "cd $i/$directory" line and at the bottom of the script that is indicated. then edit to incude subject list and directory where individual subject eprime.txt may be found
#subject_list=
#directory=
#for i in $subject_list
#do

#cd $i/$directory

#extracts stimulus types from original eprime text file and writes to a new file "stimtype"
while IFS= read -r line; do
    if [[ $line =~ StimType ]]; then
        echo "$line" >>stimtype.txt
    fi
done <eprime.txt

echo "16000" >>durationextract.txt

#extracts stimulus and fixation durations in milliseconds from original eprime text file and writes to a new file "durationextract"
while IFS= read -r line; do
    if [[ $line =~ VidBlock.Duration\: ]] || [[ $line =~ FixationBlock.Duration\: ]]; then
        echo "$line" >>durationextract.txt
    fi
done <eprime.txt

#converts stimulus duration times from durationextract.txt from milliseconds to seconds, computes onsets based on previous stimuli durations, creates timing columns, and writes the information to a new file "allcolumn"
onset=0

while IFS= read -r line; do
    if [[ $line =~ 16000 ]]; then
	echo "$onset	16	1" >>allcolumn.txt
	onset=$(($onset + 16))
    elif [[ $line =~ 15000 ]]; then
	echo "$onset	15	1" >>allcolumn.txt
	onset=$(($onset + 15))
    elif [[ $line =~ 17000 ]]; then
	echo "$onset	17	1" >>allcolumn.txt
	onset=$(($onset + 17))
    fi
done <durationextract.txt

#creates separate files for stimuli and fixation, assuming that the first and all odd presentations are fixation and even presentations are stimuli
awk 'NR % 2 == 0' allcolumn.txt >>stimtiming.txt
awk 'NR % 2 == 1' allcolumn.txt >>fixationtiming.txt

#creates separate timing files for stimuli types, searching first in stimtype.txt to determine counterbalance and write timing files accordingly
line=$(head -1 stimtype.txt)
    if [[ $line =~ Nonsocial ]]; then
	awk 'NR % 2 == 0' stimtiming.txt >>socialtiming.txt
	awk 'NR % 2 == 1' stimtiming.txt >>nonsocialtiming.txt
    elif [[ $line =~ Social ]]; then
	awk 'NR % 2 == 1' stimtiming.txt >>socialtiming.txt
	awk 'NR % 2 == 0' stimtiming.txt >>nonsocialtiming.txt
    fi

#deletes unnecessary files
rm stimtype.txt durationextract.txt allcolumn.txt stimtiming.txt

#uncomment next two lines for use with for loop above and then comment out last line
#echo "fixation and stimulus timing file creation complete for " $i
#done

echo "fixation and stimulus timing file creation complete"
