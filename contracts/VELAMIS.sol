import "./libs/IERC20.sol";
import "./libs/SafeMath.sol";
import "./libs/Address.sol";
import "./libs/Context.sol";

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract Velamis is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    address public constant ManageWallet = 0x6742e82826f03F69B46D86FF2Afaf870F9A188c6;
    address public constant PrivSaleWallet = 0x2f609c920c78535bF3aE62B92ffb131Cb37b03EB;
    address public constant PubSaleWallet = 0xd0BDc14f6457511655E2290c56FdAd5a3F96Ddea;
    address public constant AdvisoryWallet = 0x1fa257b5aA21e21bD6fa0f421638661b8A422902;
    address public constant TeamWallet = 0x7De8E2b7f921Ba243454B30406076a89FDf7c343;
    address public constant EcoGrowthWallet = 0x5b58E5DF395F87Ce0cd2A677b9a48Cbb7cB3a843;
    address public constant CompanyWallet = 0x333431Cdae737Cd1BF6ad26C22e443700710d819;
    address public constant TreasuryWallet = 0xA9ED9C85A7Cc10ED3Cb439934a25D737C6b8d006;
    address public constant StakingRewardWallet = 0x44a7CC9762C267180e0E09d56a84D70629258e29;
    address public constant PauseWallet = 0x13200C0FAC543e5A7f85791e65Bea038fE6eE25d;

    uint public constant PrivSalePercent = 5;
    uint public constant PubSalePercent = 10;
    uint public constant AdvisoryPercent = 5;
    uint public constant TeamPercent = 5;
    uint public constant EcoGrowthPercent = 10;
    uint public constant CompanyPercent = 20;
    uint public constant TreasuryPercent = 25;
    uint public constant StakingRewardPercent = 20;

    uint[] public IssuancePercent = [
        2222, 2397, 3040, 3294, 4253, 4507, 5441, 
        5623, 6434, 6615, 7328, 7455, 8015, 8142, 
        8690, 8781, 9234, 9807, 9879, 9952, 10000
    ];

    mapping(address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = "VELAMIS";
    string private _symbol = "VEL";
    uint8 private _decimals = 18;
    uint256 private _totalSupply;
    uint256 private _marketCap;
    bool[] private _distributed; 

    uint256 public burnFee = 10; // Burn Fee
    uint256 public constant intervalIssuance = 30 * 24 * 3600; 
    uint public issuanceIndex = 0;
    uint256 public issuanceTime;
    uint256 public burnTime;
    bool public status;
    uint256 public starttime;
    uint256 public totalBurnedTokens;
        
    constructor () {
        _marketCap = 300_000_000 * (10 ** _decimals);
        _totalSupply = 0;
        status = true;

        issuanceTime = starttime;
        issuanceIndex = 0;
        totalBurnedTokens = 0;
        _distributed = new bool[](8);
        for(uint i = 0; i < 8; i++) _distributed[i] = false;
    }

    modifier onlyStopper() {
        require(_msgSender() == PauseWallet, "VELAMIS: caller isn't stopper of the contract");
        _;
    }

    modifier onlyManager() {
        require(_msgSender() == ManageWallet, "VELAMIS: caller isn't manager of the contract");
        _;
    }

    modifier isRunning() {
        require(status, "VELAMIS: contract is stopped");
        _;
    }

    function pauseContract() external onlyStopper {
        status = false;
    }

    function issueTokens() external onlyManager isRunning{
        require(issuanceIndex <= 20, "VELAMIS: token issuace is ended");
        require(block.timestamp >= issuanceTime, "VELAMIS: it isn't the issuace time now");
        uint256 amount;
        if(issuanceIndex > 0) amount = _marketCap * (IssuancePercent[issuanceIndex] - IssuancePercent[issuanceIndex -1]) / 10000;
        else amount = _marketCap * IssuancePercent[issuanceIndex] / 10000;
        _balances[ManageWallet] += amount;
        _totalSupply += amount;
        issuanceTime += intervalIssuance;
        issuanceIndex = issuanceIndex + 1;
        emit Transfer(address(0), ManageWallet, amount);
    }

    function distributeTokens(uint8 index) external onlyManager isRunning{
        require(index < 8, "VELAMIS: index must be less than 8.");
        require(!_distributed[index], "VELAMIS: distribution with this index had already done.");
        address wallet;
        uint percent;
        if(index == 0) { wallet = PrivSaleWallet; percent = PrivSalePercent;}
        else if(index == 1) { wallet = PubSaleWallet; percent = PubSalePercent;}
        else if(index == 2) { wallet = AdvisoryWallet; percent = AdvisoryPercent;}
        else if(index == 3) { wallet = TeamWallet; percent = TeamPercent;}
        else if(index == 4) { wallet = EcoGrowthWallet; percent = EcoGrowthPercent;}
        else if(index == 5) { wallet = CompanyWallet; percent = CompanyPercent;}
        else if(index == 6) { wallet = TreasuryWallet; percent = TreasuryPercent;}
        else if(index == 7) { wallet = StakingRewardWallet; percent = StakingRewardPercent;}

        uint256 amount = _marketCap * percent / 100;
        _transfer(ManageWallet, wallet, amount);
    }

    function burnTokens(uint256 amount) external onlyManager isRunning{
        uint256 _burnamount = amount * burnFee / 100;
        uint256 maxBurnedTokens = _marketCap * 50 / 100;
        require(totalBurnedTokens < maxBurnedTokens, "VELAMIS: tokens have already burned");
        if(totalBurnedTokens + _burnamount > maxBurnedTokens) _burnamount = maxBurnedTokens - totalBurnedTokens;
        
        _burn(ManageWallet, _burnamount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public override isRunning returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override isRunning returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override isRunning returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override isRunning returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public isRunning returns (bool)  {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public isRunning returns (bool)  {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "VELAMIS: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "VELAMIS: transfer from the zero address");
        require(to != address(0), "VELAMIS: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "VELAMIS: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "VELAMIS: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "VELAMIS: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "VELAMIS: approve from the zero address");
        require(spender != address(0), "VELAMIS: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "VELAMIS: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}