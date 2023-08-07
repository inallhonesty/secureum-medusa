pragma solidity 0.8.19;
import "./ERC20Burn.sol";
import "./helper.sol";
import "./IVM.sol";


// Run with medusa fuzz --target contracts/ERC20Test.sol --deployment-order MyToken

contract MyToken is PropertiesAsserts, ERC20Burn{

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

    function fuzz_Transfer(uint256 amount) public returns (bool) {
        amount = clampLte(amount, balanceOf[msg.sender]);
        transfer(address(1), amount);
        return balanceOf[address(1)] == amount;
    }

    function fuzz_AproveAmountRegistersCorrectly(uint256 amount) public returns (bool) {
        approve(address(1), amount);
        return allowance[msg.sender][address(1)] == amount;
    }

    function fuzz_burn(uint256 amount) public returns (bool) {
        
        amount = clampLt(amount, totalSupply);
        uint256 initialSupply = totalSupply;
        burn(amount);
        return totalSupply == initialSupply - amount;
    }


    function fuzz_mint(uint256 amount) public returns (bool) {
        amount = clampLt(amount, totalSupply);
        burn(amount);

        uint256 initialBalance = balanceOf[msg.sender];
        _mint(msg.sender, amount);
        return totalSupply == initialBalance + amount;
    }

}