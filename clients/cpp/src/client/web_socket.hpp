#pragma once

#include <functional>
#include <ixwebsocket/IXNetSystem.h>
#include <ixwebsocket/IXUserAgent.h>
#include <ixwebsocket/IXWebSocket.h>
#include <magic_enum/magic_enum.hpp>
#include <memory>
#include <stdexcept>
#include <string>
#include <tl/optional.hpp>

class WebSocketError final : public std::runtime_error {
    using std::runtime_error::runtime_error;
};

class WebSocket final {
private:
    std::unique_ptr<ix::WebSocket> m_web_socket;
    std::function<void(void)> m_on_open;
    std::function<void(void)> m_on_close;
    std::function<tl::optional<std::string>(std::string const& message_string)> m_on_message;
    std::function<void(int status, std::string const& reason)> m_on_error;

public:
    explicit WebSocket(std::string const& url) {
        if (not ix::initNetSystem()) {
            throw WebSocketError{ "Failed to initialize web socket system." };
        }
        m_web_socket = std::make_unique<ix::WebSocket>();
        m_web_socket->setUrl(url);
        m_web_socket->setOnMessageCallback([this](ix::WebSocketMessagePtr const& message) { handle_message(message); });
    }

    WebSocket(WebSocket const& other) = delete;
    WebSocket(WebSocket&& other) noexcept = delete;
    WebSocket& operator=(WebSocket const& other) = delete;
    WebSocket& operator=(WebSocket&& other) noexcept = delete;
    ~WebSocket() = default;

    auto start() -> void {
        m_web_socket->start();
    }

    auto set_on_open_callback(std::function<void(void)> callback) -> void {
        m_on_open = std::move(callback);
    }

    auto set_on_close_callback(std::function<void(void)> callback) -> void {
        m_on_close = std::move(callback);
    }

    auto set_on_message_callback(std::function<tl::optional<std::string>(std::string const& message_string)> callback)
            -> void {
        m_on_message = std::move(callback);
    }

    auto set_on_error_callback(std::function<void(int status, std::string const& reason)> callback) -> void {
        m_on_error = std::move(callback);
    }

private:
    auto handle_message(ix::WebSocketMessagePtr const& message) -> void {
        switch (message->type) {
            using enum ix::WebSocketMessageType;

            case Open:
                if (m_on_open) {
                    m_on_open();
                }
                break;
            case Close:
                if (m_on_close) {
                    m_on_close();
                }
                break;
            case Message:
                if (m_on_message) {
                    if (auto const response = m_on_message(message->str)) {
                        m_web_socket->sendText(response.value());
                    }
                }
                break;
            case Error:
                if (m_on_error) {
                    m_on_error(message->errorInfo.http_status, message->errorInfo.reason);
                }
                break;

            default:
                // ignore
                break;
        }
    }
};
