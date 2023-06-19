// deploy.js
async function main () {
  //コントラクトがコンパイルします
  //コントラクトを扱うために必要なファイルがartifactsディレクトリが直下に生成されます
  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  //HardhatがローカルのEthereumネットワークを作成
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  //コントラクトがMintされ、ローカルのブロックチェーンにデプロイされるまで待ちます
  console.log("Contract deployed to:", nftContract.address);

  //makeAnEpicNFT関数を呼び出す。NFTがMintされる
  const txn = await nftContract.makeAnEpicNFT();
  //Mintingが仮想マイナ-によって承認されるのを待つ
  await txn.wait();
  console.log('Minted NFT #1');
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
