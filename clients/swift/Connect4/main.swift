//
//  main.swift
//  Connect 4
//
//  Created by A1N0S on 26.09.2025.
//

import Foundation

let opts = parseArguments()

guard let botName = opts.bot else { fatalError("No bot name provided.") }
print("Bot name: \(botName)")

guard let port = opts.port else { fatalError("No port provided.") }
print("Port: \(port)")

var bot: BotProtocol
switch botName {
    case "randomAI":
        bot = BotFactory.shared.randomAI()
    case "yourSuperCoolBot":
        bot = BotFactory.shared.yourSuperCoolBot()
    default:
        fatalError("No bot with that Name")
}

let urlString = "ws://host.docker.internal:\(port)/\(botName)"

guard let url = URL(string: urlString) else {
    fatalError("❌ Invalid WebSocket URL: \(urlString)")
}

let manager = WebSocketManager(url: url, bot: bot)
manager.connect()
print("🚀 WebSocket connected – waiting for the game to finish…")

// Wait until the socket is closed instead of sleeping forever.
await manager.waitUntilClosed()
print("🔚 WebSocket disconnected – exiting.")
