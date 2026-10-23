export function persistence(admin:any) {
  const rpc = async (name:string,params:Record<string,unknown>) => {
    const { data,error } = await admin.rpc(name,params);
    if (error) throw new Error(`billing RPC ${name} failed`);
    return data;
  };
  return {
    async commit(s:any) {
      return rpc('billing_commit_verification_v2', {
        p_user_id:s.userId,p_platform:s.platform,p_environment:s.environment,p_identity_hash:s.identityHash,
        p_original_identity:s.originalIdentity,p_product_id:s.productId,p_state:s.state,
        p_valid_from:s.validFrom,p_valid_until:s.validUntil,p_token:s.token,
        p_acknowledged:s.acknowledged,p_ack_pending:s.acknowledgementPending,p_observed_at:s.observedAt ?? new Date().toISOString(),
      });
    },
    async markAcknowledged(platform:string,environment:string,identityHash:string) {
      return rpc('billing_mark_acknowledged_v1',{p_platform:platform,p_environment:environment,p_identity_hash:identityHash});
    },
    async refresh(userId:string,environment:string) {
      const rows = await rpc('billing_refresh_entitlements_v1',{p_user_id:userId,p_environment:environment});
      const adFree = (rows ?? []).find((r:any)=>r.capability==='adFree');
      const active = !!adFree && ['active','gracePeriod','cancelledButActive'].includes(adFree.state);
      return {active,adFree:active,premium:active,state:adFree?.state ?? 'inactive',validUntil:adFree?.valid_until ?? null,verifiedAt:adFree?.verified_at ?? null};
    },
    async beginEvent(event:any) {return rpc('billing_begin_provider_event_v1',{
      p_provider:event.provider,p_environment:event.environment,p_event_id:event.id,p_event_type:event.type,
      p_event_time:event.time ?? null,p_identity_hash:event.identityHash ?? null,
    });},
    async finishEvent(event:any,claimId:string,state:string,errorCode:string|null=null) {
      return rpc('billing_finish_provider_event_v1',{p_provider:event.provider,p_environment:event.environment,
        p_event_id:event.id,p_claim_id:claimId,p_state:state,p_error_code:errorCode});
    },
    async lookup(platform:string,environment:string,identityHash:string) {
      const rows=await rpc('billing_lookup_source_v1',{p_platform:platform,p_environment:environment,p_identity_hash:identityHash});
      return rows?.[0] ?? null;
    },
    async accountExists(userId:string) {return rpc('billing_account_exists_v1',{p_user_id:userId});},
    async claimCandidates(environment:string,limit:number) {
      return rpc('billing_claim_reconcile_v1',{p_environment:environment,p_limit:limit});
    },
  };
}
