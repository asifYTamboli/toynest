import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const WHATSAPP_TOKEN = Deno.env.get('META_WHATSAPP_TOKEN')
    const PHONE_NUMBER_ID = Deno.env.get('META_PHONE_NUMBER_ID')
    
    // !!! YOUR PERSONAL WHATSAPP RECIPIENT NUMBER (Include country code, digits only, no + signs) !!!
    const myWhatsAppNumber = "918788506782"; 

    if (!WHATSAPP_TOKEN || !PHONE_NUMBER_ID) {
      throw new Error('Missing Meta API verification keys inside environment vault.');
    }

    const { cartItems, totalAmount } = await req.json()

    let orderSummary = "";
    cartItems.forEach((item: any) => {
      orderSummary += `${item.car} (Qty: ${item.quantity}) - ₹${item.subtotal.toFixed(2)}, `;
    });
    orderSummary = orderSummary.replace(/,\s*$/, ""); // Clean up trailing comma

    const apiUrl = `https://facebook.com{PHONE_NUMBER_ID}/messages`;
    
    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${WHATSAPP_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        messaging_product: "whatsapp",
        recipient_type: "individual",
        to: myWhatsAppNumber,
        type: "text",
        text: {
          preview_url: false,
          body: `🛍️ *New Order Received - ToyNest*\n\nItems: ${orderSummary}\n\n💰 *Total Bill: ₹${totalAmount.toFixed(2)}*`
        }
      })
    });

    const resData = await response.json();
    
    return new Response(JSON.stringify(resData), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
})
