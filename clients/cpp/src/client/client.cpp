#include "web_socket.hpp"
#include <algorithm>
#include <array>
#include <client/client.hpp>
#include <fmt/format.h>
#include <magic_enum/magic_enum.hpp>
#include <nlohmann/json.hpp>
#include <ranges>
#include <spdlog/spdlog.h>
#include <vector>

namespace json_message {
    struct Bomb {
        int row;
        int col;
        int explode_in_round;
    };

    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(Bomb, row, col, explode_in_round);

    struct Message {
        std::string bot;
        int coin_id;
        int round;
        std::vector<Bomb> bombs;
        std::array<std::array<int, Board::width>, Board::height> board;
    };

    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(Message, bot, coin_id, round, bombs, board);

    struct Response {
        std::string state;
        int column;
    };

    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(Response, state, column);
} // namespace json_message

Client::Client(
        std::string name,
        int const port,
        std::function<Move(PlayState const&)> make_move_callback,
        std::function<void(void)> on_closed_callback
)
    : m_web_socket{ std::make_unique<WebSocket>(fmt::format("ws://localhost:{}/{}", port, name)) },
      m_name{ std::move(name) },
      m_make_move_callback{ std::move(make_move_callback) },
      m_on_closed_callback{ std::move(on_closed_callback) } {
    m_web_socket->set_on_open_callback([] { spdlog::info("WebSocket connection opened."); });
    m_web_socket->set_on_close_callback([this] {
        spdlog::info("WebSocket connection closed.");
        m_on_closed_callback();
    });
    m_web_socket->set_on_error_callback([](int status, std::string const& reason) {
        spdlog::error("WebSocket error (status {}): {}", status, reason);
    });
    m_web_socket->set_on_message_callback([this](std::string const& message_string) -> tl::optional<std::string> {
        auto const move = this->handle_message(message_string);
        if (not move.has_value()) {
            return tl::nullopt;
        }
        spdlog::info("Responding with move: {}", magic_enum::enum_name(move.value()));
        auto const response = json_message::Response{
            .state = "play",
            .column = static_cast<int>(move.value()),
        };
        auto const response_json = nlohmann::json(response);
        spdlog::info("{}", response_json.dump());
        return response_json.dump();
    });
    m_web_socket->start();
}

Client::~Client() = default;

auto Client::handle_message(std::string const& message_string) -> tl::optional<Move> {
    auto message = tl::optional<json_message::Message>{};
    try {
        auto const parsed = nlohmann::json::parse(message_string);
        message = parsed.get<json_message::Message>();
    } catch (nlohmann::json::parse_error const& exception) {
        // Since this is presumably the ping message, we just ignore it.
        return tl::nullopt;
    } catch (nlohmann::json::type_error const& exception) {
        spdlog::error("JSON type error: {}", exception.what());
        return tl::nullopt;
    }
    if (not message.has_value()) {
        // This is presumably the ping message, so we just ignore it.
        return tl::nullopt;
    }
    if (message.value().bot != m_name) {
        spdlog::info("Received play state for different player '{}' -- skipping.", message.value().bot);
        return tl::nullopt;
    }
    auto const player_number = magic_enum::enum_cast<PlayerNumber>(message.value().coin_id);
    if (not player_number.has_value()) {
        throw ClientException{ fmt::format("Invalid coin_id '{}' in message.", message.value().coin_id) };
    }
    auto board = Board{};
    for (auto const row : std::views::iota(0u, Board::height)) {
        for (auto const column : std::views::iota(0u, Board::width)) {
            auto const field_value = message.value().board[row][column];
            switch (field_value) {
                case 0:
                    board[column, row] = std::monostate{};
                    break;
                case 1:
                    board[column, row] = Player<PlayerNumber::Player1>{};
                    break;
                case 2:
                    board[column, row] = Player<PlayerNumber::Player2>{};
                    break;
                case 99: {
                    // This is a bomb. We have to find the bomb in the list of bombs.
                    auto const it = std::ranges::find_if(message.value().bombs, [row, column](auto const& bomb) {
                        return bomb.row == row && bomb.col == column;
                    });
                    if (it == message.value().bombs.end()) {
                        throw ClientException{
                            fmt::format("Bomb at position ({}, {}) not found in bomb list.", column, row)
                        };
                    }
                    board[column, row] = Bomb{ static_cast<std::size_t>(it->explode_in_round) };
                    break;
                }
                default:
                    throw ClientException{
                        std::format("Invalid field value '{}' at position ({}, {}).", field_value, column, row)
                    };
            }
        }
    }
    auto const play_state = PlayState{
        player_number.value(),
        static_cast<std::size_t>(message.value().round),
        board,
    };
    return m_make_move_callback(play_state);
}
