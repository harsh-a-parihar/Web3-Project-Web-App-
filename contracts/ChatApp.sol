

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;


contract ChatApp {

    struct user {
        string name;
        friend[] friends;
    }

    struct friend {
        address publicKey;
        string name;
    }

    struct message {
        address sender;
        string msg;
        uint256 timestamp;
    }

    struct allUsersRegistered {
        string name;
        address accountAddress;
    }
    allUsersRegistered[] getAllUsers;

    mapping(address => user) users;
    mapping(bytes32 => message[]) allMessages;  // msg between two users

    // check user exists
    function checkUserExists(address publicKey) public view returns (bool) {
        return bytes(users[publicKey].name).length > 0;
    }

    // create user account
    function createUserAccount(string calldata name) external {
        require(!checkUserExists(msg.sender), "User already exists");
        require(bytes(name).length > 0, "Name cannot be empty");

        users[msg.sender].name = name;
        getAllUsers.push(allUsersRegistered(name, msg.sender));
    }

    // get user details
    function getUser(address publicKey) external view returns (string memory) {
        require(checkUserExists(publicKey), "User is not registered");
        return users[publicKey].name;
    }

    // add friend
    function addFriend(address friendPublicKey, string calldata friendName) external {
        require(checkUserExists(msg.sender), "User does not exist, create account first");
        require(checkUserExists(friendPublicKey), "Friend is not registered");
        require(friendPublicKey != msg.sender, "Cannot add yourself as friend");
        require(checkFriendExists(msg.sender, friendPublicKey) == false, "User is already a friend");
        require(bytes(friendName).length > 0, "Friend name cannot be empty");
        // return users[msg.sender].friends.push(friend(friendPublicKey, friendName));

        _addFriend(msg.sender, friendPublicKey, friendName);
        _addFriend(friendPublicKey, msg.sender, users[msg.sender].name);
    }

    // check already friend
    function checkFriendExists(address publicKey1, address publicKey2) internal view returns (bool) {

        if(users[publicKey1].friends.length > users[publicKey2].friends.length) {
            address temp = publicKey1;
            publicKey1 = publicKey2;
            publicKey2 = temp;
        }

        for (uint i = 0; i < users[publicKey1].friends.length; i++) {
            if (users[publicKey1].friends[i].publicKey == publicKey2) {
                return true;
            }
        }
        return false;
    }

    // _addFriend function
    function _addFriend(address mypublicKey, address friendPublicKey, string memory friendName) internal {
        friend memory newFriend = friend(friendPublicKey, friendName);
        users[mypublicKey].friends.push(newFriend);
    }

    // get all friends
    function getAllFriends() external view returns (friend[] memory) {
        require(checkUserExists(msg.sender), "User does not exist, create account first");
        return users[msg.sender].friends;
    }

    // get chat code
    function _getChatCode(address publickey1, address publickey2) internal pure returns (bytes32) {
        if(publickey1 < publickey2) {
            return keccak256(abi.encodePacked(publickey1, publickey2));
        } else {
            return keccak256(abi.encodePacked(publickey2, publickey1));
        }
    }

    // send message
    function sendMessage(address friendPublickey, string calldata _msg) external {
        require(checkUserExists(msg.sender), "User does not exist, create account first");
        require(checkUserExists(friendPublickey), "Friend is not registered");
        require(checkFriendExists(msg.sender, friendPublickey), "User is not your friend");
        require(bytes(_msg).length > 0, "Message cannot be empty");

        bytes32 chatCode = _getChatCode(msg.sender, friendPublickey);
        message memory newMessage = message(msg.sender, _msg, block.timestamp);
        allMessages[chatCode].push(newMessage);
    }

    // read messages
    function readMessage(address friendPublickey) external view returns (message[] memory) {
        require(checkUserExists(msg.sender), "User does not exist, create account first");
        require(checkUserExists(friendPublickey), "Friend is not registered");

        bytes32 chatCode = _getChatCode(msg.sender, friendPublickey);
        return allMessages[chatCode];
    }

    // get all users
    function getAllUsersRegistered() public view returns (allUsersRegistered[] memory) {
        return getAllUsers;
    }
};