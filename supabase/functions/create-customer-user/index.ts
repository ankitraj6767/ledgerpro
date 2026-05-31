import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

type CustomerPayload = {
  organization_id?: string;
  user_id?: string;
  member_id?: string;
  full_name?: string;
  email?: string;
  password?: string;
  phone?: string;
  notes?: string;
};

type AuthUserLite = {
  id: string;
  email?: string;
};

type CustomerMembership = {
  id: string;
  user_id: string;
  role: string;
};

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  if (!['POST', 'PATCH', 'DELETE'].includes(req.method)) {
    return json({ error: 'Method not allowed' }, 405);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return json({ error: 'Supabase function secrets are not configured.' }, 500);
  }

  const authorization = req.headers.get('Authorization') ?? '';
  const token = authorization.replace(/^Bearer\s+/i, '').trim();
  if (!token) {
    return json({ error: 'Authentication required.' }, 401);
  }

  const callerClient = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: authorization } },
  });
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const {
    data: { user: caller },
    error: callerError,
  } = await callerClient.auth.getUser(token);

  if (callerError || !caller) {
    return json({ error: 'Invalid or expired session.' }, 401);
  }

  let payload: CustomerPayload;
  try {
    payload = await req.json();
  } catch (_) {
    return json({ error: 'Invalid JSON body.' }, 400);
  }

  const organizationId = cleanOptional(payload.organization_id);
  if (organizationId == null) {
    return json({ error: 'organization_id is required.' }, 400);
  }

  const canManage = await callerCanManageOrganization(
    adminClient,
    organizationId,
    caller.id,
  );
  if (!canManage.ok) {
    return json({ error: canManage.error }, canManage.status);
  }

  if (req.method === 'POST') {
    return createCustomer(adminClient, payload, organizationId, caller.id);
  }
  if (req.method === 'PATCH') {
    return updateCustomer(adminClient, payload, organizationId, caller.id);
  }
  return deleteCustomer(adminClient, payload, organizationId, caller.id);
});

async function createCustomer(
  adminClient: SupabaseClient,
  payload: CustomerPayload,
  organizationId: string,
  callerId: string,
): Promise<Response> {
  const validationError = validateCreatePayload(payload);
  if (validationError != null) {
    return json({ error: validationError }, 400);
  }

  const fullName = payload.full_name!.trim();
  const email = payload.email!.trim().toLowerCase();
  const password = payload.password!;
  const phone = cleanOptional(payload.phone);
  const notes = cleanOptional(payload.notes);

  let authUser: AuthUserLite | null;
  try {
    authUser = await findUserByEmail(adminClient, email);
  } catch (error) {
    return json({ error: messageFrom(error) }, 500);
  }
  let createdAuthUser = false;

  if (authUser == null) {
    const { data, error } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName },
    });

    if (error) {
      try {
        authUser = await findUserByEmail(adminClient, email);
      } catch (lookupError) {
        return json({ error: messageFrom(lookupError) }, 500);
      }
      if (authUser == null) {
        return json({ error: error.message }, 400);
      }
    } else if (data.user != null) {
      authUser = {
        id: data.user.id,
        email: data.user.email ?? email,
      };
      createdAuthUser = true;
    }
  }

  if (authUser == null) {
    return json({ error: 'Could not create or locate the auth user.' }, 500);
  }

  if (!createdAuthUser) {
    const { error: reactivateError } = await adminClient.auth.admin
      .updateUserById(authUser.id, {
        email,
        password,
        email_confirm: true,
        ban_duration: 'none',
        user_metadata: { full_name: fullName },
      });
    if (reactivateError) {
      return json({ error: reactivateError.message }, 400);
    }
  }

  const profileError = await upsertProfile(adminClient, {
    userId: authUser.id,
    fullName,
    phone,
  });
  if (profileError != null) {
    return json({ error: profileError }, 500);
  }

  const membershipResult = await upsertCustomerMembership(adminClient, {
    organizationId,
    userId: authUser.id,
    callerId,
    notes,
  });

  if (!membershipResult.ok) {
    return json({ error: membershipResult.error }, membershipResult.status);
  }

  return json({
    user_id: authUser.id,
    email: authUser.email ?? email,
    membership_id: membershipResult.membershipId,
    created_auth_user: createdAuthUser,
  });
}

