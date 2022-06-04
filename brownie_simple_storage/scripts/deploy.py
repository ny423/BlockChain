from brownie import accounts, config, SimpleStorage, network
import os


def deploy_simple_storage():
    account = get_account()

    simple_storage = SimpleStorage.deploy({"from": account})
    stored_value = simple_storage.retrieve()
    print(stored_value)
    transaction = simple_storage.store(15, {"from": account})
    transaction.wait(1)
    updated_stored_value = simple_storage.retrieve()
    print(updated_stored_value)


def get_account():
    # First method
    # getting our address from one of the generated ganache fake address
    # account = accounts[0]
    # account = get_account()

    # Second method
    # getting our account from adding it to brownie
    # It requires us to input the encrypted password to view the address
    # account = accounts.load("freecodecamp-account")

    # Third Method
    # account = accounts.add(os.getenv("PRIVATE_KEY"))
    # account = accounts.add(config["wallets"]["from_key"])
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def main():
    deploy_simple_storage()
