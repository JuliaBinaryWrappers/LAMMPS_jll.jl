# Autogenerated wrapper script for LAMMPS_jll for x86_64-apple-darwin-mpi+openmpi
export liblammps, lmp

using CompilerSupportLibraries_jll
using libblastrampoline_jll
using FFTW_jll
using OpenMPI_jll
JLLWrappers.@generate_wrapper_header("LAMMPS")
JLLWrappers.@declare_library_product(liblammps, "@rpath/liblammps.0.dylib")
JLLWrappers.@declare_executable_product(lmp)
function __init__()
    JLLWrappers.@generate_init_header(CompilerSupportLibraries_jll, libblastrampoline_jll, FFTW_jll, OpenMPI_jll, MPIPreferences)
    JLLWrappers.@init_library_product(
        liblammps,
        "lib/liblammps.0.dylib",
        RTLD_LAZY | RTLD_DEEPBIND,
    )

    JLLWrappers.@init_executable_product(
        lmp,
        "bin/lmp",
    )

    JLLWrappers.@generate_init_footer()
end  # __init__()
