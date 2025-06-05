#!/bin/bash
#############################################################################
# This script excfs_cdas_vrfyfits.sh.sms processes fits to obs
# and generates the model verification statistis for CDAS/CFS
# Author:   Suranjana Saha -- Original Script
#           Shrinivas Moorthi -- Second version
#############################################################################
set -euax

export PATH=.:$PATH

##################################################
# Define input variables
##################################################
export CDUMPPREP=${CDUMPPREP:-gdas}
export CDUMPFCST=${CDUMPFCST:-gfs}
export CDUMPANAL=${CDUMPANAL:-$CDUMPPREP}
export cfsp=${cfsp:-cfs_}
export cfsd=${cfsd:-cfs_cdas_}
export NWPROD=${NWPROD:-/nwprod}
export SIGEVENTSH=${SIGEVENTSH:-$USHcfs/${cfsp}prevmpi.sh}
export BUFRPOSTSH=${BUFRPOSTSH:-$USHcfs/${cfsp}bufr_post.sh}
export FITSSH=${FITSSH:-$USHcfs/${cfsd}fits.sh}
export HORZSH=${HORZSH:-$USHcfs/${cfsd}horizn.sh}
export CNVDIAGEXEC=${CNVDIAGEXEC:-$EXECcfs/${cfsp}post_convdiag.x}
export COMOUT_FITX=${COMOUT_FITX:-$DATA}
export COMOUT=${COMOUT:-$DATA}   
export SAVEPREP=${SAVEPREP:-NO}

##[ $NEMS = YES ] && { sig=gfn; sfc=sfn; } || { sig=sig; sfc=sfc; }

export PRVT=${PRVT:-$NWPROD/fix/prepobs_errtable.global}
export PREX=${PREX:-$EXECcfs/cfs_prevmpi.x}

export CHGRP_RSTPROD=${CHGRP_RSTPROD:-YES}

export HYBLEVS=${HYBLEVS:-/dev/null}
export PREC=$DATA/prec; echo  "&PREVDATA doanls=t,fits=t /" >$PREC

#################################################################

cd $DATA
echo "JOB $job HAS BEGUN"

# make bufr convdiag postevents for analysis only...
fh1=06
fh2=00

set +u
eval COMIN_OBS=${COMIN_OBS:-$COMIN_ANALYSIS}
eval COMIN_ANALYSIS=${COMIN_ANALYSIS}
set -u

if [[ $OUTPUT_FILETYPE = nemsio || $OUTPUT_FILETYPE = netcdf ]] ; then
  [[ $OUTPUT_FILETYPE = nemsio ]] && suffix=nemsio || suffix=nc
  export PRPI=$COMIN_OBS/gdas.t${cyc}z.prepbufr
  export PRPO=$COMOUT_FITX/gdas.t${cyc}z.prepqa
  export PRPF=$COMOUT_FITX/gdas.t${cyc}z.prepqf
  export sig1=$COMIN_ANALYSIS/gdas.t${cyc}z.atmanl.$suffix
  export sfc1=$COMIN_ANALYSIS/gdas.t${cyc}z.atmanl.$suffix
  export CNVS=$COMIN_ANALYSIS/gdas.t${cyc}z.cnvstat
elif [[ $OUTPUT_FILETYPE = cfs ]]; then
  tzz=t${cyc}z
  export PRPI=$COMIN_OBS/cdas1.$tzz.prepbufr
  export PRPO=$COMOUT/cdas1.$tzz.prepqa
  export PRPF=$COMOUT_FITX/cdas1.$tzz.prepqf
  export sig1=$COMIN_ANALYSIS/cdas1.$tzz.sanl
  export sfc1=$COMIN_ANALYSIS/cdas1.$tzz.sfcanl
  export CNVS=$COMIN_ANALYSIS/cdas1.$tzz.cnvstat
else 
  echo $OUTPUT_FILETYPE = unknown OUTPUT_FILETYPE; exit 999
