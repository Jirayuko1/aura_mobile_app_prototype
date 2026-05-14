const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin
admin.initializeApp();

/**
 * Webhook function to receive data from Botnoi (1st Gen)
 */
exports.botnoiWebhook = functions.https.onRequest(async (req, res) => {
  let data = req.body;
  
  // 1. Force parse rawBody if req.body is empty (handles missing Content-Type)
  if ((!data || Object.keys(data).length === 0) && req.rawBody) {
    try {
      data = JSON.parse(req.rawBody.toString());
      console.log("Forced Parse Success (from rawBody)");
    } catch (e) {
      console.log("Failed to force parse rawBody");
    }
  }
  
  // 2. Regular string parsing fallback
  if (typeof data === "string") {
    try {
      data = JSON.parse(data);
    } catch (e) {
      console.log("Failed to parse body string:", data);
    }
  }

  console.log("Final Resolved Data (v5):", JSON.stringify(data));

  try {
    const db = admin.firestore();
    
    // 4. Extract with defaults and trim
    const room = (data.room_no || data.room || data.room_number || "?").toString().trim();
    const items = (data.request || data.items || data.message || "งานทั่วไป").toString().trim();
    let intent = (data.department_name || data.intent || "other").toString().toLowerCase().trim();

    // 5. Thai mapping
    if (intent.includes("แม่บ้าน")) intent = "housekeeping";
    if (intent.includes("ซ่อม")) intent = "maintenance";
    if (intent.includes("ส่วนกลาง")) intent = "other";

    const newTask = {
      room_number: room,
      status: "pending",
      created_at: new Date().toISOString(),
      internal_notes: "",
      extracted_data: {
        items: items,
        intent: intent,
        notes: "ส่งจาก Botnoi Webhook",
        status: "pending",
        room_number: room
      }
    };

    const docRef = await db.collection("tickets").add(newTask);

    res.status(200).send({
      status: "success",
      ticket_id: docRef.id,
      debug: {
        received_room: room,
        received_items: items,
        received_intent: intent
      }
    });

  } catch (error) {
    console.error("Webhook Error:", error);
    res.status(500).send({
      status: "error",
      message: error.message
    });
  }
});
