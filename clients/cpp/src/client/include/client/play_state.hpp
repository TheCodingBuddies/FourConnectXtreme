#pragma once

#include <array>
#include <string>
#include <tl/optional.hpp>
#include <variant>

enum class PlayerNumber {
    Player1 = 1,
    Player2 = 2,
};

template<PlayerNumber number>
struct Player {
    static constexpr auto player_number = number;
};

struct Bomb final {
    std::size_t explodes_in_turn;

    explicit Bomb(std::size_t const explodes_in_turn) : explodes_in_turn{ explodes_in_turn } { }
};

using Field = std::variant<std::monostate, Player<PlayerNumber::Player1>, Player<PlayerNumber::Player2>, Bomb>;

class Board final {
public:
    static constexpr auto width = std::size_t{ 7 };
    static constexpr auto height = std::size_t{ 6 };

private:
    std::array<Field, width * height> m_fields{};

public:
    Board() = default;

    auto operator[](this auto&& self, std::size_t const column, std::size_t const row) -> decltype(auto) {
        return self.m_fields[row * width + column];
    }
};

class PlayState final {
private:
    PlayerNumber m_coin_id;
    std::size_t m_round;
    Board m_board;

public:
    explicit PlayState(PlayerNumber const coin_id, std::size_t const round, Board const& board)
        : m_coin_id{ coin_id },
          m_round{ round },
          m_board{ board } { }

    [[nodiscard]] auto round() const -> std::size_t {
        return m_round;
    }

    [[nodiscard]] auto board() const -> Board const& {
        return m_board;
    }

    auto is_empty(std::size_t const column, std::size_t const row) const -> bool {
        return std::holds_alternative<std::monostate>(board()[column, row]);
    }

    auto is_mine(std::size_t const column, std::size_t const row) const -> bool {
        if (m_coin_id == PlayerNumber::Player1) {
            return std::holds_alternative<Player<PlayerNumber::Player1>>(board()[column, row]);
        }
        return std::holds_alternative<Player<PlayerNumber::Player2>>(board()[column, row]);
    }

    auto is_opponent(std::size_t const column, std::size_t const row) const -> bool {
        if (m_coin_id == PlayerNumber::Player1) {
            return std::holds_alternative<Player<PlayerNumber::Player2>>(board()[column, row]);
        }
        return std::holds_alternative<Player<PlayerNumber::Player1>>(board()[column, row]);
    }

    auto is_bomb(std::size_t const column, std::size_t const row) const -> tl::optional<std::size_t> {
        if (auto const& field = board()[column, row]; std::holds_alternative<Bomb>(field)) {
            return std::get<Bomb>(field).explodes_in_turn;
        }
        return tl::nullopt;
    }
};
