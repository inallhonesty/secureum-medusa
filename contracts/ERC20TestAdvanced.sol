pragma solidity 0.8.19;
import "./ERC20Burn.sol";
import "./helper.sol";
import "./IVM.sol";


// Example using an external testing
// See https://secure-contracts.com/program-analysis/echidna/basic/common-testing-approaches.html#external-testing
// Run with medusa fuzz --target contracts/ERC20TestAdvanced.sol --deployment-order ExternalTestingToken

// User is used a proxy account to simulate user specific interaction
contract User{
    constructor() {}
}

contract ExternalTestingToken is PropertiesAsserts{

    ERC20Burn token;

    User alice;

    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    constructor() {
        // Deploy the token
        // All the token belong to the contract
        token = new ERC20Burn();

        assert(token.balanceOf(address(this)) == 10**18);

        alice = new User();

        // Transfer all the token to alice
        token.transfer(address(alice), 10**18);
        
        // Approve all the token from Alice to ExternalTestingToken
        vm.prank(address(alice));
        token.approve(address(this), 10**18);
    }

    // The following test a transfer from
    // Medusa will transfer an arbitrary amount using transferFrom
    // The invariant ensure that the balance was updated by the amount transfered
    function testTransferFrom(uint amount) public{
        
        // Ensure amount is less or equal to alice's balanc
        amount = clampLte(amount, token.balanceOf(address(alice)));
        // Ensure amount is less or equal to alice's approval to this contract
        amount = clampLte(amount, token.allowance(address(alice), address(this)));

        uint balanceBefore = token.balanceOf(address(alice));
        uint balanceBeforeMedusa = token.balanceOf(address(this));

        bool success = token.transferFrom(address(alice), address(this), amount);

        uint balanceAfter = token.balanceOf(address(alice));
        uint balanceAfterMedusa = token.balanceOf(address(this));
        assertEq(success, true, "a successful transfer returns true");
        assertEq(balanceAfter - balanceBefore, amount, "The amount transfered must be equal to the expected amount");
        assertEq(balanceAfterMedusa - balanceBeforeMedusa, amount, "amount transfered equals to amount received");
    }

    function testTransfer(uint amount) public {
        amount = clampLte(amount, token.balanceOf(address(this)));
        uint balanceBefore = token.balanceOf(address(alice));
        uint balanceBeforeMedusa = token.balanceOf(address(this));
        bool success = token.transfer(address(alice), amount);
        uint balanceAfter = token.balanceOf(address(alice));
        uint balanceAfterMedusa = token.balanceOf(address(this));
        assertEq(success, true, "a successful transfer returns true");
        assertEq(balanceAfter - balanceBefore, amount, "amount transfered equals to amount received");
        assertEq(balanceAfterMedusa - balanceBeforeMedusa, amount, "amount transfered equals to amount received");
    }

    function testRemoveAllowance(uint amount) public {

        vm.prank(address(alice));
        bool success1 = token.approve(address(this), amount);
        uint256 intermediaryAllowance = token.allowance(address(alice), address(this));
        vm.prank(address(alice));
        bool success2 = token.approve(address(this), 0);
        uint256 finalAllowance = token.allowance(address(alice), address(this));


        assertEq(intermediaryAllowance, amount, "approve sets the correct allowance");
        assertEq(finalAllowance, 0, "calling the aprove function back to 0 gets the allowance back to 0");
        assertEq(success1, true, "a successful approval returns true");
        assertEq(success2, true, "a successful approval returns true");
        
    }
}