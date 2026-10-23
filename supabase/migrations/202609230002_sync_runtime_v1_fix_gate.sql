-- Phase 6B Fix Gate: receipt attachments are immutable create/delete records.
-- Apply after 202609230001_sync_runtime_v1.sql.

alter function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  rename to sync_apply_mutation_v1_phase6b_base;

revoke all on function public.sync_apply_mutation_v1_phase6b_base(
  uuid,uuid,text,uuid,text,bigint,jsonb
) from public, anon, authenticated;

create function public.sync_apply_mutation_v1(
  p_mutation_id uuid,
  p_device_id uuid,
  p_entity_type text,
  p_entity_id uuid,
  p_operation text,
  p_base_server_version bigint,
  p_payload jsonb
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    return jsonb_build_object('status','REJECTED','reason','AUTH_REQUIRED');
  end if;
  if p_entity_type='receipt_attachment' and p_operation='update' then
    return jsonb_build_object(
      'status','REJECTED','reason','UNSUPPORTED_OPERATION'
    );
  end if;
  return public.sync_apply_mutation_v1_phase6b_base(
    p_mutation_id,
    p_device_id,
    p_entity_type,
    p_entity_id,
    p_operation,
    p_base_server_version,
    p_payload
  );
end;
$$;

revoke all on function public.sync_apply_mutation_v1(
  uuid,uuid,text,uuid,text,bigint,jsonb
) from public, anon;
grant execute on function public.sync_apply_mutation_v1(
  uuid,uuid,text,uuid,text,bigint,jsonb
) to authenticated;
