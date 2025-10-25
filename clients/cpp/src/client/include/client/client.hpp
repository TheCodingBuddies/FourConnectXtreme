#pragma once

#include <client/play_state.hpp>
#include <functional>
#include <memory>
#include <stdexcept>
#include <string>
#include <tl/optional.hpp>

class WebSocket;

enum class Move {
    Column0,
    Column1,
    Column2,
    Column3,
    Column4,
    Column5,
    Column6,
};

class ClientException final : public std::runtime_error {
    using std::runtime_error::runtime_error;
};

class Client final {
private:
    std::unique_ptr<WebSocket> m_web_socket;
    std::string m_name;
    std::function<Move(PlayState const&)> m_make_move_callback;
    std::function<void(void)> m_on_closed_callback;

public:
    explicit Client(
            std::string name,
            int port,
            std::function<Move(PlayState const&)> make_move_callback,
            std::function<void(void)> on_closed_callback
    );
    Client(Client const& other) = delete;
    Client(Client&& other) noexcept = delete;
    Client& operator=(Client const& other) = delete;
    Client& operator=(Client&& other) noexcept = delete;
    ~Client();

private:
    auto handle_message(std::string const& message_string) -> tl::optional<Move>;
};
