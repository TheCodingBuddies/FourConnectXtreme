include("${PROJECT_SOURCE_DIR}/cmake/CPM.cmake")
include("${PROJECT_SOURCE_DIR}/cmake/system_link.cmake")

function(four_connect_extreme_setup_dependencies)
    CPMAddPackage(
            NAME TL_OPTIONAL
            GITHUB_REPOSITORY TartanLlama/optional
            VERSION 1.1.0
            OPTIONS
            "EXPECTED_BUILD_PACKAGE OFF"
            "EXPECTED_BUILD_TESTS OFF"
            "EXPECTED_BUILD_PACKAGE_DEB OFF"
    )

    CPMAddPackage(
            NAME TL_EXPECTED
            GITHUB_REPOSITORY TartanLlama/expected
            VERSION 1.1.0
            OPTIONS
            "EXPECTED_BUILD_PACKAGE OFF"
            "EXPECTED_BUILD_TESTS OFF"
            "EXPECTED_BUILD_PACKAGE_DEB OFF"
    )

    CPMAddPackage(
            NAME IXWEBSOCKET
            GITHUB_REPOSITORY machinezone/IXWebSocket
            VERSION 11.4.6
            OPTIONS
            "USE_ZLIB FALSE"
            "IXWEBSOCKET_INSTALL FALSE"
    )

    CPMAddPackage(
            NAME FMT
            GITHUB_REPOSITORY fmtlib/fmt
            GIT_TAG 12.0.0
            OPTIONS
            "FMT_OS OFF"
    )

    CPMAddPackage(
            NAME NLOHMANN_JSON
            GITHUB_REPOSITORY nlohmann/json
            VERSION 3.12.0
    )

    CPMAddPackage(
            NAME MAGIC_ENUM
            GITHUB_REPOSITORY Neargye/magic_enum
            VERSION 0.9.7
    )

    CPMAddPackage(
            NAME SPDLOG
            GITHUB_REPOSITORY gabime/spdlog
            VERSION 1.16.0
    )

    CPMAddPackage(
            NAME ARGUABLY
            GITHUB_REPOSITORY mgerhold/arguably
            VERSION 0.1.10
    )
endfunction()
