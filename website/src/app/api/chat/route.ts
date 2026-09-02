import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function POST(request: Request) {
  try {
    const { prompt, bins, user, leaderboard } = await request.json();

    // Check all possible environment variable keys
    const apiKey = process.env.GEMINI_API_KEY || process.env.NEXT_PUBLIC_GEMINI_API_KEY;

    // Construct system prompt with live EcoSynapse telemetry context
    const binSummary = bins
      ? bins.map((b: any) => `• ${b.name} (${b.id}): ${b.overallFill}% capacity, ${b.weight}kg, Moisture: ${b.moistureLevel}%, Alert: ${b.hasContamination ? 'Wet Contamination' : 'None'}`).join('\n')
      : 'BIN-102 at 93% capacity';

    const topLeaderboardStr = leaderboard && leaderboard.length > 0
      ? leaderboard.slice(0, 5).map((l: any) => `#${l.rank} ${l.name} (${l.flatNo}) - ${l.ecoPoints} Pts`).join('\n')
      : '#1 Ananya Sharma (C-701) - 1450 Pts\n#2 Vikram Mehta (B-304) - 1280 Pts\n#3 Priya Sundaram (A-102) - 1150 Pts';

    const rewardsSummary = `• REW-101: ₹200 Maintenance Fee Voucher (400 Pts)\n• REW-102: Free Organic Compost Bag 5kg (100 Pts)\n• REW-103: Clubhouse Event Pass (250 Pts)\n• REW-104: Eco Champion Badge & Certificate (500 Pts)`;

    const systemInstruction = `You are EcoBot, the official AI Assistant for EcoSynapse - an intelligent smart bin waste-management ecosystem.
Be concise, helpful, friendly, and enthusiastic. Use markdown formatting, emojis, bold text, and bullet points.

USER CONTEXT:
- Name: ${user?.name || 'Sriram'}
- Residency: ${user?.userType || 'Resident'} (Flat ${user?.flatNo || 'A-402'})
- EcoPoints Balance: ${user?.ecoPoints || 450} Pts
- Leaderboard Rank: #${user?.rank || 42} out of ${user?.totalResidentsInApartment || 200} residents
- Total Verified Disposals: ${user?.totalDisposals || 34}

LIVE APARTMENT LEADERBOARD STANDINGS:
${topLeaderboardStr}

REAL-TIME SMART BIN FLEET TELEMETRY (${bins?.length || 5} NODES):
${binSummary}

AVAILABLE ECOPOINTS REWARDS:
${rewardsSummary}

SOCIETY COMMUNITY METRICS:
- Total Waste Diverted from Landfills: 14.8 Tons
- CO2 Emissions Offset: 3.9 Tons
- Automated Sorting Accuracy: 98.4%

HARDWARE & ARCHITECTURE SPECIFICATIONS:
- Microcontroller: ESP32 with Wi-Fi/Bluetooth & Supabase WebSocket Realtime sync.
- Sensors: ESP32-CAM (AI visual shape recognition), Capacitive Moisture Grid (dry vs wet waste sidewall detection), Load Cell Scale (weight load), Dual Ultrasonic & ToF Lid Proximity Sensors, Bottom Liquid Sump Leak Sensor.
- Actuators: Servo-motorized diverter flap.
- Gamification: +10 EcoPoints awarded per verified dry disposal. Contamination flags generated if wet waste is placed in dry compartment.`;

    if (apiKey) {
      // Try active Google Gemini endpoints (Gemini 3.6 Flash / Flash-latest)
      const modelsToTry = ['gemini-3.6-flash', 'gemini-2.5-flash-lite', 'gemini-flash-latest', 'gemini-3.5-flash'];

      for (const model of modelsToTry) {
        try {
          const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

          const response = await fetch(geminiUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [
                {
                  parts: [
                    { text: `${systemInstruction}\n\nUSER QUESTION: ${prompt}` }
                  ]
                }
              ]
            })
          });

          if (response.ok) {
            const data = await response.json();
            const aiText = data.candidates?.[0]?.content?.parts?.[0]?.text;
            if (aiText) {
              return NextResponse.json({ success: true, reply: aiText, engine: `Google ${model} LLM` });
            }
          } else {
            const errText = await response.text();
            console.error(`[Gemini API Error ${model}]:`, errText);
          }
        } catch (e) {
          console.error(`[Gemini Fetch Failed ${model}]:`, e);
        }
      }
    }

    // High-fidelity fallback response generator if API key needs restart
    const q = prompt.toLowerCase();
    let botResponse = `🚀 Welcome to EcoSynapse! We are an intelligent smart bin ecosystem that monitors live waste telemetry (${bins?.length || 5} bins total), automates collector routes, and awards EcoPoints to residents for proper dry waste recycling.`;

    if (q.includes('leaderboard') || q.includes('rank') || q.includes('ranking') || q.includes('position') || q.includes('place') || q.includes('points') || q.includes('score')) {
      const top10Pts = leaderboard?.[9]?.ecoPoints || 610;
      const ptsNeeded = Math.max(10, top10Pts - (user?.ecoPoints || 450));
      const disposalsNeeded = Math.ceil(ptsNeeded / 10);
      botResponse = `🏆 **Your EcoSynapse Leaderboard Status**:\n\n• **Current Rank:** #${user?.rank || 42} out of ${user?.totalResidentsInApartment || 200} residents\n• **EcoPoints Balance:** ${user?.ecoPoints || 450} Pts\n• **Verified Disposals:** ${user?.totalDisposals || 34}\n\n🥇 **Top Resident:** ${leaderboard?.[0]?.name || 'Ananya Sharma'} (${leaderboard?.[0]?.ecoPoints || 1450} Pts)\n🎯 **Target:** You need **+${ptsNeeded} EcoPoints** (~${disposalsNeeded} proper dry waste disposals) to break into the Top 10 Leaderboard!`;
    } else if (q.includes('website') || q.includes('about') || q.includes('overview') || q.includes('project')) {
      botResponse = `✨ **EcoSynapse Platform Overview**:\n\n• 🗑️ **Smart Bins:** Dual dry/wet compartments with ESP32-CAM visual sorting, capacitive moisture grid, load cell scale, and ToF lid sensors.\n\n• 🏆 **Resident Rewards:** Earn +10 EcoPoints per dry disposal to rank on the Apartment Leaderboard & claim maintenance fee discounts.\n\n• 🚚 **Collector Dispatch:** Automated route optimization prioritized by bin fill urgency.\n\n• ☁️ **Supabase Cloud DB:** Real-time database sync & predictive fill forecasting.`;
    }

    return NextResponse.json({
      success: true,
      reply: botResponse,
      engine: 'EcoBot Knowledge Engine',
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: 'Gemini LLM API error' },
      { status: 500 }
    );
  }
}
