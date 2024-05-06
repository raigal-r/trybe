import IndexClient from "@indexnetwork/sdk";

const indexClient = new IndexClient({
  privateKey: "0xc45...a5", // Wallet that interacts
  domain: "index.network",
  network: "ethereum", // Provide your network
});

indexClient.authenticate();
