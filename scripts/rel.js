const { resolve } = require('path');

/**
 *
 * @param  {...string[]} segments
 * @returns
 */
function rel(...segments) {
  return resolve(__dirname, '..', ...segments);
}

module.exports = { rel };