async function updateCustomer(
  adminClient: SupabaseClient,
  payload: CustomerPayload,
  organizationId: string,
  callerId: string,
): Promise<Response> {
  const validationError = validateUpdatePayload(payload);
  if (validationError != null) {
    return json({ error: validationError }, 400);
  }

  const membership = await findCustomerMembership(
    adminClient,
    organizationId,
    payload,
  );
  if (!membership.ok) {
    return json({ error: membership.error }, membership.status);
  }

  const fullName = payload.full_name!.trim();
  const email = payload.email!.trim().toLowerCase();
  const password = cleanOptional(payload.password);
  const phone = cleanOptional(payload.phone);
  const notes = cleanOptional(payload.notes);

  const existingUser = await findUserByEmail(adminClient, email);
  if (existingUser != null && existingUser.id !== membership.customer.user_id) {
    return json({ error: 'Another auth user already uses this email.' }, 409);
  }

  const attributes: Record<string, unknown> = {
    email,
    ban_duration: 'none',
    user_metadata: { full_name: fullName },
  };
  if (password != null) {
    attributes.password = password;
  }

  const { error: authError } = await adminClient.auth.admin.updateUserById(
    membership.customer.user_id,
    attributes,
  );
  if (authError) {
    return json({ error: authError.message }, 400);
  }

  const profileError = await upsertProfile(adminClient, {
    userId: membership.customer.user_id,
    fullName,
    phone,
  });
  if (profileError != null) {
    return json({ error: profileError }, 500);
  }

  const { data, error } = await adminClient
    .from('organization_members')
    .update({
      notes,
      deleted_at: null,
      updated_by: callerId,
      updated_at: new Date().toISOString(),
    })
    .eq('id', membership.customer.id)
    .eq('role', 'customer')
    .select('id')
    .single();

  if (error) {
    return json({ error: error.message }, 500);
  }

  return json({
    user_id: membership.customer.user_id,
    email,
    membership_id: data.id,
    updated_auth_user: true,
  });
}

async function deleteCustomer(
  adminClient: SupabaseClient,
  payload: CustomerPayload,
  organizationId: string,
  callerId: string,
): Promise<Response> {
  const membership = await findCustomerMembership(
    adminClient,
    organizationId,
    payload,
  );
  if (!membership.ok) {
    return json({ error: membership.error }, membership.status);
  }
  if (membership.customer.user_id === callerId) {
    return json({ error: 'You cannot remove your own access.' }, 400);
  }

  const { error } = await adminClient
    .from('organization_members')
    .update({
      deleted_at: new Date().toISOString(),
      updated_by: callerId,
      updated_at: new Date().toISOString(),
    })
    .eq('id', membership.customer.id)
    .eq('role', 'customer');

  if (error) {
    return json({ error: error.message }, 500);
  }

  const disabledPassword = crypto.randomUUID() + crypto.randomUUID();
  const { error: disableAuthError } = await adminClient.auth.admin
    .updateUserById(membership.customer.user_id, {
      password: disabledPassword,
      ban_duration: '876000h',
      user_metadata: {
        customer_access_deleted_at: new Date().toISOString(),
        customer_access_deleted_from: organizationId,
      },
    });
  if (disableAuthError) {
    return json({ error: disableAuthError.message }, 500);
  }

  const { error: assignmentError } = await adminClient
    .from('customer_project_assignments')
    .update({
      deleted_at: new Date().toISOString(),
      updated_by: callerId,
      updated_at: new Date().toISOString(),
    })
    .eq('organization_id', organizationId)
    .eq('customer_user_id', membership.customer.user_id)
    .is('deleted_at', null);
  if (assignmentError) {
    return json({ error: assignmentError.message }, 500);
  }

  const { error: revokeError } = await adminClient.rpc(
    'revoke_auth_sessions_for_user',
    { p_user_id: membership.customer.user_id },
  );
  if (revokeError) {
    return json({ error: revokeError.message }, 500);
  }

  return json({
    user_id: membership.customer.user_id,
    membership_id: membership.customer.id,
    deleted: true,
  });
}

function validateCreatePayload(payload: CustomerPayload): string | null {
  const shared = validateCustomerDetails(payload);
  if (shared != null) return shared;
  if ((payload.password ?? '').length < 8) {
    return 'Password must be at least 8 characters.';
  }
  return null;
}

