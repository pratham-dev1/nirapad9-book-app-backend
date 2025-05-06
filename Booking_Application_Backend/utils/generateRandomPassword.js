const generateRandomPassword = () => {
    const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numberChars = '0123456789';
    const specialChars = '!@#$%^&*()_+';
    const allChars = lowercaseChars + uppercaseChars + numberChars + specialChars;
    const passwordLength = 8;
    let password = '';
    password += lowercaseChars[Math.floor(Math.random() * 26)];
    password += uppercaseChars[Math.floor(Math.random() * 26)];
    password += numberChars[Math.floor(Math.random() * 10)];
    password += specialChars[Math.floor(Math.random() * specialChars.length)];
    for (let i = 4; i < passwordLength; i++) {
        password += allChars[Math.floor(Math.random() * allChars.length)];
    }
    password = password.split('').sort(() => Math.random() - 0.5).join('');
    return password;
};

module.exports = { generateRandomPassword }