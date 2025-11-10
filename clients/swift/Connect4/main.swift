//
//  main.swift
//  Connect 4
//
//  Created by A1N0S on 26.09.2025.
//

import Foundation

let bot = BotFactory.shared.randomAI()

let urlString = "ws://host.docker.internal:5051/\(bot.name)"

guard let url = URL(string: urlString) else {
    fatalError("❌ Invalid WebSocket URL: \(urlString)")
}

let manager = WebSocketManager(url: url, bot: bot)

manager.connect()
print("🚀 WebSocket connected – waiting for the game to finish…")

// Wait until the socket is closed instead of sleeping forever.
await manager.waitUntilClosed()
print("🔚 WebSocket disconnected – exiting.")
