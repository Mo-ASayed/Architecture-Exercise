const cassandra = require('cassandra-driver');

// Connect to Cassandra inside Docker using the service name
const client = new cassandra.Client({
    contactPoints: ['cassandra'],  // Use the Docker service name 'cassandra'
    localDataCenter: 'datacenter1',  // This should match your Cassandra setup
    keyspace: process.env.CASSANDRA_KEYSPACE,
    credentials: {
        username: process.env.CASSANDRA_USERNAME,
        password: process.env.CASSANDRA_PASSWORD,
    }
});

// Function to check Cassandra readiness
const checkCassandraReady = async () => {
    let isReady = false;
    while (!isReady) {
        try {
            // Execute a simple query to check if Cassandra is ready
            await client.execute('SELECT now() FROM system.local');
            isReady = true;
        } catch (err) {
            console.log('Waiting for Cassandra to be ready...', err.message);
            await new Promise(resolve => setTimeout(resolve, 5000));  // Wait 5 seconds before retrying
        }
    }
};

// Create keyspace if it doesn't exist
const createKeyspace = async () => {
    const query = `
        CREATE KEYSPACE IF NOT EXISTS ${process.env.CASSANDRA_KEYSPACE}
        WITH replication = {
            'class': 'SimpleStrategy',
            'replication_factor': '1'
        }`;
    await client.execute(query);
};

// Create table if it doesn't exist
const createTable = async () => {
    const query = `
        CREATE TABLE IF NOT EXISTS ${process.env.CASSANDRA_KEYSPACE}.main_app_data (
            id uuid PRIMARY KEY,
            username text,
            data text
        )`;
    await client.execute(query);
};

// Wait for Cassandra to be ready, create keyspace and table
checkCassandraReady()
    .then(() => createKeyspace())
    .then(() => createTable())
    .then(() => console.log(`Keyspace ${process.env.CASSANDRA_KEYSPACE} and table main_app_data are ready`))
    .catch((err) => console.error('Error creating keyspace/table:', err));

module.exports = client;
