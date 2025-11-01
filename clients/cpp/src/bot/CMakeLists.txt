add_executable(Bot main.cpp
        base_bot.hpp)
target_link_libraries(Bot PRIVATE Client)
target_link_system_libraries(Bot PRIVATE Arguably)
