// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


interface IERC20 {
function balanceOf(address owner) external view returns (uint256);
function allowance(address owner, address spender) external view returns (uint256);
function approve(address spender, uint256 value) external returns (bool);
function transfer(address to, uint256 value) external returns (bool);
function transferFrom(address from, address to, uint256 value) external returns (bool);
function decimals() external view returns (uint8);
}