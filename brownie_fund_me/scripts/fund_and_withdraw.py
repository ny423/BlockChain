from brownie import FundMe
from scripts.helpful_scripts import *


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    print(f"The current entrance fee is {entrance_fee}")
    print("Funding...")
    fund_me.fund(
        {
            "from": account,
            # "gas_limit": 6721975,
            "value": entrance_fee,
            # "allow_revert": True,
        }
    )


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from": account, "gas_limit": 6721975, "allow_revert": True})


def main():
    try:
        fund()
    except ValueError:
        print("ValueError occurred for fund function...\n")
    withdraw()
