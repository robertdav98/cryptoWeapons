// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";


contract CryptoWeapons is ERC721Enumerable, Ownable, Pausable, ReentrancyGuard, VRFConsumerBase{

    event FuseSuccess(address fuser, uint256 itemId, uint256 indexed plus);

    //chainlink attributes
    bytes32 internal keyHash;
    uint256 internal fee;  
    

    using Strings for uint256;
    using SafeMath for uint256;

    //RARITIES
    string private NORMAL = "NORMAL";
    string private RARE = "RARE";
    string private SUPER_RARE = "SUPER_RARE";
    string private ULTA_RARE = "ULTRA_RARE";
    string private HYPER_RARE = "HYPER_RARE";
    string private LEGENDARY_RARE = "LEGENDARY_RARE";

    //unique IDs getting incremented
    uint256 private token_id;

    // Base URI
    string private _custom_base_uri;

    //token rarity mapping
    mapping(uint256 => uint256) private currentPlus;

    //token rarity uri suffix
    mapping(uint256 => string) private uri_suffix;

    //name of item
    mapping(uint256 => string) private tokenId2Name; 

    //mapping for tokenid to imguri
    mapping(uint256 => string) private tokenId2ImgUri;

    //mapping for weapon type
    mapping(uint256 => string) private tokenId2Weapontype;

    //current item that is suppossed to be fused
    uint256 currentItem2Fuse;

    //mapping for counting free fuse trys
    mapping(uint256 => uint256) public freeFuseTry;

    //currentPrice for fusing
    uint256 public currentPriceForFusing;
    address private cashMaker;
    
    //traitsmap
    mapping(uint256 => string) public stringType;
    mapping(uint256 => string) public bowType;
    mapping(uint256 => string) public arrowType;
    
    //freetrys
    uint256 private freeTrys = 3;

    function setFusePrice(uint256 price) public onlyOwner{
        currentPriceForFusing = price;
    }
    //fusingprice in gwei
    constructor() ERC721("CryptoWeapons", "CWEAPON")  VRFConsumerBase(
            0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // VRF Coordinator
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // LINK Token
        ){
        
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 100000000000000; // 0.0001 LINK

        cashMaker = msg.sender;

        currentPriceForFusing = 100000000;

        token_id = 0;

        uri_suffix[0] = NORMAL;

        uri_suffix[1] = RARE;

        uri_suffix[2] = SUPER_RARE;

        uri_suffix[3] = ULTA_RARE;

        uri_suffix[4] = HYPER_RARE;

        uri_suffix[5] = LEGENDARY_RARE;

    }

    function pauseFusing() public onlyOwner{
        _pause();
    }

    function unpauseFusing() public onlyOwner{
        _unpause();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _custom_base_uri;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _custom_base_uri = baseURI_;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory stringPart1 = string(abi.encodePacked('{"name":"CryptoWeapon #', 
                                        string(abi.encodePacked(tokenId.toString(),  
                                            string(abi.encodePacked(" (+", 
                                                string(abi.encodePacked(currentPlus[tokenId].toString(), ')",')))
                                            ))
                                        ))
                                    ); 

        string memory stringPart2 = string(abi.encodePacked('"description": "This is one of the NFTs created by https://weirdWeaponCollection", "external_url": "https://weirdWeaponCollection.com/all", "image": "', 
            string(abi.encodePacked(
                string(abi.encodePacked(tokenId2ImgUri[tokenId], tokenId.toString(), "/" ,tokenId.toString())), 
                    uri_suffix[currentPlus[tokenId]], (currentPlus[tokenId] >=4 ? ".gif" : ".png")))));
        string memory stringPart3 = string(abi.encodePacked('", "attributes": [{"trait_type": "Current Enhancement", "value": "', currentPlus[tokenId].toString()));

        string memory tmp = string(
            abi.encodePacked(stringPart1, 
                string(
                    abi.encodePacked(stringPart2,
                        string(
                            abi.encodePacked(stringPart3, '"},')
                        )
                    )
                )
            )
        );

        string memory metaData1 = string(abi.encodePacked('{"trait_type": "Bowtype", "value": "', bowType[tokenId], '"},'));
        string memory metaData2 = string(abi.encodePacked('{"trait_type": "Stringtype", "value": "', stringType[tokenId], '"},'));
        string memory metaData3 = string(abi.encodePacked('{"trait_type": "Arrowtype", "value": "', arrowType[tokenId], '"}]}'));
        return string(abi.encodePacked(tmp, metaData1, metaData2, metaData3));
        
    }

    function doAlchemy(uint256 tokenId) external whenNotPaused nonReentrant payable{
        require(_exists(tokenId));
        require(_isApprovedOrOwner(_msgSender(), tokenId));
        require(currentPlus[tokenId] < 5, "Item already fused to maximum");
        if(freeFuseTry[tokenId] < freeTrys){
            currentItem2Fuse = tokenId;
            startFuseProccess();
            freeFuseTry[tokenId] = freeFuseTry[tokenId] + 1;
        }else{
            require(msg.value >= currentPriceForFusing, "not enough eth provided");
            currentItem2Fuse = tokenId;
            startFuseProccess();
        }   
    }

    function withDrawMatic() public onlyOwner{
        payable(cashMaker).transfer(address(this).balance);
    }

    function mint(string memory imgURI, string memory weaponType, string memory bowTypeP,string memory arrowTypeP, string memory stringTypeP ) external onlyOwner() {
        _mint(owner(), token_id);
        currentPlus[token_id] = 0;
        tokenId2ImgUri[token_id] = imgURI;
        tokenId2Weapontype[token_id] = weaponType;
        freeFuseTry[token_id] = 0;

        //sets traits
        stringType[token_id] = stringTypeP;
        arrowType[token_id] = arrowTypeP;
        bowType[token_id] = bowTypeP;

        incrment();
    }

    function setNewImgURI(uint256 tokenid, string memory newUri) external onlyOwner(){
        require(_exists(tokenid));
        tokenId2ImgUri[tokenid] = newUri;
    }

    function getCurrentPlus(uint256 tokenId) external view returns(uint256){
        require(_exists(tokenId));
        return currentPlus[tokenId];
    }

    function incrment() private {
        token_id = token_id.add(1);
    }


    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        //uint256 success = randomness % (currentPlus[currentItem2Fuse] * 6 + 2);    
        uint256 success = randomness % 2; 
        if(success == 0){
            currentPlus[currentItem2Fuse] = currentPlus[currentItem2Fuse] + 1;
        }
        
        if(currentPlus[currentItem2Fuse] >= 3){
            emit FuseSuccess(msg.sender, currentItem2Fuse, currentPlus[currentItem2Fuse]);
        }
    }

    function startFuseProccess() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function setCashMaker(address payable cm) onlyOwner public{
        cashMaker = cm;
    }

    function getCurrentLinkBalance() public view onlyOwner returns(uint256){
        return LINK.balanceOf(address(this));
    }

}