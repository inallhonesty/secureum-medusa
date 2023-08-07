pragma solidity 0.8.19;

import {FixedPointMathLib} from "./FixedPointMathLib.sol";
import "./helper.sol";
import "./IVM.sol";

// Run with medusa fuzz --target contracts/FixedPointMathLibTest.sol --deployment-order FixedPointMathLibTest


contract FixedPointMathLibTest is PropertiesAsserts{
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    // We work with a decimals of 18
    uint decimals = 10**18;

    function testmulWadDown(uint256 x, uint256 y) public{

        // Ensure x and y are geater than 1
        x = clampGte(x, decimals);
        y = clampGte(y, decimals);


        uint z = FixedPointMathLib.mulWadDown(x, y);
        uint zDivX = FixedPointMathLib.divWadDown(z, x);
        uint zDivY = FixedPointMathLib.divWadDown(z, y);

        // Ensure that z <= x and z <= y
        assertGte(z, x, "Z should be more or equal to X");
        assertGte(z, y, "Z should be more or equal to Y");
        assertGte(y, zDivX, "Y should be more or equal to zDivX due to round down of z");
        assertGte(x, zDivY, "X should be more or equal to zDivY due to round down of z");
    }
    
    function testWAD() public {
        assertEq(FixedPointMathLib.WAD, 1e18, "WAD should be 1e18");
    }

    function testMAX_UINT256() public {
        assertEq(FixedPointMathLib.MAX_UINT256, 2**256 - 1, "MAX_UINT256 should be 2**256 - 1");
    }

    function testmulWadDownZero(uint256 x, uint256 y) public{
        
        if (x == 0 && y == 0) {

            uint z = FixedPointMathLib.mulWadDown(x, y);
            assertEq(z, 0, "0 * 0 = 0");
        }
        if (x == 0) {
            y = clampGte(y, decimals);
            uint z = FixedPointMathLib.mulWadDown(x, y);
            assertEq(z, 0, "0 * y = 0");
        }
        if (y == 0) {
            x = clampGte(x, decimals);
            uint z = FixedPointMathLib.mulWadDown(x, y);
            assertEq(z, 0, "x * 0 = 0");
        }


    }
    function testmulWadUp(uint256 x, uint256 y) public{


        x = clampGte(x, decimals);
        y = clampGte(y, decimals);

        // compute z = x * y
        uint z = FixedPointMathLib.mulWadUp(x, y);
        uint zDivX = FixedPointMathLib.divWadUp(z, x);
        uint zDivY = FixedPointMathLib.divWadUp(z, y);

        // Ensure that z <= x and z <= y
        assertGte(z, x, "Z should be more or equal to X");
        assertGte(z, y, "Z should be more or equal to Y");
        assertLte(y, zDivX, "Y should be more or equal to zDivX due to round up of z");
        assertLte(x, zDivY, "X should be more or equal to zDivY due to round up of z");
    }

    function testmulWadUpZero(uint256 x, uint256 y) public{
        
        if (x == 0 && y == 0) {

            uint z = FixedPointMathLib.mulWadUp(x, y);
            assertEq(z, 0, "0 * 0 = 0");
        }
        if (x == 0) {
            y = clampGte(y, decimals);
            uint z = FixedPointMathLib.mulWadUp(x, y);
            assertEq(z, 0, "0 * y = 0");
        }
        if (y == 0) {
            x = clampGte(x, decimals);
            uint z = FixedPointMathLib.mulWadUp(x, y);
            assertEq(z, 0, "x * 0 = 0");
        }
    }

    function testDivWadDown(uint256 x, uint256 y) public{

        // Ensure x and y are greater than 1
        x = clampGte(x, decimals);
        y = clampGte(y, decimals);

        // compute z = x / y
        uint z = FixedPointMathLib.divWadDown(x, y);
        uint zMulY = FixedPointMathLib.mulWadDown(z, y);

        // Ensure that z <= x
        assertLte(z, x, "Z should be less or equal to X");
        assertGte(x, zMulY, "X should be more or equal to zMulY");
        
    }

    function testdivWadDownZero(uint256 x, uint256 y) public{
        
        // This is useful to test the unsafeDiv part of the Lib
        if (x == 0 && y == 0) {

            uint z = FixedPointMathLib.unsafeDiv(x, y);
            assertEq(z, 0, "0 / 0 = 0");
        }
        if (x == 0) {
            y = clampGte(y, decimals);
            uint z = FixedPointMathLib.divWadDown(x, y);
            assertEq(z, 0, "0 / y = 0");
        }
        if (y == 0) {
            x = clampGte(x, decimals);
            uint z = FixedPointMathLib.unsafeDiv(x, y);
            assertEq(z, 0, "x / 0 = 0");
        }
    }


    function testDivWadUp(uint256 x, uint256 y) public{


        // Ensure x and y are greater than 1
        x = clampGte(x, decimals);
        y = clampGte(y, decimals);

        // compute z = x / y
        uint z = FixedPointMathLib.divWadUp(x, y);
        uint zMulY = FixedPointMathLib.mulWadUp(z, y);

        // Ensure that z <= x
        assertLte(z, x, "Z should be less or equal to X");
        assertLte(x, zMulY, "X should be less or equal to zMulY");
        
    }

    
    function testdivWadUpZero(uint256 x, uint256 y) public{
        
        // This is useful to test the unsafeDivUp part of the Lib
        if (x == 0 && y == 0) {

            uint z = FixedPointMathLib.unsafeDivUp(x, y);
            assertEq(z, 0, "0 / 0 = 0");
        }
        if (x == 0) {
            y = clampGte(y, decimals);
            uint z = FixedPointMathLib.divWadUp(x, y);
            assertEq(z, 0, "0 / y = 0");
        }
        if (y == 0) {
            x = clampGte(x, decimals);
            uint z = FixedPointMathLib.unsafeDivUp(x, y);
            assertEq(z, 0, "x / 0 = 0");
        }
    }

    function testRpow(uint256 x, uint256 n, uint256 scalar) public {
        scalar = clampBetween(scalar, 0, 6);
        uint256 z = FixedPointMathLib.rpow(x, n, scalar);
        
        if (x == 0 && n == 0) {
            assertEq(z, scalar, "0 to the power of 0 is 1");
        }

        if (x == 0 && n != 0) {
            assertEq(z, 0, "0 to a non-zero positive number is 0");
        }

        if (x >= 4 * 10 ** scalar && n > 128) {
            assertEq(z, 0, "z reverted because of overflow");
        }

        if (scalar >= x && x != 0 && n != 0) {
            assertLte(z, scalar, "a subunitary x raised to the power of n (while n!=0) < 1");
        }
        
        x = clampGt(x, 1);
        z = FixedPointMathLib.rpow(x, n, scalar);

        if (x > scalar && n > 1 && z != 0) {
            assertGte(z, x, "z in case of a supraunitary x raised to a power n > 1 is bigger than x");
        }
    }

    function sqrtNewton(uint256 x) public pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        result = x / 2 + 1; // Initial guess

        while (result * result > x) {
            result = (result + x / result) / 2; // Update the estimate using Newton's method
        }
    }

    function sqrtBinarySearch (uint256 x) public pure returns (uint256 z) {

        if (x == 0) {
            return 0;
        }

        // Use binary search to find the square root
        uint256 left = 1;
        uint256 right = x;

        while (left <= right) {
            uint256 mid = (left + right) / 2;
            uint256 midSquared = mid * mid;

            if (midSquared == x) {
                return mid;
            } else if (midSquared < x) {
                left = mid + 1;
                z = mid; // Store the best candidate so far
            } else {
                right = mid - 1;
            }
        }
    }


    function testSqrt(uint256 x) public {
        uint256 z = FixedPointMathLib.sqrt(x); 

        if (x == 0) {
            assertEq(z, 0, "sqrt of 0 is 0");
        }

        uint256 sqrtN = sqrtNewton(x);
        uint256 sqrtBS = sqrtBinarySearch(x);

        assertEq(sqrtN, z, "must be equal to sqrt extracted using Newton's method");
        assertEq(sqrtBS, z, "must be equal to sqrt extracted using binary search method");
        assertGte(x, z, "x is greater than z with the exception of 1 and 0 when it's equal");
    
    }

    function testUnsafeModZero(uint256 x, uint256 y) public {
        y = clampLt(y, 1);
        uint256 z = FixedPointMathLib.unsafeMod(x, y);
        assertEq(z, 0, "when y = 0 unsafeMod is 0");
    }
    function testUnsafeModNonZero(uint256 x, uint256 y) public {
        y = clampGt(y, 1);
        uint256 z = FixedPointMathLib.unsafeMod(x, y);
        assertEq(z, x % y, "when y != 0 unsafeMod is x % y");

    }


}