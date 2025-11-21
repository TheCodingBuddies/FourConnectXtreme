//
//  CLIParser.swift
//  Connect 4
//
//  Created by A1N0S on 18.11.2025.
//

import Foundation

struct CLIOptions {
    var bot: String?
    var port: Int?
}

func parseArguments() -> CLIOptions {
    var options = CLIOptions()

    let args = CommandLine.arguments
    // Example: ["./myprog", "--bot", "Alice", "--port", "8080"]
    var index = 1  // skip the program name

    while index < args.count {
        let arg = args[index]

        switch arg {
        case "--bot":
            let nextIndex = index + 1
            if nextIndex < args.count {
                options.bot = args[nextIndex]
                index += 2
            } else {
                // error: --bot given but no value
                print("Error: --bot requires a value")
                exit(1)
            }

        case "--port":
            let nextIndex = index + 1
            if nextIndex < args.count {
                let value = args[nextIndex]
                if let portNum = Int(value) {
                    options.port = portNum
                } else {
                    print("Error: port value '\(value)' is not a valid integer")
                    exit(1)
                }
                index += 2
            } else {
                // error: --port given but no value
                print("Error: --port requires a value")
                exit(1)
            }

        default:
            // Unknown argument — you can handle flags or positional params here
            print("Unknown argument: \(arg)")
            index += 1
        }
    }

    return options
}
