/* eslint-disable react/jsx-key */
import Bonfire from "../../../components/assets/bonfireLogo";
import { frames } from "../frames";
import { Button } from "frames.js/next";
import { createPublicClient, http } from "viem";
import { hardhat } from "viem/chains";

export const publicClient = createPublicClient({
  chain: hardhat,
  transport: http(),
});

export const POST = frames(async ctx => {
  const state = ctx.state;
  const haiku = await fetch(`https://fworks.vercel.app/api/mongo/haiku?id=${state.id}&type=hash`);
  const hk = await haiku.json();
  const hkLength = hk.length;
  const latestHaiku = hk[hkLength - 1];
  console.log(ctx.message);

  const wagmiAbi = [
    {
      type: "function",
      name: "tribeStats",
      inputs: [
        {
          name: "_tokenId",
          type: "uint256",
          internalType: "uint256",
        },
      ],
      outputs: [
        {
          name: "",
          type: "string[4]",
          internalType: "string[4]",
        },
      ],
      stateMutability: "view",
    },
  ] as Abi;

  const data = await publicClient.readContract({
    address: "0xFBA3912Ca04dd458c843e2EE08967fC04f3579c2",
    abi: wagmiAbi,
    functionName: "tribeStats",
    args: [1n],
  });

  return {
    image: (
      <div
        style={{
          color: "white",
          backgroundColor: "black",
          display: "flex",
          flexDirection: "row",
          fontSize: 60,
          padding: 16,
          alignItems: "center",
          justifyContent: "center",
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          position: "absolute",
        }}
      >
        <div tw="flex flex-col -top-24">
          HaiKus
          <div
            tw="flex flex-col"
            style={{
              fontSize: 20,
              bottom: 0,
              right: 0,
              position: "relative",
              backgroundColor: "black",
              color: "white",
            }}
          >
            {" "}
            made by the Nerds
            <br />
            <div tw="flex">Transaction submitted! {ctx.message?.transactionId}</div>
          </div>
          <span style={{ fontSize: 40 }} tw="flex flex-col w-2/3 top-12 left-52 p-6">
            {latestHaiku?.haikipu.haiku}
            {data}
          </span>
        </div>
        <Bonfire />
      </div>
    ),
    buttons: [
      <Button action="link" target={`https://www.onceupon.gg/tx/${ctx.message?.transactionId}`}>
        View on block explorer
      </Button>,
      <Button action="post" target="/">
        Reset
      </Button>,
    ],
    state: ctx.state,
  };
});
