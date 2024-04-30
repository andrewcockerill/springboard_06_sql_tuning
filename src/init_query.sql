-- Setup database
DROP DATABASE IF EXISTS dblp;

CREATE DATABASE dblp;

\c dblp

-- begin ct statements

-- articles
CREATE TABLE public.article
(
    "articleID" UUID NOT NULL DEFAULT
    gen_random_uuid (),
    title text,
    author text,
    year text,
    journal text,
    pages text,
    CONSTRAINT articles_pkey PRIMARY KEY ("articleID")
);

-- authors
CREATE TABLE public.author
(
    "authorID" UUID NOT NULL DEFAULT gen_random_uuid (),
    "authorName" text COLLATE pg_catalog."default",
    CONSTRAINT authors_pkey PRIMARY KEY ("authorID")
);

-- books
CREATE TABLE public.book
(
    "bookID" UUID NOT NULL DEFAULT gen_random_uuid (),
    title text COLLATE pg_catalog."default",
    author text COLLATE pg_catalog."default",
    publisher text COLLATE pg_catalog."default",
    isbn text,
    year text,
    pages text,
    CONSTRAINT books_pkey PRIMARY KEY ("bookID") 
);

-- inproceedings
CREATE TABLE public.inproceedings
(
    "inproceedingsID" UUID NOT NULL DEFAULT gen_random_uuid (),
    title text COLLATE pg_catalog."default",
    author text COLLATE pg_catalog."default",
    year text,
    pages text,
    booktitle text COLLATE pg_catalog."default",
    CONSTRAINT inproceedings_pkey PRIMARY KEY ("inproceedingsID")
);

-- proceedings
CREATE TABLE public.proceedings
(
    "proceedingsID" UUID NOT NULL DEFAULT gen_random_uuid (),
    title text,
    editor text,
    year text,
    booktitle text,
    series text,
    publisher text,
    CONSTRAINT proceedings_pkey PRIMARY KEY ("proceedingsID")
);

-- publications
CREATE TABLE public.publications
(
    "pubID" UUID NOT NULL DEFAULT gen_random_uuid (),
    title text,
    year text,
    pages text,
    CONSTRAINT publications_pkey PRIMARY KEY ("pubID")
);