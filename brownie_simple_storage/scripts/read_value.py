from asyncore import read
from brownie import SimpleStorage, accounts, config


def read_contract():
    # taking the last deployed contract address
    simple_storage = SimpleStorage[-1]
    print(simple_storage.retrieve())


def main():
    read_contract()
