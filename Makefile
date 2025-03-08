-include .env

CONTRACT_PATH=src/StreamFund.sol:StreamFund

.PHONY: deploySF changeFeeCollector addAllowedToken removeAllowedToken

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

supportWithToken:
	forge script \
		--rpc-url $(RPC_URL) \
		--private-key $(VIEWER_PK) \
		--broadcast \
		script/SupportWithToken.s.sol:SupportWithToken

supportWithETH:
	forge script \
		--rpc-url $(RPC_URL) \
		--private-key $(VIEWER_PK) \
		--broadcast \
		script/SupportWithETH.s.sol:SupportWithETH

deploySF:
	forge create \
		--rpc-url $(RPC_URL) \
		--constructor-args $(CONSTRUCTOR_ARGS) \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--verify \
		--private-key $(PRIVATE_KEY) \
		$(CONTRACT_PATH)
