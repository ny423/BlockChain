from brownie import Lottery, accounts, config, network
from web3 import Web3


def test_get_entrance_fee():
    account = accounts[0]
    lottery = Lottery.deploy(
        config["networks"][network.show_active()]["eth_usd_price_feed"],
        {"from": account, "gas_limit": 6721975, "allow_revert": True},
    )
    fee = lottery.getEntranceFee()
    print(f"The entrance fee is ${fee}")
    assert fee > Web3.toWei(0.027, "ether")
    assert fee < Web3.toWei(0.030, "ether")
