'use client';

import { useEffect } from 'react';
import { fetchRentEaseData, subscribeToRentEaseData } from '@/lib/supabase-data';
import { supabase } from '@/lib/supabase';
import { writeDemoData } from '@/lib/demo-store';

export default function SupabaseRealtimeBridge() {
    useEffect(() => {
        if (!supabase)
            return undefined;
        let active = true;
        const sync = async () => {
            try {
                const data = await fetchRentEaseData();
                if (active)
                    writeDemoData(data);
            }
            catch (error) {
                console.error('Unable to synchronize RentEase with Supabase.', error);
            }
        };
        void sync();
        const unsubscribe = subscribeToRentEaseData(() => {
            void sync();
        });
        const { data: authListener } = supabase.auth.onAuthStateChange(() => {
            void sync();
        });
        return () => {
            active = false;
            unsubscribe();
            authListener.subscription.unsubscribe();
        };
    }, []);
    return null;
}
