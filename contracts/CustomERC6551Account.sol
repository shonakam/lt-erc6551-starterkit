// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
// import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
// import "@openzeppelin/contracts/interfaces/IERC165.sol";
// import "@openzeppelin/contracts/interfaces/IERC721.sol";
// import "@openzeppelin/contracts/interfaces/IERC1271.sol";
// import "./latest6551/interface/IERC6551Account.sol";



// contract CustomERC6551Account is IERC165, IERC1271, IERC6551Account {
	
// 	uint256 private _nonce;
// 	string public accountName = "Custom ERC6551 Token Owned Account";
// 	uint256 public depositCount = 0;
// 	mapping(uint256 => Deposit) public deposits;
// 	mapping(address => uint256) tokenBalances;
// 	mapping(address => PrivateCalendarEvent[]) public userPrivateEvents;
// 	mapping(address => PublicCalendarEvent[]) public userPublicEvents;
// 	address public calendarAddress = 0x37F8Bb1B8798CEFAbDb7f8BbDE61A168705404D4;
	
	
// 	event NewPrivateEventCreated(string title, address indexed attendee, uint startTime, uint endTime, uint timestamp);
// 	event NewPublicEventCreated(string title, address indexed attendee, uint startTime, uint endTime, address indexed calendarAddress, uint timestamp);
// 	event NewDeposit(address indexed depositor, uint256 amount, uint timestamp);
// 	event NewERC20Deposit(address indexed depositor, address indexed tokenAddress, uint256 amount, uint timestamp);
// 	event WithdrawEvent(uint256 amount, address indexed recipient, uint timestamp);

// 	struct PrivateCalendarEvent {
// 		string title;
// 		address attendee;
// 		uint startTime;
// 		uint endTime;
// 	}

// 	struct PublicCalendarEvent {
// 		string title;
// 		address attendee;
// 		uint startTime;
// 		uint endTime;
// 		address calendar;
// 	}

// 	struct Deposit {
// 		address depositor;
// 		address tokenAddress;
// 		uint256 amount;
// 		uint256 timestamp;
// 	}   

// 	receive() external payable {}

// // set custom name for account
// 	function setAccountName(string memory newName) public {
// 		require(msg.sender == owner(), "Only the contract owner can set the contract name");
// 		accountName = newName;
// 	}

// // change default calendar contract address
// 	function setCalendarAddress(address _contractAddress) public {
// 		require(msg.sender == owner(), "Only owner can create calendar events ");
// 		calendarAddress = _contractAddress;
// 	}

// // private calendar events are saved on this contract
// 	function createPrivateCalendarEvent(string memory title, uint startTime, uint endTime) public {
// 		require(msg.sender == owner(), "Only owner can create calendar events ");
// 		PrivateCalendarEvent memory privateCalendarEvent;
// 		privateCalendarEvent.title = title;
// 		privateCalendarEvent.startTime = startTime;
// 		privateCalendarEvent.endTime = endTime;
// 		privateCalendarEvent.attendee = address(this);
// 		userPrivateEvents[address(this)].push(privateCalendarEvent);
// 		emit NewPrivateEventCreated(title, address(this), startTime, endTime, block.timestamp);
// 	}

// // private calendar events saved on contract
// 	function getUserPrivateEvents(address user) public view returns (PrivateCalendarEvent[] memory) {
// 		require(msg.sender == owner(), "Only the contract owner can fetch private events");
// 		return userPrivateEvents[user];
// 	}

// // public events saved on remote contract
// 	function getUserPublicEvents(address user) public view returns (PublicCalendarEvent[] memory) {
// 		return userPublicEvents[user];
// 	}

// // receive native chain erc20 tokens ie. TLOS
// 	function deposit() public payable {
// 		require(msg.value > 0, "Deposit amount must be greater than 0.");
// 			depositCount++; 
// 			deposits[depositCount] = Deposit({
// 			depositor: msg.sender, // address of depositor
// 			tokenAddress: address(0),  // native chain token. TLOS
// 			amount: msg.value, // amount to deposit
// 			timestamp: block.timestamp // timestamp of deposit
// 		});
// 		emit NewDeposit(msg.sender, msg.value, block.timestamp);
// 	}

// // function for depositing any erc20 token. 
// 	function receiveERC20(address _erc20Token, uint256 amount) public payable {
// 		tokenBalances[_erc20Token] += amount;
// 		depositCount++;
// 		deposits[depositCount] = Deposit({
// 			depositor: msg.sender,
// 			tokenAddress: _erc20Token,
// 			amount: amount,
// 			timestamp: block.timestamp
// 		});
// 		emit NewERC20Deposit(msg.sender, _erc20Token, msg.value, block.timestamp);
// 	}

// // fetch contract tlos balance
// 	function getBalance() public view returns (uint256) {
// 		return address(this).balance;
// 	}

// 	function executeCall(
// 		address to,
// 		uint256 value,
// 		bytes calldata data
// 	) public payable returns (bytes memory result) {
// 		require(msg.sender == owner(), "Not token owner");
// 		bool success;
// 		(success, result) = to.call{value: value}(data);
// 		if (!success) {
// 			assembly {
// 				revert(add(result, 32), mload(result))
// 			}
// 		}
// 		_nonce += 1;
// 	}


// 	function owner() public view returns (address) {
// 		(uint256 chainId, address tokenContract, uint256 tokenId) = this
// 			.token();
// 		if (chainId != block.chainid) return address(0);

// 		return IERC721(tokenContract).ownerOf(tokenId);
// 	}

// 	function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
// 		return (interfaceId == type(IERC165).interfaceId ||
// 			interfaceId == type(IERC6551Account).interfaceId ||
// 			interfaceId == type(IERC1271).interfaceId);
// 	}

// 	function owner() public view returns (address) {
// 		(uint256 chainId, address tokenContract, uint256 tokenId) = this
// 			.token();
// 		if (chainId != block.chainid) return address(0);

// 		return IERC721(tokenContract).ownerOf(tokenId);
// 	}

// 	function isValidSignature(bytes32 hash, bytes memory signature)
// 		external
// 		view
// 		returns (bytes4 magicValue)
// 	{
// 		bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

// 		if (isValid) {
// 			return IERC1271.isValidSignature.selector;
// 		}

// 		return bytes4(0xffffffff);
// 	}
// 	    function isValidERC1271SignatureNow(
//         address signer,
//         bytes32 hash,
//         bytes memory signature
//     ) internal view returns (bool) {
//         (bool success, bytes memory result) = signer.staticcall(
//             abi.encodeCall(IERC1271.isValidSignature, (hash, signature))
//         );
//         return (success &&
//             result.length >= 32 &&
//             abi.decode(result, (bytes32)) ==
//             bytes32(IERC1271.isValidSignature.selector));
//     }


// 	function nonce() external view override returns (uint256) {
// 		return _nonce;
// 	}
// }