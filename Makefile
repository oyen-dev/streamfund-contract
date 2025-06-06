-include .env

CONTRACT_PATH=src/StreamFund.sol:StreamFund

.PHONY: deploySF changeFeeCollector addAllowedToken removeAllowedToken deployMockToken supportWithToken supportWithETH

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
		--verify \
		--verifier blockscout \
		--verifier-url $(VERIFIER_URL) \
		--broadcast \
		--private-key $(PRIVATE_KEY) \
		$(CONTRACT_PATH) \
		--constructor-args $(CONSTRUCTOR_ARGS) 

deployMockToken:
	forge create \
		--rpc-url $(RPC_URL) \
		--verify \
		--verifier blockscout \
		--verifier-url $(VERIFIER_URL) \
		--broadcast \
		--private-key $(PRIVATE_KEY) \
		src/ERC20Mock.sol:ERC20Mock \
		--constructor-args $(CONSTRUCTOR_ARGS)
