import { NextResponse } from "next/server";

export async function GET() {
  const response = await fetch("https://api.elevenlabs.io/v1/voices", {
    headers: {
      "xi-api-key": process.env.ELEVEN_LABS_API_KEY!,
    },
  });

  const data = await response.json();
  return NextResponse.json(data);
}
