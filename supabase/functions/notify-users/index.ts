import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js";
import admin from "https://esm.sh/firebase-admin";

admin.initializeApp({
  credential: admin.credential.cert(
    JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!)
  ),
});

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);

serve(async (req) => {
  const { title, body, type, promo_id } = await req.json();

  // 1️⃣ Get all user tokens
  const { data: tokens } = await supabase
    .from("user_fcm_tokens")
    .select("token");

  if (!tokens || tokens.length === 0) {
    return new Response("No tokens", { status: 200 });
  }

  // 2️⃣ Build message
  const message = {
    notification: {
      title,
      body,
    },
    data: {
      type,
      promo_id: promo_id?.toString() ?? "",
    },
    tokens: tokens.map((t) => t.token),
  };

  // 3️⃣ Send push
  await admin.messaging().sendEachForMulticast(message);

  return new Response("Notification sent", { status: 200 });
});
