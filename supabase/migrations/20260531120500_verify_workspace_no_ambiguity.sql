-- One-time verification (already executed). Retained as a no-op so local
-- migration history matches the remote database. The original DO block proved
-- that ensure_infra_workspace no longer raises "user_id is ambiguous".
select 1;
