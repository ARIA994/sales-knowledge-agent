-- Similarity search called by the n8n Supabase Vector Store node.
-- The <=> operator is cosine distance, so 1 - distance gives similarity.
-- The signature must match what the node sends; renaming the arguments breaks it.

create or replace function match_documents (
  query_embedding vector(1536),
  match_count int default null,
  filter jsonb default '{}'
) returns table (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
) language plpgsql as $$
begin
  return query
  select d.id, d.content, d.metadata,
         1 - (d.embedding <=> query_embedding) as similarity
  from documents d
  where d.metadata @> filter
  order by d.embedding <=> query_embedding
  limit match_count;
end;
$$;
