const axios = require('axios');
const process = require('node:process');
const dotenv = require('dotenv');
const fs = require('node:fs');
const { hostname } = require('node:os');

dotenv.config();

async function uploadAsset(buffer, assetId) {
	const client = axios.create({
		timeout: 60 * 3 * 1000, // 3 minutes timeout
		method: 'POST',
		data: buffer,
		headers: {
			Cookie: `.ROBLOSECURITY=${process.env.ROBLOXCOOKIE}`,
			'User-Agent': 'Roblox/WinInet',
			'Content-Type': 'application/xml',
			Accept: 'application/json',
		},
	});

	console.debug('Uploading to Roblox...');
	let response = await client
		.request(`https://data.roblox.com/Data/Upload.ashx?assetid=${assetId}`)
		.then((d) => d)
		.catch((e) => {
			console.error(e);
			return e;
		});

	// Check for CSRF challenge
	if (response.response.status === 403 && response.response.headers['x-csrf-token']) {
		const csrfToken = response.response.headers['x-csrf-token'];
		console.debug('Received CSRF challenge, retrying with token...');
		// Retry with CSRF token
		client.defaults.headers.post['X-CSRF-Token'] = csrfToken;
		response = await client
			.request(`https://data.roblox.com/Data/Upload.ashx?assetid=${assetId}`)
			.then((d) => d)
			.catch((e) => {
				console.error(e);
				return e;
			});
	}

	// Check if upload was successful
	if (response.response.status >= 200 && response.response.status < 300) {
		return; // Successful upload
	} else {
		throw new Error(`Roblox API returned an error, status ${response.status}.`);
	}
}

uploadAsset(Buffer.from(fs.readFileSync(`./${process.env.TARGETFILE}`)), process.env.TARGETASSET);
