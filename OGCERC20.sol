// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/ERC20.sol)

// OGC token contract

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
import "./Timers.sol";


contract OGCERC20 is Context, IERC20, IERC20Metadata {
    using Timers for Timers.BlockNumber;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "OwlGameCoin";
    string private _symbol = "OGC";

    Timers.BlockNumber private _teamAddress1UnlockTime;
    Timers.BlockNumber private _teamAddress2UnlockTime;

    address public _pubOfferAddress;
    address public _teamAddress1;
    address public _teamAddress2;
    address public _inGameAddress;
    address public _foundationAddress;

    constructor() {

        _pubOfferAddress        = 0x8C34C503387810d1BfB7AAC8E450308Db1D523E3;
        _teamAddress1           = 0x873d35BfE469A3a00D2106209125f695983335c3;
        _teamAddress2           = 0xf74Ce83e2C4B9F3E89847EB9e858d67fBd4ed87D;
        _inGameAddress          = 0xdA6e9442AB3E2Abb08CDa52587717319b524231a;
        _foundationAddress      = 0x478989d6802c8db2795AE685483804AcfDd99a8E;

        uint256 countBase           = 10**decimals();
        _mint(_pubOfferAddress,     2000000000 * countBase);
        _mint(_teamAddress1,        500000000 * countBase);
        _mint(_teamAddress2,        1000000000 * countBase);
        _mint(_inGameAddress,       5000000000 * countBase);
        _mint(_foundationAddress,   1500000000 * countBase);

        uint64 teamAddr1UnlockBlockNum = uint64(block.number) + 16000000;
        _teamAddress1UnlockTime = Timers.BlockNumber(teamAddr1UnlockBlockNum);

        uint64 teamAddr2UnlockBlockNum = uint64(block.number) + 30000000;
        _teamAddress2UnlockTime = Timers.BlockNumber(teamAddr2UnlockBlockNum);
    }

    function teamAddress1UnlockBlockNum() public view returns (uint64)
    {
        return _teamAddress1UnlockTime.getDeadline();
    }

    function isTeamAddress1Unlock() public view returns (bool)
    {
        return _teamAddress1UnlockTime.isExpired();
    }

    function teamAddress2UnlockBlockNum() public view returns (uint64)
    {
        return _teamAddress2UnlockTime.getDeadline();
    }

    function isTeamAddress2Unlock() public view returns (bool)
    {
        return _teamAddress2UnlockTime.isExpired();
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }


        return true;
    }

    function _requireUnlockedAddress(address chkAddress) internal view {
        if (chkAddress == _teamAddress1)
        {
            require(isTeamAddress1Unlock(), "team address1 not unlock");
            return;
        }
        if (chkAddress == _teamAddress2)
        {
            require(isTeamAddress2Unlock(), "team address2 not unlock");
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _requireUnlockedAddress(sender);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _requireUnlockedAddress(owner);

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
