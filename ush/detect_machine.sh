#!/bin/bash

case $(hostname -f) in

  adecflow0[12].acorn.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### acorn
  alogin0[12].acorn.wcoss2.ncep.noaa.gov)    MACHINE_ID=wcoss2 ;; ### acorn
  clogin0[1-9].cactus.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### cactus01-9
  clogin10.cactus.wcoss2.ncep.noaa.gov)      MACHINE_ID=wcoss2 ;; ### cactus10
  dlogin0[1-9].dogwood.wcoss2.ncep.noaa.gov) MACHINE_ID=wcoss2 ;; ### dogwood01-9
  dlogin10.dogwood.wcoss2.ncep.noaa.gov)     MACHINE_ID=wcoss2 ;; ### dogwood10

  gaea5[1-8])          MACHINE_ID=gaeac5 ;; ### gaea51-58
  gaea5[1-8].ncrc.gov) MACHINE_ID=gaeac5 ;; ### gaea51-58
  gaea6[1-8])          MACHINE_ID=gaeac6 ;; ### gaea61-68
  gaea6[1-8].ncrc.gov) MACHINE_ID=gaeac6 ;; ### gaea61-68

  hfe0[1-9]) MACHINE_ID=hera ;; ### hera01-9
  hfe1[0-2]) MACHINE_ID=hera ;; ### hera10-12
  hecflow01) MACHINE_ID=hera ;; ### heraecflow01

  s4-submit.ssec.wisc.edu) MACHINE_ID=s4 ;; ### s4

  fe[1-8]) MACHINE_ID=jet ;; ### jet01-8
  tfe[12]) MACHINE_ID=jet ;; ### tjet1-2

  Orion-login-[1-4].HPC.MsState.Edu) MACHINE_ID=orion ;; ### orion1-4

  [Hh]ercules-login-[1-4].[Hh][Pp][Cc].[Mm]s[Ss]tate.[Ee]du) MACHINE_ID=hercules ;; ### hercules1-4

  login[1-4].stampede2.tacc.utexas.edu) MACHINE_ID=stampede ;; ### stampede1-4

  login0[1-2].expanse.sdsc.edu) MACHINE_ID=expanse ;; ### expanse1-2

  discover3[1-5].prv.cube) MACHINE_ID=discover ;; ### discover31-35
esac

# Overwrite auto-detect with MACHINE if set
MACHINE_ID=${MACHINE:-${MACHINE_ID}}

# Append compiler (only on machines that have multiple compilers)
if [ $MACHINE_ID = hera ] || [ $MACHINE_ID = cheyenne ]; then
    MACHINE_ID=${MACHINE_ID}.${COMPILER}
fi
