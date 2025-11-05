mod error;

use async_trait::async_trait;
use error::BotResult;
use futures_util::{
    stream::{SplitSink, SplitStream},
    SinkExt, StreamExt,
};
use serde::{Deserialize, Serialize};
use tokio::{join, net::TcpStream, sync::mpsc};
use tokio_tungstenite::{connect_async, tungstenite::Message, MaybeTlsStream, WebSocketStream};

#[cfg(feature = "enable-tracing")]
use tracing::{error, info, trace};

#[derive(Deserialize, Debug)]
pub struct Bomb {
    pub row: i32,
    pub col: i32,
    pub explode_in_round: i32,
}
#[derive(Deserialize, Debug)]
pub struct PlayState {
    pub bot: String,
    pub coin_id: i32,
    pub round: i32,
    pub bombs: Vec<Bomb>,
    pub board: Vec<Vec<i32>>,
}

#[derive(Serialize, Debug)]
pub struct Trigger {
    pub state: String,
    pub column: i32,
}

#[async_trait]
pub trait FourConnectConsumer {
    async fn handle_message(&mut self, message: PlayState) -> Trigger;
}

#[derive(Default)]
pub struct FourConnectBot;

impl FourConnectBot {
    pub async fn start<F>(&self, url: &str, name: &str, mut consumer: F) -> BotResult<()>
    where
        F: FourConnectConsumer + Send + 'static,
    {
        #[cfg(feature = "enable-tracing")]
        info!("Starting FourConnectBot");

        let (message_sender, message_receiver) = mpsc::channel::<Trigger>(64);
        let (consumer_sender, mut consumer_receiver) = mpsc::channel::<PlayState>(64);

        let bot_name = name.to_string();
        tokio::spawn(async move {
            while let Some(play_state) = consumer_receiver.recv().await {
                #[cfg(feature = "enable-tracing")]
                trace!("Received play_state for handling: {play_state:?}");
                if play_state.bot == bot_name {
                    let response = consumer.handle_message(play_state).await;

                    #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
                    if let Err(error) = message_sender.send(response).await {
                        #[cfg(feature = "enable-tracing")]
                        error!("{error}");
                    };
                }
            }
        });

        let socket_handler = SocketHandler::new(consumer_sender, message_receiver);
        #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
        if let Err(error) = start_socket(url, name, socket_handler).await {
            #[cfg(feature = "enable-tracing")]
            error!("Failed to start socket: {error}");
        }
        Ok(())
    }
}

struct SocketHandler {
    pub(crate) sender: mpsc::Sender<PlayState>,
    pub(crate) receiver: mpsc::Receiver<Trigger>,
}

impl SocketHandler {
    fn new(sender: mpsc::Sender<PlayState>, receiver: mpsc::Receiver<Trigger>) -> Self {
        Self { sender, receiver }
    }
}

async fn start_socket(url: &str, name: &str, socket_handler: SocketHandler) -> BotResult<()> {
    #[cfg(feature = "enable-tracing")]
    info!("Connecting to WebSocket at: {url}");

    let request = format!("{url}/{name}");
    let (ws_stream, _) = connect_async(request).await?;

    let (write, read) = ws_stream.split();

    let join = tokio::spawn(async move {
        join!(
            read_from_socket(read, socket_handler.sender),
            write_to_socket(write, socket_handler.receiver)
        )
    });

    join.await?;
    Ok(())
}

async fn read_from_socket(
    mut read: SplitStream<WebSocketStream<MaybeTlsStream<TcpStream>>>,
    sender: mpsc::Sender<PlayState>,
) {
    while let Some(Ok(message)) = read.next().await {
        match message {
            Message::Binary(message) => {
                let play_state: PlayState = match serde_json::from_slice(&message) {
                    Ok(state) => state,
                    #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
                    Err(error) => {
                        #[cfg(feature = "enable-tracing")]
                        error!("Failed to deserialize message: {error}");
                        continue;
                    }
                };

                #[cfg(feature = "enable-tracing")]
                trace!("Received binary message: {:?}", play_state);

                #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
                if let Err(error) = sender.send(play_state).await {
                    #[cfg(feature = "enable-tracing")]
                    error!("Failed to send message to channel: {error}");
                }
            }
            #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
            Message::Close(close_frame) => {
                #[cfg(feature = "enable-tracing")]
                info!("Received close frame: {close_frame:?}");
            }
            _ => {
                #[cfg(feature = "enable-tracing")]
                trace!("Received unhandled message type");
            }
        }
    }
}

async fn write_to_socket(
    mut write: SplitSink<WebSocketStream<MaybeTlsStream<TcpStream>>, Message>,
    mut receiver: mpsc::Receiver<Trigger>,
) {
    while let Some(trigger) = receiver.recv().await {
        #[cfg(feature = "enable-tracing")]
        trace!("Sending trigger to WebSocket: {:?}", trigger);

        let message = match serde_json::to_vec(&trigger) {
            Ok(bytes) => bytes,
            #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
            Err(error) => {
                #[cfg(feature = "enable-tracing")]
                error!("Failed to serialize trigger: {:?}", error);
                continue;
            }
        };

        #[cfg_attr(not(feature = "enable-tracing"), allow(unused_variables))]
        if let Err(error) = write.send(Message::Binary(message.into())).await {
            #[cfg(feature = "enable-tracing")]
            error!("Failed to send message over WebSocket: {error}");
        }
    }
}
