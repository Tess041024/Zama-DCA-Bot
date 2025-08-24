// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MockRouter {
  receive() external payable {}

  function swapExactTokensForETH(
    uint amountIn,
    uint /*amountOutMin*/,
    address[] calldata /*path*/,
    address to,
    uint /*deadline*/
  ) external returns (uint[] memory amounts) {
    (bool ok, ) = payable(to).call{value: amountIn}("");
    require(ok, "send fail");
    amounts = new uint[](2);
    amounts[0] = amountIn;
    amounts[1] = amountIn;
  }
}