// MyEpicNFT.sol
// SPDX-Lincense-Identifier: MIT
pragma solidity ^0.8.18;

//いくつかのOpenZeppelinのコントラクトをインポート
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

// utilsライブラリをインポートして文字列を処理
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// Base64.solコントラクトからSVGとJSONをBase64に変換する関数をインポートします。
import { Base64 } from "./libraries/Base64.sol";

//インポートしたOpenZeppelinのコントラクトを継承
//継承したコントラクトのメソッドにアクセスできるようになる
contract MyEpicNFT is ERC721URIStorage {
    
    //OpenZeppelinがtokenIdを簡単に追跡するために提供するライブラリを呼び出し
    using Counters for Counters.Counter;

    //_tokenIDsを初期化（_tokenIds = 0）
    Counters.Counter private _tokenIds;

    // SVGコードを作成
    //変更されるのは表示される単語だけ
    //すべてのNFTにSVGコードを適用するために、baseSvg変数を作成
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    //３つの配列string[]にそれぞれランダムな単語を設定
    string[] firstWords = ["Love", "Peace", "Social", "Heart", "Mind", "Pigeon"];
    string[] secondWords = ["Bird", "Lion", "Elephant", "Dog", "Cat", "Monkey"];
    string[] thirdWords = ["Happy", "Sad", "Angry", "Motivated", "Iritated", "Excited"];

    event NewEpicNFTMinted(address sender, uint256 tokenId);


    //NFTトークンの名前とそのシンボルを渡す
    constructor() ERC721 ("SquareNFT", "SQUARE") {
      console.log("This is my NFT contract.");
    }

    //シードを作成する関数を作成
    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    //各配列からランダムに単語を選ぶ関数を３つ作成
    //pickRandomFirstWord関数は最初の単語を選びます
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        
        // pickRandomFirstWord関数のシードとなるrandを作成
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));

        // seed rand をターミナルに出力する。
        console.log("rand seed: ", rand);

        // firstWords配列の長さを基準に、rand 番目の単語を選びます。
        rand = rand % firstWords.length;

        // firstWords配列から何番目の単語が選ばれるかターミナルに出力する。
        console.log("rand first word: ", rand);
        return firstWords[rand];
    }

    // pickRandomSecondWord関数は、2番目に表示されるの単語を選びます。
    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {

        // pickRandomSecondWord 関数のシードとなる rand を作成します。
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    // pickRandomThirdWord関数は、3番目に表示されるの単語を選びます。
    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {

        // pickRandomThirdWord 関数のシードとなる rand を作成します。
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }


    // ユーザーが NFT を取得するために実行する関数です。
    function makeAnEpicNFT() public {

        // NFT が Mint されるときのカウンターをインクリメントします。
        _tokenIds.increment();

        // 現在のtokenIdを取得します。tokenIdは1から始まります。
        uint256 newItemId = _tokenIds.current();

        // 3つの配列からそれぞれ1つの単語をランダムに取り出します。
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);

        //3つの単語を連携して格納する変数combinedWordを定義
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        // 3つの単語を連結して、<text>タグと<svg>タグで閉じます。
        string memory finalSvg = string(abi.encodePacked(baseSvg, first, second, third, "</text></svg>"));

	    // NFTに出力されるテキストをターミナルに出力します。
	    console.log("\n----- SVG data -----");
        console.log(finalSvg);
        console.log("--------------------\n");

        // JSONファイルを所定の位置に取得し、base64としてエンコードします。
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // NFTのタイトルを生成される言葉（例: GrandCuteBird）に設定します。
                        combinedWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        //  data:image/svg+xml;base64 を追加し、SVG を base64 でエンコードした結果を追加します。
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // データの先頭に data:application/json;base64 を追加します。
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n----- Token URI ----");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // msg.sender を使って NFT を送信者に Mint します。
        _safeMint(msg.sender, newItemId);

        // tokenURI は後で設定します。
        // 今は、tokenURI の代わりに、"We will set tokenURI later." を設定します。
        _setTokenURI(newItemId, finalTokenUri);
        // NFTがいつ誰に作成されたかを確認します。
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}