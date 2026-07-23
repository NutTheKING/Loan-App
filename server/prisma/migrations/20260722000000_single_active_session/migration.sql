DELETE FROM "RefreshToken"
WHERE "id" IN (
  SELECT "id"
  FROM (
    SELECT
      "id",
      ROW_NUMBER() OVER (
        PARTITION BY "userId"
        ORDER BY "createdAt" DESC, "id" DESC
      ) AS "position"
    FROM "RefreshToken"
  ) AS "rankedTokens"
  WHERE "position" > 1
);

DROP INDEX IF EXISTS "RefreshToken_userId_expiresAt_idx";
CREATE UNIQUE INDEX "RefreshToken_userId_key" ON "RefreshToken"("userId");
