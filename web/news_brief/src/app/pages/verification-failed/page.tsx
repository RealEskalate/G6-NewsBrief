export default function VerificationFailed() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-3xl font-bold mb-4 text-red-600">
        Verification Failed
      </h1>
      <p className="text-center">
        There was a problem verifying your email. Please try again.
      </p>
    </div>
  );
}
