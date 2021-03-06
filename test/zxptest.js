const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("zXP", function () {

  var _registry; 
  var _itemManager;
  var _characterManager;
  var _wheelToken;
  var _beastToken;
  var _wheel;
  var _beast;
  var _beastBattle;
  var _wheelRace;
  var _characterS0;

  describe("zXP Season 0", function () {
      it("Deploy the managers and register contracts", async function () {
              //console.log(regGMtx);
      const addy = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
      const erc721wheelToken = await ethers.getContractFactory("ERC721TestToken");
      const wheelToken = await erc721wheelToken.deploy('Wilder Wheels', 'WHEEL', {
        "id": 0,
        "description": "Wilder Wheels",
        "external_url": "0://wilder.wheels",
        "image": "wheel.png",
        "name": "Wilder Wheels"
      });
      await wheelToken.deployed();
      _wheelToken = wheelToken;
      await wheelToken.mint(addy);
      expect(await wheelToken.ownerOf(0)).to.equal(addy);

      const erc721beastToken = await ethers.getContractFactory("ERC721TestToken");
      const beastToken = await erc721beastToken.deploy('Wilder Beasts', 'BEAST', {
        "id": 0,
        "description": "Beasts",
        "external_url": "0://wilder.beasts",
        "image": "beast.png",
        "name": "Wilder Beasts"
      });
      await beastToken.deployed();
      _beastToken = beastToken;
      await beastToken.mint(addy);
      expect(await beastToken.ownerOf(0)).to.equal(addy);
    
      const RegistryFactory = await ethers.getContractFactory("Registry");
      const registry = await RegistryFactory.deploy();
      await registry.deployed();
      _registry = registry;
      
      const ItemManagerFactory = await ethers.getContractFactory("ItemManager");
      const itemManager = await ItemManagerFactory.deploy(registry.address);
      await itemManager.deployed();
      _itemManager = itemManager;

      const CharacterManagerFactory = await ethers.getContractFactory("CharacterManager");
      const characterManager = await CharacterManagerFactory.deploy(registry.address);
      await characterManager.deployed();
      _characterManager = characterManager;

      const CharacterS0Factory = await ethers.getContractFactory("Character_S0");
      const characterS0 = await CharacterS0Factory.deploy(registry.address);
      await characterS0.deployed();
      _characterS0 = characterS0;

      const Wheels = await ethers.getContractFactory("Wheel_S0");
      const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("Wheel_S0"), registry.address, _wheelToken.address);
      await wheel.deployed();
      _wheel = wheel;

      const Beasts = await ethers.getContractFactory("Beast_S0");
      const beast = await Beasts.deploy(ethers.utils.formatBytes32String("Beast_S0"), registry.address, beastToken.address);
      await beast.deployed();
      _beast = beast;

      const beastBattles = await ethers.getContractFactory("BeastBattle_S0");
      const beastBattle = await beastBattles.deploy(registry.address);
      await beastBattle.deployed();
      _beastBattle = beastBattle;
  
      //await registry.registerAddress(ethers.utils.formatBytes32String("GameManager"), gameManager.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("ItemManager"), itemManager.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("CharacterManager"), characterManager.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Character"), characterS0.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Wheel"), wheel.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Beast"), beast.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("BeastBattle"), beastBattle.address);

    });
    it("Player 1 creates character", async function () {
      _characterManager.create();
    });
    it("Player 1 views beast stats", async function (){
      
    })
    it("P1 equips wheel", async function () {
      _characterS0.equipWheel(0);
    });
    it("P1 equips beast", async function () {
      _characterS0.equipBeast(0);
    });
    it("P1 uses wheel in game, player and wheel earn XP", async function () {
      //_wheelRace.race();
    });
    it("P1 uses beast in game, player and beast earn XP", async function () {
      _beastBattle.battle();
    });
  });

  describe("zXP Season 1", function () {
    it("Deploy the managers and register contracts", async function () {
      const CharacterS1Factory = await ethers.getContractFactory("Character_S1");
      const characterS1 = await CharacterS1Factory.deploy(_registry.address);
      await characterS1.deployed();
      _characterS1 = characterS1;
      
      const Wheels = await ethers.getContractFactory("Wheel_S1");
      const wheel = await Wheels.deploy(ethers.utils.formatBytes32String("Wheel_S1"), _registry.address, _wheelToken.address);
      await wheel.deployed();
      _wheel = wheel;

      const Beasts = await ethers.getContractFactory("Beast_S1");
      const beast = await Beasts.deploy(ethers.utils.formatBytes32String("Beast_S1"), _registry.address, _beastToken.address);
      await beast.deployed();
      _beast = beast;

      const beastBattles = await ethers.getContractFactory("BeastBattle_S1");
      const beastBattle = await beastBattles.deploy(_registry.address);
      await beastBattle.deployed();
      _beastBattle = beastBattle;

      await _registry.registerAddress(ethers.utils.formatBytes32String("Wheel_S1"), wheel.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("Beast_S1"), beast.address);
      await _registry.registerAddress(ethers.utils.formatBytes32String("BeastBattle_S1"), beastBattle.address);
  });
    it("P1 advances season", async function () {
        _characterManager.advance();
    });
  });

});