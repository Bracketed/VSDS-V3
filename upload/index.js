const axios = require('axios');
const process = require('node:process');
const dotenv = require('dotenv');
const fs = require('node:fs');

dotenv.config();

async function uploadAsset(buffer, assetId) {
	// URL to upload assets
	const url = `https://data.roblox.com/Data/Upload.ashx?assetid=${assetId}`;

	// Configure Axios instance with appropriate headers and timeout
	const client = axios.create({
		timeout: 60 * 3 * 1000, // 3 minutes timeout
		headers: {
			Cookie: `.ROBLOSECURITY=${process.env.ROBLOXCOOKIE}`,
			'User-Agent': 'Roblox/WinInet',
			'Content-Type': 'application/xml',
			Accept: 'application/json',
		},
	});

	const buildRequest = () => {
		return client
			.post(url, buffer)
			.then((d) => d)
			.catch((e) => e);
	};

	// Attempt to upload the asset
	try {
		console.debug('Uploading to Roblox...');
		let response = await buildRequest();

		// Check for CSRF challenge
		if (response.status === 403 && response.headers['x-csrf-token']) {
			const csrfToken = response.headers['x-csrf-token'];
			console.debug('Received CSRF challenge, retrying with token...');
			// Retry with CSRF token
			response = await buildRequest().then((req) => req.setHeader('X-CSRF-Token', csrfToken));
		}

		// Check if upload was successful
		if (response.status >= 200 && response.status < 300) {
			return; // Successful upload
		} else {
			throw new Error(`Roblox API returned an error, status ${response.status}.`);
		}
	} catch (error) {
		throw new Error(`Error during upload: ${error.message}`);
	}
}

uploadAsset(Buffer.from(fs.readFileSync(`./${process.env.TARGETFILE}`)), process.env.TARGETASSET);
