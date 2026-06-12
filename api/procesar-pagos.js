module.exports = async (req, res) => {
    // Configurar cabeceras CORS de forma clásica
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    // Responder de inmediato a la verificación de seguridad del navegador
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Método no permitido' });
    }

    try {
        const { device_id, total, mp_token } = req.body;

        // Petición directa a Mercado Pago usando el fetch nativo de Node.js
        const response = await fetch(`https://api.mercadopago.com/point/integration-api/devices/${device_id}/payment-intents`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${mp_token}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                amount: parseFloat(total),
                description: "Venta TacosPOSPro"
            })
        });

        const data = await response.json();
        return res.status(response.status).json(data);

    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
};
