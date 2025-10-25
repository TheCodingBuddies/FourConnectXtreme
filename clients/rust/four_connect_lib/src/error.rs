use std::fmt;
use tokio::task;
use tokio_tungstenite::tungstenite;

#[derive(Debug, thiserror::Error)]
pub enum BotError {
    Generic(String),

    #[error(transparent)]
    Tungstenite(#[from] tungstenite::Error),

    #[error(transparent)]
    Join(#[from] task::JoinError),
}

impl fmt::Display for BotError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Generic(msg) => write!(formatter, "GenericError: {msg}"),
            Self::Tungstenite(msg) => write!(formatter, "TungsteniteError: {msg}"),
            Self::Join(msg) => write!(formatter, "JoinError: {msg}"),
        }
    }
}

pub type BotResult<T, E = BotError> = Result<T, E>;
