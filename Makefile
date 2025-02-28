-include .env

CONTRACT_PATH=src/StreamFund.sol:StreamFund

echo:
	echo $(RPC_URL)
	echo $(CONSTRUCTOR_ARGS)
	echo $(ETHERSCAN_API_KEY)
	echo $(CONTRACT_PATH)

.PHONY: deploy

deploy:
	forge create \
		--rpc-url $(RPC_URL) \
		--constructor-args $(CONSTRUCTOR_ARGS) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--verify \
		--private-key $(PRIVATE_KEY) \
		$(CONTRACT_PATH)

# Usage:
# source .env
# make deploy
