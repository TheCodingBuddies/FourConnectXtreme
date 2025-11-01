#include "base_bot.hpp"

#include <arguably.hpp>
#include <iostream>
#include <memory>
#include <magic_enum/magic_enum.hpp>
#include <random>
#include <spdlog/spdlog.h>
#include <string_view>

/* The demo bot implements a very simple strategy:
 * It randomly selects a column and places its coin there,
 * retrying until an empty column is found. */
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

/* The following macro has to list all available bot classes. Each
 * class that is listed here, can be instantiated by providing its name
 * via the command line argument '--bot' or '-b'.
 * E.g.: Running the executable with `--bot DemoBot --name my_bot` will
 *       instantiate the `DemoBot` class and use `my_bot` as bot name.
 */
#define BOT_LIST                          \
    /* Register your bot classes here: */ \
    X(DemoBot)

[[nodiscard]] static auto instantiate_bot(std::string_view const bot_class, std::string name, int const port)
        -> std::unique_ptr<BaseBot> {
#define X(BotClass)                                               \
    if (bot_class == #BotClass) {                                 \
        return std::make_unique<BotClass>(std::move(name), port); \
    }
    BOT_LIST
#undef X
    return nullptr;
}

int main(int, char** const argv) {
    auto parser = arguably::create_parser()
                          .optionally_named<'b', "bot", "The bot class to instantiate", std::string>("")
                          .optionally_named<'n', "name", "Bot name", std::string>("")
                          .optionally_named<'p', "port", "Port number", int>(5051)
                          .create();
    parser.parse(argv);

    if (not parser) {
        parser.print_help(std::cerr << "Usage:\n");
        return EXIT_FAILURE;
    }

    if (not parser.was_provided<'b'>()) {
        parser.print_help(std::cerr << "Error: You must provide a bot class.\nUsage:\n");
        return EXIT_FAILURE;
    }

    if (not parser.was_provided<'n'>()) {
        parser.print_help(std::cerr << "Error: You must provide a bot name.\nUsage:\n");
        return EXIT_FAILURE;
    }

    auto const port = parser.get<'p'>();
    auto const bot = instantiate_bot(parser.get<'b'>(), parser.get<'n'>(), port);
    if (bot == nullptr) {
        std::cerr << "Error: Unknown bot class: " << parser.get<'b'>() << "\n";
        return EXIT_FAILURE;
    }
    bot->play();
    return EXIT_SUCCESS;
}
