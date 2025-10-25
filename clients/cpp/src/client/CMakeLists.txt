add_library(Client
        STATIC
        include/client/play_state.hpp
        include/client/client.hpp
        web_socket.hpp
        client.cpp
)

target_include_directories(Client PUBLIC include)

target_link_system_libraries(
        Client
        PRIVATE
        ixwebsocket::ixwebsocket
        nlohmann_json::nlohmann_json
        PUBLIC
        spdlog::spdlog
        fmt::fmt
        magic_enum::magic_enum
        tl::optional
        tl::expected
)
