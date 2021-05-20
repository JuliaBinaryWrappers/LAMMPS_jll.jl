# Use baremodule to shave off a few KB from the serialized `.ji` file
baremodule LAMMPS_jll
using Base
using Base: UUID
import JLLWrappers

JLLWrappers.@generate_main_file_header("LAMMPS")
JLLWrappers.@generate_main_file("LAMMPS", UUID("5b3ab26d-9607-527c-88ea-8fe5ba57cafe"))
end  # module LAMMPS_jll
