-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil zktest

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ZKSYNC_LOCAL_KEY := 0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110

all: clean remove install update build

# Read Help
help:
	@echo "Available make commands:"
	@echo ""
	@echo "General Commands:"
	@echo "  make all          - Clean, remove modules, install dependencies, update, and build the project."
	@echo "  make clean        - Remove build artifacts."
	@echo "  make remove       - Remove git submodules and related files."
	@echo "  make install      - Install required dependencies."
	@echo "  make update       - Update dependencies."
	@echo "  make build        - Compile the project."
	@echo "  make zkbuild      - Compile the project for zkSync."
	@echo "  make format       - Format Solidity files using Foundry."
	@echo "  make snapshot     - Generate a test snapshot."
	@echo ""
	@echo "Testing & Development:"
	@echo "  make test         - Run all tests."
	@echo "  make zktest       - Run tests on zkSync."
	@echo "  make anvil        - Start Anvil (local Ethereum testnet)."
	@echo "  make zk-anvil     - Start zkSync Anvil testnet."
	@echo ""
	@echo "Deployment Commands:"
	@echo "  make deploy       - Deploy FundMe contract to local network."
	@echo "  make deploy-sepolia - Deploy FundMe contract to Sepolia."
	@echo "  make deploy-zk    - Deploy FundMe contract to zkSync local network."
	@echo "  make deploy-zk-sepolia - Deploy FundMe contract to zkSync Sepolia."
	@echo ""
	@echo "Interaction Commands:"
	@echo "  make fund         - Fund the deployed contract."
	@echo "  make withdraw     - Withdraw funds from the deployed contract."
	@echo ""
	@echo "Run 'make <command>' to execute a specific command."

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

zkbuild :; forge build --zksync

test :; forge test

zktest :; foundryup-zksync && forge test --zksync && foundryup

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

zk-anvil :; npx zksync-cli dev start

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy-sepolia:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

# As of writing, the Alchemy zkSync RPC URL is not working correctly 
deploy-zk:
	forge create src/FundMe.sol:FundMe --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args $(shell forge create test/mock/MockV3Aggregator.sol:MockV3Aggregator --rpc-url http://127.0.0.1:8011 --private-key $(DEFAULT_ZKSYNC_LOCAL_KEY) --constructor-args 8 200000000000 --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --legacy --zksync

deploy-zk-sepolia:
	forge create src/FundMe.sol:FundMe --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account default --constructor-args 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF --legacy --zksync


# For deploying Interactions.s.sol:FundFundMe as well as for Interactions.s.sol:WithdrawFundMe we have to include a sender's address `--sender <ADDRESS>`
SENDER_ADDRESS := <sender's address>
 
fund:
	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)