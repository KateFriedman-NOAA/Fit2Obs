#!/bin/bash
if [ $# -ne 6 ] ; then
  echo "Usage: $0 PDY (yyyymmdd) cyc (hh) PRPO COMOUT DATA fh1 fh2"
  exit 1
fi

set -xeua

export HOMEcfs=${HOMEcfs:-/nwprod}
export cfss=${cfss:-cfs}
export cfsp=${cfsp:-cfs_}
export EXECcfs=$HOMEcfs/exec

export PDY=$1
export cyc=$2
export PRPO=$3
export COMOUT=$4
export DATA=$5
export fh1=$6
export fh2=$7

prfile=$DATA/fits.${PDY}${cyc}
> $prfile

rm -f fort.*

list='raob sfc acft acar surf'
for sub in $list ; do
  ln -sf $PRPO fort.11
  ln -sf f$fh1.$sub.${PDY}${cyc} fort.51
  ln -sf f$fh2.$sub.${PDY}${cyc} fort.52
  $EXECcfs/${cfsp}${sub}.x > $prfile.${sub}.f${fh1}_f${fh2}
  export err=$?; $DATA/err_chk
  mv f$fh1.$sub.${PDY}${cyc} $COMOUT/.
  mv f$fh2.$sub.${PDY}${cyc} $COMOUT/.

  if [ "$CHGRP_RSTPROD" = 'YES' ]; then
    chgrp rstprod $COMOUT/f$fh1.$sub.${PDY}${cyc}
    chgrp rstprod $COMOUT/f$fh2.$sub.${PDY}${cyc}
    chmod 640 $COMOUT/f$fh1.$sub.${PDY}${cyc}
    chmod 640 $COMOUT/f$fh2.$sub.${PDY}${cyc}
  fi
done

