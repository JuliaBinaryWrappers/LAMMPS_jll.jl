using Base.BinaryPlatforms

# Can't use Preferences since we might be running this very early with a non-existing Manifest
MPIPreferences_UUID = Base.UUID("3da0fdf6-3ccc-4f1b-acd9-58baa6c99267")
const preferences = Base.get_preferences(MPIPreferences_UUID)

const binary_to_abi = Dict(
    "MPIABI_jll" => "MPIABI",
    "MPICH_jll" => "MPICH",
    "MPICH_CUDA_jll" => "MPICH",
    "MPItrampoline_jll" => "MPItrampoline",
    "MicrosoftMPI_jll" => "MicrosoftMPI",
    "OpenMPI_jll" => "OpenMPI",
)

# Keep logic in sync with MPIPreferences.jl
function augment_mpi!(platform)
    # Doesn't need to be `const` since we depend on MPIPreferences so we
    # invalidate the cache when it changes.

    # Determine which jll binary provides our MPI implementation.
    # Use MPIPreferences if set, otherwise use either MPICH or MicrosoftMPI (on Windows).
    # Note: MPIPreferences uses `Sys.iswindows()` without the `platform` argument.
    binary = get(preferences, "binary", Sys.iswindows(platform) ? "MicrosoftMPI_jll" : "MPICH_jll")

    # Convert the jll binary to an ABI
    if binary == "system"
        abi = get(preferences, "abi", nothing)
        abi === nothing && error("MPIPreferences: Inconsistent state detected, `binary` is set to system, but `abi` is not set.")
    else
        abi = get(binary_to_abi, binary, nothing)
        abi == nothing && error("Unknown MPI binary: $binary")
    end

    # Add an `mpi` entry to the platform if it's missing
    if !haskey(platform, "mpi")
        platform["mpi"] = abi
    end

    return platform
end


using Base.BinaryPlatforms

try
    using CUDA_Runtime_jll
catch
    # during initial package installation, CUDA_Runtime_jll may not be available.
end

# every other tag that artifacts are selected on must be set before calling this
function augment_cuda_tag!(platform::Platform)
    if @isdefined(CUDA_Runtime_jll) && isdefined(CUDA_Runtime_jll, :augment_dependent!)
        # both Pkg and the JLL module include this file from the JLL's `.pkg` directory
        artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
        CUDA_Runtime_jll.augment_dependent!(platform, artifacts_toml)
    elseif !haskey(platform, "cuda")
        # CUDA_Runtime_jll is missing during initial installation, or briefly older than
        # our compat bound while Pkg changes the environment. select the CPU build, if
        # any; without the tag, Pkg would select any build.
        platform["cuda"] = "none"
    end
    return platform
end

function augment_platform!(platform::Platform)
    augment_mpi!(platform)
    augment_cuda_tag!(platform)
end