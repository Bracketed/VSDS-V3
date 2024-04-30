const axios = require('axios');
const process = require('node:process');
const dotenv = require('dotenv');
const fs = require('node:fs');

dotenv.config();

async function uploadAsset() {
	const buffer = fs.readFileSync(`./${process.env.TARGETFILE}`); // This is just the rbxm file

	console.debug('Uploading to Roblox...');
	let response = await axios
		.post(`https://data.roblox.com/Data/Upload.ashx?assetid=${process.env.TARGETASSET}`, buffer, {
			timeout: 60 * 3 * 1000, // 3 mins
			headers: {
				Cookie: `.ROBLOSECURITY=${process.env.ROBLOXCOOKIE}`,
				'User-Agent': 'Roblox/WinInet',
				'Content-Type': 'application/xml',
				Accept: 'application/json',
			},
		})
		.then((d) => d)
		.catch((e) => {
			console.error(e);
			return e;
		});

	if (response.response.status === 403 && response.response.headers['x-csrf-token']) {
		const csrfToken = response.response.headers['x-csrf-token'];
		console.debug('Received CSRF challenge, retrying with token...');

		response = await axios
			.post(`https://data.roblox.com/Data/Upload.ashx?assetid=${process.env.TARGETASSET}`, buffer, {
				timeout: 60 * 3 * 1000, // 3 mins
				headers: {
					'X-CSRF-Token': csrfToken,
					Cookie: `.ROBLOSECURITY=${process.env.ROBLOXCOOKIE}`,
					'User-Agent': 'Roblox/WinInet',
					'Content-Type': 'application/xml',
					Accept: 'application/json',
				},
			})
			.then((d) => d)
			.catch((e) => {
				console.error(e);
				return e;
			});
	}

	if (response.response.status >= 200 && response.response.status < 300) {
		return;
	} else {
		throw new Error(`Unable to upload: ${response.status}`);
	}
}

uploadAsset();
