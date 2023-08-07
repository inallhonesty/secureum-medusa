pragma solidity 0.8.19;
import {SignedWadMath} from "./SignedWadMath.sol";
import "./helper.sol";

import "./IVM.sol";

// Run with medusa fuzz --target contracts/SignedWadMathTest.sol --deployment-order SignedWadMathTest




contract SignedWadMathTest is PropertiesAsserts{
    IVM vm = IVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    int256 internal constant WAD = 1e18;

    function testToWadUnsafe(uint256 x) public{

        x = clampLte(x, 2 ** 195);

        int256 y = SignedWadMath.toWadUnsafe(x);



        assertLte(x, uint(y), "X should be less or equal to Y");
        assertEq(x, uint(y) / 1e18, "should work backwards");
    }

    function testToDaysWadUnsafe(uint256 x) public{

        x = clampLte(x, 2 ** 195);

        int256 y = SignedWadMath.toDaysWadUnsafe(x);


        assertLte(x, uint(y), "X should be less or equal to Y");
        assertGte(x, uint(y) * 86400 / 1e18, "should work backwards");
    }

    function testFromDaysWadUnsafe(int256 x) public{

        x = clampBetween(x, 0, 2 ** 239);

        uint256 y = SignedWadMath.fromDaysWadUnsafe(x);


        assertGte(uint(x), y, "X should be greater or equal to Y");
        assertGte(uint(x), y * 1e18 / 86400, "should work backwards");
    }

    function testUnsafeWadMul(int256 x, int256 y) public {
        if (x == 0 || y == 0) {
            int256 z = SignedWadMath.unsafeWadMul(x, y);
            assertEq(z, 0, "0 multiplied with anything is 0");
        }

        if (x < 0 && y < 0) {
            int256 x = clampBetween(x, -2 ** 127, -1);
            int256 y = clampBetween(y, -2 ** 127, -1);
            int256 z = SignedWadMath.unsafeWadMul(x, y);
            assertGte(z, 0, "- * - = +");
            assertLte(z * (-1), x / 1e18, "-z < x");
            assertLte(z * (-1), y / 1e18, "-z < y");
        }
        

        if (x > 0 && y > 0) {
            int256 x = clampBetween(x, 1, 2 ** 127);
            int256 y = clampBetween(y, 1, 2 ** 127);

            int256 z = SignedWadMath.unsafeWadMul(x, y);

            assertLte(x / 1e18, z, "z >= x if it doesn't overflow");
            assertLte(y / 1e18, z, "z >= y if it doesn't overflow");
        }

        if (x > 0 && y < 0) {
            int256 x = clampBetween(x, 1, 2 ** 127);
            int256 y = clampBetween(y, -2 ** 127, -1 );
            int256 z = SignedWadMath.unsafeWadMul(x, y);

            assertLte(z, 0, "- * + = -");
        }

        if (x < 0 && y > 0) {
            int256 y = clampBetween(y, 1, 2 ** 127);
            int256 x = clampBetween(x, -2 ** 127, -1 );
            int256 z = SignedWadMath.unsafeWadMul(x, y);

            assertLte(z, 0, "- * + = -");
        }

    }

    function testUnsafeWadDivZero(int256 x, int256 y) public {
        int z = SignedWadMath.unsafeWadDiv(x, y);

        if (y == 0) {
            assertEq(z, y, "division by 0 returns 0");
        } else {
            assertEq(z, x * 1e18 / y, "normal division if y != 0");
        }
    }

    function testWadMul(int256 x, int256 y) public {
        if (x == 0 || y == 0) {
            int z = SignedWadMath.wadMul(x, y);
            assertEq(z, 0, "0 * anything = 0");
        }

        if (x < 0 && y < 0) {
            int256 x = clampBetween(x, -2 ** 127, -1);
            int256 y = clampBetween(y, -2 ** 127, -1);

            int256 z = SignedWadMath.wadMul(x, y);
            assertGte(z, 0, "- * - = +");
            assertLte(z * (-1), x / 1e18, "-z < x");
            assertLte(z * (-1), y / 1e18, "-z < y");
        }
        

        if (x > 0 && y > 0) {
            int256 x = clampBetween(x, 1, 2 ** 127);
            int256 y = clampBetween(y, 1, 2 ** 127);

            int256 z = SignedWadMath.unsafeWadMul(x, y);

            assertLte(x / 1e18, z, "z >= x if it doesn't overflow");
            assertLte(y / 1e18, z, "z >= y if it doesn't overflow");
        }

        if (x > 0 && y < 0) {
            int256 x = clampBetween(x, 1, 2 ** 127);
            int256 y = clampBetween(y, -2 ** 127, -1 );
            int256 z = SignedWadMath.unsafeWadMul(x, y);

            assertLte(z, 0, "- * + = -");
        }

        if (x < 0 && y > 0) {
            int256 y = clampBetween(y, 1, 2 ** 127);
            int256 x = clampBetween(x, -2 ** 127, -1 );
            int256 z = SignedWadMath.unsafeWadMul(x, y);

            assertLte(z, 0, "- * + = -");
        }
    }

    function testWadDiv(int256 x, int256 y) public {
        if (x < 0 && y < 0) {
        x = clampBetween(x, -2 ** 195, -1);
        int z = SignedWadMath.wadDiv(x, y);
        assertLte(x * 1e18, y * z, "x * 1e18 < y * z if both x and y are negative");
        }

        if (x > 0 && y > 0) {
        x = clampBetween(x, 1, 2 ** 195);
        int z = SignedWadMath.wadDiv(x, y);
        assertGte(x * 1e18, y * z, "x * 1e18 > y * z if both x and y are positive");
        }

        if (x > 0 && y < 0) {
            x = clampBetween(x, 1, 2 ** 195);
            int z = SignedWadMath.wadDiv(x, y);
            assertLte(z, 0, "sign mismatch z is negative");

        }

        if (x < 0 && y > 0) {
            x = clampBetween(x, -2 ** 195, -1);
            int z = SignedWadMath.wadDiv(x, y);
            assertLte(z, 0, "sign mismatch z is negative");
        }
    }

    function testWadExp(int256 x) public {
        x = clampBetween(x, -42 * 2**96 , 136 * 2 ** 96);
        int256 z = SignedWadMath.wadExp(x);
        assertGte(z, 0, "e**x is always positive");
        if (x < 0) {
            assertLt(x, z, "when x<0 you have e^x> 0 >x");
        }
        if (x == 0) {
            assertEq(z, 1e18, "e**0 = 1");
        }
        if (x > 0) {
            assertLt(x + 1, z, "e**x >= 1+x >x");
        }
    }

    function estimateLn(uint256 x, uint256 maxIterations) public pure returns (int256) {
        require(x > 0, "x must be positive");
        require(maxIterations > 0, "maxIterations must be greater than 0");

        int256 result = 0;
        uint256 numerator = x - 1;
        uint256 denominator = x + 1;

        for (uint256 i = 0; i < maxIterations; i++) {
            uint256 term = (numerator * numerator) / denominator;
            result += int256(term) / int256(2 * (i) + 1);
            numerator *= x - 1;
            denominator *= x + 1;
        }

        // Scale the result to get the final approximation of ln(x)
        return (result * int256(2));
    }

    function testWadLn(int256 x) public {

        x = clampBetween(x, 1, 2 ** 96);
        int256 estimatedLn = estimateLn(uint(x), 5);
        int256 z = SignedWadMath.wadLn(x);

        assertLt(z, x, "ln x < x");
        assertLte(z, estimatedLn * 1e18, "z should >= than the estimated value");

    }

    function testUnsafeDiv(int256 x, int256 y) public {
        int z = SignedWadMath.unsafeDiv(x, y);
        if (y == 0) {
            assertEq(z, 0, "z = 0 in case of y = 0");
        } else {
            assertEq(z, x/y, "in absence of 0 case this should be a normal division");
        }
    }

    function testWadPow(int256 x, int256 y) public {
        x = clampBetween(x, 0, 2 ** 30);
        y = clampLt(y, 150);
        int z = SignedWadMath.wadPow(x, y);

        if (z > 1e18) {
        assertGte(z, x, "Result >= Base");
        }
    }
}