    using Base.BinaryPlatforms

    module __CUDA
        using Base.BinaryPlatforms

try
    using CUDA_Runtime_jll
catch
    # during initial package installation, CUDA_Runtime_jll may not be available.
    # in that case, we just won't select an artifact.
end

# can't use Preferences for the same reason
const CUDA_Runtime_jll_uuid = Base.UUID("76a88914-d11a-5bdc-97e0-2f5a05c973a2")
const preferences = Base.get_preferences(CUDA_Runtime_jll_uuid)
Base.record_compiletime_preference(CUDA_Runtime_jll_uuid, "version")
Base.record_compiletime_preference(CUDA_Runtime_jll_uuid, "local")
const local_toolkit = something(tryparse(Bool, get(preferences, "local", "false")), false)

function cuda_comparison_strategy(_a::String, _b::String, a_requested::Bool, b_requested::Bool)
    # if we're using a local toolkit, we can't use artifacts
    if local_toolkit
        return false
    end

    # if either isn't a version number (e.g. "none"), perform a simple equality check
    a = tryparse(VersionNumber, _a)
    b = tryparse(VersionNumber, _b)
    if a === nothing || b === nothing
        return _a == _b
    end

    # if both b and a requested, then we fall back to equality
    if a_requested && b_requested
        return Base.thisminor(a) == Base.thisminor(b)
    end

    # otherwise, do the comparison between the the single version cap and the single version:
    function is_compatible(artifact::VersionNumber, host::VersionNumber)
        if host >= v"11.0"
            # enhanced compatibility, semver-style
            artifact.major == host.major &&
            Base.thisminor(artifact) <= Base.thisminor(host)
        else
            Base.thisminor(artifact) == Base.thisminor(host)
        end
    end
    if a_requested
        is_compatible(b, a)
    else
        is_compatible(a, b)
    end
end

function augment_platform!(platform::Platform)
    if !@isdefined(CUDA_Runtime_jll)
        # don't set to nothing or Pkg will download any artifact
        platform["cuda"] = "none"
    end

    if !haskey(platform, "cuda")
        CUDA_Runtime_jll.augment_platform!(platform)
    end
    BinaryPlatforms.set_compare_strategy!(platform, "cuda", cuda_comparison_strategy)

    return platform
end
    end

    # Can't use Preferences since we might be running this very early with a non-existing Manifest
MPIPreferences_UUID = Base.UUID("3da0fdf6-3ccc-4f1b-acd9-58baa6c99267")
const preferences = Base.get_preferences(MPIPreferences_UUID)

# Keep logic in sync with MPIPreferences.jl
function augment_mpi!(platform)
    # Doesn't need to be `const` since we depend on MPIPreferences so we
    # invalidate the cache when it changes.
    # Note: MPIPreferences uses `Sys.iswindows()` without the `platform` argument.
    binary = get(preferences, "binary", Sys.iswindows(platform) ? "MicrosoftMPI_jll" : "MPICH_jll")

    abi = if binary == "system"
        let abi = get(preferences, "abi", nothing)
            if abi === nothing
                error("MPIPreferences: Inconsistent state detected, binary set to system, but no ABI set.")
            else
                abi
            end
        end
    elseif binary == "MicrosoftMPI_jll"
        "MicrosoftMPI"
    elseif binary == "MPICH_jll"
        "MPICH"
    elseif binary == "OpenMPI_jll"
        "OpenMPI"
    elseif binary == "MPItrampoline_jll"
        "MPItrampoline"
    else
        error("Unknown binary: $binary")
    end

    if !haskey(platform, "mpi")
        platform["mpi"] = abi
    end
    return platform
end


    function augment_platform!(platform::Platform)
        augment_mpi!(platform)
        __CUDA.augment_platform!(platform)
    end
