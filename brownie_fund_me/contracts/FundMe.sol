//SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

// importing the Interface from chainlink's github file
// OR you can google "npm @chainlink/contracts" and find the github page to look for the source code
// https://github.com/smartcontractkit/chainlink
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

// Interface is an Abstract Base Class in c++
// only have functions and variable declared and won't be called directly
// this interface have been imported from the chainlink github file, so we commend it out
/*
interface AggregatorV3Interface {
  function decimals()
    external
    view
    returns (
      uint8
    );
  function description()
    external
    view
    returns (
      string memory
    );
  function version()
    external
    view
    returns (
      uint256
    );
   getRoundData and latestRoundData should both raise "No data present"
   if they do not have data to report, instead of returning unset values
   which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}*/

// Anytime you want to interact with an already deployed smart contract, you will need an ABI
// Interfaces compile down to an ABI (Application Binary Interface)
// The ABI tells solidity and other programming languages how it can interact with anothrer contract
contract FundMe {
    using SafeMathChainlink for uint256; // prevent integer overflow

    mapping(address => uint256) public addressToAmountFunded;
    uint256 public transaction = 0;

    address public owner;
    address[] public funders; // for resetting the values in the mapping
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        // the owner of the contract would be set to who pay and run this contract
        owner = msg.sender;
    }

    // 1e18 Wei = 1 ETH
    function fund() public payable {
        // $50
        uint256 minimumUSD = 50 * 10**8;
        // if (msg.value < minimumUSD){ revert;}
        transaction = getConversionRate(msg.value);
        require(transaction >= minimumUSD, "You need to spend more ETH");

        // 20000000000000000
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        // what's the ETHUSD price?
    }

    function getVersion() public view returns (uint256) {
        // This have been done in the constructor
        // address RinkbyTestNetETHUSD = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     RinkbyTestNetETHUSD
        // );
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        address RinkbyTestNetETHUSD = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            RinkbyTestNetETHUSD
        );
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        /*
        // Turple
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();*/

        // To omit the excess unused values stored
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
        // should get sth like 3128, which is 1 ETH = 3,128.82040500 USD
    }

    // 1,000,000,000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        // the default unit of ETH is GWei here
        // Convert Wei back into ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / (10**8);
        return ethAmountInUsd;
    }

    // 0.0926ETH = 92600000000000000 Wei = 29001579200 = 290.01579200 USD at this moment

    // Modifier is used to change the behaviour of a function in a declarative way
    modifier onlyOwner() {
        // _; // can also put in front of the condition
        require(msg.sender == owner); // run this code first
        _; // run the rest of the code if the above condition is true
    }

    /*
    function withdraw() payable public{
      // only want the contract admin/owner to access this function
      require(msg.sender==owner, "You are not the owner!");
      msg.sender.transfer(address(this).balance);
    }*/

    // Same of the above code but declared the condition explicitly
    function withdraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        // resetting the mapping
        for (uint256 i = 0; i < funders.length; i++) {
            addressToAmountFunded[funders[i]] = 0;
        }
        // resetting funders array by assigning a new 0 array to it
        funders = new address[](0);
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }
}
