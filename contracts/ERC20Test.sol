pragma solidity 0.8.19;
import "./ERC20Burn.sol";
import "./helper.sol";
import "./IVM.sol";


// Run with medusa fuzz --target contracts/ERC20Test.sol --deployment-order MyToken

contract MyToken is ERC20Burn {
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // Test that the total supply is always below or equal to 10**18
    function fuzz_Supply() public returns(bool){
        return totalSupply <= 10**18;
    }
    function fuzz_Decimals() public returns(bool){
        return decimals == 18;
    }

    function fuzz_Name() public returns (bool){
        return keccak256(bytes(name)) == keccak256(bytes("MyToken"));
    }

    function fuzz_TransferReturnsTrueOnSuccess(uint256 amount) public returns (bool) {
        // return transfer(address(0), amount);
        return false;
    }
}

