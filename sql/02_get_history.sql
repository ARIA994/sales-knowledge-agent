-- Last 6 messages for one user, oldest first.
-- The user_id filter runs before the limit, so two reps asking at the same
-- time never consume each other's slots.

select role, content
from (
  select role, content, created_at
  from conversations
  where user_id = '{{ $json.user_id }}'
  order by created_at desc
  limit 6
) recent
order by created_at asc;
