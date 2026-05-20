#!/usr/bin/env julia

using Pkg

try
    @eval using LicenseCheck
catch
    Pkg.add("LicenseCheck")
    @eval using LicenseCheck
end

function main(args)
    if length(args) != 1
        println("Usage: julia check_registry_license.jl /path/to/LICENSE")
        return 1
    end

    license_file = abspath(args[1])

    if !isfile(license_file)
        println("FAIL: file does not exist: $license_file")
        return 1
    end

    text = read(license_file, String)
    result = licensecheck(text)

    licenses_found = collect(result.licenses_found)

    if isempty(licenses_found)
        println("FAIL: No licenses detected. An OSI-approved license is required.")
        return 1
    end

    osi_results = String[]
    non_osi_results = String[]

    for identifier in licenses_found
        if is_osi_approved(identifier)
            push!(osi_results, "$(identifier) license in $(basename(license_file))")
        else
            push!(non_osi_results, "$(identifier) license in $(basename(license_file))")
        end
    end

    if isempty(osi_results)
        println("FAIL: Found no OSI-approved licenses. Found non-OSI license(s): " *
                join(non_osi_results, ", ", ", and ") * ".")
        return 1
    end

    println("PASS: Found OSI-approved license(s): " *
            join(osi_results, ", ", ", and ") * ".")

    if !isempty(non_osi_results)
        println("Also found non-OSI license(s): " *
                join(non_osi_results, ", ", ", and ") * ".")
    else
        println("Found no other licenses.")
    end

    if hasproperty(result, :percent_covered)
        println("Coverage: ", getproperty(result, :percent_covered), "%")
    end

    return 0
end

exit(main(ARGS))