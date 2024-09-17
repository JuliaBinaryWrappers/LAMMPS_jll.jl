# Autogenerated wrapper script for LAMMPS_jll for x86_64-linux-gnu-cxx03-cuda+11.8-mpi+mpitrampoline
export liblammps, lmp

using CompilerSupportLibraries_jll
using libblastrampoline_jll
using FFTW_jll
using MPItrampoline_jll
using CUDA_Runtime_jll
using CUDA_Driver_jll
JLLWrappers.@generate_wrapper_header("LAMMPS")
JLLWrappers.@declare_library_product(liblammps, "liblammps.so.0")
JLLWrappers.@declare_executable_product(lmp)
function __init__()
    JLLWrappers.@generate_init_header(CompilerSupportLibraries_jll, libblastrampoline_jll, FFTW_jll, MPItrampoline_jll, MPIPreferences, CUDA_Runtime_jll, CUDA_Driver_jll)
    JLLWrappers.@init_library_product(
        liblammps,
        "lib/liblammps.so",
        RTLD_LAZY | RTLD_DEEPBIND,
    )

    JLLWrappers.@init_executable_product(
        lmp,
        "bin/lmp",
    )

    JLLWrappers.@generate_init_footer()
end  # __init__()
