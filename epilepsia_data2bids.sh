#!/bin/bash
source `which my_do_cmd`
fakeflag=""

origloc=/misc/ernst/rcruces/database/BIDS_epilepsia
bidsdir=/misc/mansfield/lconcha/TMP/bids/epilepsia

responsefile=/misc/mansfield/lconcha/TMP/epilepsia_processing/sternberg_hand_answer_yes.txt

export PATH=${PATH}:/misc/mansfield/lconcha/TMP/epilepsia_processing/code


mkdir ${bidsdir}/sourcedata

cpln="cp -v"
#cpln="ln -s"

printf '%s\n' participant_id > ${bidsdir}/participants.tsv

isOK=1
for s in ${origloc}/?????
do
  subj=`basename $s`
  echolor yellow "working on subject $subj , directory $s"
  
  my_do_cmd $fakeflag mkdir -p \
    ${bidsdir}/sub-${subj}/func \
    ${bidsdir}/sub-${subj}/anat

  # T1w
  T1w_orig=${origloc}/${subj}/T1.nii.gz
  if [ ! -f $T1w_orig ]
  then
    echolor red "  ERROR: Did not find T1w: $T1w_orig"
    isOK=0
  else
    T1w=${bidsdir}/sub-${subj}/anat/sub-${subj}_T1w.nii.gz
    my_do_cmd $fakeflag $cpln $T1w_orig $T1w
    my_do_cmd $fakeflag cp -v ${bidsdir}/base_T1w.json ${T1w%.nii.gz}.json
  fi


  # rsfmri
  rsfmri_orig=${origloc}/${subj}/fmrRS.nii.gz
  if [ ! -f $rsfmri_orig ]
  then
    echolor red "  ERROR: Did not find rsfmri: $rsfmri_orig"
  else
    rsfmri=${bidsdir}/sub-${subj}/func/sub-${subj}_task-resting_bold.nii.gz
    my_do_cmd $fakeflag $cpln $rsfmri_orig $rsfmri
    my_do_cmd $fakeflag cp -v ${bidsdir}/base_fmri_resting.json ${rsfmri%.nii.gz}.json
    echolor yellow "  [INFO] Adding slice timing information to file ${rsfmri%.nii.gz}.json"
    inb_get_slicetiming.sh $rsfmri alt+z /tmp/$$.json
    mv /tmp/$$.json ${rsfmri%.nii.gz}.json
  fi

  # Sternberg
  stern_orig=${origloc}/${subj}/fmrSTB.nii.gz
  if [ ! -f $stern_orig ]
  then
    echolor red "  ERROR: Did not find Sternberg: $stern_orig"
  else
    bold_sternberg=${bidsdir}/sub-${subj}/func/sub-${subj}_task-sternberg_bold.nii.gz
    my_do_cmd $fakeflag $cpln $stern_orig $bold_sternberg
    my_do_cmd $fakeflag cp -v ${bidsdir}/base_fmri_sternberg.json ${bold_sternberg%.nii.gz}.json
    echolor yellow "  [INFO] Adding slice timing information to file ${bold_sternberg%.nii.gz}.json"
    inb_get_slicetiming.sh $bold_sternberg alt+z /tmp/$$.json
    mv /tmp/$$.json ${bold_sternberg%.nii.gz}.json
  
    eprime=`ls ${origloc}/${subj}/eprime/S*.txt`
    if [ ! -f $eprime ]
    then
      echolor red "  ERROR: Did not find eprime file: $eprime"
    else
      echolor yellow "  Eprime file is $eprime"
      side=`grep $subj $responsefile | awk -F, '{print $2}'`
      echolor yellow "  Eprime response side is $side"
      sternberg_eprime2times_2018.sh $eprime /tmp/stern_$$ $side > \
	${bidsdir}/sourcedata/sub-${subj}_task-sternberg_answers.txt
      printf '%s\t%s\t%s\n' onset duration trial_type > /tmp/stern_$$_all.times
      awk '{OFS="\t";print $1,$2,"Coding"}'    /tmp/stern_$$_COD.times >> /tmp/stern_$$_all.times
      awk '{OFS="\t";print $1,$2,"Retention"}' /tmp/stern_$$_RET.times >> /tmp/stern_$$_all.times
      awk '{OFS="\t";print $1,$2,"Test"}'      /tmp/stern_$$_PRB.times >> /tmp/stern_$$_all.times
      cat /tmp/stern_$$_all.times | sort -n | awk '{OFS="\t"; print $1,$2,$3}' > \
          ${bidsdir}/sub-${subj}/func/sub-${subj}_task-sternberg_events.tsv
    fi
  fi
  if [ $isOK -eq 1 ]
  then
    echo $subj >> ${bidsdir}/participants.tsv
  else
    echolor orange "[WARNING] Subject $subj was not added to participant list"
  fi
done





