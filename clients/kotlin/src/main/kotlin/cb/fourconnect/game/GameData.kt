package cb.fourconnect.game

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class GameData(
    @SerialName("bot") val bot: String,
    @SerialName("coin_id") val coinId: Int,
    @SerialName("round") val round: Int,
    @SerialName("bombs") val bombs: List<Bomb>,
    @SerialName("board") val board: List<List<Int>>,
)