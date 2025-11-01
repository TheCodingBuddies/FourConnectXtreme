include(CheckIPOSupported)

# This function tries to enable link-time optimizations. It outputs a warning on failure.
function(try_enable_link_time_optimizations)
    check_ipo_supported(RESULT ipo_supported)
    if (ipo_supported)
        message("link-time optimizations enabled")
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION True PARENT_SCOPE)
    else ()
        message(WARNING "unable to enable link-time optimizations (not supported on this platform)")
    endif ()
endfunction()
