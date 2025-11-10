//
//  BotHelpers.swift
//  Connect 4
//
//  Created by A1N0S on 03.11.2025.
//

import Foundation

@MainActor final class BotFactory {
    static let shared = BotFactory()

    private init() { return }

    func randomAI() -> BotProtocol {
        return RandomAIBot(name: "randomAI")
    }

    func yourSuperCoolBot() -> BotProtocol {
        return YourSuperCoolBot(name: "YourSuperCoolBot")
    }
}

@MainActor final class RandomAIBot: BotProtocol {
    let name: String
    public init(name: String) {
        self.name = name
    }

    @MainActor func play(board: [[Int]], round: Int, bomb: Bomb?) -> Int {
        return Int.random(in: 0...6)
    }
}

@MainActor final class YourSuperCoolBot: BotProtocol {
    let name: String
    public init(name: String) {
        self.name = name
    }

    @MainActor func play(board: [[Int]], round: Int, bomb: Bomb?) -> Int {
        // Implement your code here and return the column as Int
        return 0
    }
}

@MainActor protocol BotProtocol {
    var name: String { get }
    func play(board: [[Int]], round: Int, bomb: Bomb?) -> Int
}
