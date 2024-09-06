help([[
Build environment for fit2obs on Hercules
]])

prepend_path("MODULEPATH", "/work/noaa/epic/role-epic/spack-stack/hercules/spack-stack-1.6.0/envs/gsi-addon-env/install/modulefiles/Core")

local stack_intel_ver=os.getenv("stack_intel_ver") or "2021.9.0"
local stack_impi_ver=os.getenv("stack_impi_ver") or "2021.9.0"

load(pathJoin("stack-intel", stack_intel_ver))
load(pathJoin("stack-intel-oneapi-mpi", stack_impi_ver))

load("fit2obs_common")

whatis("Description: fit2obs environment on Hercules with Intel Compilers")
