using System.Net.WebSockets;
using System.Text;
using System.Text.Json;
using CsClient.Bots;
using CsClient.Bots.Internal;

namespace CsClient.CsharpClient
{
    public class Connect4WebsocketClient : IDisposable
    {
        public delegate void MyMessageReceivedEventHandler(object sender, string message);

        public event EventHandler? OnOpen;
        public event EventHandler? OnClose;
        public event MyMessageReceivedEventHandler? OnMessage;

        private readonly UTF8Encoding _encoding = new();
        private readonly IBot _bot;
        private ClientWebSocket? _webSocket;

        /// <summary>
        /// Verbindet mit Zielurl
        /// </summary>
        /// <param name="uri"></param>
        /// <returns>Das Taskobjekt welches die asynchrone Ausfuehrung repraesentiert</returns>
        public async Task Connect(string uri)
        {
            await Connect(new Uri($"{uri}/{_bot.Name}"));
        }

        /// <summary>
        /// Verbindet mit Zielurl
        /// </summary>
        /// <param name="uri"></param>
        /// <returns>Das Taskobjekt welches die asynchrone Ausfuehrung repraesentiert</returns>
        public async Task Connect(Uri uri) 
        {
            _webSocket?.Dispose();
            _webSocket = new();
            await _webSocket.ConnectAsync(uri, CancellationToken.None);

            OnOpen?.Invoke(this, EventArgs.Empty);
            await Listen();
        }

        /// <summary>
        /// Trennt die Verbindung zum Connect 4 Server.
        /// </summary>
        /// <returns>Das Taskobjekt welches die asynchrone Ausfuehrung repraesentiert</returns>
        public async Task Disconnect()
        {
            if (_webSocket is not null)
            {
                await _webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, "Normal Closure", CancellationToken.None);
                _webSocket.Dispose();
            }
            OnClose?.Invoke(this, EventArgs.Empty);
        }

        /// <summary>
        /// Sendet Nachricht an den Connect 4 Server.
        /// </summary>
        /// <param name="message"></param>
        /// <returns>Das Taskobjekt welches die asynchrone Ausfuehrung repraesentiert</returns>
        public async Task Send(string message)
        {
#if DEBUG
            Console.WriteLine("Send: " + message);
#endif
            await _webSocket!.SendAsync(
                new ArraySegment<byte>(_encoding.GetBytes(message)),
                messageType: WebSocketMessageType.Text,
                endOfMessage: true,
                cancellationToken: CancellationToken.None);
        } 

        public Connect4WebsocketClient(IBot bot)
        {
            _bot = bot;
        }

        private async Task Listen()
        {
            var memoryBuffer = new Memory<byte>(new byte[1024]);
            while (_webSocket?.State == WebSocketState.Open)
            {
                using (var ms = new MemoryStream())
                {
                    ValueWebSocketReceiveResult result;
                    do
                    {
                        result = await _webSocket.ReceiveAsync(memoryBuffer, CancellationToken.None);
                        if (result.MessageType == WebSocketMessageType.Close)
                        {
                            await _webSocket.CloseAsync(WebSocketCloseStatus.NormalClosure, string.Empty, CancellationToken.None);
                            break;
                        }
                        else
                        {
                            await ms.WriteAsync(memoryBuffer[..result.Count]);
                        }
                    }
                    while (!result.EndOfMessage);

                    ms.Seek(0, SeekOrigin.Begin);
                    if (result.MessageType == WebSocketMessageType.Binary)
                    {
                        using (var reader = new StreamReader(ms, _encoding))
                        {
                            var stringData = await reader.ReadToEndAsync();
#if DEBUG
                            Console.WriteLine($"Receive: {stringData}");
#endif
                            OnMessage?.Invoke(this, stringData);
                            await HandleMessage(stringData);
                        }
                    }
                }
            }

        }

        private async Task HandleMessage(string stringData)
        {
            try
            {
                PlayState? playState = JsonSerializer.Deserialize<PlayState>(stringData);
                if (playState is null)
                    throw new JsonException("Unable to Deserialize " + stringData);
                
                // React only to messages when it's your turn
                if (_bot.Name == playState.Bot)
                {
                    string reaction = $"{{\"column\":{JsonSerializer.Serialize(_bot.Play(playState))}}}";
                    await Send(reaction);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Got Ping Message");
                Console.WriteLine("Fehler: " + ex.Message);
            }
        }

        public void Dispose()
        {
            _webSocket?.Dispose();
        }
    }
}
