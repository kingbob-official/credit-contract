pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../../contracts/ERC1155e.sol";
import "../utils/PayableThrowProxy.sol";

contract TestFungible {

    ERC1155E private credit;
    string private uri;
    bool private isNF;
    uint256 private id;
    bool private result;
    address[] private testAccounts;
    uint256[] private quantities;
    PayableThrowProxy private throwProxy;
    ERC1155E private proxyCredit;

    function beforeEach() external {
      credit = new ERC1155E();
      uri = "foo";
      isNF = false;
      result = false;
      id = credit.create(uri, isNF);
      testAccounts = new address[](0);
      testAccounts.push(address(1));
      quantities = new uint256[](0);
      quantities.push(1);
      throwProxy = new PayableThrowProxy(address(credit));
      proxyCredit = ERC1155E(address(throwProxy));
    }

    function testWhenCreditIsNonFungible() external {
      isNF = true;
      id = credit.create(uri, isNF);
      credit.mintNonFungible(id, testAccounts);

      proxyCredit.burnFungible(id, 1);
      (result, ) = throwProxy.execute();
      Assert.isFalse(result, "should not pass since type of credit is non fungible");
    }

    function testQuantities() external {
      credit.mintFungible(id, testAccounts, quantities);

      proxyCredit.burnFungible(id, 1);
      (result, ) = throwProxy.execute();
      Assert.equal(credit.balanceOf(testAccounts[0], id), 0, "credit after being burned should be 0");
      Assert.isTrue(result, "should pass since credit is fungible");

      proxyCredit.burnFungible(id, 1);
      (result, ) = throwProxy.execute();
      Assert.isFalse(result, "should not pass since credit quantity is less than 1");
    }
}