function validateUpdatePayload(payload: CustomerPayload): string | null {
  if (cleanOptional(payload.user_id) == null && cleanOptional(payload.member_id) == null) {
    return 'user_id or member_id is required.';
  }
  const shared = validateCustomerDetails(payload);
  if (shared != null) return shared;
  const password = cleanOptional(payload.password);
  if (password != null && password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  return null;
}

function validateCustomerDetails(payload: CustomerPayload): string | null {
  if (cleanOptional(payload.full_name) == null) {
    return 'Customer name is required.';
  }
  const email = cleanOptional(payload.email);
  if (email == null || !emailRegex.test(email)) {
    return 'Enter a valid customer email.';
  }
  return null;
}

async function callerCanManageOrganization(
  adminClient: SupabaseClient,
  organizationId: string,
  callerId: string,
): Promise<{ ok: true } | { ok: false; status: number; error: string }> {
  const { data, error } = await adminClient
    .from('organization_members')
    .select('role')
    .eq('organization_id', organizationId)
    .eq('user_id', callerId)
    .is('deleted_at', null)
    .maybeSingle();

  if (error) {
    return { ok: false, status: 500, error: error.message };
  }
  if (data == null || !['owner', 'manager'].includes(String(data.role))) {
    return { ok: false, status: 403, error: 'Not permitted to manage customers.' };
  }
  return { ok: true };
}

async function findCustomerMembership(
  adminClient: SupabaseClient,
  organizationId: string,
  payload: CustomerPayload,
): Promise<
  | { ok: true; customer: CustomerMembership }
  | { ok: false; status: number; error: string }
> {
  let query = adminClient
    .from('organization_members')
    .select('id, user_id, role')
    .eq('organization_id', organizationId)
    .eq('role', 'customer')
    .is('deleted_at', null);

  const memberId = cleanOptional(payload.member_id);
  const userId = cleanOptional(payload.user_id);
  if (memberId != null) {
    query = query.eq('id', memberId);
  } else if (userId != null) {
    query = query.eq('user_id', userId);
  } else {
    return { ok: false, status: 400, error: 'user_id or member_id is required.' };
  }

  const { data, error } = await query.maybeSingle();
  if (error) {
    return { ok: false, status: 500, error: error.message };
  }
  if (data == null) {
    return { ok: false, status: 404, error: 'Customer access was not found.' };
  }
  return {
    ok: true,
    customer: {
      id: String(data.id),
      user_id: String(data.user_id),
      role: String(data.role),
    },
  };
}

async function findUserByEmail(
  adminClient: SupabaseClient,
  email: string,
): Promise<AuthUserLite | null> {
  for (let page = 1; page <= 10; page += 1) {
    const { data, error } = await adminClient.auth.admin.listUsers({
      page,
      perPage: 1000,
    });
    if (error) {
      throw error;
    }

    const match = data.users.find(
      (user) => (user.email ?? '').toLowerCase() === email.toLowerCase(),
    );
    if (match != null) {
      return { id: match.id, email: match.email ?? email };
    }
    if (data.users.length < 1000) {
      return null;
    }
  }
  return null;
}

async function upsertProfile(
  adminClient: SupabaseClient,
  params: { userId: string; fullName: string; phone: string | null },
): Promise<string | null> {
  const { error } = await adminClient.from('profiles').upsert({
    id: params.userId,
    full_name: params.fullName,
    phone: params.phone,
    default_language: 'en',
    deleted_at: null,
    updated_at: new Date().toISOString(),
  });
  return error?.message ?? null;
}

async function upsertCustomerMembership(
  adminClient: SupabaseClient,
  params: {
    organizationId: string;
    userId: string;
    callerId: string;
    notes: string | null;
  },
): Promise<
  | { ok: true; membershipId: string }
  | { ok: false; status: number; error: string }
> {
  const { data: existing, error: existingError } = await adminClient
    .from('organization_members')
    .select('id, role, deleted_at')
    .eq('organization_id', params.organizationId)
    .eq('user_id', params.userId)
    .maybeSingle();

  if (existingError) {
    return { ok: false, status: 500, error: existingError.message };
  }

  if (existing != null) {
    if (String(existing.role) !== 'customer') {
      return {
        ok: false,
        status: 409,
        error:
          'This auth user is already a non-customer member. Role changes need explicit admin handling.',
      };
    }

    const { data, error } = await adminClient
      .from('organization_members')
      .update({
        role: 'customer',
        notes: params.notes,
        deleted_at: null,
        updated_by: params.callerId,
        updated_at: new Date().toISOString(),
      })
      .eq('id', existing.id)
      .select('id')
      .single();

    if (error) {
      return { ok: false, status: 500, error: error.message };
    }
    return { ok: true, membershipId: data.id };
  }

  const { data, error } = await adminClient
    .from('organization_members')
    .insert({
      organization_id: params.organizationId,
      user_id: params.userId,
      role: 'customer',
      notes: params.notes,
      created_by: params.callerId,
      updated_by: params.callerId,
    })
    .select('id')
    .single();

  if (error) {
    return { ok: false, status: 500, error: error.message };
  }
  return { ok: true, membershipId: data.id };
}

function cleanOptional(value: string | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed == null || trimmed.length === 0 ? null : trimmed;
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function messageFrom(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
