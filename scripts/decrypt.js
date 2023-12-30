const { createDecipheriv, pbkdf2, createHash } = require('crypto');
const { writeFile } = require('fs').promises;
const { readFile } = require('fs').promises;
const { rel } = require('./rel');

(async function main(arg) {
  console.log(`Decrypting ${arg}`);

  const file = rel(arg);
  const [data, password] = await Promise.all(
    [`${file}.enc`, `${file}.key`].map((path) => readFile(path)),
  );

  const iv = data.slice(0, 16);
  const dataToDecrypt = data.slice(16);
  const key = await createHash('sha256').update(password).digest();
  const decipher = createDecipheriv('aes-256-cbc', key, iv);
  const decryptedData = Buffer.concat([
    decipher.update(dataToDecrypt),
    decipher.final(),
  ]);

  await writeFile(file, decryptedData);
})();

await Promise.all(process.argv.slice(2).map((file) => main(file)));
