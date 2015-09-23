using Base.Test

function runtests()
    nprocs = min(4, CPU_CORES)
    exename = joinpath(JULIA_HOME, Base.julia_exename())
    testdir = dirname(@__FILE__)
    istest(f) = endswith(f, ".jl") && f != "runtests.jl"
    testfiles = sort(filter(istest, readdir(testdir)))
    nfail = 0
    print_with_color(:white, "Running MPI.jl tests\n")
    for f in testfiles
        try
            run(`mpirun -np $nprocs $exename $(joinpath(testdir, f))`)
            Base.with_output_color(:green,STDOUT) do io
                println(io,"\tSUCCESS: $f")
            end
        catch ex
            Base.with_output_color(:red,STDERR) do io
                println(io,"\tError: $(joinpath(testdir, f))")
                showerror(io,ex,backtrace())
            end
            nfail += 1
        end
    end
    return nfail
end

exit(runtests())
