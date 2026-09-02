export type UserRole = 'admin' | 'user' | 'collector' | 'guest';
export type UserType = 'Resident' | 'Owner';

export interface SmartBin {
  id: string;
  name: string;
  location: string;
  type: 'Residential' | 'Commercial' | 'Public Park' | 'Campus';
  dryFill: number; // 0-100%
  wetFill: number; // 0-100%
  overallFill: number; // 0-100%
  battery: number; // 0-100%
  weight: number; // in kg
  moistureLevel: number; // 0-100 scale
  isOnline: boolean;
  hasContamination: boolean;
  hasLiquidLeak: boolean;
  predictedFullHours: number;
  lastUpdated: string;
}

export interface UserProfile {
  id: string;
  name: string;
  userType: UserType;
  flatNo: string;
  ecoPoints: number;
  ecoScore: number;
  totalDisposals: number;
  rank: number;
  totalResidentsInApartment: number;
}

export interface LeaderboardEntry {
  rank: number;
  name: string;
  userType: UserType;
  flatNo: string;
  ecoPoints: number;
  ecoScore: number;
  isCurrentUser?: boolean;
}

export interface RewardItem {
  id: string;
  title: string;
  costPoints: number;
  category: string;
  description: string;
}

export interface SystemEvent {
  id: string;
  binId: string;
  timestamp: string;
  type: 'DISPOSAL_SUCCESS' | 'CONTAMINATION_ALERT' | 'OVERFILL_WARNING' | 'MAINTENANCE_REQUIRED';
  message: string;
  severity: 'info' | 'warning' | 'critical';
}
