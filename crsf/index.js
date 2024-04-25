const axios = require('axios');
const process = require('node:process');
const dotenv = require('dotenv');

dotenv.config();

axios.post(
	'https://auth.roblox.com/',
	{},
	{
		headers: {
			Accept: 'application/json',
			'User-Agent': 'Roblox/WinInet',
			Cookie: process.env.ROBLOXCOOKIE,
		},
	}
).catch((e) => console.log('::set-output name=CRSF-TOKEN::', e.response.headers['x-csrf-token']));
