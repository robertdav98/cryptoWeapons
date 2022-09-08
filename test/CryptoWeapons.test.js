const CryptoWeapons = artifacts.require("CryptoWeapons");


const baseURI = "https://myBaseUri.de/";
var assert = require('assert');

contract("CryptoWeapons", async (accounts) => {

    let CryptoWeaponsContract;

    beforeEach('setup contract for test', async function () {
        CryptoWeaponsContract = await CryptoWeapons.deployed();
    })

    it("deploy test", async () => {     
        let ownerOfContract = await CryptoWeaponsContract.owner();
        let contractSymbol = await CryptoWeaponsContract.symbol();
        let contractName = await CryptoWeaponsContract.name();

        assert.equal(ownerOfContract, accounts[0]);
        assert.equal(contractSymbol, "CWEAPON");
        assert.equal(contractName, "CryptoWeapons");
        
    });

    it("set uris", async() => {
        await CryptoWeaponsContract.setBaseURI(baseURI);
    })

    
    it("mint tokens", async() => {

        await CryptoWeaponsContract.mint("https://testUri.de/", "Swort", "Bowtype1", "Arrowtype1", "Stringtype1");

        let totalSupply = await CryptoWeaponsContract.totalSupply();
        assert.equal(totalSupply, 1);

        let ownerOfFirstNFT = await CryptoWeaponsContract.ownerOf("0");
        assert.equal(accounts[0], ownerOfFirstNFT);

        let full_token_uri = await CryptoWeaponsContract.tokenURI("0");
        assert.equal('{"name":"CryptoWeapon #0 (+0)","description": "This is one of the NFTs created by https://weirdWeaponCollection", "external_url": "https://weirdWeaponCollection.com/all", "image": "https://ipfs.hsjdhasjdhajsdhajsdFIRSTTEST/0NORMAL.png", "attributes": [{"trait_type": "Current Enhancement", "value": "0"},{"trait_type": "Bowtype", "value": "Bowtype1"},{"trait_type": "Stringtype", "value": "Stringtype1"},{"trait_type": "Arrowtype", "value": "Arrowtype1"}]}', full_token_uri);

        let currentPlus = await CryptoWeaponsContract.getCurrentPlus("0");
        assert.equal("0", currentPlus)

        //mint some more
        await CryptoWeaponsContract.mint("https://testUri.de/", "Spear", "Bowtype2", "Arrowtype3", "Stringtype2");
        await CryptoWeaponsContract.mint("https://testUri.de/", "Bow", "Bowtype3", "Arrowtype3", "Stringtype3");
        await CryptoWeaponsContract.mint("https://testUri.de/", "Shield", "Bowtype4", "Arrowtype4", "Stringtype4");

        let balanceOfOwner = await CryptoWeaponsContract.balanceOf(accounts[0]);
        assert.equal("4", balanceOfOwner);
        
        //get all items he owns
        let allNftsFromUser = await getAllNFTFromUser(accounts[0], "0");    
        assert.equal(eqSet(new Set([0, 1, 2, 3]), allNftsFromUser), true);

        //transfer one nft to sb else
        await CryptoWeaponsContract.safeTransferFrom(accounts[0], accounts[1], "2")

        balanceOfOwner = await CryptoWeaponsContract.balanceOf(accounts[0]);
        assert.equal("3", balanceOfOwner);

        balanceOfOwner = await CryptoWeaponsContract.balanceOf(accounts[1]);
        assert.equal("1", balanceOfOwner);
        
        allNftsFromUser = await getAllNFTFromUser(accounts[0]); 
        assert.equal(eqSet(new Set([0, 1, 3]), allNftsFromUser), true);

        allNftsFromUser = await getAllNFTFromUser(accounts[1]);  
        assert.equal(eqSet(new Set([2]), allNftsFromUser), true);


        await CryptoWeaponsContract.safeTransferFrom(accounts[1], accounts[4], "2", { from: accounts[1] })
        
        allNftsFromUser = await getAllNFTFromUser(accounts[1]);  
        assert.equal(eqSet(new Set(), allNftsFromUser), true);

        allNftsFromUser = await getAllNFTFromUser(accounts[4]);  
        assert.equal(eqSet(new Set([2]), allNftsFromUser), true);
        
    })
    /* doesnt work cause chainlink
    it("test fuse tokens", async () => {

        let currentPlus = await CryptoWeaponsContract.getCurrentPlus("2")

        while(currentPlus != 4){
            await CryptoWeaponsContract.doAlchemy("2", {from: accounts[4], gasPrice: 0, value: 39842938492343434});
            currentPlus = await CryptoWeaponsContract.getCurrentPlus("2")
        }

        let rareURI = await CryptoWeaponsContract.tokenURI("2")
        assert.equal('{"name":"CryptoWeapon #2 (+4)", description:"This is one of the NFTs created by https://weirdWeaponCollection", external_url: "https://weirdWeaponCollection.com/all", image: "https://ipfs.hsjdhasjdhajsdhajsdTEST2/2RARE", "attributes": [{"trait_type": "Current Enhancement", "value":4}]}', rareURI);
   

    })
    */

    //HELPER METHODS
    async function getAllNFTFromUser(user) {
        let balanceOfOwner = await CryptoWeaponsContract.balanceOf(user);

        //get all items he owns
        let allItems = new Set();

        for(i = 0; i < balanceOfOwner; i++){
            let currentItem = await CryptoWeaponsContract.tokenOfOwnerByIndex(user, i);
            allItems.add(currentItem.toNumber());
        }
        return allItems;
    }
    

});



//HELPER METHOD
function eqSet(as, bs) {
    if (as.size !== bs.size) return false;
    for (var a of as) if (!bs.has(a)) return false;
    return true;
}