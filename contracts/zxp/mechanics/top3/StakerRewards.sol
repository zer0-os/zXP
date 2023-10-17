import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IStakerRewards} from "./interfaces/ITop3Rewards.sol";

contract StakerRewards is IStakerRewards {
    IERC20 public rewardToken;

    constructor(IERC20 _rewardToken) {
        rewardToken = _rewardToken;
    }
}
