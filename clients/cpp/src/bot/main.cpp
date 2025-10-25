#include "base_bot.hpp"

#include <magic_enum/magic_enum.hpp>
#include <random>
#include <spdlog/spdlog.h>

class DemoBot final : public BaseBot {
private:
    std::mt19937_64 m_random_engine{ std::random_device{}() };
    std::uniform_int_distribution<int> m_distribution{ 0, static_cast<int>(Board::width - 1) };

public:
    using BaseBot::BaseBot;

    auto make_move(PlayState const& play_state) -> Move override {
        while (true) {
            auto const move = m_distribution(m_random_engine);
            if (play_state.is_empty(move, Board::height - 1)) {
                return magic_enum::enum_cast<Move>(move).value();
            }
        }
    }
};

[[nodiscard]] constexpr std::optional<int> parse(std::string_view const s) {
    auto result = int{};
    auto const [pointer, errc] = std::from_chars(s.data(), s.data() + s.length(), result, 10);
    if (pointer != s.data() + s.length() or errc != std::errc{}) {
        return std::nullopt;
    }
    return result;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        spdlog::error("Usage: {} <bot_name> [port=5051]", argv[0]);
        return EXIT_FAILURE;
    }
    auto const bot_name = std::string{ argv[1] };
    auto port = 5051;
    if (argc >= 3) {
        auto const parsed_port = parse(argv[2]);
        if (not parsed_port.has_value()) {
            spdlog::error("Invalid port number: {}", argv[2]);
            return EXIT_FAILURE;
        }
        port = parsed_port.value();
    }
    auto bot = DemoBot{ bot_name, port };
    bot.play();
}
