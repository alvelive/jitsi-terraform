const { randomBytes, createCipheriv, pbkdf2, createHash } = require('crypto');
const { writeFile } = require('fs').promises;
const { readFile } = require('fs').promises;
const { rel } = require('./rel');

(async function main(arg) {
  console.log(`Encrypting ${arg}`);

  const file = rel(arg);
  const [data, password] = await Promise.all(
    [file, `${file}.key`].map((path) => readFile(path)),
  );

  const iv = randomBytes(16);
  const key = await createHash('sha256').update(password).digest();
  const cipher = createCipheriv('aes-256-cbc', key, iv);

  await writeFile(
    `${file}.enc`,
    Buffer.concat([iv, cipher.update(data), cipher.final()]),
  );
})();

await Promise.all(process.argv.slice(2).map((file) => main(file)));
