import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const verifier = url.searchParams.get("verifier");
  const token = url.searchParams.get("token");

  if (!verifier || !token) {
    return NextResponse.redirect(new URL("/verification-failed", request.url));
  }

  return NextResponse.redirect(new URL("/pages/verified", request.url));
  
}
