
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


import { IERC20 } from "./IERC20.sol";
import { IUniswapRouter } from "./IUniswapRouter.sol";
import { IIntentVault } from "./Interfaces.sol";


/**
* @title Batcher (MVP)
* @notice Collects USDC contributions into a batch, swaps once USDC->ETH via UniswapV2, and records claimable ETH per user.
*/
contract Batcher {
IERC20 public immutable USDC;
IUniswapRouter public immutable router;
IIntentVault public immutable vault;
address public immutable WETH;
bytes32 public immutable pairKey;
}

uint256 public kTarget;
uint256 public timeoutSec;


struct BatchSlot {
uint256 openedAt;
bool executed;
uint256 totalIn; // USDC collected
uint256 totalOut; // ETH received
address[] users;
mapping(address => uint256) contrib;
mapping(address => bool) seen;
}


mapping(bytes32 => BatchSlot) private _batches; // one open slot per pairKey
uint256 public batchCounter; // increments at execute


// claimable[batchId][user] = ETH amount
mapping(uint256 => mapping(address => uint256)) public claimable;


event BatchOpened(bytes32 indexed pair, uint256 openedAt);
event Contributed(bytes32 indexed pair, address indexed user, uint256 amount);
event BatchExecuted(bytes32 indexed pair, uint256 indexed batchId, uint256 totalIn, uint256 totalOut, uint256 k);
event Claimed(uint256 indexed batchId, address indexed user, uint256 amount);


constructor(
address usdc,
address uniRouter,
address _vault,
address _weth,
bytes32 _pairKey,
uint256 _kTarget,
uint256 _timeoutSec
) {
USDC = IERC20(usdc);
router = IUniswapRouter(uniRouter);
vault = IIntentVault(_vault);
WETH = _weth;
pairKey = _pairKey;
kTarget = _kTarget;
timeoutSec = _timeoutSec;
}


// --- batching API ---


function openBatch(bytes32 pair) external {
require(pair == pairKey, "pair mismatch");
BatchSlot storage b = _batches[pair];
require(b.openedAt == 0 || b.executed, "already open");


// reset previous bookkeeping to avoid stale contribs
for (uint256 i = 0; i < b.users.length; i++) {
address u = b.users[i];
b.contrib[u] = 0;
b.seen[u] = false;
}
delete b.users;


b.openedAt = block.timestamp;
b.executed = false;
}