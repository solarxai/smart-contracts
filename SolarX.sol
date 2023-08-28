//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// @title SolarX token ERC20 contract
/// @notice The SolarX token is the token for solarx.ai. It implements the ERC20 fungible token standard.
/// @dev AccessControl from openzeppelin implementation is used to handle the minter and updater roles.
/// User with DEFAULT_ADMIN_ROLE can grant MINTER_ROLE and UPDATER_ROLE to any address.
/// The DEFAULT_ADMIN_ROLE is intended to be a 2 out of 3 multisig wallet in the beginning and then be moved to governance in the future.

contract SolarX is ERC20, AccessControl {
    using SafeMath for uint256;

    uint256 private MAX_TOTAL_SUPPLY;
    uint256 private MAX_ALLOWED_BURN_AMOUNT;
    uint256 private commissionPercentage;
    uint256 private tP = 100;

    address public advisors;
    address public miningPoolAddress;

    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event MiningPoolAddressUpdated(
        address indexed updater,
        address indexed _newaddress,
        string indexed _type
    );
    event MaxBurnUpdated(address indexed updater, uint256 newAmount);
    event CommissionPercentageUpdated(
        address indexed updater,
        uint256 percentage
    );

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimals,
        address _miningPoolAddress,
        uint256 _MAX_ALLOWED_BURN_AMOUNT,
        uint256 _MAX_TOTAL_SUPPLY,
        uint8 _commissionPercentage
    ) ERC20(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(UPDATER_ROLE, _msgSender());    
        _setupRole(MINTER_ROLE, _msgSender());

        advisors = _msgSender();

        _mint(_msgSender(), initialSupply * (10**decimals));
        require(
            _miningPoolAddress != address(0),
            "Mining Pool Address cannot be null!"
        );

        MAX_TOTAL_SUPPLY = _MAX_TOTAL_SUPPLY * (10**decimals);

        miningPoolAddress = _miningPoolAddress;
        MAX_ALLOWED_BURN_AMOUNT = _MAX_ALLOWED_BURN_AMOUNT * (10**decimals);

        require(
            _commissionPercentage >= 0 && _commissionPercentage <= 10,
            "Percentage must be between 0 and 10"
        );
        commissionPercentage = tP - _commissionPercentage;
    }

    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {

        uint256 userTransaction = amount.mul(commissionPercentage).div(100);
        uint256 commission = amount.sub(userTransaction);

        _transfer(_msgSender(), to, userTransaction);
        _transfer(_msgSender(), miningPoolAddress, commission);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        uint256 userTransaction = amount.mul(commissionPercentage).div(100);
        uint256 commission = amount.sub(userTransaction);

        super.transferFrom(from, to, userTransaction);
        super.transferFrom(from, miningPoolAddress, commission);

        return true;
    }

    /// @notice The mint function is exclusively used for facilitating token transfers between the X chain and Polygon, in either direction.
    /// @dev Only possible for address with the 'MINTER_ROLE'
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount)
        public
        virtual
        onlyRole(MINTER_ROLE)
    {
        uint256 currentSupply = totalSupply();
        require(
            currentSupply + amount <= MAX_TOTAL_SUPPLY,
            "Mint amount exceeds the maximum limit, cannot mint"
        );
        require(to != address(0), "Address must not be zero address");
        _mint(to, amount);
    }

    /// @notice The burn function is exclusively used for facilitating token transfers between the X chain and Polygon, in either direction.
    /// @dev Only possible for advisors address
    /// @param amount The amount of tokens to burn
    function burn(uint256 amount) public virtual {
        require(
            amount <= MAX_ALLOWED_BURN_AMOUNT,
            "Burn amount exceeds the maximum limit"
        );
        require(_msgSender() != address(0), "Address must not be zero address");
        require(_msgSender() == advisors, "Address can't burn tokens");
        _burn(_msgSender(), amount);
    }

    /// @notice Sets the Mining Pool address
    /// @dev Only possible for updater role
    /// @param _miningPoolAddress The new Mining Pool address
    function setMiningPoolAddress(address _miningPoolAddress)
        public
        virtual
        onlyRole(UPDATER_ROLE)
    {
        require(
            _miningPoolAddress != address(0),
            "Address must not be zero address"
        );
        miningPoolAddress = _miningPoolAddress;
        emit MiningPoolAddressUpdated(
            _msgSender(),
            _miningPoolAddress,
            "Mining Pool Address"
        );
    }

    /// @notice Sets commission percentage
    /// @dev Only possible for updater role
    /// @param percentage The new percentage
    function setCommissionPercentage(uint256 percentage)
        public
        virtual
        onlyRole(UPDATER_ROLE)
    {
        require(
            percentage >= 0 && percentage <= 10,
            "Percentage must be between 0 and 100"
        );
        commissionPercentage = tP - percentage;

        emit CommissionPercentageUpdated(_msgSender(), percentage);
    }

    /// @notice Sets the max burn amount
    /// @dev Only possible for updater role
    /// @param amount The new max burn amount
    function setMaxBurn(uint256 amount) public virtual onlyRole(UPDATER_ROLE) {
        require(amount > 0, "MAX_ALLOWED_BURN_AMOUNT must not be zero");
        MAX_ALLOWED_BURN_AMOUNT = amount * (10**18);

        emit MaxBurnUpdated(_msgSender(), amount);
    }

    function maxTotalSupply() public view virtual returns (uint256) {
        return MAX_TOTAL_SUPPLY;
    }

    function maxAllowedBurnAmount() public view virtual returns (uint256) {
        return MAX_ALLOWED_BURN_AMOUNT;
    }

    function currentCommissionPercentage()
        public
        view
        virtual
        returns (uint256)
    {
        return tP - commissionPercentage;
    }
}