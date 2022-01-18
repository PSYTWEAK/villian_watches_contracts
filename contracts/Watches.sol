// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTreeLibrary.sol";
import "./IERC20.sol";

contract Watches is ERC721Enumerable, Ownable {

    using NFTreeLibrary for uint8;
    using ECDSA for bytes32;

    struct Trait {
        string traitName;
        string traitType;
        string pixels;
        uint256 pixelCount;
    }
    
    // Price
    uint256 public price = 0.02 ether;

    //Mappings
    mapping(uint256 => Trait[]) public traitTypes;
    mapping(uint256 => string) internal tokenIdToHash;
    mapping(uint256 => string) internal tokenIdTocolor;
    mapping(uint256 => uint256) internal tokenIdToChristmasSpiritCount;
    mapping(address => uint256) public priceInToken;

    //uint256s
    uint256 public MAX_SUPPLY = 6000;
    uint256 public MAX_DEV_AMOUNT = 30;
    uint256 SEED_NONCE = 0;

    //string arrays
    string[] COLORS;

    address _owner;
    address _dev = 0x5cAce277eEC49e93Aa8c321d14D84ADb1d495e23;


    uint256 public devAmountMinted;
    bool public saleLive;

    event LightTreeUp(uint256 tokenId, address account);
    
    constructor() ERC721("Christmas NFTree", "TREE") {
        _owner = msg.sender;
         }

    
    function mint() external payable {
        require(price <= msg.value, "INSUFFICIENT_ETH");

        mintInternal(); 

        payable(_dev).transfer(address(this).balance);

    }

    function mintWithToken(address token) external {       
        require(priceInToken[token] > 0, "TOKEN_NOT_ALLOWED");

        require(IERC20(token).transferFrom(msg.sender, _dev, priceInToken[token]), "TOKEN_NOT_PAID");

        mintInternal(); 

    }

    /**
     * @dev Mint internal, this is to avoid code duplication.
     */
    function mintInternal() internal {
        require(saleLive, "SALE_CLOSED");

        uint256 _totalSupply = totalSupply();
        require(_totalSupply < MAX_SUPPLY);

        require(!NFTreeLibrary.isContract(msg.sender));

        uint256 thisTokenId = _totalSupply;

        _mint(msg.sender, thisTokenId);  
 
        emit LightTreeUp(_totalSupply, msg.sender); 
    } 
    
    function mintReserve() onlyOwner external  {
        devAmountMinted++;
        require(devAmountMinted < MAX_DEV_AMOUNT); // Reserved for teams and giveaways
         mintInternal(); 
    }

    /**
     * @dev Adds to christmasSpirit count if christmasSpirit is great enough     
     * @param tokenId the token to edit ChristmasSpirit count for
     * @param index position in the current TIER * 5
     */
    function setTokenIdChristmasSpirit(uint256 tokenId, uint256 index) internal {
         if (index < 20) {  
           uint256 cScore = (20 - index);
           tokenIdToChristmasSpiritCount[tokenId] += cScore; 
        }
    }


    function withdraw() external onlyOwner {
        payable(_dev).transfer(address(this).balance);
    }

    function getPolygon(uint hour) public view returns (string memory) {
        uint polygonTopBottom = 40;
        uint polygonLeft = 30;
        uint polygonRight = 50;        

        if (hour > 0) {
            uint addition = 24 * hour;
            polygonTopBottom += addition;
            polygonLeft += addition;
            polygonRight += addition; 
        }

        return "<polygon fill='pink' points='",
                polygonLeft,
                ",290 ",
                polygonTopBottom,
                ",305 ",
                polygonRight,
                ",290 ",
                polygonTopBottom,
                ",275'/>"
    }

    function getHighlightedNumbers() public view returns (string memory) {
        uint timestamp = block.timestamp;

        uint hour = getHour(timestamp);
        uint minute = getMinute(timestamp);

        uint hourX = (hour % 10) * 30;
        uint hourY = 40 + ((hour / 10) * 25);
        uint minuteX = (minute % 10) * 30;
        uint minuteY = 115 + ((minute / 10) * 25);


        return
                "<text fill='#F33F19' font-family='Open Sans' font-size='15' style='white-space: pre' xml:space='preserve'><tspan x=",
                string(abi.encodePacked(hourX)),
                " y=",
                string(abi.encodePacked(hourY)),
                ">",
                string(abi.encodePacked(hour)),
                "</tspan><tspan x=",
                string(abi.encodePacked(minuteX)),
                " y=",
                string(abi.encodePacked(minuteY)),
                ">",
                string(abi.encodePacked(minute)),
                "</tspan></text>";
    }


   /**
     * @dev creates string for current time and applies to the watch SVG
     */
    function SVG()
        public
        view
        returns (string memory)
    {   
        string memory svgString;

        uint timestamp = block.timestamp;

        uint hour = getHour(timestamp);
        uint minute = getMinute(timestamp);

        uint hourX = (hour % 10) * 30;
        uint hourY = 40 + ((hour / 10) * 25);
        uint minuteX = (minute % 10) * 30;
        uint minuteY = 115 + ((minute / 10) * 25);


        svgString = string(
            abi.encodePacked(
                ,
                getPolygon(hour)
                
            )
        );
        
        svgString = string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' width='350' height='340'><path d='M.675.3h350.09v340.88H.675z' vector-effect='non-scaling-stroke'/>
                <linearGradient id='text_color' x1='0' x2='0' y1='0' y2='100%' gradientUnits='userSpaceOnUse' >
                <stop stop-color='gray' offset='0%'/>
                <stop stop-color='pink' offset='100%'/> 
                </linearGradient>
                <text fill='url(#text_color)'  font-family='Open Sans' font-size='12' style='white-space:pre' xml:space='preserve' letter-spacing='3' fill-opacity='0.55'>
                <tspan x='30' y='40'>01  02  03  04  05  06  07  08  09  10</tspan>
                <tspan x='30' y='65'>11  12  13  14  15  16  17  18  19  20</tspan>
                <tspan x='30' y='90'>21  22  23  00  00  00  00  00  00  00</tspan>  
                <tspan x='30' y='115'>01  02  03  04  05  06  07  08  09  10</tspan>
                <tspan x='30' y='140'>11  12  13  14  15  16  17  18  19  20</tspan>
                <tspan x='30' y='165'>21  22  23  24  25  26  27  28  29  30</tspan>
                <tspan x='30' y='190'>31  32  33  34  35  36  37  38  39  40</tspan>
                <tspan x='30' y='215'>41  42  43  44  45  46  47  48  49  50</tspan>
                <tspan x='30' y='240'>51  52  53  54  55  56  57  58  59  60</tspan>
                </text>
                <line x1="30" y1="290" x2="315" y2="290" style="stroke:url(#text_color);" />
                ",
                svgString,
                "</svg>")
        );

        return svgString;
    }

    /**
     * @dev Hash to metadata function
     */
    function hashToMetadata(string memory _hash, uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory metadataString;

        for (uint8 i = 0; i < 4; i++) { 
            uint8 thisTraitIndex = NFTreeLibrary.parseInt(
                NFTreeLibrary.substring(_hash, i, i + 1)
            );

            metadataString = string(
                abi.encodePacked(
                    metadataString,
                    '{"trait_type": color ","value":"',
                    ,
                    '"},'
                )
            );
          
        }

        metadataString = string(abi.encodePacked(metadataString, '{"display_type": "spirit", "trait_type": "Christmas Spirit", "value":',NFTreeLibrary.toString(tokenIdToChristmasSpiritCount[_tokenId]),'}'));

        return string(abi.encodePacked("[", metadataString, "]"));
    }

    /**
     * @dev Returns the SVG and metadata for a token Id
     * @param _tokenId The tokenId to return the SVG and metadata for.
     */
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId));

        string memory tokenHash = _tokenIdToHash(_tokenId);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    NFTreeLibrary.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "Villian Watch #',
                                    NFTreeLibrary.toString(_tokenId),
                                    '", "description": "Bespoke digital watch", "image": "data:image/svg+xml;base64,',
                                    NFTreeLibrary.encode(
                                        bytes(SVG())
                                    ),
                                    '","attributes":',
                                    hashToMetadata(tokenHash, _tokenId),
                                    "}"
                                )
                            )
                        )
                    )
                )
            );
    }

    /**
     * @dev Returns a hash for a given tokenId
     * @param _tokenId The tokenId to return the hash for.
     */
    function _tokenIdToHash(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        string memory tokenHash = tokenIdToHash[_tokenId];
        //If this is a burned token, override the previous hash
        if (ownerOf(_tokenId) == 0x000000000000000000000000000000000000dEaD) {
            tokenHash = string(
                abi.encodePacked(
                    "1",
                    NFTreeLibrary.substring(tokenHash, 1, 5)
                )
            );
        }

        return tokenHash;
    }



    /**
     * @dev Returns the number of rare assets of a tokenId
     * @param _tokenId The tokenId to return the number of rare assets for.
     */
    function getTokenChristmasSpiritCount(uint256 _tokenId)
        public
        view
        returns (uint256)
    {
        return tokenIdToChristmasSpiritCount[_tokenId];
    }

    /**
     * @dev Changes the price
     */
    function changePrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    /**
     * @dev changes the price in a token
     * @param token token you want to change the price for
     * @param _price the price you want the token to be
     */
    function changePriceInToken(address token, uint256 _price) external onlyOwner {
        priceInToken[token] = _price;
    }

    /**
     * @dev gets the price
     */
    function getPrice() public view returns (uint256) {
        return price;
    }

    /**
     * @dev Returns the wallet of a given wallet. Mainly for ease for frontend devs.
     * @param _wallet The wallet to get the tokens of.
     */
    function walletOfOwner(address _wallet)
        public
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_wallet);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_wallet, i);
        }
        return tokensId;
    }

    function toggleSaleStatus() external onlyOwner {
        saleLive = !saleLive;
    }


    /**
     * @dev Add a trait type
     * @param _traitTypeIndex The trait type index
     * @param traits Array of traits to add
     */

    function addColor(string memory color)
        public
        onlyOwner
    {
            COLOR.push(color);
        }
        
    function getHour(uint256 timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
        }

    function getMinute(uint256 timestamp) public pure returns (uint8) {
        return uint8((timestamp / 60) % 60);
        }
        
    }
