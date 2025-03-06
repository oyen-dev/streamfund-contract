-include .env

CONTRACT_PATH=src/StreamFund.sol:StreamFund

echo:
	echo $(RPC_URL)
	echo $(CONSTRUCTOR_ARGS)
	echo $(ETHERSCAN_API_KEY)
	echo $(CONTRACT_PATH)

.PHONY: deploy

addAllowedToken:
	forge script \
		--rpc-url $(RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		script/AddAllowedToken.s.sol:AddAllowedToken 

removeAllowedToken:
	forge script \
		--rpc-url $(RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		script/RemoveAllowedToken.s.sol:RemoveAllowedToken

changeFeeCollector:
	forge script \
		--rpc-url $(RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		script/ChangeFeeCollector.s.sol:ChangeFeeCollector

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
# make addAllowedToken
