-- Vector store for the document chunks, plus the conversation log.
-- The documents table and match_documents signature are what n8n's
-- Supabase Vector Store node expects; changing them breaks the node.

create extension if not exists vector;

create table documents (
  id        bigserial primary key,
  content   text,
  metadata  jsonb,          -- { source: "01_pricing.md", section: "Plans" }
  embedding vector(1536)    -- text-embedding-3-small
);

create index on documents using ivfflat (embedding vector_cosine_ops) with (lists = 100);

create table conversations (
  id         bigserial primary key,
  user_id    text not null,
  role       text not null,  -- 'user' or 'assistant'
  content    text not null,
  created_at timestamptz default now()
);

-- The agent only ever reads the last few rows for one user,
-- so index on that pair rather than on time alone.
create index on conversations (user_id, created_at desc);
