const argon2 = require('argon2');


const hashValue = async (value) => {
  try {
    const hash = await argon2.hash(value, {
      type: argon2.argon2id,  // Use Argon2id for better security
      memoryCost: 2 ** 16,    // 64 MB
      timeCost: 5,            // 5 iterations
      parallelism: 1          // 1 thread
    });
    return hash;
  } catch (err) {
    console.error('Error hashing value:', err);
    throw new Error('Hashing failed');
  }
};

const compareValues = async (plainValue, hashedValue) => {
  try {
    const match = await argon2.verify(hashedValue, plainValue);
    return match;
  } catch (err) {
    console.error('Error comparing values:', err);
    throw new Error('Comparison failed');
  }
};

module.exports = {
  hashValue,
  compareValues,
};
