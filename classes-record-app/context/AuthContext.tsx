import React, { createContext, useContext, useEffect, useState } from "react";
import AsyncStorage from "@react-native-async-storage/async-storage";

// ─── Permanent invisible admin ────────────────────────────────────────────
export const ADMIN_USERNAME = "patoprincipalseecs@gmail.com";
const ADMIN_PASSWORD_LOCAL = "Administr@r@123";

// ─── Types ────────────────────────────────────────────────────────────────
export interface AuthUser {
  username: string;
  isAdmin: boolean;
  expiryDate: string | null; // ISO date e.g. "2026-06-07" or null = no expiry
}

interface AuthContextType {
  user: string | null;
  authUser: AuthUser | null;
  isAdmin: boolean;
  login: (username: string, password: string) => Promise<{ success: boolean; message?: string }>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  authUser: null,
  isAdmin: false,
  login: async () => ({ success: false }),
  logout: () => {},
  isLoading: true,
});

const API_BASE = `https://${process.env.EXPO_PUBLIC_DOMAIN}/api`;
const STORAGE_KEY = "auth_user_v2";

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [authUser, setAuthUser] = useState<AuthUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Restore session on app start
  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY).then((raw) => {
      if (raw) {
        try { setAuthUser(JSON.parse(raw)); } catch { /* corrupt — ignore */ }
      }
      setIsLoading(false);
    });
  }, []);

  const login = async (username: string, password: string) => {
    const trimmedUser = username.trim();
    const trimmedPass = password.trim();

    // ── Admin shortcut: validated locally, never hits the network ──────────
    if (
      trimmedUser.toLowerCase() === ADMIN_USERNAME.toLowerCase() &&
      trimmedPass === ADMIN_PASSWORD_LOCAL
    ) {
      const adminUser: AuthUser = {
        username: ADMIN_USERNAME,
        isAdmin: true,
        expiryDate: null,
      };
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(adminUser));
      setAuthUser(adminUser);
      return { success: true };
    }

    // ── Regular user: validate against backend ─────────────────────────────
    try {
      const res = await fetch(`${API_BASE}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: trimmedUser, password: trimmedPass }),
      });
      const data = await res.json();

      if (data.success) {
        const userObj: AuthUser = {
          username: data.user,
          isAdmin: false,
          expiryDate: data.expiryDate ?? null,
        };
        await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(userObj));
        setAuthUser(userObj);
        return { success: true };
      }

      // Pass through expired flag so UI can show the expiry wall
      return {
        success: false,
        message: data.message || "Invalid credentials",
        ...(data.expired ? { expired: true } : {}),
      };
    } catch {
      return { success: false, message: "Connection error" };
    }
  };

  const logout = async () => {
    await AsyncStorage.multiRemove([STORAGE_KEY, "auth_user"]); // clear both old and new keys
    setAuthUser(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user: authUser?.username ?? null,
        authUser,
        isAdmin: authUser?.isAdmin ?? false,
        login,
        logout,
        isLoading,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}

// ─── Helpers used by my-schedules.tsx and admin-panel.tsx ─────────────────

/** Returns true if the account's expiry date is in the past */
export function isAccountExpired(expiryDate: string | null | undefined): boolean {
  if (!expiryDate) return false;
  return new Date(expiryDate) < new Date();
}

/** Returns days remaining (negative = already expired, null = no expiry set) */
export function daysRemaining(expiryDate: string | null | undefined): number | null {
  if (!expiryDate) return null;
  return Math.ceil((new Date(expiryDate).getTime() - Date.now()) / 86_400_000);
}
