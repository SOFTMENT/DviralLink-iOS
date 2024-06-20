CREATE TABLE "device_tokens" (
    "id" serial NOT NULL PRIMARY KEY,
    "token" VARCHAR NOT NULL UNIQUE,
    "user_id" bigint NOT NULL REFERENCES users(id)
);