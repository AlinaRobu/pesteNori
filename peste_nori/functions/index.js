const { logger } = require("firebase-functions");
const { defineSecret } = require("firebase-functions/params");
const { HttpsError, onCall } = require("firebase-functions/v2/https");

const routingKey = defineSecret("OPENROUTESERVICE_API_KEY");
const directionsUrl =
  "https://api.heigit.org/openrouteservice/v2/directions/foot-walking/geojson";

function isCoordinate(point) {
  return Array.isArray(point) &&
    point.length === 2 &&
    Number.isFinite(point[0]) && Math.abs(point[0]) <= 180 &&
    Number.isFinite(point[1]) && Math.abs(point[1]) <= 90;
}

async function requestApproach(start, entry, apiKey) {
  const response = await fetch(directionsUrl, {
    method: "POST",
    headers: {
      Authorization: apiKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      coordinates: [start, entry],
      radiuses: [100, 25],
      instructions: false,
    }),
    signal: AbortSignal.timeout(8000),
  });

  if (response.status === 404) return null;
  if (!response.ok) {
    logger.warn("Walking route request failed", { status: response.status });
    throw new Error("Routing provider returned an error");
  }

  const result = await response.json();
  const feature = result.features?.[0];
  const duration = feature?.properties?.summary?.duration;
  const coordinates = feature?.geometry?.coordinates;
  if (feature?.geometry?.type !== "LineString" ||
      !Number.isFinite(duration) || duration <= 0 ||
      !Array.isArray(coordinates) || coordinates.length < 2 ||
      !coordinates.every(isCoordinate)) {
    return null;
  }
  return { coordinates, duration };
}

exports.walkingApproach = onCall({
  region: "europe-west1",
  secrets: [routingKey],
  enforceAppCheck: true,
  maxInstances: 3,
  concurrency: 10,
  timeoutSeconds: 20,
}, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in to get walking directions.");
  }
  const { start, entries } = request.data ?? {};
  if (!isCoordinate(start) || !Array.isArray(entries) ||
      entries.length < 1 || entries.length > 3 ||
      !entries.every(isCoordinate)) {
    throw new HttpsError("invalid-argument", "Invalid trail approach coordinates.");
  }

  const results = await Promise.allSettled(
    entries.map((entry) => requestApproach(start, entry, routingKey.value())),
  );
  let best = null;
  for (const result of results) {
    if (result.status !== "fulfilled" || result.value === null) continue;
    if (best === null || result.value.duration < best.duration) {
      best = result.value;
    }
  }
  if (best === null && results.some((result) => result.status === "rejected")) {
    throw new HttpsError("unavailable", "The walking route provider is unavailable.");
  }
  return { coordinates: best?.coordinates ?? null };
});
