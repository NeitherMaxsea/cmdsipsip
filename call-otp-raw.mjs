const res = await fetch('https://us-central1-thesiscapstone-785e2.cloudfunctions.net/sendRegistrationOtp', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ data: { email: 'gramaticasteve5@gmail.com', role: 'user', contactNumber: '90212212121' } }),
});
const text = await res.text();
console.log('STATUS', res.status);
console.log(text);
