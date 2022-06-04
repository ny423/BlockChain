// SPDX-License-Identifier: MIT

// change the compiler version of solidiy version in settings (Ctrl+,)
pragma solidity >=0.6.0 <0.9.0; // verison of solidity must be 0.6.x ~ 0.9.x

contract SimpleStorage {
    // this will get initialized to 0
    uint256 favouriteNumber;
    bool favouriteBool;

    // struct similar as c++
    struct People {
        uint256 favouriteNumber;
        string name;
    }
    // Constructing a People type object
    People public person = People({favouriteNumber: 2, name: "Patrick"});
    // Constructing a People type (dyanmic) array
    People[] public people; // empty at the beginning

    /*
    Visibility of function/ variables
        if didn't stated by programmer, the default visibility will be internal

        public: most free
        external: can only be called externally (i.e. cannot call store() inside the store function
        internal: can only be called in the same contract and contracts derived from it (maybe contracts inherit from it? idk)
        private: most restricted, cannot be called in derived contracts
    */
    function store(uint256 _favouriteNumber) public returns (uint256) {
        favouriteNumber = _favouriteNumber;
        return favouriteNumber;
    }

    // view : only read the state of the block
    // (similar as const keyword in c++)
    function retrieve() public view returns (uint256) {
        return favouriteNumber;
    }

    // pure: cannot read and modify state variables
    function getResult() public pure returns (uint256 product, uint256 sum) {
        uint256 a = 1;
        uint256 b = 2;
        product = a * b;
        sum = a + b;
    }

    // Data Structure: Mapping
    mapping(string => uint256) public nameToFavouriteNumber;

    /*
    Storage Types (memory vs storage)
        storage: persistent between function calls, more expensive
        memory: used to hole temporary values, cheaper to use (reduce the gas fee)
    */
    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        people.push(People({favouriteNumber: _favouriteNumber, name: _name}));
        nameToFavouriteNumber[_name] = _favouriteNumber; // adding key for mapping
    }
}
