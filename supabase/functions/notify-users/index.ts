import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.1/mod.ts";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

const serviceAccount = JSON.parse(
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!
);

// 🔑 Create Google OAuth2 Access Token
async function getAccessToken() {
  const now = getNumericDate(0);

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    },
    serviceAccount.private_key
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const data = await res.json();
  return data.access_token;
}

serve(async (req) => {
  try {
    const { title, body, type, promo_id } = await req.json();

    // 1️⃣ Get tokens
    const { data: tokens } = await supabase
      .from("user_fcm_tokens")
      .select("token");

    if (!tokens || tokens.length === 0) {
      return new Response("No tokens", { status: 200 });
    }

    const accessToken = await getAccessToken();

    // 2️⃣ Send notifications (one-by-one, safe)
    for (const t of tokens) {
      await fetch(
        `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token: t.token,
              notification: { title, body },
              data: {
                type: type ?? "",
                promo_id: promo_id?.toString() ?? "",
              },
            },
          }),
        }
      );
    }

    return new Response("Notification sent", { status: 200 });
  } catch (e) {
    console.error("❌ ERROR:", e);
    return new Response("Internal error", { status: 500 });
  }
});