fi

[ ${ACPROFit:-YES} != NO ] && PRPI=$($USHcfs/ACprof)

$BUFRPOSTSH $sig1 $CNVS $PRPI $PRPO ${PDY}${cyc}

[ "$CHGRP_RSTPROD" = 'YES' ] && chgrp rstprod $PRPO && chmod 640 $PRPO
[ $SAVEPREP = YES          ] && cp $PRPO $ARCDIR/$(basename $PRPO).06.00
[ $SAVEPREP = YES          ] && cp $PRPI $ARCDIR

$FITSSH     ${PDY}${cyc} $PRPO $COMOUT_FITX $DATA 06 00
$HORZSH     ${PDY}${cyc} $PRPO $COMOUT_FITX $DATA anl 2> horizout

#################################################################
# make prepqf file containing forecasts
#################################################################

cp $PRPO $PRPF || exit 2

if [ ${cyc} = "00" -o ${cyc} = "12" -o ${cyc} = "06" -o ${cyc} = "18" ] ; then
  fp1="fh1=12;fh2=36"
  fp2="fh1=24;fh2=48"
  fp3="fh1=60;fh2=84"
  fp4="fh1=72;fh2=96"
  fp5="fh1=108;fh2=120"
else
  exit
fi

# interpolate background from fh

tspan=6

for fp in $fp1 $fp2 $fp3 $fp4 $fp5 
do
eval $fp
for fh in $fh1 $fh2                 
do

[ $fh = xx ] && continue

FDATE=$(date --utc +%Y%m%d%H -d "${PDY} ${cyc} - ${fh} hours")
fdy=${FDATE:0:8}
fzz=${FDATE:8:2}
export COMIN_HISTORY="${COM_VRFYARCH:?}/${RUN:?}.${fdy}/${fzz}"

if [[ $OUTPUT_FILETYPE = nemsio || $OUTPUT_FILETYPE = netcdf ]] ; then
  fhm3=$((fh-$tspan)); [ $fhm3 -lt 10 ] && fhm3=0$fhm3; [ $fhm3 -lt 100 ] && fhm3=0$fhm3
  fhp3=$((fh+$tspan)); [ $fhp3 -lt 10 ] && fhp3=0$fhp3; [ $fhp3 -lt 100 ] && fhp3=0$fhp3
  fh00=$fh;            [ $fh00 -lt 10 ] && fh00=0$fh00; [ $fh00 -lt 100 ] && fh00=0$fh00
  tzz=t$(echo $FDATE|cut -c9-10)z
  [[ $OUTPUT_FILETYPE = nemsio ]] && suffix=nemsio || suffix=nc
  export sig1=$COMIN_HISTORY/gfs.$tzz.atmf$fhm3.$suffix
  export sig2=$COMIN_HISTORY/gfs.$tzz.atmf$fh00.$suffix
  export sig3=$COMIN_HISTORY/gfs.$tzz.atmf$fhp3.$suffix
  export sfc1=$COMIN_HISTORY/gfs.$tzz.atmf$fhm3.$suffix
  export sfc2=$COMIN_HISTORY/gfs.$tzz.atmf$fh00.$suffix
  export sfc3=$COMIN_HISTORY/gfs.$tzz.atmf$fhp3.$suffix
elif [[ $OUTPUT_FILETYPE = cfs ]]; then
  CDAM3=$(date --utc +%Y%m%d%H -d "${PDY} ${cyc} - ${tspan} hours")
  CDAP3=$(date --utc +%Y%m%d%H -d "${PDY} ${cyc} + ${tspan} hours")
  export sig1=$COMIN_HISTORY/sigf${CDAM3}.01.$FDATE
  export sig2=$COMIN_HISTORY/sigf${PDY}${cyc}.01.$FDATE
  export sig3=$COMIN_HISTORY/sigf${CDAP3}.01.$FDATE
  export sfc1=$COMIN_HISTORY/sfcf${CDAM3}.01.$FDATE
  export sfc2=$COMIN_HISTORY/sfcf${PDY}${cyc}.01.$FDATE
  export sfc3=$COMIN_HISTORY/sfcf${CDAP3}.01.$FDATE
