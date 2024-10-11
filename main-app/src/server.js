const express = require('express');
const axios = require('axios');
const cassandraClient = require('./cassandra');
const cors = require('cors'); // Import CORS middleware
require('dotenv').config();

const app = express();

// Use CORS middleware
app.use(cors());

app.use(express.json());

app.post('/request', async (req, res) => {
    const { username, password, data } = req.body;

    try {
        console.log(`Sending auth request to ${process.env.AUTH_SERVICE_URL}/auth/login`);
        const authResponse = await axios.post(`${process.env.AUTH_SERVICE_URL}/auth/login`, { username, password });

        if (authResponse.status === 200) {
            console.log("Auth response: Login successful");
            const query = 'INSERT INTO main_app_db.main_app_data (id, username, data) VALUES (uuid(), ?, ?)';
            await cassandraClient.execute(query, [username, data], { prepare: true });

            res.status(200).json({ message: 'Data saved successfully!' });
        } else {
            res.status(401).json({ message: 'Unauthorized' });
        }
    } catch (error) {
        console.error("Error during request processing:", error.message);
        res.status(500).json({ message: 'Error processing request: ' + error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Main App running on port ${PORT}`);
});
