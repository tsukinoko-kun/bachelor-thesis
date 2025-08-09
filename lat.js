const timesMs = [
  14.198, 13.348, 16.855, 13.408, 16.714, 16.627, 18.547, 16.562, 16.681,
  13.874, 13.389, 14.309, 13.56, 14.392, 14.096, 14.071, 13.314, 17.408, 16.579,
  16.652,
];

timesMs.sort((a, b) => a - b);

const median = timesMs[Math.floor(timesMs.length / 2)];
const mean = timesMs.reduce((a, b) => a + b, 0) / timesMs.length;
const stdDev = Math.sqrt(
  timesMs.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / timesMs.length,
);

console.log(`Median: ${median}ms`);
console.log(`Durchschnitt: ${mean}ms`);
console.log(`Standardabweichung: ${stdDev}ms`);
