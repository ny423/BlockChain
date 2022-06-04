from itertools import chain
import json
from solcx import compile_standard, install_solc
from web3 import Web3  # read more about web3 from its doc
import os
from dotenv import load_dotenv

# *Load the environment variables
load_dotenv()

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    # print(simple_storage_file)

# exit()
# print("Installing solidity 0.6.0...")
# install_solc("0.6.0")
# print("Installing Done!")

# *Compile our solidity file
# *Read the doc of py-solc-x to know more about this part
# compiling Solidity source code
compiled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {
                    "*": ["abi", "metadata", "evm.bytecode", "evm.bytecode.sourceMap"]
                }
            }
        },
    },
    solc_version="0.6.0",
)
# print(compiled_sol)

# saving the compiled code to a json file
with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)

# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# for connecting to ganache
# w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))
# chain_id = 1337
# my_address = "0x90F8bf6A479f320ead074411a4B0e7944Ea8c9C1"

# for connecting to rinkby
w3 = Web3(
    Web3.HTTPProvider("https://rinkeby.infura.io/v3/1bcabb6ad69e45d9a71c185d64152fad")
)
chain_id = 4
# getting the private key and address from metamask
my_address = "0x853673BB045Be4F57F275e3F3074cb8a054Bd324"

# ! Do not hard code the private key!!!
# private_key = "0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d"

# Don't do this also
# from key import key
# private_key = key

# *Do this instead
private_key = os.getenv("PRIVATE_KEY")

# Create the contract in python
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# get the latest transaction
nonce = w3.eth.getTransactionCount(my_address)
# print(nonce)  # 0 if the address haven't made any transactions before

# TODO 1. Build a transaction
transaction = SimpleStorage.constructor().buildTransaction(
    {
        "chainId": chain_id,
        "gasPrice": w3.eth.gas_price,
        "from": my_address,
        "nonce": nonce,
    }
)
# print(transaction)

# TODO 2. Sign a transaction
signed_txn = w3.eth.account.sign_transaction(transaction, private_key=private_key)
# print(signed_txn)

# TODO 3. Send a transaction
print("Deploying contract...")
tx_hash = w3.eth.send_raw_transaction(signed_txn.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)  # Optional
print("Deployed!")

# Working with the contract you always need:
# contract address
# contract ABI
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)
# Call -> Simulate making the call and getting a return value
# Transact -> Actually make a state change

# Creating a contract call
print(simple_storage.functions.retrieve().call())
print("Updating contract...")
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "chainId": chain_id,
        "gasPrice": w3.eth.gas_price,
        "from": my_address,
        "nonce": nonce + 1,
    }
)
signed_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)
send_store_tx = w3.eth.send_raw_transaction(signed_store_txn.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(send_store_tx)
print("Updated Contract!")
print(simple_storage.functions.retrieve().call())  # printing out 15 after we store it
