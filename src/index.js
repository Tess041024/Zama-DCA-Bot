import 'dotenv/config';
import { ethers } from 'ethers';
import fs from 'fs';

const { RPC_URL, PRIVATE_KEY, PAIR_KEY='USDC-ETH', TIMEOUT_SEC='300' } = process.env;
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY, provider);

const addrFile = new URL('../../packages/contracts/deploy-addresses.json', import.meta.url).pathname;
let addresses = {}; try { addresses = JSON.parse(fs.readFileSync(addrFile, 'utf8')); } catch {}

const ABI = [
  "function openBatch(bytes32 pair) external",
  "function executeBatch(bytes32 pair) external",
  "event BatchExecuted(bytes32 indexed pair, uint256 indexed batchId, uint256 totalIn, uint256 totalOut, uint256 k)"
];

async function main() {
  if (!addresses.Batcher) throw new Error("Provide packages/contracts/deploy-addresses.json with Batcher");
  const batcher = new ethers.Contract(addresses.Batcher, ABI, wallet);
  const pairHash = ethers.keccak256(ethers.toUtf8Bytes(PAIR_KEY));
  while (true) {
    try {
      const tx1 = await batcher.openBatch(pairHash); await tx1.wait();
      console.log("Opened batch");
      await new Promise(r => setTimeout(r, parseInt(TIMEOUT_SEC)*1000));
      const tx2 = await batcher.executeBatch(pairHash); await tx2.wait();
      console.log("Executed batch");
    } catch (e) { console.error(e.message); await new Promise(r => setTimeout(r, 15000)); }
  }
}
main();
