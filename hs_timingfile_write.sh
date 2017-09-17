#!/bin/bash

#extracts stimulus type order and saves to a .txt file for later use
while IFS= read -r line; do
    if [[ $line =~ StimType ]]; then
        echo "$line" >>stimtypetest.txt
    fi
done <eprime.txt

#creates a .txt file containing the initial fixation duration
echo "16000" >>durationextracttest.txt

#extracts stimulus and fixation durations after initial fixation
while IFS= read -r line; do
    if [[ $line =~ VidBlock.Duration\: ]] || [[ $line =~ FixationBlock.Duration\: ]]; then
        echo "$line" >>durationextracttest.txt
    fi
done <eprime.txt

#calculates onset and duration for conditions and creates a file containing the appropriate columns required by FSL
onset=0

while IFS= read -r line; do
    if [[ $line =~ 16000 ]]; then
	echo "$onset	16	1" >>allcolumntest.txt
	onset=$(($onset + 16))
    elif [[ $line =~ 15000 ]]; then
	echo "$onset	15	1" >>allcolumntest.txt
	onset=$(($onset + 15))
    elif [[ $line =~ 17000 ]]; then
	echo "$onset	17	1" >>allcolumntest.txt
	onset=$(($onset + 17))
    fi
done <durationextracttest.txt

#separates the fixation and stimulus conditions and sends them to separate txt files based on whether the lines are odd or even
awk 'NR % 2 == 0' allcolumntest.txt >>stimtimingtest.txt
awk 'NR % 2 == 1' allcolumntest.txt >>fixationtimingtest.txt

#separates the different types of stimuli and sends them to different .txt files based on whether the lines are odd or even, with the determination of the particular stimulus being the result of the first line of the previously created stimulus type .txt
line=$(head -1 stimtypetest.txt)
    if [[ $line =~ Nonsocial ]]; then
	awk 'NR % 2 == 0' stimtimingtest.txt >>socialtimingtest.txt
	awk 'NR % 2 == 1' stimtimingtest.txt >>nonsocialtimingtest.txt
    elif [[ $line =~ Social ]]; then
	awk 'NR % 2 == 1' stimtimingtest.txt >>socialtimingtest.txt
	awk 'NR % 2 == 0' stimtimingtest.txt >>nonsocialtimingtest.txt
    fi

#cleans up unnecessary .txt files so that only the needed timing files and original eprime.txt are remaining
rm stimtypetest.txt durationextracttest.txt allcolumntest.txt stimtimingtest.txt
