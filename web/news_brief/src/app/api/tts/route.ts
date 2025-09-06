import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  const { text, voice_id, language_code } = await req.json();

  const apiKey = "sk_107fc415dec63614c2d861bf0426dc47e00cf5708cf41fd1";
  if (!apiKey) {
    return NextResponse.json({ error: "API key not found" }, { status: 500 });
  }

  let response: Response;
  try {
    response = await fetch(
      `https://api.elevenlabs.io/v1/text-to-speech/${voice_id}`,
      {
        method: "POST",
        headers: {
          "xi-api-key": apiKey,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          text,
          voice_settings: { stability: 0.5, similarity_boost: 0.7 },
          language_code: language_code || "en",
        }),
      }
    );
  } catch {
    return NextResponse.json(
      { error: "Failed to reach ElevenLabs API" },
      { status: 500 }
    );
  }

  // handle error responses safely
  if (!response.ok) {
    let errorData: { message: string } = { message: "Unknown error" };

    try {
      errorData = (await response.json()) as { message: string };
    } catch {
      errorData = { message: await response.text() };
    }

    return NextResponse.json({ error: errorData }, { status: response.status });
  }

  // read audio once
  const audioBuffer = await response.arrayBuffer();
  return new NextResponse(audioBuffer, {
    status: 200,
    headers: { "Content-Type": "audio/mpeg" },
  });
}
