document.getElementById('login-form').addEventListener('submit', async function(event) {
    event.preventDefault();

    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const responseMessage = document.getElementById('response-message');
    const dataContainer = document.getElementById('data-container');
    const dataOutput = document.getElementById('data-output');

    try {
        const response = await fetch('http://localhost:3000/request', {  // Ensure the correct backend URL
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: username,
                password: password,
                data: 'Login request from frontend'
            })
        });

        const result = await response.json();

        if (response.ok) {
            responseMessage.innerText = 'Login successful!';
            responseMessage.style.color = 'green';
            dataContainer.classList.remove('hidden');
            dataOutput.innerText = `Welcome, ${username}! Here's your data: ${result.data || 'No data returned from server.'}`;
        } else {
            responseMessage.innerText = 'Login failed: ' + result.message;
            responseMessage.style.color = 'red';
            dataContainer.classList.add('hidden');
        }
    } catch (error) {
        responseMessage.innerText = 'Error: ' + error.message;
        responseMessage.style.color = 'red';
        dataContainer.classList.add('hidden');
    }
});
