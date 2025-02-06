help([[
Build environment for fit2obs on Gaea C5
]])

prepend_path("MODULEPATH", "/ncrc/proj/epic/spack-stack/spack-stack-1.6.0/envs/gsi-addon-dev/install/modulefiles/Core")

local stack_intel_ver=os.getenv("stack_intel_ver") or "2023.1.0"
local stack_cray_mpich_ver=os.getenv("stack_cray_mpich_ver") or "8.1.25"

load(pathJoin("stack-intel", stack_intel_ver))
load(pathJoin("stack-cray-mpich", stack_cray_mpich_ver))

load("fit2obs_common")

whatis("Description: fit2obs environment on Gaea with Intel Compilers")
