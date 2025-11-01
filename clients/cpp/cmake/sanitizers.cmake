# this file is based on:
# https://github.com/cpp-best-practices/cmake_template/blob/main/cmake/Sanitizers.cmake

function(enable_sanitizers
        target_name
        enable_address_sanitizer
        enable_undefined_behavior_sanitizer
)
    set(sanitizers "")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
        if (${enable_address_sanitizer})
            list(APPEND sanitizers "address")
        endif ()

        if (${enable_undefined_behavior_sanitizer})
            list(APPEND sanitizers "undefined")
        endif ()
    elseif (MSVC)
        if (${enable_address_sanitizer})
            list(APPEND sanitizers "address")
        endif ()
        if (${enable_undefined_behavior_sanitizer})
            message(WARNING "MSVC only supports address sanitizer")
        endif ()
    endif ()

    list(
            JOIN
            sanitizers
            ","
            list_of_sanitizers)

    if (list_of_sanitizers)
        if (NOT
                "${list_of_sanitizers}"
                STREQUAL
                "")
            message("enabling sanitizers: ${list_of_sanitizers}")
            if (NOT MSVC)
                target_compile_options(${target_name} INTERFACE -fsanitize=${list_of_sanitizers})
                target_link_options(${target_name} INTERFACE -fsanitize=${list_of_sanitizers})
            else ()
                string(FIND "$ENV{PATH}" "$ENV{VSINSTALLDIR}" index_of_vs_install_dir)
                if ("${index_of_vs_install_dir}" STREQUAL "-1")
                    message(
                            SEND_ERROR
                            "Using MSVC sanitizers requires setting the MSVC environment before building the project. Please manually open the MSVC command prompt and rebuild the project."
                    )
                endif ()
                target_compile_options(${target_name} INTERFACE /fsanitize=${list_of_sanitizers} /Zi /INCREMENTAL:NO)
                target_compile_definitions(${target_name} INTERFACE _DISABLE_VECTOR_ANNOTATION _DISABLE_STRING_ANNOTATION)
                target_link_options(${target_name} INTERFACE /INCREMENTAL:NO)
            endif ()
        endif ()
    endif ()
endfunction()
