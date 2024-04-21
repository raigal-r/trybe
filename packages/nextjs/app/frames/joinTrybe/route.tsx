import { NextRequest, NextResponse } from "next/server";
import { TransactionTargetResponse } from "frames.js";
import { getFrameMessage } from "frames.js";
import { Abi, encodeFunctionData } from "viem";

export async function POST(req: NextRequest): Promise<NextResponse<TransactionTargetResponse>> {
  const json = await req.json();

  const frameMessage = await getFrameMessage(json);
  if (!frameMessage) {
    throw new Error("No frame message");
  }
  console.log(frameMessage);
  const trybeName = Number(frameMessage.inputText);
  console.log(trybeName);

  const abi = [
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_tokenId",
          type: "uint256",
        },
      ],
      name: "mintNew",
      outputs: [],
      stateMutability: "payable",
      type: "function",
    },
  ] as const;
  const calldata = encodeFunctionData({
    abi: abi,
    functionName: "mintNew",
    args: [BigInt(trybeName)],
  });

  const TRYBE_ADDRESS = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";

  return NextResponse.json({
    chainId: "eip155:31337", // OP Mainnet 10
    method: "eth_sendTransaction",
    params: {
      abi: abi as Abi,
      to: TRYBE_ADDRESS,
      data: calldata,
      value: "100000000000000000",
    },
  });
}
