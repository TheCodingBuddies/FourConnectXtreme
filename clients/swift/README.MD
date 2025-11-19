# Four Connect Swift Client


Welcome to the Four Connect Swift Client! This project provides a swift client for the [Coding Buddies Four Connext Extreme](https://github.com/TheCodingBuddies/FourConnectXtreme) tournament.

## Prerequisites
| Item | Minimum | Install |
|--|--|--|
| Docker | 20.10 | [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
| Git | - | [https://git-scm.com/install/](https://git-scm.com/downloads)


## Getting Started

How to get started with the random Bot:
1. Clone the repo: 
```bash
git clone https://github.com/TheCodingBuddies/FourConnectXtreme.git
cd FourConnectXtreme
```
2. start the Godot game server
3. run ``docker compose up`` in the swift client directory

How to implement a custom Bot:
1. There is already a class called ``YourSuperCoolBot``. You must only implement the play function of this class.
2. Make sure the ``BotFactory`` class has a function that returns the correct bot that you have implemented.
3. Make sure that in the ``main.swift`` line 10 returns the correct bot: eg: ``let bot = BotFactory.shared.randomAI()``  for the random Bot and ``let bot = BotFactory.shared.yourSuperCoolBot()`` for your custom Bot.
4. Try your code by running: ``docker compose up`` in the swift client directory

## Troubleshooting

Running ``docker compose up`` and it does connect to the Godot game server:
Make sure you have started the game server before running ``docker compose up``.

Warning during ``docker compose up``:
Ignore the ``WARN: SecretsUsedInArgOrEnv: Do not use ARG or ENV instructions`` during the ``docker compose up``. I took the Dockerfile from the official [swift repo](https://github.com/swiftlang/swift-docker/blob/main/6.2/ubuntu/24.04/Dockerfile).  Since Swift does not support Websocket without a specific curl version, I needed to switch from ubuntu 24.04 to ubuntu 25.04 ([check here](https://willhbr.net/2025/10/13/the-6-2nd-stage-of-swift-on-linux/)). These are the only changes I made to the Dockerfile.
