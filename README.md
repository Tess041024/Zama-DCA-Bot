Delivery checklist (Demo → Deploy → Maintenance)
Demo flow (Sepolia)

cd packages/contracts && cp .env.example .env → fill SEPOLIA_RPC_URL, PRIVATE_KEY, UNISWAP_V2_ROUTER, WETH.

pnpm i (at workspace root or per package)

Deploy mock USDC → pnpm -C packages/contracts deploy:mockusdc

Deploy batcher → pnpm -C packages/contracts deploy:batcher

Mint yourself → pnpm -C packages/contracts mint

cd packages/contracts/dca-ui && cp .env.example .env → fill VITE_RPC_URL, VITE_USDC_ADDRESS, VITE_BATCHER_ADDRESS from deploy-addresses.json.

pnpm -C packages/contracts/dca-ui dev → open http://localhost:5173

Connect MetaMask, switch to Sepolia if prompted → Open → Approve → Contribute → Execute → Claim.

Production hand‑off

This MVP targets Sepolia. For mainnet, reuse same artifacts and set mainnet Router/WETH.

kTarget and timeoutSec provided at deployment; can be exposed via admin methods in future versions.

Uniswap v2 router must exist on the target chain.

Maintenance & common issues

Chain mismatch: UI has Switch to Sepolia; ensure .env RPC is Sepolia.

ABI errors: Only viem ABIs via parseAbi([...]).

Pending forever: we now wait for receipts; if stuck → check Etherscan → cancel/speed up in MetaMask → ensure enough test ETH.

Approve/allowance issues: re‑approve with a higher amount.

conditions not met on Execute: adjust K_TARGET or wait TIMEOUT_SEC.

USDC decimals: set to 6; use parseUnits(x, 6) in UI/scripts.