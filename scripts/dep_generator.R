library("sysreqs")
library("sf")
getwd()
spatial_packages <- readLines("./scripts/spatial_packages.txt")
spatiotemporal_packages <- readLines("./scripts/spatiotemporal_packages.txt")
all_packages = sort(unique(c(spatial_packages, spatiotemporal_packages)))
unused_package = c('lgcp')
all_packages = setdiff(all_packages, unused_package)
pardir = "./scripts/sysreqs/"

platforms = c(
    # "linux-x86_64-arch-gcc",
    # "linux-x86_64-centos6-epel",
    # "linux-x86_64-debian-clang",
    # "linux-x86_64-debian-gcc",
    # "linux-x86_64-fedora-clang",
    # "linux-x86_64-fedora-gcc",
    "linux-x86_64-ubuntu-gcc"
)
for (platform in platforms){
    # Initialization
    all_deps = c()
    # Use cache
    # all_deps = readLines(paste0(pardir, platform, "-deps-cache.txt"))
    
    # failed packages file
    file.create(paste0(pardir, platform, "-failed-packages.txt"))
    i = 0
    for (p in all_packages[1:length(all_packages)]){
        i = i + 1
        print(paste0("[",  i, "/", length(all_packages), "] ", platform, " ", p))
        tryCatch(
            {
                library(p, character.only=TRUE)
                dep <- sysreqs(desc = file.path(path.package(package = p), "DESCRIPTION"), platform=platform)
                print(paste0("Number of dep: ", length(dep)))
                print(paste0("Number of unique dep: ", length(unique(dep))))
                # print(sort(dep))
                all_deps <- c(all_deps, dep)
                # print(all_deps)
            },
            error=function(error_message) {
                message(paste0("Error message from R for : "), p)
                message(error_message)
                # update failed packages file
                failed_packages <- readLines(paste0(pardir, platform, "-failed-packages.txt"))
                failed_packages <- sort(c(failed_packages, p))
                failed_packages_file <- file(paste0(pardir, platform, "-failed-packages.txt"))
                writeLines(failed_packages, failed_packages_file)
                close(failed_packages_file)
            }
        )
        if (i %% 10 == 0){
            # Write result cache here
            print("Writing cache")
            if (length(all_deps) > 0){
                all_deps <- sort(unique(all_deps))
                dep_file_cache <- file(paste0(pardir, platform, "-deps-cache.txt"))
                writeLines(all_deps, dep_file_cache)
                close(dep_file_cache)
            }
            
        }
    }
    all_deps <- sort(unique(all_deps))
    print(paste0("Total dep : ", length(all_deps)))

    # print(all_deps)
    # Write list of package to file
    dep_file <- file(paste0(pardir, platform, "-deps.txt"))
    if (length(all_deps) > 0){
        writeLines(all_deps, dep_file)
    }
    close(dep_file)

    # Failed packages
    failed_packages <- readLines(paste0(pardir, platform, "-failed-packages.txt"))
    if (length(failed_packages) > 0){
        print("Failed packages are: ")
        print(failed_packages)
    } else {
    print("No failed packages.")
    }

}
