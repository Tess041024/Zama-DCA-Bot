// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import {IERC20} from "./IERC20.sol";
import {IIntentVault} from "./Interfaces.sol";

contract IntentVault is IIntentVault {
  IERC20 public immutable USDC;
  address public batcher;
  mapping(address => uint256[]) private _userIntents;
  Intent[] public intents;
  modifier onlyBatcher() { require(msg.sender == batcher, "only batcher"); _; }

  constructor(address usdc) {
    USDC = IERC20(usdc);
    intents.push();
  }
  function setBatcher(address b) external {
    require(batcher == address(0) || msg.sender == batcher, "forbidden");
    batcher = b;
  }
  function depositUSDC(uint256 amount) external {
    require(USDC.transferFrom(msg.sender, address(this), amount), "transferFrom failed");
  }
  function storeIntent(bytes calldata encAmount, bytes calldata encBudget, bytes calldata encFreq, bytes calldata encUntil, bytes calldata encDynRule) external returns (uint256 intentId) {
    intents.push(Intent({ user: msg.sender, fheAmount: encAmount, fheBudget: encBudget, fheUntil: encUntil, fheFreq: encFreq, fheDynRule: encDynRule, createdAt: block.timestamp, active: true }));
    intentId = intents.length - 1;
    _userIntents[msg.sender].push(intentId);
  }
  function cancelIntent(uint256 intentId) external {
    Intent storage it = intents[intentId];
    require(it.user == msg.sender, "not owner");
    require(it.active, "inactive");
    it.active = false;
  }
  function markConsumed(uint256 intentId) external onlyBatcher {
    Intent storage it = intents[intentId];
    if (it.active) it.active = false;
  }
  function userActiveIntents(address user) external view returns (uint256[] memory ids) {
    uint256[] memory all = _userIntents[user];
    uint n; for (uint i=0;i<all.length;i++) if (intents[all[i]].active) n++;
    ids = new uint256[](n);
    uint j; for (uint i=0;i<all.length;i++) if (intents[all[i]].active) ids[j++] = all[i];
  }
}