else
  echo $OUTPUT_FILETYPE = unknown OUTPUT_FILETYPE; exit 999
fi

if [ -s $sig1 -a -s $sig2 -a -s $sig3 ] ; then 
 [ -s $sfc1 -a -s $sfc2 -a -s $sfc3 ] && rsfc=t || rsfc=f
 [ $fh = $fh1 ] && echo  "&PREVDATA dofcst=t,nbax=3,span=$tspan,fits=t,rsfc=$rsfc /" >$PREC
 [ $fh = $fh2 ] && echo  "&PREVDATA doanls=t,nbax=3,span=$tspan,fits=t,rsfc=$rsfc /" >$PREC
 cp $PRPF prepqm
 $SIGEVENTSH prepqm ${PDY}${cyc}
 cp prepqm $PRPF
else
 [ $fh = $fh1 ] && fh1=xx
 [ $fh = $fh2 ] && fh2=xx
fi

done # endi of inner loop over two forecast times

if [ $fh1 != xx -o $fh2 != xx ] ; then
 [ "$CHGRP_RSTPROD" = 'YES' ] && chgrp rstprod $PRPF && chmod 640 $PRPF
 [ $SAVEPREP = YES          ] && cp $PRPF $ARCDIR/$(basename $PRPO).$fh1.$fh2
 $FITSSH ${PDY}${cyc} $PRPF $COMOUT_FITX $DATA $fh1 $fh2
 [ ${cyc} = 00 -a $fh1 = 24 ] &&  $HORZSH ${PDY}${cyc} $PRPF $COMOUT_FITX $DATA fcs 2> horizout
 [ ${cyc} = 12 -a $fh1 = 12 ] &&  $HORZSH ${PDY}${cyc} $PRPF $COMOUT_FITX $DATA fcs 2> horizout
fi

done # end of outer loop over multiple forecast times

########################################################
# copy the fit files to the FIT_DIR
########################################################

set +e

rm -f $COMOUT_FITX/fxx*

mkdir -p $FIT_DIR
cp $COMOUT_FITX/f*.raob.${PDY}${cyc}  $FIT_DIR
cp $COMOUT_FITX/f*.acft.${PDY}${cyc}  $FIT_DIR
cp $COMOUT_FITX/f*.acar.${PDY}${cyc}  $FIT_DIR
cp $COMOUT_FITX/f*.surf.${PDY}${cyc}  $FIT_DIR
cp $COMOUT_FITX/f*.sfc.${PDY}${cyc}   $FIT_DIR

for typ in anl fcs
do
mkdir -p $HORZ_DIR/$typ   
cp -p $COMOUT_FITX/adpupa.mand.$typ.${PDY}${cyc}  $HORZ_DIR/$typ/adpupa.mand.${PDY}${cyc}
cp -p $COMOUT_FITX/adpsfc.$typ.${PDY}${cyc}       $HORZ_DIR/$typ/adpsfc.${PDY}${cyc}
cp -p $COMOUT_FITX/sfcshp.$typ.${PDY}${cyc}       $HORZ_DIR/$typ/sfcshp.${PDY}${cyc}
cp -p $COMOUT_FITX/aircar.$typ.${PDY}${cyc}       $HORZ_DIR/$typ/aircar.${PDY}${cyc}
cp -p $COMOUT_FITX/aircft.$typ.${PDY}${cyc}       $HORZ_DIR/$typ/aircft.${PDY}${cyc}
done

################## END OF SCRIPT #######################
echo "ENDED NORMALLY."
cd $(dirname $DATA)
if [ ${KEEPDATA:-"NO"} = "NO" ] ; then rm -rf $DATA ; fi
################## END OF SCRIPT #######################
