CREATE TABLE "roles" (
                         "id" serial NOT NULL PRIMARY KEY,
                         "name" varchar(15) NOT NULL UNIQUE
);

CREATE TABLE "users" (
                         "id" serial NOT NULL PRIMARY KEY,
                         "email" varchar(100) NOT NULL UNIQUE,
                         "password" varchar(255),
                         "name" varchar(100),
                         "about_user" varchar(200),
                         "instagram_account" varchar(120),
                         "twitter_account" varchar(120),
                         "role_id" bigint NOT NULL REFERENCES roles(id),
                         "authentication_provider" varchar(15) NOT NULL,
                         "confirmed" BOOLEAN NOT NULL,
                         "posts_views" integer
);

CREATE TABLE "tokens" (
                          "key" varchar(100) NOT NULL PRIMARY KEY,
                          "expiration_time" TIMESTAMP NOT NULL,
                          "user_id" bigint NOT NULL UNIQUE REFERENCES users(id)
);

CREATE TABLE "posts" (
                         "id" serial NOT NULL PRIMARY KEY,
                         "link" varchar(255) NOT NULL,
                         "picture" varchar(500) NOT NULL,
                         "song_name" varchar(500) NOT NULL,
                         "creation_time" TIMESTAMP NOT NULL,
                         "user_id" bigint NOT NULL REFERENCES users(id)
);


CREATE TABLE "comments" (
                            "id" serial NOT NULL PRIMARY KEY,
                            "text" varchar(255) NOT NULL,
                            "creation_time" TIMESTAMP NOT NULL,
                            "user_id" bigint NOT NULL REFERENCES users(id),
                            "post_id" bigint NOT NULL REFERENCES posts(id) ON DELETE CASCADE
);

INSERT INTO roles VALUES(1, 'USER');
INSERT INTO roles VALUES(2, 'ADMIN');