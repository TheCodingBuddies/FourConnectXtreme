#pragma once

#include <client/client.hpp>
#include <mutex>
#include <condition_variable>

class BaseBot {
private:
    Client m_client;
    std::mutex m_mutex;
    std::condition_variable m_condition_variable;
    bool m_should_end = false;

public:
    BaseBot(std::string name, int const port)
        : m_client{
              std::move(name),
              port,
              [this](PlayState const& state) {
                  return make_move(state);
              },
              [this] { on_connection_closed(); },
          } { }

    BaseBot(BaseBot const& other) = delete;
    BaseBot(BaseBot&& other) noexcept = delete;
    BaseBot& operator=(BaseBot const& other) = delete;
    BaseBot& operator=(BaseBot&& other) noexcept = delete;
    virtual ~BaseBot() = default;

    auto play() -> void {
        auto lock = std::unique_lock{ m_mutex };
        m_condition_variable.wait(lock, [this] { return m_should_end; });
    }

    virtual auto make_move(PlayState const& play_state) -> Move = 0;

private:
    void on_connection_closed() {
        auto const lock = std::lock_guard{ m_mutex };
        m_should_end = true;
        m_condition_variable.notify_all();
    }
};
