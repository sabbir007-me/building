import { supabase } from '@/lib/supabase';

const tables = ['profiles', 'properties', 'applications', 'rentals', 'payments', 'maintenance', 'notifications'];

function assertConfigured() {
    if (!supabase) {
        throw new Error('Supabase is not configured. Set NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY.');
    }
}

function mapProfile(row) {
    return { id: row.id, name: row.name, email: row.email, phone: row.phone, role: row.role, status: row.status };
}

function mapRow(table, row) {
    if (table === 'profiles')
        return mapProfile(row);
    return Object.fromEntries(Object.entries(row).map(([key, value]) => [
        key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase()),
        value,
    ]));
}

export async function fetchRentEaseData() {
    assertConfigured();
    const results = await Promise.all(tables.map(async (table) => {
        const { data, error } = await supabase.from(table).select('*');
        if (error)
            throw new Error(`Unable to load ${table} from Supabase: ${error.message}`, { cause: error });
        return [table, data.map((row) => mapRow(table, row))];
    }));
    return {
        users: results.find(([table]) => table === 'profiles')[1],
        ...Object.fromEntries(results.filter(([table]) => table !== 'profiles')),
    };
}

export function subscribeToRentEaseData(onChange) {
    assertConfigured();
    const channel = supabase
        .channel('rentease-realtime')
        .on('postgres_changes', { event: '*', schema: 'public' }, onChange)
        .subscribe();
    return () => {
        void supabase.removeChannel(channel);
    };
}

export async function signIn(email, password) {
    assertConfigured();
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error)
        throw new Error(error.message, { cause: error });
    return data.user;
}

export async function signUp({ email, password, name, phone, role }) {
    assertConfigured();
    const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: { data: { name, phone, role } },
    });
    if (error)
        throw new Error(error.message, { cause: error });
    return data.user;
}

export async function signOut() {
    assertConfigured();
    const { error } = await supabase.auth.signOut();
    if (error)
        throw new Error(error.message, { cause: error });
}
