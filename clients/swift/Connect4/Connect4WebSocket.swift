//
//  Connect4WebSocket.swift
//  Connect 4
//
//  Created by A1N0S on 31.10.2025.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

@MainActor final class WebSocketManager: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private let bot: BotProtocol

    // Continuation that will be resumed when the socket closes
    private var closeContinuation: CheckedContinuation<Void, Never>?

    init(url: URL, bot: BotProtocol) {
        self.url = url
        self.bot = bot
    }

    func connect() {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        self.receiveMessage()
    }

    func waitUntilClosed() async {
        await withCheckedContinuation { cont in
            self.closeContinuation = cont
        }
    }

    func send(message: Data) {
        let message = URLSessionWebSocketTask.Message.data(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                case .data(let data):
                    print("Received data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")
                    DispatchQueue.main.sync {
                        do {
                            let response: WebSocketResponse = try data.decoded()
                            print("Received Data for Bot: \(response.bot)")
                            if response.bot == self.bot.name {
                                let col = self.bot.play(board: response.board, bomb: response.bombs.first)
                                let messageData = "{\"state\": \"play\", \"column\": \(col)}".data(using: .utf8)!
                                self.send(message: messageData)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                @unknown default:
                    print("Received unknown message type")
                }

                Task { @MainActor in
                    self.receiveMessage()
                }
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
            }
        }
    }

    func close(code: URLSessionWebSocketTask.CloseCode = .normalClosure, reason: Data? = nil) {
        webSocketTask?.cancel(with: code, reason: reason)
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    nonisolated public func urlSession(_ session: URLSession,
                                webSocketTask: URLSessionWebSocketTask,
                                didOpenWithProtocol protocol: String?) {
        print("WebSocket did connect")
    }

    nonisolated public func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        print("WebSocket did disconnect with code: \(closeCode.rawValue)")
        DispatchQueue.main.sync {
            closeContinuation?.resume()
        }
    }
}

extension Data {
    @inline(__always)
    func decoded<T: Decodable>(as type: T.Type = T.self,
                               decoder: JSONDecoder? = nil) throws -> T {
        let dec = decoder ?? Self.sharedDecoder
        return try dec.decode(T.self, from: self)
    }

    private static let sharedDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
}

struct WebSocketResponse: Decodable {
    let board: [[Int]]
    let bombs: [Bomb]
    let bot: String
    let coin_id: Int
    let round: Int
}

struct Bomb: Decodable {
    let row: Int
    let col: Int
    let explode_in_round: Int
}
