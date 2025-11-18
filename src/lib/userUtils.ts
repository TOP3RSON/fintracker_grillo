import { supabase } from '@/integrations/supabase/client';

// Utility function to get the current user's ID
export const getCurrentUserId = async (): Promise<string | null> => {
  const { data: { user } } = await supabase.auth.getUser();
  return user?.id || null;
};

// Utility function to check if the user is authenticated
export const isAuthenticated = async (): Promise<boolean> => {
  const { data: { user } } = await supabase.auth.getUser();
  return !!user;
};

// Utility function to get user profile details if needed
export const getCurrentUserProfile = async () => {
  const { data: { user }, error } = await supabase.auth.getUser();
  
  if (error) {
    console.error('Erro ao obter usuário atual:', error);
    return null;
  }
  
  if (!user) {
    return null;
  }
  
  // Optionally fetch additional user info from usuarios table if needed
  return {
    id: user.id,
    email: user.email,
    created_at: user.created_at,
  };
};