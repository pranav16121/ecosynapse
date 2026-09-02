'use client';

import React, { useState, useEffect } from 'react';
import { 
  Trash2, 
  Activity, 
  AlertTriangle, 
  BatteryCharging, 
  Droplets, 
  Scale, 
  QrCode, 
  Award, 
  TrendingUp, 
  RefreshCw, 
  CheckCircle2, 
  ShieldAlert, 
  MapPin, 
  Navigation, 
  Radio, 
  Zap,
  Sliders,
  User,
  Truck,
  LayoutDashboard,
  Trophy,
  Gift,
  Home,
  Building,
  ArrowRight,
  LogOut,
  Sparkles,
  Sun,
  Moon,
  ChevronUp,
  Copy,
  Check,
  Eye,
  EyeOff,
  HelpCircle,
  ChevronDown,
  Menu,
  X,
  Keyboard,
  Cookie,
  Info,
  Star,
  Mail,
  Send,
  Users,
  CheckCircle,
  ExternalLink,
  ChevronRight,
  Volume2,
  VolumeX,
  Printer,
  Camera,
  Clock,
  Scan,
  Bot,
  UserCheck,
  Bell,
  BellRing
} from 'lucide-react';
import { INITIAL_BINS, INITIAL_USER, TOP_LEADERBOARD, AVAILABLE_REWARDS, INITIAL_EVENTS } from '../lib/mockData';
import { SmartBin, UserProfile, SystemEvent, UserRole, UserType, LeaderboardEntry, RewardItem } from '../lib/types';
import { supabase, isSupabaseConfigured } from '@/lib/supabase';
import { signUpUser, signInUser, signOutUser } from '@/lib/auth';
import { calculatePredictiveFullHours } from '@/lib/predictiveEngine';

interface RegisteredAccount {
  name: string;
  email: string;
  password: string;
  userType: UserType;
  flatNo: string;
}

export default function EcoSynapseApp() {
  // Authentication & Navigation States
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(false);
  const [activeRole, setActiveRole] = useState<UserRole>('user');
  const [authMode, setAuthMode] = useState<'login' | 'signup'>('login');
  
  // Registration & Form States
  const [userNameInput, setUserNameInput] = useState<string>('Sriram');
  const [userEmailInput, setUserEmailInput] = useState<string>('sriram@ecosynapse.com');
  const [userTypeInput, setUserTypeInput] = useState<UserType>('Resident');
  const [flatNoInput, setFlatNoInput] = useState<string>('A-402');
  const [passwordInput, setPasswordInput] = useState<string>('EcoSynapse2026!');
  const [showPassword, setShowPassword] = useState<boolean>(false);
  const [authError, setAuthError] = useState<string | null>(null);

  // Registered Accounts DB (persisted in localStorage)
  const [registeredAccounts, setRegisteredAccounts] = useState<RegisteredAccount[]>([
    {
      name: 'Sriram',
      email: 'sriram@ecosynapse.com',
      password: 'EcoSynapse2026!',
      userType: 'Resident',
      flatNo: 'A-402',
    },
    {
      name: 'Admin Manager',
      email: 'admin@ecosynapse.com',
      password: 'adminpassword',
      userType: 'Owner',
      flatNo: 'ADMIN-01',
    },
  ]);

  // App Core States
  const [activeTab, setActiveTab] = useState<'dashboard' | 'simulator' | 'collector' | 'userApp'>('userApp');
  const [bins, setBins] = useState<SmartBin[]>(INITIAL_BINS);
  const [user, setUser] = useState<UserProfile>(INITIAL_USER);
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>(TOP_LEADERBOARD);
  const [rewards, setRewards] = useState<RewardItem[]>(AVAILABLE_REWARDS);
  const [events, setEvents] = useState<SystemEvent[]>(INITIAL_EVENTS);
  const [selectedBinId, setSelectedBinId] = useState<string>('BIN-102');
  const [simulationRunning, setSimulationRunning] = useState<boolean>(true);
  
  // UI Feature States
  const [isDarkMode, setIsDarkMode] = useState<boolean>(true);
  const [showCookieBanner, setShowCookieBanner] = useState<boolean>(false);
  const [showCookieModal, setShowCookieModal] = useState<boolean>(false);
  const [cookiePreferences, setCookiePreferences] = useState({
    telemetry: true,
    analytics: true,
    leaderboard: true,
  });
  const [showBackToTop, setShowBackToTop] = useState<boolean>(false);
  const [showShortcutsModal, setShowShortcutsModal] = useState<boolean>(false);
  const [showAboutModal, setShowAboutModal] = useState<boolean>(false);
  const [showContactModal, setShowContactModal] = useState<boolean>(false);
  const [showWaitlistModal, setShowWaitlistModal] = useState<boolean>(false);
  const [showThankYouModal, setShowThankYouModal] = useState<boolean>(false);
  const [showQrModal, setShowQrModal] = useState<boolean>(false);
  const [showNotificationsModal, setShowNotificationsModal] = useState<boolean>(false);
  const [collectorFilter, setCollectorFilter] = useState<'all' | 'urgent'>('all');
  
  // Audio Voice Feedback State
  const [audioEnabled, setAudioEnabled] = useState<boolean>(true);

  // Trigger Audio Voice Alert for Sanitation Collectors & Residents
  const triggerVoiceAlert = (text: string) => {
    if (typeof window !== 'undefined' && 'speechSynthesis' in window && audioEnabled) {
      try {
        window.speechSynthesis.cancel();
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.rate = 1.0;
        window.speechSynthesis.speak(utterance);
      } catch (e) {}
    }
  };

  // AI Chatbot State
  const [showChatbotModal, setShowChatbotModal] = useState<boolean>(false);
  const [chatInput, setChatInput] = useState<string>('');
  const [chatMessages, setChatMessages] = useState<Array<{ sender: 'user' | 'bot'; text: string }>>([
    {
      sender: 'bot',
      text: '👋 Hello! I am EcoBot, your EcoSynapse AI Assistant. Ask me anything about waste sorting, EcoPoints, smart bin telemetry, sensor fusion, or sanitation collection routes!',
    },
  ]);

  const [thankYouDetails, setThankYouDetails] = useState<{ title: string; desc: string }>({ title: '', desc: '' });
  const [copiedText, setCopiedText] = useState<string | null>(null);
  const [isLoadingSkeleton, setIsLoadingSkeleton] = useState<boolean>(false);
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(0);
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [waitlistEmail, setWaitlistEmail] = useState<string>('');

  // Load Registered Accounts & Cookie Consent from localStorage
  useEffect(() => {
    if (typeof window !== 'undefined') {
      const savedAccounts = localStorage.getItem('ecosynapse_accounts');
      if (savedAccounts) {
        try {
          setRegisteredAccounts(JSON.parse(savedAccounts));
        } catch (e) {}
      }
      const savedConsent = localStorage.getItem('ecosynapse_cookie_consent');
      if (!savedConsent) {
        setShowCookieBanner(true);
      }
    }
  }, []);

  // Time-Based Dynamic Greeting Generator (Uses user device local clock, e.g. IST Bangalore)
  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  };
  // Toast Helper
  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Copy Helper
  const handleCopy = (text: string, label: string) => {
    if (typeof window !== 'undefined' && navigator.clipboard) {
      navigator.clipboard.writeText(text);
    }
  };

  // Skeleton Loader
  const handleTriggerRefresh = () => {
    setIsLoadingSkeleton(true);
    setTimeout(() => {
      setIsLoadingSkeleton(false);
      showToast('Refreshed live telemetry node states');
    }, 800);
  };

  // Back to Top Scroll Listener
  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 200) setShowBackToTop(true);
      else setShowBackToTop(false);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  // Keyboard Shortcuts Listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === '?' || (e.shiftKey && e.key === '/')) {
        setShowShortcutsModal((prev) => !prev);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Auth Submit: Real Supabase Auth & Local Account Verification
  const handleAuthSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setAuthError(null);

    if (authMode === 'signup') {
      const res = await signUpUser(
        userEmailInput,
        passwordInput,
        userNameInput,
        userTypeInput,
        flatNoInput
      );

      if (res.error) {
        setAuthError(res.error);
        return;
      }

      if (res.user) {
        setUser((prev) => ({
          ...prev,
          name: res.user!.name,
          userType: res.user!.userType,
          flatNo: res.user!.flatNo,
          ecoPoints: res.user!.ecoPoints,
        }));
        setIsLoggedIn(true);
        navigateRoleTab(activeRole);
        showToast(`🎉 Registration successful! Account synced for ${res.user.name}.`);
      }
    } else {
      // LOGIN MODE VERIFICATION
      const res = await signInUser(userEmailInput, passwordInput);

      if (res.error) {
        setAuthError(res.error);
        return;
      }

      if (res.user) {
        setUser((prev) => ({
          ...prev,
          name: res.user!.name,
          userType: res.user!.userType,
          flatNo: res.user!.flatNo,
          ecoPoints: res.user!.ecoPoints,
        }));
        setIsLoggedIn(true);
        navigateRoleTab(activeRole);
        showToast(`Welcome back, ${res.user.name}! Logged in cleanly.`);
      } else {
        setAuthError('Invalid email or password. Please check your credentials or Sign Up.');
      }
    }
  };

  // Guest Quick Access
  const handleContinueAsGuest = () => {
    setUser((prev) => ({
      ...prev,
      name: 'Guest Resident',
      userType: 'Resident',
      flatNo: 'A-402',
    }));
    setActiveRole('user');
    setActiveTab('userApp');
    setIsLoggedIn(true);
    showToast('Entered EcoSynapse in Guest Mode.');
  };

  const navigateRoleTab = (role: UserRole) => {
    if (role === 'admin') setActiveTab('dashboard');
    else if (role === 'collector') setActiveTab('collector');
    else setActiveTab('userApp');
  };

  // AI Chatbot Knowledge Engine & Google Gemini LLM API Handler
  const handleSendChatMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!chatInput.trim()) return;

    const userText = chatInput.trim();
    const newMessages = [...chatMessages, { sender: 'user' as const, text: userText }];
    setChatMessages(newMessages);
    setChatInput('');

    try {
      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prompt: userText,
          bins,
          user,
          leaderboard,
        }),
      });

      if (res.ok) {
        const data = await res.json();
        if (data.reply) {
          setChatMessages((prev) => [...prev, { sender: 'bot', text: data.reply }]);
          return;
        }
      }
    } catch (err) {
      console.log('Gemini API fetch fallback:', err);
    }

    // Fallback response generator
    const q = userText.toLowerCase();
    let botResponse = `EcoSynapse is an intelligent waste-management ecosystem. Currently monitoring ${bins.length} smart bins (${selectedBin.id} is at ${selectedBin.overallFill}% capacity). You can ask me about hardware sensors, EcoPoints rewards, leaderboards, or collection routes!`;

    if (q.includes('leaderboard') || q.includes('rank') || q.includes('ranking') || q.includes('position') || q.includes('place') || q.includes('points') || q.includes('score')) {
      const top10Pts = leaderboard[9]?.ecoPoints || 610;
      const ptsNeeded = Math.max(10, top10Pts - user.ecoPoints);
      const disposalsNeeded = Math.ceil(ptsNeeded / 10);
      botResponse = `🏆 **Your EcoSynapse Leaderboard Status**:\n\n• **Current Rank:** #${user.rank} out of ${user.totalResidentsInApartment} residents\n• **EcoPoints Balance:** ${user.ecoPoints} Pts\n• **Verified Disposals:** ${user.totalDisposals}\n\n🥇 **Top Resident:** ${leaderboard[0]?.name || 'Ananya Sharma'} (${leaderboard[0]?.ecoPoints || 1450} Pts)\n🎯 **Target:** You need **+${ptsNeeded} EcoPoints** (~${disposalsNeeded} proper dry waste disposals) to break into the Top 10 Leaderboard!`;
    } else if (q.includes('which') || q.includes('full') || q.includes('critical') || q.includes('overflow') || q.includes('houses')) {
      const fullBins = bins.filter((b) => b.overallFill >= 80);
      if (fullBins.length === 0) {
        botResponse = '🟢 Good news! All smart bins in the society are currently under 80% capacity.';
      } else {
        const listStr = fullBins.map((b) => `• ${b.name} (${b.location}) — ${b.overallFill}% Full`).join('\n');
        botResponse = `🚨 Smart Bins & Blocks Needing Immediate Pickup (≥80% Full):\n\n${listStr}\n\nSanitation drivers have been dispatched for these locations!`;
      }
    } else if (q.includes('dustbin') || q.includes('my bin') || q.includes('bin status') || q.includes('bin-102')) {
      const myBin = (bins && bins.length > 1 ? bins[1] : bins[0]);
      botResponse = `🗑️ Details for Your Assigned Smart Bin (${myBin.name} — ${myBin.id}):\n\n• Location: ${myBin.location}\n• Overall Capacity: ${myBin.overallFill}% ${myBin.overallFill >= 85 ? '(CRITICAL FULL)' : '(Normal)'}\n• Dry Compartment: ${myBin.dryFill}%\n• Wet Compartment: ${myBin.wetFill}%\n• Weight Load: ${myBin.weight} kg\n• Moisture Grid: ${myBin.moistureLevel}%\n• Active Sensor Flags: ${myBin.hasContamination ? '⚠️ Wet Contamination in Dry' : ''} ${myBin.hasLiquidLeak ? '🚨 Bottom Sump Leak' : 'All Clear'}\n• Predictive Engine: Reaches 100% capacity in ~${myBin.predictedFullHours} hrs.`;
    }

    setChatMessages((prev) => [...prev, { sender: 'bot', text: botResponse }]);
  };

  // Ticker for Auto Simulation
  useEffect(() => {
    if (!simulationRunning || !isLoggedIn) return;
    const interval = setInterval(() => {
      setBins((prevBins) =>
        prevBins.map((bin) => {
          if (!bin.isOnline) return bin;
          const fillDelta = Math.random() > 0.6 ? 1 : 0;
          const newDry = Math.min(100, bin.dryFill + fillDelta);
          const newWet = Math.min(100, bin.wetFill + (fillDelta > 0 ? 1 : 0));
          const newOverall = Math.round((newDry + newWet) / 2);
          return {
            ...bin,
            dryFill: newDry,
            wetFill: newWet,
            overallFill: newOverall,
            weight: Number((bin.weight + (fillDelta * 0.1)).toFixed(1)),
            lastUpdated: 'Just now',
          };
        })
      );
    }, 4000);
    return () => clearInterval(interval);
  }, [simulationRunning, isLoggedIn]);

  // FETCH LIVE DATA FROM SUPABASE CLOUD DATABASE ON MOUNT
  useEffect(() => {
    async function loadCloudData() {
      try {
        if (!isSupabaseConfigured()) return;

        // 1. Fetch Smart Bins
        const { data: binRows } = await supabase.from('bins').select('*').order('id');
        if (binRows && binRows.length > 0) {
          const mappedBins: SmartBin[] = binRows.map((r: any) => ({
            id: r.id,
            name: r.name,
            location: r.location,
            type: r.type,
            dryFill: r.dry_fill,
            wetFill: r.wet_fill,
            overallFill: r.overall_fill,
            battery: r.battery,
            weight: Number(r.weight),
            moistureLevel: r.moisture_level,
            isOnline: r.is_online,
            hasContamination: r.has_contamination,
            hasLiquidLeak: r.has_liquid_leak,
            predictedFullHours: Number(r.predicted_full_hours),
            lastUpdated: 'Live Supabase DB',
          }));
          setBins(mappedBins);
        }

        // 2. Fetch Leaderboard Users
        const { data: userRows } = await supabase.from('users').select('*').order('eco_points', { ascending: false });
        if (userRows && userRows.length > 0) {
          const dbEntries: LeaderboardEntry[] = userRows.map((u: any, idx: number) => ({
            rank: idx + 1,
            name: u.name,
            userType: u.user_type,
            flatNo: u.flat_no,
            ecoPoints: u.eco_points,
            ecoScore: u.eco_score,
          }));

          if (dbEntries.length >= 10) {
            setLeaderboard(dbEntries.slice(0, 10));
          } else {
            // Fill remaining spots with TOP_LEADERBOARD mock data so the Leaderboard always displays Top 10
            const dbNames = new Set(dbEntries.map((e) => e.name.toLowerCase()));
            const fillFromMock = TOP_LEADERBOARD.filter((m) => !dbNames.has(m.name.toLowerCase()));
            const combined = [...dbEntries, ...fillFromMock]
              .sort((a, b) => b.ecoPoints - a.ecoPoints)
              .slice(0, 10)
              .map((item, idx) => ({ ...item, rank: idx + 1 }));
            setLeaderboard(combined);
          }
        }

        // 3. Fetch Rewards
        const { data: rewardRows } = await supabase.from('rewards').select('*');
        if (rewardRows && rewardRows.length > 0) {
          const mappedRewards: RewardItem[] = rewardRows.map((r: any) => ({
            id: r.id,
            title: r.title,
            costPoints: r.cost_points,
            category: r.category,
            description: r.description,
          }));
          setRewards(mappedRewards);
        }
      } catch (err) {
        console.log('Supabase mount fetch fallback:', err);
      }
    }
    loadCloudData();

    // 4. SUPABASE REALTIME WEBSOCKET SUBSCRIPTION (Zero Latency Instant Push)
    if (isSupabaseConfigured()) {
      const channel = supabase
        .channel('realtime-bins-channel')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'bins' }, (payload: any) => {
          if (payload.new) {
            const updated = payload.new;
            setBins((prev) =>
              prev.map((b) =>
                b.id === updated.id
                  ? {
                      ...b,
                      dryFill: updated.dry_fill ?? b.dryFill,
                      wetFill: updated.wet_fill ?? b.wetFill,
                      overallFill: updated.overall_fill ?? b.overallFill,
                      weight: Number(updated.weight ?? b.weight),
                      moistureLevel: updated.moisture_level ?? b.moistureLevel,
                      battery: updated.battery ?? b.battery,
                      isOnline: updated.is_online ?? true,
                      predictedFullHours: calculatePredictiveFullHours(updated.overall_fill ?? b.overallFill),
                      lastUpdated: 'Realtime WebSocket Push ⚡',
                    }
                  : b
              )
            );
          }
        })
        .subscribe();

      return () => {
        supabase.removeChannel(channel);
      };
    }
  }, []);

  // Handler: Simulate Disposal with Audio Voice Cue
  const handleSimulateDisposal = (binId: string, isCorrect: boolean) => {
    setBins((prev) =>
      prev.map((b) => {
        if (b.id !== binId) return b;
        const dryAdd = isCorrect ? 8 : 2;
        const wetAdd = isCorrect ? 1 : 12;
        const newDry = Math.min(100, b.dryFill + dryAdd);
        const newWet = Math.min(100, b.wetFill + wetAdd);
        const newOverall = Math.round((newDry + newWet) / 2);
        return {
          ...b,
          dryFill: newDry,
          wetFill: newWet,
          overallFill: newOverall,
          hasContamination: !isCorrect || b.hasContamination,
          moistureLevel: isCorrect ? Math.max(10, b.moistureLevel - 5) : Math.min(95, b.moistureLevel + 35),
          weight: Number((b.weight + 0.4).toFixed(1)),
        };
      })
    );

    if (isCorrect) {
      setUser((u) => ({
        ...u,
        ecoPoints: u.ecoPoints + 10,
        totalDisposals: u.totalDisposals + 1,
        ecoScore: Math.min(100, u.ecoScore + 1),
      }));
      addEvent(binId, 'DISPOSAL_SUCCESS', `Verified Dry Waste disposal (+10 EcoPoints)`, 'info');
      showToast('🎉 +10 EcoPoints! Verified Dry disposal.');
    } else {
      addEvent(binId, 'CONTAMINATION_ALERT', 'Contamination alert! Wet waste detected in Dry compartment.', 'warning');
      showToast('⚠️ Warning: Wet waste detected in Dry compartment!');
    }
  };

  // Redeem Reward
  const handleRedeemReward = (reward: RewardItem) => {
    if (user.ecoPoints < reward.costPoints) {
      showToast(`Insufficient points! You need ${reward.costPoints - user.ecoPoints} more points.`);
      return;
    }
    setUser((u) => ({
      ...u,
      ecoPoints: u.ecoPoints - reward.costPoints,
    }));

    setThankYouDetails({
      title: `Voucher Claimed: ${reward.title}`,
      desc: `Your redemption code [ECO-REC-${Math.floor(1000 + Math.random() * 9000)}] has been credited to flat ${user.flatNo}!`,
    });
    setShowThankYouModal(true);
  };

  // Empty Bin
  const handleEmptyBin = (binId: string) => {
    setBins((prev) =>
      prev.map((b) => {
        if (b.id !== binId) return b;
        return {
          ...b,
          dryFill: 0,
          wetFill: 0,
          overallFill: 0,
          weight: 0.5,
          hasContamination: false,
          hasLiquidLeak: false,
          moistureLevel: 10,
          predictedFullHours: 24.0,
          lastUpdated: 'Just now (Emptied)',
        };
      })
    );
    addEvent(binId, 'DISPOSAL_SUCCESS', `Bin ${binId} emptied by collection staff.`, 'info');
    showToast(`Bin ${binId} marked as emptied!`);
  };

  const handleToggleOnline = (binId: string) => {
    setBins((prev) =>
      prev.map((b) => (b.id === binId ? { ...b, isOnline: !b.isOnline } : b))
    );
  };

  const addEvent = (binId: string, type: SystemEvent['type'], message: string, severity: SystemEvent['severity']) => {
    const newEvt: SystemEvent = {
      id: `EVT-${Date.now().toString().slice(-4)}`,
      binId,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' }),
      type,
      message,
      severity,
    };
    setEvents((prev) => [newEvt, ...prev.slice(0, 9)]);
  };

  // FAQs Data
  const faqs = [
    {
      q: '1. How does EcoSynapse differentiate between Dry and Wet waste?',
      a: 'EcoSynapse uses multi-sensor fusion: the top intake tray measures surface moisture, load cell weight density, and camera visual shape before the motorized diverter flap opens.',
    },
    {
      q: '2. How do I earn EcoPoints as a Resident or Owner?',
      a: 'Scan the QR code on any EcoSynapse bin using your mobile app before throwing waste. Proper dry disposal awards +10 EcoPoints towards your apartment leaderboard rank.',
    },
    {
      q: '3. What happens if wet waste is accidentally thrown in the Dry compartment?',
      a: 'The dry compartment sidewall humidity sensor detects the moisture spike, triggers an immediate Contamination Alert on the Admin Dashboard, and boosts collection route priority.',
    },
    {
      q: '4. How can I redeem my EcoPoints for apartment maintenance rewards?',
      a: 'Go to the User EcoPoints tab, browse available vouchers (Maintenance Fee Credits, Compost Bags, Passes), and tap "Redeem Voucher". Your voucher code is automatically sent to your flat.',
    },
    {
      q: '5. What hardware and sensors are used in an EcoSynapse smart bin?',
      a: 'Each node includes an ESP32 microcontroller, ToF proximity lid sensor, ESP32-CAM visual sensor with flash LED, capacitive moisture grid, load cell weight sensor, dual ultrasonic fill sensors, and bottom sump leak sensor.',
    },
  ];

  // Reviews Data
  const reviews = [
    {
      name: 'Ananya Sharma',
      role: 'Owner (Flat C-701)',
      comment: 'EcoSynapse transformed our society! Everyone is competing on the green leaderboard to get maintenance fee credits.',
      rating: 5,
    },
    {
      name: 'Rajesh V.',
      role: 'Estate Manager, Greenwood Heights',
      comment: 'Bin overflow complaints dropped to zero. The predictive fill system alerts our collectors before bins hit 90%.',
      rating: 5,
    },
    {
      name: 'Vikram Mehta',
      role: 'Resident (Flat B-304)',
      comment: 'The touchless lid and instant EcoPoints verification make recycling super addictive and rewarding.',
      rating: 5,
    },
  ];

  const teamMembers = [
    { name: 'Sriram', role: 'Lead Systems Architect & Software Engineer', avatar: '⚡' },
    { name: 'EcoSynapse Hardware Team', role: 'Embedded Systems & Sensor Integration', avatar: '🔬' },
    { name: 'EcoSynapse AI Team', role: 'Computer Vision & Predictive Analytics', avatar: '🤖' },
  ];

  const selectedBin = bins.find((b) => b.id === selectedBinId) || bins[0];
  const fullBinsCount = bins.filter((b) => b.overallFill >= 85).length;
  const alertBinsCount = bins.filter((b) => b.hasContamination || b.hasLiquidLeak || !b.isOnline).length;
  const tenthRankPoints = leaderboard[9]?.ecoPoints || 610;

  const themeContainerClass = isDarkMode ? 'dark-theme bg-slate-950 text-slate-100' : 'light-theme bg-slate-50 text-slate-900';
  const cardBgClass = isDarkMode ? 'bg-slate-900 border-slate-800' : 'bg-white border-slate-200 shadow-sm';
  const subCardBgClass = isDarkMode ? 'bg-slate-950 border-slate-800' : 'bg-slate-100 border-slate-200';

  // =========================================================================
  // SCREEN 1: LOGIN / ENTRY PORTAL SCREEN (IF NOT LOGGED IN)
  // =========================================================================
  if (!isLoggedIn) {
    return (
      <div className={`min-h-screen ${themeContainerClass} flex flex-col items-center justify-center p-6 relative overflow-hidden transition-colors duration-300`}>
        
        <a href="#main-auth" className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-emerald-500 text-slate-950 font-bold px-4 py-2 rounded-lg z-50">
          Skip to main auth content
        </a>

        <button
          onClick={() => setIsDarkMode(!isDarkMode)}
          className="absolute top-6 right-6 p-2.5 rounded-xl border border-slate-800 bg-slate-900 text-slate-300 hover:text-white transition-all shadow"
          title="Toggle Theme"
        >
          {isDarkMode ? <Sun className="h-5 w-5 text-amber-400" /> : <Moon className="h-5 w-5 text-indigo-600" />}
        </button>

        <div id="main-auth" className={`max-w-md w-full ${cardBgClass} border rounded-3xl p-8 shadow-2xl space-y-6 relative z-10`}>
          
          <div className="text-center space-y-2">
            <div className="h-14 w-14 rounded-2xl bg-gradient-to-tr from-emerald-500 to-teal-400 mx-auto flex items-center justify-center shadow-lg shadow-emerald-500/20">
              <Activity className="h-8 w-8 text-slate-950 stroke-[2.5]" />
            </div>
            <h1 className="text-2xl font-extrabold tracking-tight">ECOSYNAPSE</h1>
            <p className="text-xs text-slate-400">Intelligent Waste-Management Ecosystem</p>
          </div>

          <div className="bg-gradient-to-r from-emerald-500/10 to-teal-500/10 border border-emerald-500/20 rounded-2xl p-3.5 text-center space-y-1">
            <p className="text-xs font-bold text-emerald-400 flex items-center justify-center gap-1">
              <Sparkles className="h-3.5 w-3.5" /> Next-Gen Smart Bin Ecosystem
            </p>
            <p className="text-[11px] text-slate-300">Log in or Sign Up to track your EcoPoints, manage fleet telemetry, or dispatch collectors.</p>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-semibold text-slate-400 uppercase tracking-wider">1. Select Access Portal</label>
            <div className="grid grid-cols-3 gap-2">
              <button
                type="button"
                onClick={() => setActiveRole('user')}
                className={`p-3 rounded-xl border text-left transition-all hover:scale-[1.02] ${
                  activeRole === 'user'
                    ? 'border-emerald-500 bg-emerald-500/10 text-emerald-400 ring-1 ring-emerald-500'
                    : 'border-slate-800 bg-slate-950 text-slate-400'
                }`}
              >
                <User className="h-5 w-5 mb-1" />
                <div className="text-xs font-bold">User Portal</div>
                <div className="text-[9px] opacity-70">Resident/Owner</div>
              </button>

              <button
                type="button"
                onClick={() => setActiveRole('admin')}
                className={`p-3 rounded-xl border text-left transition-all hover:scale-[1.02] ${
                  activeRole === 'admin'
                    ? 'border-emerald-500 bg-emerald-500/10 text-emerald-400 ring-1 ring-emerald-500'
                    : 'border-slate-800 bg-slate-950 text-slate-400'
                }`}
              >
                <LayoutDashboard className="h-5 w-5 mb-1" />
                <div className="text-xs font-bold">Admin Portal</div>
                <div className="text-[9px] opacity-70">Facility Mgr</div>
              </button>

              <button
                type="button"
                onClick={() => setActiveRole('collector')}
                className={`p-3 rounded-xl border text-left transition-all hover:scale-[1.02] ${
                  activeRole === 'collector'
                    ? 'border-emerald-500 bg-emerald-500/10 text-emerald-400 ring-1 ring-emerald-500'
                    : 'border-slate-800 bg-slate-950 text-slate-400'
                }`}
              >
                <Truck className="h-5 w-5 mb-1" />
                <div className="text-xs font-bold">Collector App</div>
                <div className="text-[9px] opacity-70">Sanitation</div>
              </button>
            </div>
          </div>

          <div className="flex bg-slate-950 p-1 rounded-xl border border-slate-800">
            <button
              type="button"
              onClick={() => { setAuthMode('login'); setAuthError(null); }}
              className={`flex-1 py-1.5 text-xs font-semibold rounded-lg transition-all ${
                authMode === 'login' ? 'bg-slate-800 text-white shadow' : 'text-slate-400'
              }`}
            >
              Log In
            </button>
            <button
              type="button"
              onClick={() => { setAuthMode('signup'); setAuthError(null); }}
              className={`flex-1 py-1.5 text-xs font-semibold rounded-lg transition-all ${
                authMode === 'signup' ? 'bg-slate-800 text-white shadow' : 'text-slate-400'
              }`}
            >
              Sign Up
            </button>
          </div>

          {authError && (
            <div className="bg-rose-500/10 border border-rose-500/30 text-rose-400 p-3 rounded-xl text-xs flex items-center gap-2 font-medium">
              <AlertTriangle className="h-4 w-4 flex-shrink-0" />
              <span>{authError}</span>
            </div>
          )}

          <form onSubmit={handleAuthSubmit} className="space-y-4">
            <div className="space-y-1">
              <label className="text-xs font-medium text-slate-400">Full Name</label>
              <input
                type="text"
                value={userNameInput}
                onChange={(e) => setUserNameInput(e.target.value)}
                placeholder="Enter full name"
                required
                className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500"
              />
            </div>

            <div className="space-y-1">
              <label className="text-xs font-medium text-slate-400">Email Address</label>
              <input
                type="email"
                value={userEmailInput}
                onChange={(e) => setUserEmailInput(e.target.value)}
                placeholder="enter@email.com"
                required
                className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500"
              />
            </div>

            {authMode === 'signup' && activeRole === 'user' && (
              <>
                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-slate-400">Residency Classification</label>
                  <div className="grid grid-cols-2 gap-2">
                    <button
                      type="button"
                      onClick={() => setUserTypeInput('Resident')}
                      className={`p-2.5 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 transition-all ${
                        userTypeInput === 'Resident'
                          ? 'border-emerald-500 bg-emerald-500/20 text-emerald-400'
                          : 'border-slate-800 bg-slate-950 text-slate-400'
                      }`}
                    >
                      <Home className="h-4 w-4" /> Resident / Tenant
                    </button>
                    <button
                      type="button"
                      onClick={() => setUserTypeInput('Owner')}
                      className={`p-2.5 rounded-xl border text-xs font-bold flex items-center justify-center gap-2 transition-all ${
                        userTypeInput === 'Owner'
                          ? 'border-emerald-500 bg-emerald-500/20 text-emerald-400'
                          : 'border-slate-800 bg-slate-950 text-slate-400'
                      }`}
                    >
                      <Building className="h-4 w-4" /> Flat Owner
                    </button>
                  </div>
                </div>

                <div className="space-y-1">
                  <label className="text-xs font-medium text-slate-400">Apartment Flat No</label>
                  <input
                    type="text"
                    value={flatNoInput}
                    onChange={(e) => setFlatNoInput(e.target.value)}
                    placeholder="e.g. A-402"
                    required
                    className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500"
                  />
                </div>
              </>
            )}

            <div className="space-y-1">
              <label className="text-xs font-medium text-slate-400">Password</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={passwordInput}
                  onChange={(e) => setPasswordInput(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500 pr-10"
                />
                <button
                  type="button"
                  onClick={(e) => {
                    e.preventDefault();
                    e.stopPropagation();
                    setShowPassword((prev) => !prev);
                  }}
                  className="absolute right-3 top-2 text-slate-400 hover:text-white z-20 cursor-pointer p-1"
                  title="Toggle Password Visibility"
                >
                  {showPassword ? <Eye className="h-4 w-4 text-emerald-400" /> : <EyeOff className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              className="w-full bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-extrabold text-sm py-3 rounded-xl transition-all shadow-lg shadow-emerald-500/20 flex items-center justify-center gap-2 hover:scale-[1.01]"
            >
              {authMode === 'signup' ? 'Create Account & Enter' : 'Log In & Enter Platform'} <ArrowRight className="h-4 w-4" />
            </button>
          </form>

          {/* REPLACE DEMO MODE WITH CONTINUE AS GUEST OPTION */}
          <div className="text-center pt-2 border-t border-slate-800">
            <button
              type="button"
              onClick={handleContinueAsGuest}
              className="text-xs text-slate-400 hover:text-emerald-400 font-semibold transition-colors flex items-center justify-center gap-1.5 mx-auto"
            >
              <UserCheck className="h-4 w-4" /> Continue as Guest (Quick Demo Access)
            </button>
          </div>

        </div>
      </div>
    );
  }

  // =========================================================================
  // MAIN SYSTEM APP (AFTER LOGGING IN WITH STRICT ROLE ACCESS)
  // =========================================================================
  return (
    <div className={`min-h-screen ${themeContainerClass} flex flex-col font-sans relative transition-colors duration-300`}>
      
      <a href="#main-content" className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-emerald-500 text-slate-950 font-bold px-4 py-2 rounded-lg z-50">
        Skip to main content
      </a>

      {toastMessage && (
        <div className="fixed top-20 right-6 z-50 bg-emerald-500 text-slate-950 font-bold text-xs px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2 animate-bounce">
          <Sparkles className="h-4 w-4" /> {toastMessage}
        </div>
      )}

      {/* Sticky Header Bar with Dynamic Time-Based Greeting */}
      <header className={`border-b ${isDarkMode ? 'border-slate-800 bg-slate-900/80' : 'border-slate-200 bg-white/80'} backdrop-blur-md px-6 py-4 flex items-center justify-between gap-4 sticky top-0 z-40`}>
        
        <div className="flex items-center gap-3">
          <div className="h-10 w-10 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 flex items-center justify-center shadow-lg shadow-emerald-500/20">
            <Activity className="h-6 w-6 text-slate-950 stroke-[2.5]" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              {/* DYNAMIC TIME-BASED GREETING ON TOP */}
              <h1 className="text-lg font-bold tracking-tight">
                {getGreeting()}, <span className="text-emerald-400">{user.name}</span>!
              </h1>
              <span className="bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs px-2 py-0.5 rounded-full font-mono">
                {activeRole === 'user' ? `${user.userType}` : activeRole.toUpperCase()}
              </span>
            </div>
            <p className="text-xs text-slate-400">EcoSynapse Intelligent Waste-Management Ecosystem</p>
          </div>
        </div>

        {/* STRICT ROLE-BASED NAVIGATION TABS */}
        <div className="hidden md:flex items-center bg-slate-950 p-1.5 rounded-xl border border-slate-800">
          
          {(activeRole === 'user' || activeRole === 'guest') && (
            <button
              onClick={() => setActiveTab('userApp')}
              className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition-all ${
                activeTab === 'userApp'
                  ? 'bg-emerald-500 text-slate-950 shadow-md font-semibold'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              <User className="h-4 w-4" /> User EcoPoints
            </button>
          )}

          {activeRole === 'admin' && (
            <>
              <button
                onClick={() => setActiveTab('dashboard')}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition-all ${
                  activeTab === 'dashboard'
                    ? 'bg-emerald-500 text-slate-950 shadow-md font-semibold'
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                <LayoutDashboard className="h-4 w-4" /> Admin Fleet
              </button>
              <button
                onClick={() => setActiveTab('simulator')}
                className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition-all ${
                  activeTab === 'simulator'
                    ? 'bg-emerald-500 text-slate-950 shadow-md font-semibold'
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                <Sliders className="h-4 w-4" /> Hardware Sim
              </button>
            </>
          )}

          {(activeRole === 'collector' || activeRole === 'admin') && (
            <button
              onClick={() => setActiveTab('collector')}
              className={`flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-xs font-medium transition-all ${
                activeTab === 'collector'
                  ? 'bg-emerald-500 text-slate-950 shadow-md font-semibold'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
            >
              <Truck className="h-4 w-4" /> Collector App
            </button>
          )}

          {/* Contact Modal Link for all roles */}
          <button
            onClick={() => setShowContactModal(true)}
            className="text-slate-400 hover:text-white px-3 py-1.5 text-xs font-medium"
          >
            Contact
          </button>

          {/* WAITLIST & ABOUT ARE STRICTLY FOR USER ROLE ONLY */}
          {(activeRole === 'user' || activeRole === 'guest') && (
            <>
              <button
                onClick={() => setShowAboutModal(true)}
                className="text-slate-400 hover:text-white px-3 py-1.5 text-xs font-medium"
              >
                About
              </button>
              <button
                onClick={() => setShowWaitlistModal(true)}
                className="text-emerald-400 hover:text-emerald-300 px-3 py-1.5 text-xs font-bold"
              >
                Waitlist
              </button>
            </>
          )}
        </div>

        {/* Header Right Actions */}
        <div className="flex items-center gap-2">
          {/* COLLECTOR DISPATCH NOTIFICATION BELL */}
          <button
            onClick={() => setShowNotificationsModal(!showNotificationsModal)}
            className="relative p-2 rounded-xl border border-slate-800 bg-slate-950 text-slate-400 hover:text-white transition-all"
            title="Collector Dispatch Alerts"
          >
            {bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length > 0 ? (
              <BellRing className="h-4 w-4 text-rose-400 animate-bounce" />
            ) : (
              <Bell className="h-4 w-4" />
            )}
            {bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length > 0 && (
              <span className="absolute -top-1 -right-1 bg-rose-500 text-white font-mono text-[9px] font-extrabold h-4 w-4 rounded-full flex items-center justify-center border border-slate-950 shadow-md">
                {bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length}
              </span>
            )}
          </button>

          <button
            onClick={handleTriggerRefresh}
            className="p-2 rounded-xl border border-slate-800 bg-slate-950 text-slate-400 hover:text-white transition-all"
            title="Refresh Data"
          >
            <RefreshCw className={`h-4 w-4 ${isLoadingSkeleton ? 'animate-spin text-emerald-400' : ''}`} />
          </button>

          <button
            onClick={() => setIsDarkMode(!isDarkMode)}
            className="p-2 rounded-xl border border-slate-800 bg-slate-950 text-slate-400 hover:text-white transition-all"
            title="Toggle Theme"
          >
            {isDarkMode ? <Sun className="h-4 w-4 text-amber-400" /> : <Moon className="h-4 w-4 text-indigo-600" />}
          </button>

          <div className="text-right text-xs hidden sm:block pl-2 border-l border-slate-800">
            <p className="font-bold">{user.name}</p>
            <p className="text-[11px] text-emerald-400 font-mono">
              {activeRole === 'user' ? `${user.userType} • ${user.flatNo}` : activeRole.toUpperCase()}
            </p>
          </div>

          <button
            onClick={() => setIsLoggedIn(false)}
            className="bg-slate-950 hover:bg-rose-500/10 text-slate-400 hover:text-rose-400 p-2 rounded-xl border border-slate-800 transition-colors"
            title="Log Out"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </header>

      {/* Main Workspace */}
      <main id="main-content" className="flex-1 p-6 max-w-7xl w-full mx-auto space-y-6">

        {/* Breadcrumb Trail */}
        <div className="flex items-center gap-2 text-xs text-slate-400 font-mono">
          <span>Home</span>
          <ChevronRight className="h-3 w-3" />
          <span className="capitalize">{activeRole} Portal</span>
          <ChevronRight className="h-3 w-3" />
          <span className="text-emerald-400 font-bold uppercase">{activeTab}</span>
        </div>

        {/* Live Site Analytics Bar */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 bg-gradient-to-r from-emerald-500/10 via-teal-500/10 to-sky-500/10 border border-emerald-500/20 p-4 rounded-2xl text-xs">
          <div>
            <p className="text-slate-400 text-[10px] uppercase font-mono">Total Waste Diverted</p>
            <p className="text-base font-extrabold text-emerald-400 font-mono">14.8 Tons</p>
          </div>
          <div>
            <p className="text-slate-400 text-[10px] uppercase font-mono">CO2 Emissions Saved</p>
            <p className="text-base font-extrabold text-teal-400 font-mono">3.9 Tons</p>
          </div>
          <div>
            <p className="text-slate-400 text-[10px] uppercase font-mono">Sorting Accuracy</p>
            <p className="text-base font-extrabold text-sky-400 font-mono">98.4%</p>
          </div>
          <div>
            <p className="text-slate-400 text-[10px] uppercase font-mono">Active Smart Bins</p>
            <p className="text-base font-extrabold text-indigo-400 font-mono">5 Bins (100% Sim)</p>
          </div>
        </div>

        {isLoadingSkeleton ? (
          <div className="space-y-6 animate-pulse">
            <div className="h-32 bg-slate-900 rounded-3xl border border-slate-800" />
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="h-64 bg-slate-900 rounded-2xl border border-slate-800 md:col-span-2" />
              <div className="h-64 bg-slate-900 rounded-2xl border border-slate-800" />
            </div>
          </div>
        ) : (
          <>
            {/* ========================================================= */}
            {/* TAB: USER ECOPOINTS & LEADERBOARD (USER ROLE) */}
            {/* ========================================================= */}
            {activeTab === 'userApp' && (
              <div className="space-y-6 animate-fade-in-up">
                
                {/* User Profile Card */}
                <div className={`${cardBgClass} border rounded-3xl p-6 flex flex-col md:flex-row items-start md:items-center justify-between gap-6 hover:border-emerald-500/30 transition-all shadow-xl animate-fade-in-scale`}>
                  <div className="flex items-center gap-4">
                    <div className="h-16 w-16 bg-gradient-to-tr from-emerald-500 to-teal-400 text-slate-950 rounded-2xl flex items-center justify-center font-extrabold text-2xl shadow-lg shadow-emerald-500/20">
                      {user.name.charAt(0)}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h2 className="text-2xl font-bold">{user.name}</h2>
                        <span className="bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs px-2.5 py-0.5 rounded-full font-semibold">
                          {user.userType} ({user.flatNo})
                        </span>
                        
                        <button
                          onClick={() => handleCopy(user.flatNo, 'Flat Code')}
                          className="p-1 text-slate-400 hover:text-white transition-colors"
                          title="Copy Flat Code"
                        >
                          {copiedText === user.flatNo ? <Check className="h-3.5 w-3.5 text-emerald-400" /> : <Copy className="h-3.5 w-3.5" />}
                        </button>
                      </div>
                      <p className="text-xs text-slate-400 mt-1 flex items-center gap-2">
                        <span>Apartment Rank: <strong className="text-amber-400">#{user.rank} of {user.totalResidentsInApartment}</strong></span>
                        • <span>Disposals: <strong>{user.totalDisposals}</strong></span>
                      </p>
                    </div>
                  </div>

                  <div className={`${subCardBgClass} border rounded-2xl px-6 py-4 flex items-center gap-6 w-full md:w-auto justify-between`}>
                    <div>
                      <p className="text-[11px] font-semibold uppercase tracking-wider text-slate-400">EcoPoints Balance</p>
                      <p className="text-3xl font-extrabold text-emerald-400 font-mono mt-0.5">{user.ecoPoints}</p>
                    </div>
                    
                    {/* Printable Bin QR Code Action */}
                    <div className="flex gap-2">
                      <button
                        onClick={() => setShowQrModal(true)}
                        className="bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 font-bold text-xs p-2.5 rounded-xl transition-all"
                        title="Print Bin QR Label"
                      >
                        <Printer className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleSimulateDisposal('BIN-102', true)}
                        className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold text-xs px-4 py-2.5 rounded-xl transition-all shadow-md shadow-emerald-500/10 flex items-center gap-2 hover:scale-[1.02]"
                      >
                        <QrCode className="h-4 w-4" /> Scan QR & Dispose
                      </button>
                    </div>
                  </div>
                </div>

                {/* ECOPOINTS SYSTEM FORMULA & USER TIERS CARD (FROM INFOGRAPHIC) */}
                <div className={`${cardBgClass} border rounded-3xl p-6 space-y-4 hover:border-emerald-500/30 transition-all shadow-xl`}>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 border-b border-slate-800 pb-3">
                    <div>
                      <h3 className="text-base font-bold flex items-center gap-2">
                        <Sparkles className="h-5 w-5 text-amber-400" /> EcoPoints Calculation Engine & User Tiers
                      </h3>
                      <p className="text-xs text-slate-400">Rewarding Responsible Waste Behaviour • Driving a Circular Future</p>
                    </div>
                    <span className="bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs px-3 py-1 rounded-full font-mono font-bold">
                      💎 Platinum Tier (1.5x Multiplier)
                    </span>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {/* Formula Card */}
                    <div className={`${subCardBgClass} p-4 rounded-2xl border space-y-2 text-xs md:col-span-2`}>
                      <h4 className="font-bold text-emerald-400 flex items-center justify-between">
                        <span>Formula: EP = (SA × 40%) + (RP × 25%) + (WR × 20%) + (CS × 10%) + (CB × 5%)</span>
                        <span className="font-mono text-[10px] text-slate-500">Weighted Scoring</span>
                      </h4>
                      <div className="grid grid-cols-2 sm:grid-cols-5 gap-2 text-[11px] font-mono pt-1">
                        <div className="bg-slate-950 p-2 rounded-xl border border-slate-800 text-center">
                          <p className="text-emerald-400 font-bold">SA (40%)</p>
                          <p className="text-[10px] text-slate-500 mt-0.5">Segregation Accuracy</p>
                        </div>
                        <div className="bg-slate-950 p-2 rounded-xl border border-slate-800 text-center">
                          <p className="text-sky-400 font-bold">RP (25%)</p>
                          <p className="text-[10px] text-slate-500 mt-0.5">Recycling Rate</p>
                        </div>
                        <div className="bg-slate-950 p-2 rounded-xl border border-slate-800 text-center">
                          <p className="text-indigo-400 font-bold">WR (20%)</p>
                          <p className="text-[10px] text-slate-500 mt-0.5">Waste Reduction</p>
                        </div>
                        <div className="bg-slate-950 p-2 rounded-xl border border-slate-800 text-center">
                          <p className="text-amber-400 font-bold">CS (10%)</p>
                          <p className="text-[10px] text-slate-500 mt-0.5">Streak Consistency</p>
                        </div>
                        <div className="bg-slate-950 p-2 rounded-xl border border-slate-800 text-center">
                          <p className="text-teal-400 font-bold">CB (5%)</p>
                          <p className="text-[10px] text-slate-500 mt-0.5">Disposal Bonus</p>
                        </div>
                      </div>
                    </div>

                    {/* Tiers Card */}
                    <div className={`${subCardBgClass} p-4 rounded-2xl border space-y-2 text-xs`}>
                      <h4 className="font-bold text-amber-400">User Tiers & Multipliers</h4>
                      <div className="space-y-1 font-mono text-[11px]">
                        <div className="flex justify-between text-slate-400"><span>🌱 Green (&lt; 50 Score):</span><span>1.0x</span></div>
                        <div className="flex justify-between text-slate-300"><span>🥈 Silver (50-69 Score):</span><span>1.1x</span></div>
                        <div className="flex justify-between text-amber-300"><span>🥇 Gold (70-89 Score):</span><span>1.25x</span></div>
                        <div className="flex justify-between text-emerald-400 font-bold"><span>💎 Platinum (90+ Score):</span><span>1.5x</span></div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* ASSIGNED BIN CAPACITY & SENSOR FAULT WIDGET */}
                <div className={`${cardBgClass} border rounded-3xl p-6 space-y-4 hover:border-emerald-500/30 transition-all shadow-xl animate-fade-in-up`}>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 border-b border-slate-800 pb-3">
                    <div>
                      <h3 className="text-base font-bold flex items-center gap-2">
                        <Radio className="h-5 w-5 text-emerald-400" /> My Assigned Smart Bin: Greenwood Block B (BIN-102)
                      </h3>
                      <p className="text-xs text-slate-400">Tower B Lobby • Monitored 24/7 by EcoSynapse Telemetry Sensors</p>
                    </div>
                    <span className={`text-xs px-3 py-1 rounded-full font-bold font-mono ${
                      bins[1].overallFill >= 85
                        ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                        : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                    }`}>
                      {bins[1].overallFill}% Capacity
                    </span>
                  </div>

                  {(bins[1].hasContamination || bins[1].hasLiquidLeak || !bins[1].isOnline || bins[1].overallFill >= 85) && (
                    <div className="space-y-2">
                      {bins[1].hasContamination && (
                        <div className="bg-amber-500/10 border border-amber-500/30 text-amber-400 p-3 rounded-xl text-xs flex items-center justify-between">
                          <span className="flex items-center gap-2 font-medium">
                            <AlertTriangle className="h-4 w-4" /> <strong>Sensor Alert:</strong> Moisture sensor detected wet waste contamination in the Dry compartment!
                          </span>
                          <span className="text-[10px] font-mono text-amber-300">Action Flagged</span>
                        </div>
                      )}
                      {bins[1].hasLiquidLeak && (
                        <div className="bg-rose-500/10 border border-rose-500/30 text-rose-400 p-3 rounded-xl text-xs flex items-center justify-between">
                          <span className="flex items-center gap-2 font-medium">
                            <Droplets className="h-4 w-4" /> <strong>Sensor Alert:</strong> Bottom liquid sump sensor detected leachate pooling under wet liner bag.
                          </span>
                          <span className="text-[10px] font-mono text-rose-300">Collector Alerted</span>
                        </div>
                      )}
                      {bins[1].overallFill >= 85 && (
                        <div className="bg-rose-500/10 border border-rose-500/30 text-rose-400 p-3 rounded-xl text-xs flex items-center justify-between">
                          <span className="flex items-center gap-2 font-medium">
                            <Zap className="h-4 w-4" /> <strong>Capacity Alert:</strong> Bin is {bins[1].overallFill}% full. Predictive engine estimates full capacity in ~{bins[1].predictedFullHours} hrs.
                          </span>
                          <span className="text-[10px] font-mono text-rose-300">Collection Dispatched</span>
                        </div>
                      )}
                    </div>
                  )}

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-1">
                    <div className={`${subCardBgClass} p-3.5 rounded-2xl border space-y-2`}>
                      <div className="flex justify-between text-xs font-semibold">
                        <span className="text-sky-400">Dry Recyclables Capacity</span>
                        <span className="font-mono">{bins[1].dryFill}%</span>
                      </div>
                      <div className="w-full bg-slate-800 h-2.5 rounded-full overflow-hidden">
                        <div className="bg-sky-400 h-full transition-all duration-500" style={{ width: `${bins[1].dryFill}%` }} />
                      </div>
                    </div>

                    <div className={`${subCardBgClass} p-3.5 rounded-2xl border space-y-2`}>
                      <div className="flex justify-between text-xs font-semibold">
                        <span className="text-emerald-400">Wet Organic Capacity</span>
                        <span className="font-mono">{bins[1].wetFill}%</span>
                      </div>
                      <div className="w-full bg-slate-800 h-2.5 rounded-full overflow-hidden">
                        <div className="bg-emerald-400 h-full transition-all duration-500" style={{ width: `${bins[1].wetFill}%` }} />
                      </div>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                  <div className="lg:col-span-2 space-y-4">
                    <div className="flex items-center justify-between">
                      <h3 className="text-lg font-bold flex items-center gap-2">
                        <Trophy className="h-5 w-5 text-amber-400" /> Apartment Green Leaderboard (Top 10 of 200)
                      </h3>
                      <span className="text-xs text-slate-400 font-mono">Greenwood Heights Apartments</span>
                    </div>

                    <div className={`${cardBgClass} border rounded-2xl overflow-hidden space-y-0`}>
                      <div className="grid grid-cols-12 text-xs font-semibold text-slate-400 p-4 border-b border-slate-800 bg-slate-950/50">
                        <div className="col-span-2">Rank</div>
                        <div className="col-span-5">Resident / Owner</div>
                        <div className="col-span-2 text-center">Flat No</div>
                        <div className="col-span-3 text-right">EcoPoints</div>
                      </div>

                      <div className="divide-y divide-slate-800/60">
                        {leaderboard.map((item) => (
                          <div
                            key={item.rank}
                            className="grid grid-cols-12 items-center p-4 text-xs transition-colors hover:bg-slate-800/40"
                          >
                            <div className="col-span-2 font-bold flex items-center gap-2">
                              {item.rank === 1 && <span className="text-lg">🥇</span>}
                              {item.rank === 2 && <span className="text-lg">🥈</span>}
                              {item.rank === 3 && <span className="text-lg">🥉</span>}
                              <span className={item.rank <= 3 ? 'text-amber-400 font-extrabold' : 'text-slate-400'}>
                                #{item.rank}
                              </span>
                            </div>

                            <div className="col-span-5">
                              <p className="font-bold">{item.name}</p>
                              <span className={`text-[10px] px-2 py-0.5 rounded-full font-medium ${
                                item.userType === 'Owner' ? 'bg-indigo-500/10 text-indigo-400' : 'bg-emerald-500/10 text-emerald-400'
                              }`}>
                                {item.userType}
                              </span>
                            </div>

                            <div className="col-span-2 text-center font-mono text-slate-400">{item.flatNo}</div>

                            <div className="col-span-3 text-right">
                              <span className="font-mono font-bold text-emerald-400 text-sm">{item.ecoPoints} Pts</span>
                            </div>
                          </div>
                        ))}
                      </div>

                      {user.rank > 10 && (
                        <div className="p-4 bg-slate-950 border-t-2 border-dashed border-slate-800 space-y-2">
                          <div className="flex items-center justify-between text-xs">
                            <div className="flex items-center gap-3">
                              <span className="h-7 w-7 rounded-full bg-slate-800 text-slate-300 font-bold font-mono flex items-center justify-center">
                                #{user.rank}
                              </span>
                              <div>
                                <p className="font-bold flex items-center gap-2">
                                  {user.name} <span className="text-[10px] text-emerald-400 border border-emerald-500/30 px-2 py-0.5 rounded">(YOU)</span>
                                </p>
                                <p className="text-[11px] text-slate-400">{user.userType} • Flat {user.flatNo}</p>
                              </div>
                            </div>
                            <div className="text-right">
                              <p className="font-mono font-bold text-emerald-400 text-sm">{user.ecoPoints} Pts</p>
                              <p className="text-[10px] text-amber-400 mt-0.5">
                                Need +{tenthRankPoints - user.ecoPoints} pts to enter Top 10!
                              </p>
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="space-y-4">
                    <h3 className="text-lg font-bold flex items-center gap-2">
                      <Gift className="h-5 w-5 text-emerald-400" /> Redeem EcoPoints
                    </h3>

                    <div className="space-y-3">
                      {rewards.map((reward) => (
                        <div
                          key={reward.id}
                          className={`${cardBgClass} border rounded-2xl p-4 space-y-3 hover:border-emerald-500/40 transition-all hover:scale-[1.01]`}
                        >
                          <div className="flex items-start justify-between">
                            <div>
                              <span className="text-[10px] uppercase tracking-wider text-emerald-400 font-semibold bg-emerald-500/10 px-2 py-0.5 rounded">
                                {reward.category}
                              </span>
                              <h4 className="font-bold text-sm mt-1">{reward.title}</h4>
                            </div>
                            <span className="font-mono font-extrabold text-emerald-400 text-xs bg-slate-950 px-2.5 py-1 rounded-lg border border-slate-800">
                              {reward.costPoints} Pts
                            </span>
                          </div>

                          <p className="text-xs text-slate-400">{reward.description}</p>

                          <button
                            onClick={() => handleRedeemReward(reward)}
                            className={`w-full text-xs font-bold py-2 rounded-xl transition-all ${
                              user.ecoPoints >= reward.costPoints
                                ? 'bg-emerald-500 hover:bg-emerald-600 text-slate-950 shadow-md shadow-emerald-500/10 hover:scale-[1.01]'
                                : 'bg-slate-800 text-slate-500 cursor-not-allowed'
                            }`}
                          >
                            {user.ecoPoints >= reward.costPoints ? 'Redeem Voucher' : `Needs ${reward.costPoints - user.ecoPoints} More Pts`}
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                <div className={`${cardBgClass} border rounded-3xl p-6 space-y-4`}>
                  <h3 className="text-lg font-bold flex items-center gap-2">
                    <Star className="h-5 w-5 text-amber-400 fill-amber-400" /> Community Reviews & Feedback
                  </h3>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {reviews.map((rev, i) => (
                      <div key={i} className={`${subCardBgClass} p-4 rounded-2xl border space-y-2 text-xs`}>
                        <div className="flex text-amber-400">
                          {Array.from({ length: rev.rating }).map((_, idx) => (
                            <Star key={idx} className="h-3.5 w-3.5 fill-amber-400" />
                          ))}
                        </div>
                        <p className="text-slate-300 italic">&quot;{rev.comment}&quot;</p>
                        <div>
                          <p className="font-bold">{rev.name}</p>
                          <p className="text-[10px] text-slate-500">{rev.role}</p>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div className={`${cardBgClass} border rounded-3xl p-6 space-y-4`}>
                  <h3 className="text-lg font-bold flex items-center gap-2">
                    <HelpCircle className="h-5 w-5 text-emerald-400" /> Frequently Asked Questions (5 FAQs)
                  </h3>

                  <div className="space-y-2">
                    {faqs.map((faq, index) => (
                      <div key={index} className={`${subCardBgClass} border rounded-xl overflow-hidden`}>
                        <button
                          onClick={() => setOpenFaqIndex(openFaqIndex === index ? null : index)}
                          className="w-full text-left p-4 flex items-center justify-between text-xs font-bold"
                        >
                          <span>{faq.q}</span>
                          <ChevronDown className={`h-4 w-4 transition-transform ${openFaqIndex === index ? 'rotate-180 text-emerald-400' : ''}`} />
                        </button>
                        {openFaqIndex === index && (
                          <div className="px-4 pb-4 text-xs text-slate-400 border-t border-slate-800/60 pt-3">
                            {faq.a}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>

                <div className={`${cardBgClass} border rounded-3xl p-6 space-y-4 text-center`}>
                  <h3 className="text-lg font-bold flex items-center justify-center gap-2">
                    <Users className="h-5 w-5 text-sky-400" /> EcoSynapse Core Engineering Team
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    {teamMembers.map((m, i) => (
                      <div key={i} className={`${subCardBgClass} p-4 rounded-2xl border space-y-1`}>
                        <div className="text-3xl">{m.avatar}</div>
                        <h4 className="font-bold text-xs">{m.name}</h4>
                        <p className="text-[10px] text-slate-400">{m.role}</p>
                      </div>
                    ))}
                  </div>
                </div>

              </div>
            )}

            {/* ========================================================= */}
            {/* TAB: ADMIN FLEET DASHBOARD (ADMIN ROLE) */}
            {/* ========================================================= */}
            {activeTab === 'dashboard' && (activeRole === 'admin' || activeRole === 'guest') && (
              <div className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className={`${cardBgClass} border rounded-2xl p-5 flex items-center justify-between`}>
                    <div>
                      <p className="text-xs text-slate-400 font-medium">Total Smart Bins</p>
                      <h3 className="text-2xl font-bold mt-1">{bins.length} Nodes</h3>
                      <p className="text-[11px] text-emerald-400 mt-1 flex items-center gap-1">
                        <Radio className="h-3 w-3" /> {bins.filter((b) => b.isOnline).length} Active Online
                      </p>
                    </div>
                    <div className="h-12 w-12 rounded-xl bg-slate-800 flex items-center justify-center text-slate-300">
                      <Trash2 className="h-6 w-6" />
                    </div>
                  </div>

                  <div className={`${cardBgClass} border rounded-2xl p-5 flex items-center justify-between`}>
                    <div>
                      <p className="text-xs text-slate-400 font-medium">Critical Capacity (&gt;85%)</p>
                      <h3 className="text-2xl font-bold text-amber-400 mt-1">{fullBinsCount} Bins</h3>
                      <p className="text-[11px] text-slate-400 mt-1">Requires priority dispatch</p>
                    </div>
                    <div className="h-12 w-12 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20 flex items-center justify-center">
                      <AlertTriangle className="h-6 w-6" />
                    </div>
                  </div>

                  <div className={`${cardBgClass} border rounded-2xl p-5 flex items-center justify-between`}>
                    <div>
                      <p className="text-xs text-slate-400 font-medium">Active Sensor Alerts</p>
                      <h3 className="text-2xl font-bold text-rose-400 mt-1">{alertBinsCount} Flags</h3>
                      <p className="text-[11px] text-slate-400 mt-1">Contamination / Leaks</p>
                    </div>
                    <div className="h-12 w-12 rounded-xl bg-rose-500/10 text-rose-400 border border-rose-500/20 flex items-center justify-center">
                      <ShieldAlert className="h-6 w-6" />
                    </div>
                  </div>

                  <div className={`${cardBgClass} border rounded-2xl p-5 flex items-center justify-between`}>
                    <div>
                      <p className="text-xs text-slate-400 font-medium">EcoPoints Issued</p>
                      <h3 className="text-2xl font-bold text-emerald-400 mt-1">{user.ecoPoints} Pts</h3>
                      <p className="text-[11px] text-emerald-400 mt-1">{user.totalDisposals} Verified Disposals</p>
                    </div>
                    <div className="h-12 w-12 rounded-xl bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 flex items-center justify-center">
                      <Award className="h-6 w-6" />
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                  <div className="lg:col-span-2 space-y-4">
                    <div className="flex items-center justify-between">
                      <h2 className="text-lg font-bold flex items-center gap-2">
                        <Radio className="h-5 w-5 text-emerald-400" /> Smart Bin Network Fleet
                      </h2>
                      <span className="text-xs text-slate-400 font-mono">Live Telemetry Updates Every 4s</span>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      {bins.map((bin) => (
                        <div
                          key={bin.id}
                          onClick={() => setSelectedBinId(bin.id)}
                          className={`cursor-pointer ${cardBgClass} border rounded-2xl p-5 space-y-4 transition-all hover:border-emerald-500/50 hover:scale-[1.01] ${
                            selectedBinId === bin.id
                              ? 'border-emerald-500 ring-1 ring-emerald-500 shadow-lg shadow-emerald-500/10'
                              : ''
                          }`}
                        >
                          <div className="flex items-start justify-between">
                            <div>
                              <div className="flex items-center gap-2">
                                <h3 className="font-bold text-base">{bin.name}</h3>
                                {!bin.isOnline && (
                                  <span className="bg-slate-800 text-slate-400 text-[10px] px-2 py-0.5 rounded font-mono">
                                    OFFLINE
                                  </span>
                                )}
                              </div>
                              <p className="text-xs text-slate-400 flex items-center gap-1 mt-0.5">
                                <MapPin className="h-3 w-3" /> {bin.location}
                              </p>
                            </div>
                            <span
                              className={`text-xs px-2.5 py-1 rounded-full font-bold font-mono ${
                                bin.overallFill >= 85
                                  ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20'
                                  : bin.overallFill >= 60
                                  ? 'bg-amber-500/10 text-amber-400 border border-amber-500/20'
                                  : 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                              }`}
                            >
                              {bin.overallFill}% Capacity
                            </span>
                          </div>

                          <div className={`space-y-2 ${subCardBgClass} p-3 rounded-xl border`}>
                            <div>
                              <div className="flex justify-between text-xs mb-1 font-mono">
                                <span className="text-sky-400 font-medium">Dry Recyclables</span>
                                <span>{bin.dryFill}%</span>
                              </div>
                              <div className="w-full bg-slate-800 h-2 rounded-full overflow-hidden">
                                <div
                                  className="bg-sky-400 h-full transition-all duration-500"
                                  style={{ width: `${bin.dryFill}%` }}
                                />
                              </div>
                            </div>

                            <div>
                              <div className="flex justify-between text-xs mb-1 font-mono">
                                <span className="text-emerald-400 font-medium">Wet / Organic</span>
                                <span>{bin.wetFill}%</span>
                              </div>
                              <div className="w-full bg-slate-800 h-2 rounded-full overflow-hidden">
                                <div
                                  className="bg-emerald-400 h-full transition-all duration-500"
                                  style={{ width: `${bin.wetFill}%` }}
                                />
                              </div>
                            </div>
                          </div>

                          <div className="grid grid-cols-3 gap-2 text-center text-xs">
                            <div className={`${subCardBgClass} p-2 rounded-lg border`}>
                              <p className="text-[10px] text-slate-500 flex items-center justify-center gap-1">
                                <Scale className="h-3 w-3" /> Weight
                              </p>
                              <p className="font-mono font-semibold mt-0.5">{bin.weight} kg</p>
                            </div>
                            <div className={`${subCardBgClass} p-2 rounded-lg border`}>
                              <p className="text-[10px] text-slate-500 flex items-center justify-center gap-1">
                                <Droplets className="h-3 w-3" /> Moisture
                              </p>
                              <p className={`font-mono font-semibold mt-0.5 ${bin.moistureLevel > 60 ? 'text-amber-400' : ''}`}>
                                {bin.moistureLevel}%
                              </p>
                            </div>
                            <div className={`${subCardBgClass} p-2 rounded-lg border`}>
                              <p className="text-[10px] text-slate-500 flex items-center justify-center gap-1">
                                <BatteryCharging className="h-3 w-3" /> Battery
                              </p>
                              <p className="font-mono text-emerald-400 font-semibold mt-0.5">{bin.battery}%</p>
                            </div>
                          </div>

                          {(bin.hasContamination || bin.hasLiquidLeak) && (
                            <div className="flex flex-wrap gap-2 pt-1">
                              {bin.hasContamination && (
                                <span className="bg-amber-500/10 text-amber-400 border border-amber-500/20 text-[11px] px-2 py-0.5 rounded-md flex items-center gap-1 font-medium">
                                  <AlertTriangle className="h-3 w-3" /> Dry Contaminated
                                </span>
                              )}
                              {bin.hasLiquidLeak && (
                                <span className="bg-rose-500/10 text-rose-400 border border-rose-500/20 text-[11px] px-2 py-0.5 rounded-md flex items-center gap-1 font-medium">
                                  <Droplets className="h-3 w-3" /> Bottom Sump Leak
                                </span>
                              )}
                            </div>
                          )}
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-6">
                    <div className={`${cardBgClass} border rounded-2xl p-5 space-y-4`}>
                      <h3 className="text-base font-bold flex items-center justify-between border-b border-slate-800 pb-3">
                        <span className="flex items-center gap-2"><Activity className="h-4 w-4 text-emerald-400" /> Node Inspector</span>
                        <span className="font-mono text-xs text-emerald-400">{selectedBin.id}</span>
                      </h3>

                      <div className="space-y-3 text-xs">
                        <div className="flex justify-between py-1 border-b border-slate-800/60">
                          <span className="text-slate-400">Node Name:</span>
                          <span className="font-medium">{selectedBin.name}</span>
                        </div>
                        <div className="flex justify-between py-1 border-b border-slate-800/60">
                          <span className="text-slate-400">Category:</span>
                          <span className="font-mono">{selectedBin.type}</span>
                        </div>
                        <div className="flex justify-between py-1 border-b border-slate-800/60">
                          <span className="text-slate-400">Predictive Capacity:</span>
                          <span className="text-amber-400 font-medium">Full in ~{selectedBin.predictedFullHours} hrs</span>
                        </div>
                        <div className="flex justify-between py-1 border-b border-slate-800/60">
                          <span className="text-slate-400">Telemetry Heartbeat:</span>
                          <span className="text-emerald-400 font-mono">{selectedBin.lastUpdated}</span>
                        </div>
                      </div>

                      <div className="pt-2 grid grid-cols-2 gap-2">
                        <button
                          onClick={() => handleSimulateDisposal(selectedBin.id, true)}
                          className="w-full bg-emerald-500/10 hover:bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 text-xs py-2 rounded-xl font-medium transition-colors"
                        >
                          + Verified Disposal
                        </button>
                        <button
                          onClick={() => handleEmptyBin(selectedBin.id)}
                          className="w-full bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 text-xs py-2 rounded-xl font-medium transition-colors"
                        >
                          Reset / Empty Bin
                        </button>
                      </div>
                    </div>

                    <div className={`${cardBgClass} border rounded-2xl p-5 space-y-4`}>
                      <h3 className="text-base font-bold flex items-center gap-2 border-b border-slate-800 pb-3">
                        <ShieldAlert className="h-4 w-4 text-amber-400" /> Real-time System Audit Feed
                      </h3>

                      {events.length === 0 ? (
                        <div className="text-center py-8 text-slate-500 space-y-2">
                          <Info className="h-8 w-8 mx-auto text-slate-600" />
                          <p className="text-xs">No active alerts or events in the system queue.</p>
                        </div>
                      ) : (
                        <div className="space-y-3 max-h-80 overflow-y-auto pr-1">
                          {events.map((evt) => (
                            <div key={evt.id} className={`${subCardBgClass} p-3 rounded-xl border text-xs space-y-1`}>
                              <div className="flex items-center justify-between text-[11px]">
                                <span className="font-mono text-emerald-400 font-bold">{evt.binId}</span>
                                <span className="text-slate-500 font-mono">{evt.timestamp}</span>
                              </div>
                              <p className="text-slate-300">{evt.message}</p>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================= */}
            {/* TAB: HARDWARE TELEMETRY SIMULATOR (ADMIN ROLE) */}
            {/* ========================================================= */}
            {activeTab === 'simulator' && (activeRole === 'admin' || activeRole === 'guest') && (
              <div className="max-w-4xl mx-auto space-y-6">
                <div className={`${cardBgClass} border rounded-2xl p-6 space-y-6`}>
                  <div>
                    <h2 className="text-xl font-bold flex items-center gap-2">
                      <Sliders className="h-5 w-5 text-emerald-400" /> Hardware Telemetry Simulator
                    </h2>
                    <p className="text-xs text-slate-400 mt-1">
                      Inject virtual sensor events to test how the EcoSynapse software platform responds before physical ESP32 hardware is connected.
                    </p>
                  </div>

                  <div className="space-y-2">
                    <label className="text-xs font-semibold uppercase tracking-wider text-slate-400">Select Target Bin Node</label>
                    <select
                      value={selectedBinId}
                      onChange={(e) => setSelectedBinId(e.target.value)}
                      className={`w-full ${subCardBgClass} border text-sm rounded-xl p-3 focus:outline-none focus:border-emerald-500`}
                    >
                      {bins.map((b) => (
                        <option key={b.id} value={b.id}>
                          {b.id} — {b.name} (Overall Fill: {b.overallFill}%)
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* COMPUTER VISION SNAPSHOT INSPECTOR */}
                  <div className={`${subCardBgClass} border rounded-2xl p-4 space-y-3`}>
                    <h4 className="text-xs font-bold text-sky-400 flex items-center justify-between">
                      <span className="flex items-center gap-2"><Camera className="h-4 w-4" /> ESP32-CAM AI Snapshot Preview ({selectedBin.id})</span>
                      <span className="font-mono text-[10px] text-slate-500">Live Intake Inspection</span>
                    </h4>
                    
                    <div className="relative bg-slate-950 h-36 rounded-xl border border-slate-800 flex items-center justify-center overflow-hidden">
                      {/* Bounding Box Visual Overlays */}
                      <div className="absolute inset-4 border-2 border-emerald-500/60 rounded-lg flex items-start justify-end p-2 bg-emerald-500/5 animate-pulse">
                        <span className="bg-emerald-500 text-slate-950 font-mono text-[10px] font-bold px-2 py-0.5 rounded">
                          Plastic Packaging (94% Conf)
                        </span>
                      </div>
                      <div className="text-center text-slate-500 text-xs space-y-1 z-10">
                        <Scan className="h-8 w-8 mx-auto text-emerald-400 opacity-60" />
                        <p className="font-mono text-[11px] text-slate-300">ESP32-CAM Snapshot Feed Active</p>
                      </div>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-2">
                    <div className={`${subCardBgClass} p-4 rounded-xl border space-y-3`}>
                      <h4 className="text-sm font-semibold text-emerald-400 flex items-center gap-2">
                        <CheckCircle2 className="h-4 w-4" /> 1. Simulate Verified Disposal
                      </h4>
                      <p className="text-xs text-slate-400">
                        Triggers top intake camera + moisture sensors verifying clean dry waste. Speaks audio voice prompt.
                      </p>
                      <button
                        onClick={() => handleSimulateDisposal(selectedBinId, true)}
                        className="w-full bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-semibold text-xs py-2.5 rounded-lg transition-colors"
                      >
                        Trigger Verified Dry Disposal (+10 Pts)
                      </button>
                    </div>

                    <div className={`${subCardBgClass} p-4 rounded-xl border space-y-3`}>
                      <h4 className="text-sm font-semibold text-amber-400 flex items-center gap-2">
                        <AlertTriangle className="h-4 w-4" /> 2. Simulate Contamination
                      </h4>
                      <p className="text-xs text-slate-400">
                        Simulates wet waste thrown into dry compartment, triggering a sidewall humidity alert & warning voice prompt.
                      </p>
                      <button
                        onClick={() => handleSimulateDisposal(selectedBinId, false)}
                        className="w-full bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 border border-amber-500/30 text-xs py-2.5 rounded-lg font-semibold transition-colors"
                      >
                        Trigger Contamination Warning
                      </button>
                    </div>

                    <div className={`${subCardBgClass} p-4 rounded-xl border space-y-3`}>
                      <h4 className="text-sm font-semibold text-rose-400 flex items-center gap-2">
                        <Zap className="h-4 w-4" /> 3. Trigger Rapid Overfill (96%)
                      </h4>
                      <p className="text-xs text-slate-400">
                        Spikes bin fill levels to 96% to test collector priority alert dispatching.
                      </p>
                      <button
                        onClick={() => {
                          setBins((prev) =>
                            prev.map((b) =>
                              b.id === selectedBinId
                                ? { ...b, dryFill: 96, wetFill: 96, overallFill: 96, predictedFullHours: 0.2 }
                                : b
                            )
                          );
                          addEvent(selectedBinId, 'OVERFILL_WARNING', `Bin ${selectedBinId} capacity spiked to 96%.`, 'critical');
                        }}
                        className="w-full bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/30 text-xs py-2.5 rounded-lg font-semibold transition-colors"
                      >
                        Set Fill Capacity to 96%
                      </button>
                    </div>

                    <div className={`${subCardBgClass} p-4 rounded-xl border space-y-3`}>
                      <h4 className="text-sm font-semibold text-sky-400 flex items-center gap-2">
                        <Radio className="h-4 w-4" /> 4. Toggle Node Connection State
                      </h4>
                      <p className="text-xs text-slate-400">
                        Disconnects/reconnects virtual ESP32 Node Wi-Fi heartbeats.
                      </p>
                      <button
                        onClick={() => handleToggleOnline(selectedBinId)}
                        className="w-full bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs py-2.5 rounded-lg font-semibold transition-colors"
                      >
                        Toggle Node Online/Offline State
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* ========================================================= */}
            {/* TAB: COLLECTOR APP (COLLECTOR ROLE) */}
            {/* ========================================================= */}
            {activeTab === 'collector' && (activeRole === 'collector' || activeRole === 'guest') && (
              <div className="max-w-3xl mx-auto space-y-6">
                
                {/* LIVE COLLECTOR URGENT DISPATCH NOTIFICATION BANNER */}
                {bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length > 0 && (
                  <div className="bg-gradient-to-r from-rose-500/15 via-amber-500/15 to-rose-500/15 border border-rose-500/30 p-5 rounded-3xl space-y-3 shadow-xl animate-fade-in-down">
                    <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                      <div className="flex items-center gap-2 text-rose-400 font-extrabold text-xs uppercase tracking-wider">
                        <ShieldAlert className="h-5 w-5 text-rose-400 animate-bounce flex-shrink-0" />
                        <span>🚨 URGENT COLLECTOR DISPATCH ALERT: {bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length} BINS FULL / CRITICAL!</span>
                      </div>
                      <button
                        onClick={() => {
                          const fullBinDetails = bins
                            .filter((b) => b.overallFill >= 80)
                            .map((b) => `${b.name} at ${b.location} is ${b.overallFill} percent full`)
                            .join('. ');
                          triggerVoiceAlert(`Sanitation Dispatch Alert: ${fullBinDetails || 'Priority smart bins require collection.'}`);
                          showToast('🔊 Audio voice alert announced for Sanitation Drivers.');
                        }}
                        className="bg-rose-500 hover:bg-rose-600 text-slate-950 text-xs font-extrabold px-3.5 py-1.5 rounded-xl transition-all flex items-center gap-1.5 shadow-md hover:scale-105"
                      >
                        <Volume2 className="h-4 w-4" /> Play Voice Alert
                      </button>
                    </div>

                    <p className="text-xs text-slate-300">
                      The following flat smart bins have reached critical fill levels (80% or higher) or logged sensor faults. Please prioritize pickup for these nodes:
                    </p>

                    <div className="space-y-2">
                      {bins
                        .filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak)
                        .map((bin) => (
                          <div key={bin.id} className="bg-slate-950/80 border border-rose-500/30 p-3 rounded-2xl text-xs flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 shadow-inner">
                            <div>
                              <div className="flex items-center gap-2">
                                <span className="font-extrabold text-white text-sm">{bin.name} ({bin.id})</span>
                                <span className="bg-rose-500/20 text-rose-400 font-mono text-[10px] px-2 py-0.5 rounded font-bold border border-rose-500/30 animate-pulse">
                                  🔴 URGENT PICKUP
                                </span>
                              </div>
                              <p className="text-slate-400 text-[11px] flex items-center gap-1 mt-0.5">
                                <Navigation className="h-3 w-3 text-sky-400" /> {bin.location}
                                {bin.hasContamination && <span className="text-amber-400 font-semibold">• ⚠️ Dry Waste Contaminated</span>}
                                {bin.hasLiquidLeak && <span className="text-rose-400 font-semibold">• 🚨 Sump Leak</span>}
                              </p>
                            </div>
                            <div className="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end border-t sm:border-t-0 border-slate-800 pt-2 sm:pt-0">
                              <span className="font-mono font-extrabold text-rose-400 text-sm bg-rose-500/10 px-2.5 py-1 rounded-lg border border-rose-500/20">
                                {bin.overallFill}% Full
                              </span>
                              <button
                                onClick={() => handleEmptyBin(bin.id)}
                                className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 text-xs font-bold px-3.5 py-1.5 rounded-xl shadow transition-all hover:scale-105"
                              >
                                Mark Emptied
                              </button>
                            </div>
                          </div>
                        ))}
                    </div>
                  </div>
                )}

                <div className={`${cardBgClass} border rounded-2xl p-6 space-y-6 shadow-xl`}>
                  <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-slate-800 pb-4">
                    <div>
                      <h2 className="text-xl font-bold flex items-center gap-2">
                        <Truck className="h-5 w-5 text-emerald-400" /> EcoSynapse Collector Dispatch
                      </h2>
                      <p className="text-xs text-slate-400 mt-0.5">Automated collection route ordered by bin fill urgency</p>
                    </div>
                    
                    <div className="flex items-center gap-2 bg-slate-950 p-1 rounded-xl border border-slate-800 text-xs">
                      <button
                        type="button"
                        onClick={() => setCollectorFilter('all')}
                        className={`px-3 py-1.5 rounded-lg font-semibold transition-all ${
                          collectorFilter === 'all' ? 'bg-slate-800 text-white shadow' : 'text-slate-400'
                        }`}
                      >
                        All Bins ({bins.length})
                      </button>
                      <button
                        type="button"
                        onClick={() => setCollectorFilter('urgent')}
                        className={`px-3 py-1.5 rounded-lg font-semibold transition-all ${
                          collectorFilter === 'urgent' ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30' : 'text-slate-400'
                        }`}
                      >
                        🚨 Urgent ({bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length})
                      </button>
                    </div>
                  </div>

                  <div className="space-y-4">
                    {bins
                      .slice()
                      .filter((b) => (collectorFilter === 'urgent' ? b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak : true))
                      .sort((a, b) => b.overallFill - a.overallFill)
                      .map((bin, index) => (
                        <div
                          key={bin.id}
                          className={`${subCardBgClass} border rounded-2xl p-5 space-y-3 transition-all hover:border-emerald-500/40`}
                        >
                          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                            <div className="flex items-center gap-3">
                              <div className={`h-8 w-8 rounded-full font-mono font-bold flex items-center justify-center text-xs ${
                                bin.overallFill >= 80 ? 'bg-rose-500 text-white shadow-md shadow-rose-500/20' : 'bg-slate-800 text-emerald-400'
                              }`}>
                                #{index + 1}
                              </div>
                              <div>
                                <div className="flex items-center gap-2">
                                  <h4 className="text-sm font-bold">{bin.name}</h4>
                                  <span className="font-mono text-xs text-slate-500">({bin.id})</span>
                                  {bin.overallFill >= 80 && (
                                    <span className="bg-rose-500/10 text-rose-400 border border-rose-500/20 text-[10px] px-2 py-0.5 rounded font-extrabold font-mono">
                                      FULL (DISPATCH REQUIRED)
                                    </span>
                                  )}
                                </div>
                                <p className="text-xs text-slate-400 flex items-center gap-1 mt-0.5">
                                  <Navigation className="h-3 w-3 text-sky-400" /> {bin.location} • Types: <span className="font-mono text-slate-300">{bin.type}</span>
                                </p>
                              </div>
                            </div>

                            <div className="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end border-t sm:border-t-0 border-slate-800/60 pt-2 sm:pt-0">
                              <span
                                className={`text-xs px-3 py-1 rounded-full font-extrabold font-mono border ${
                                  bin.overallFill >= 85
                                    ? 'bg-rose-500/10 text-rose-400 border-rose-500/30 animate-pulse'
                                    : bin.overallFill >= 60
                                    ? 'bg-amber-500/10 text-amber-400 border-amber-500/30'
                                    : 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30'
                                }`}
                              >
                                {bin.overallFill}% Full
                              </span>

                              <button
                                onClick={() => handleEmptyBin(bin.id)}
                                className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 text-xs font-extrabold px-4 py-2 rounded-xl transition-all hover:scale-105 shadow-md shadow-emerald-500/10"
                              >
                                Mark Emptied
                              </button>
                            </div>
                          </div>

                          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 text-xs pt-1">
                            <div className="bg-slate-950 p-2 rounded-xl border border-slate-800">
                              <p className="text-[10px] text-slate-500">Dry Recyclables</p>
                              <p className="font-mono font-semibold text-sky-400 mt-0.5">{bin.dryFill}%</p>
                            </div>
                            <div className="bg-slate-950 p-2 rounded-xl border border-slate-800">
                              <p className="text-[10px] text-slate-500">Wet Organic</p>
                              <p className="font-mono font-semibold text-emerald-400 mt-0.5">{bin.wetFill}%</p>
                            </div>
                            <div className="bg-slate-950 p-2 rounded-xl border border-slate-800">
                              <p className="text-[10px] text-slate-500">Weight Load</p>
                              <p className="font-mono font-semibold mt-0.5">{bin.weight} kg</p>
                            </div>
                            <div className="bg-slate-950 p-2 rounded-xl border border-slate-800">
                              <p className="text-[10px] text-slate-500">Predictive Full</p>
                              <p className="font-mono font-semibold text-amber-400 mt-0.5">~{bin.predictedFullHours} hrs</p>
                            </div>
                          </div>
                        </div>
                      ))}
                  </div>
                </div>
              </div>
            )}
          </>
        )}

      </main>

      {/* FLOATING AI CHATBOT WIDGET BUTTON ("EcoBot AI") */}
      <button
        onClick={() => setShowChatbotModal(true)}
        className="fixed bottom-6 left-6 z-40 bg-gradient-to-r from-emerald-500 to-teal-400 text-slate-950 font-bold px-4 py-3 rounded-full shadow-2xl hover:scale-105 transition-all flex items-center gap-2"
        title="Open EcoBot AI Assistant"
      >
        <Bot className="h-5 w-5 stroke-[2.5]" />
        <span className="text-xs font-extrabold tracking-wide">EcoBot AI</span>
      </button>

      {/* FLOATING AI CHATBOT MODAL */}
      {showChatbotModal && (
        <div className="fixed bottom-20 left-6 z-50 max-w-sm w-full bg-slate-900 border border-slate-800 rounded-3xl shadow-2xl overflow-hidden flex flex-col h-[460px] animate-in fade-in slide-in-from-bottom-5">
          <div className="bg-gradient-to-r from-emerald-500 to-teal-500 p-4 text-slate-950 flex items-center justify-between font-bold text-xs">
            <div className="flex items-center gap-2">
              <Bot className="h-5 w-5" />
              <span>EcoBot AI Project Assistant</span>
            </div>
            <button onClick={() => setShowChatbotModal(false)} className="text-slate-950 hover:opacity-80">
              <X className="h-5 w-5" />
            </button>
          </div>

          <div className="flex-1 p-4 overflow-y-auto space-y-3 text-xs bg-slate-950">
            {chatMessages.map((msg, idx) => (
              <div
                key={idx}
                className={`flex gap-2 ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}
              >
                {msg.sender === 'bot' && (
                  <div className="h-7 w-7 rounded-lg bg-emerald-500/20 text-emerald-400 flex items-center justify-center flex-shrink-0">
                    <Bot className="h-4 w-4" />
                  </div>
                )}
                <div
                  className={`p-3 rounded-2xl max-w-[85%] leading-relaxed whitespace-pre-wrap text-xs ${
                    msg.sender === 'user'
                      ? 'bg-emerald-500 text-slate-950 font-semibold rounded-br-none'
                      : 'bg-slate-900 border border-slate-800 text-slate-200 rounded-bl-none'
                  }`}
                >
                  {msg.text.split('\n').map((line, lIdx) => {
                    const parts = line.split(/(\*\*.*?\*\*)/g);
                    return (
                      <div key={lIdx} className={line.startsWith('•') || line.startsWith('1.') || line.startsWith('2.') ? 'pl-2 my-1 text-slate-200' : 'my-0.5'}>
                        {parts.map((part, pIdx) => {
                          if (part.startsWith('**') && part.endsWith('**')) {
                            return <strong key={pIdx} className="font-extrabold text-emerald-400">{part.slice(2, -2)}</strong>;
                          }
                          return part;
                        })}
                      </div>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>

          <form onSubmit={handleSendChatMessage} className="p-3 bg-slate-900 border-t border-slate-800 flex gap-2">
            <input
              type="text"
              value={chatInput}
              onChange={(e) => setChatInput(e.target.value)}
              placeholder="Ask EcoBot about telemetry, points..."
              className="flex-1 bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-xs text-white focus:outline-none focus:border-emerald-500"
            />
            <button
              type="submit"
              className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 p-2 rounded-xl font-bold transition-all"
            >
              <Send className="h-4 w-4" />
            </button>
          </form>
        </div>
      )}

      {/* PRINTABLE BIN QR CODE MODAL */}
      {showQrModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-sm w-full space-y-4 text-center shadow-2xl relative`}>
            <button onClick={() => setShowQrModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>
            
            <div className="space-y-1">
              <span className="text-[10px] uppercase font-mono tracking-wider text-emerald-400 bg-emerald-500/10 px-2.5 py-0.5 rounded-full border border-emerald-500/20">
                Official Bin Node Label
              </span>
              <h3 className="text-lg font-bold">Greenwood Block B (BIN-102)</h3>
              <p className="text-xs text-slate-400">Scan with EcoSynapse App to Unlock & Earn +10 Pts</p>
            </div>

            <div className="bg-white p-6 rounded-2xl border-4 border-slate-800 text-slate-950 space-y-3 mx-auto w-56 shadow-inner">
              <div className="flex items-center justify-center gap-1.5 font-black text-xs border-b pb-2 border-slate-200">
                <Activity className="h-4 w-4 text-emerald-600" /> ECOSYNAPSE
              </div>
              <QrCode className="h-32 w-32 mx-auto text-slate-900" />
              <div className="font-mono font-extrabold text-[11px] bg-slate-100 py-1 rounded border">
                NODE ID: BIN-102
              </div>
            </div>

            <button
              onClick={() => {
                if (typeof window !== 'undefined') window.print();
                showToast('Sent Bin QR Label to printer');
              }}
              className="w-full bg-emerald-500 hover:bg-emerald-600 text-slate-950 font-bold text-xs py-3 rounded-xl transition-all flex items-center justify-center gap-2"
            >
              <Printer className="h-4 w-4" /> Print / Download Bin QR Label
            </button>
          </div>
        </div>
      )}

      {/* Thank You Modal */}
      {showThankYouModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-sm w-full space-y-4 text-center shadow-2xl relative animate-in fade-in zoom-in-95`}>
            <div className="h-14 w-14 bg-emerald-500/20 text-emerald-400 rounded-full mx-auto flex items-center justify-center">
              <CheckCircle className="h-8 w-8" />
            </div>
            <h3 className="text-lg font-bold">{thankYouDetails.title}</h3>
            <p className="text-xs text-slate-400">{thankYouDetails.desc}</p>
            <button
              onClick={() => setShowThankYouModal(false)}
              className="w-full bg-emerald-500 text-slate-950 font-bold text-xs py-2.5 rounded-xl"
            >
              Close & Done
            </button>
          </div>
        </div>
      )}

      {/* WAITLIST MODAL (USER ROLE ONLY) */}
      {showWaitlistModal && (activeRole === 'user' || activeRole === 'guest') && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-sm w-full space-y-4 shadow-2xl relative`}>
            <button onClick={() => setShowWaitlistModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>
            <h3 className="text-base font-bold flex items-center gap-2">
              <Send className="h-5 w-5 text-emerald-400" /> Join EcoSynapse Waitlist
            </h3>
            <p className="text-xs text-slate-400">
              Want EcoSynapse smart bins installed in your apartment complex or tech park? Enter your email to request a pilot deployment.
            </p>
            <form onSubmit={(e) => {
              e.preventDefault();
              setShowWaitlistModal(false);
              setThankYouDetails({
                title: 'Joined EcoSynapse Deployment Waitlist!',
                desc: `We have received your deployment request for ${waitlistEmail || 'your apartment'}. Our hardware team will contact you shortly!`,
              });
              setShowThankYouModal(true);
            }} className="space-y-3">
              <input
                type="email"
                value={waitlistEmail}
                onChange={(e) => setWaitlistEmail(e.target.value)}
                placeholder="enter@apartment.com"
                required
                className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500"
              />
              <button type="submit" className="w-full bg-emerald-500 text-slate-950 font-bold text-xs py-2.5 rounded-xl">
                Submit Deployment Request
              </button>
            </form>
          </div>
        </div>
      )}

      {/* ABOUT MODAL (USER ROLE ONLY) */}
      {showAboutModal && (activeRole === 'user' || activeRole === 'guest') && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-md w-full space-y-4 shadow-2xl relative`}>
            <button onClick={() => setShowAboutModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>
            <h3 className="text-lg font-bold flex items-center gap-2">
              <Info className="h-5 w-5 text-emerald-400" /> About EcoSynapse
            </h3>
            <p className="text-xs text-slate-300 leading-relaxed">
              EcoSynapse is an intelligent waste-management platform connecting physical smart bins, multi-sensor telemetry, collection staff, and residents.
            </p>
            <p className="text-xs text-slate-400 leading-relaxed">
              Using a sensor-fusion approach (Camera + Moisture + Load Cell) and predictive fill algorithms, EcoSynapse eliminates bin overflows while rewarding users with EcoPoints.
            </p>
            <button onClick={() => setShowAboutModal(false)} className="w-full bg-slate-800 text-white font-bold text-xs py-2.5 rounded-xl">
              Close
            </button>
          </div>
        </div>
      )}

      {/* Contact Modal */}
      {showContactModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-sm w-full space-y-4 shadow-2xl relative`}>
            <button onClick={() => setShowContactModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>
            <h3 className="text-base font-bold flex items-center gap-2">
              <Mail className="h-5 w-5 text-emerald-400" /> Support & Maintenance Contact
            </h3>
            <p className="text-xs text-slate-400">Report a bin malfunction, damaged sensor, or reach the facility manager.</p>
            <form onSubmit={(e) => {
              e.preventDefault();
              setShowContactModal(false);
              showToast('Ticket submitted to EcoSynapse Maintenance Support!');
            }} className="space-y-3">
              <input type="text" placeholder="Bin ID or Location" required className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2 text-xs text-white" />
              <textarea placeholder="Describe issue (e.g. Lid stuck, low battery)" required className="w-full bg-slate-950 border border-slate-800 rounded-xl px-3.5 py-2 text-xs text-white h-20" />
              <button type="submit" className="w-full bg-emerald-500 text-slate-950 font-bold text-xs py-2.5 rounded-xl">
                Submit Support Ticket
              </button>
            </form>
          </div>
        </div>
      )}

      {/* Back To Top Button */}
      {showBackToTop && (
        <button
          onClick={() => {
            if (typeof window !== 'undefined') window.scrollTo({ top: 0, behavior: 'smooth' });
          }}
          className="fixed bottom-6 right-24 z-40 h-12 w-12 rounded-full bg-emerald-500 text-slate-950 flex items-center justify-center shadow-2xl hover:scale-110 transition-all font-bold"
          title="Back to Top"
        >
          <ChevronUp className="h-6 w-6" />
        </button>
      )}

      {/* Persistent Cookie Banner */}
      {showCookieBanner && (
        <div className="fixed bottom-0 inset-x-0 z-50 bg-slate-900/95 border-t border-slate-800 p-4 backdrop-blur-md flex flex-col sm:flex-row items-center justify-between gap-4 text-xs">
          <div className="flex items-center gap-3">
            <Cookie className="h-6 w-6 text-amber-400 flex-shrink-0" />
            <p className="text-slate-300">
              EcoSynapse uses cookies & telemetry storage to optimize bin dispatching, EcoPoints rewards, and user sessions.
            </p>
          </div>
          <div className="flex items-center gap-2 w-full sm:w-auto">
            <button
              onClick={() => setShowCookieModal(true)}
              className="bg-slate-800 text-slate-300 hover:text-white px-3 py-1.5 rounded-lg text-xs font-medium"
            >
              Preferences
            </button>
            <button
              onClick={() => {
                if (typeof window !== 'undefined') {
                  localStorage.setItem('ecosynapse_cookie_consent', 'accepted');
                }
                setShowCookieBanner(false);
                showToast('Cookie preferences accepted and saved!');
              }}
              className="bg-emerald-500 text-slate-950 px-4 py-1.5 rounded-lg text-xs font-bold hover:bg-emerald-600 transition-colors"
            >
              Accept All
            </button>
          </div>
        </div>
      )}

      {/* Cookie Preferences Modal */}
      {showCookieModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-sm w-full space-y-4 shadow-2xl relative`}>
            <button onClick={() => setShowCookieModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>
            <h3 className="text-base font-bold flex items-center gap-2">
              <Cookie className="h-5 w-5 text-amber-400" /> Cookie & Telemetry Preferences
            </h3>
            <p className="text-xs text-slate-400">Manage how EcoSynapse stores your telemetry session data.</p>
            
            <div className="space-y-3 pt-1">
              <div className="flex items-center justify-between p-3 rounded-xl bg-slate-950 border border-slate-800 text-xs">
                <div>
                  <p className="font-bold">Essential Hardware Telemetry</p>
                  <p className="text-[10px] text-slate-500">Required for bin status updates</p>
                </div>
                <span className="text-[10px] bg-slate-800 text-slate-400 px-2 py-0.5 rounded font-mono">Always On</span>
              </div>

              <div className="flex items-center justify-between p-3 rounded-xl bg-slate-950 border border-slate-800 text-xs">
                <div>
                  <p className="font-bold">EcoPoints & Leaderboard Sync</p>
                  <p className="text-[10px] text-slate-500">Syncs your EcoPoints across sessions</p>
                </div>
                <input
                  type="checkbox"
                  checked={cookiePreferences.leaderboard}
                  onChange={(e) => setCookiePreferences((prev) => ({ ...prev, leaderboard: e.target.checked }))}
                  className="h-4 w-4 accent-emerald-500 rounded cursor-pointer"
                />
              </div>

              <div className="flex items-center justify-between p-3 rounded-xl bg-slate-950 border border-slate-800 text-xs">
                <div>
                  <p className="font-bold">Environmental Impact Analytics</p>
                  <p className="text-[10px] text-slate-500">Tracks CO2 savings statistics</p>
                </div>
                <input
                  type="checkbox"
                  checked={cookiePreferences.analytics}
                  onChange={(e) => setCookiePreferences((prev) => ({ ...prev, analytics: e.target.checked }))}
                  className="h-4 w-4 accent-emerald-500 rounded cursor-pointer"
                />
              </div>
            </div>

            <button
              onClick={() => {
                if (typeof window !== 'undefined') {
                  localStorage.setItem('ecosynapse_cookie_consent', JSON.stringify(cookiePreferences));
                }
                setShowCookieModal(false);
                setShowCookieBanner(false);
                showToast('Custom cookie preferences saved!');
              }}
              className="w-full bg-emerald-500 text-slate-950 font-bold text-xs py-2.5 rounded-xl hover:bg-emerald-600 transition-colors"
            >
              Save Cookie Preferences
            </button>
          </div>
        </div>
      )}

      {/* Keyboard Shortcuts Modal */}
      {showShortcutsModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-slate-900 border border-slate-800 rounded-3xl p-6 max-w-sm w-full space-y-4 shadow-2xl relative">
            <button onClick={() => setShowShortcutsModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>
            <h3 className="text-base font-bold flex items-center gap-2">
              <Keyboard className="h-5 w-5 text-emerald-400" /> Keyboard Shortcuts
            </h3>
            <div className="space-y-2 text-xs font-mono">
              <div className="flex justify-between p-2 rounded bg-slate-950 border border-slate-800">
                <span className="text-slate-400">Shift + ?</span>
                <span className="text-emerald-400">Toggle Shortcuts Modal</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* COLLECTOR NOTIFICATIONS DISPATCH MODAL */}
      {showNotificationsModal && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className={`${cardBgClass} border rounded-3xl p-6 max-w-md w-full space-y-4 shadow-2xl relative animate-in fade-in zoom-in-95`}>
            <button onClick={() => setShowNotificationsModal(false)} className="absolute top-4 right-4 text-slate-400 hover:text-white">
              <X className="h-5 w-5" />
            </button>

            <div className="flex items-center gap-3 border-b border-slate-800 pb-3">
              <div className="h-10 w-10 rounded-xl bg-rose-500/20 text-rose-400 flex items-center justify-center font-bold">
                <BellRing className="h-5 w-5 animate-pulse" />
              </div>
              <div>
                <h3 className="text-base font-bold">Collector Dispatch Notifications</h3>
                <p className="text-xs text-slate-400">Live full bin notifications & sanitation alerts</p>
              </div>
            </div>

            {bins.filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak).length === 0 ? (
              <div className="text-center py-8 space-y-2 text-slate-400">
                <CheckCircle2 className="h-10 w-10 text-emerald-400 mx-auto" />
                <p className="text-xs font-bold text-slate-200">All Smart Bins Clear!</p>
                <p className="text-[11px]">No bins currently exceed 80% capacity or require emergency dispatch.</p>
              </div>
            ) : (
              <div className="space-y-3 max-h-80 overflow-y-auto pr-1">
                {bins
                  .filter((b) => b.overallFill >= 80 || b.hasContamination || b.hasLiquidLeak)
                  .map((bin) => (
                    <div key={bin.id} className={`${subCardBgClass} border border-rose-500/30 p-3.5 rounded-2xl text-xs space-y-2`}>
                      <div className="flex items-center justify-between font-bold">
                        <span className="text-white flex items-center gap-1.5">
                          <Trash2 className="h-3.5 w-3.5 text-rose-400" /> {bin.name}
                        </span>
                        <span className="font-mono text-rose-400 font-extrabold bg-rose-500/10 px-2 py-0.5 rounded border border-rose-500/20">
                          {bin.overallFill}% FULL
                        </span>
                      </div>
                      <p className="text-[11px] text-slate-400 flex items-center gap-1">
                        <MapPin className="h-3 w-3 text-sky-400" /> {bin.location} ({bin.id})
                      </p>
                      {bin.hasContamination && (
                        <p className="text-[10px] text-amber-400 font-semibold flex items-center gap-1">
                          <AlertTriangle className="h-3 w-3" /> Contamination: Wet waste detected in Dry compartment
                        </p>
                      )}
                      {bin.hasLiquidLeak && (
                        <p className="text-[10px] text-rose-400 font-semibold flex items-center gap-1">
                          <Droplets className="h-3 w-3" /> Liquid Leak: Sump sensor triggered
                        </p>
                      )}

                      <div className="flex items-center justify-between pt-1 border-t border-slate-800">
                        <button
                          onClick={() => {
                            triggerVoiceAlert(`Alert: ${bin.name} at ${bin.location} is ${bin.overallFill} percent full.`);
                            showToast(`Voice alert sent for ${bin.id}`);
                          }}
                          className="text-slate-400 hover:text-white text-[11px] flex items-center gap-1 font-medium"
                        >
                          <Volume2 className="h-3.5 w-3.5 text-sky-400" /> Announce Voice
                        </button>
                        {(activeRole === 'collector' || activeRole === 'admin') ? (
                          <button
                            onClick={() => {
                              handleEmptyBin(bin.id);
                              showToast(`Bin ${bin.id} marked as emptied by Collector!`);
                            }}
                            className="bg-emerald-500 hover:bg-emerald-600 text-slate-950 text-[11px] font-bold px-3 py-1.5 rounded-xl shadow transition-all"
                          >
                            Mark Emptied
                          </button>
                        ) : (
                          <span className="text-[10px] font-mono text-rose-400 bg-rose-500/10 px-2 py-0.5 rounded border border-rose-500/20 font-bold">
                            Dispatch Scheduled
                          </span>
                        )}
                      </div>
                    </div>
                  ))}
              </div>
            )}

            {(activeRole === 'collector' || activeRole === 'admin') && (
              <button
                onClick={() => {
                  setActiveRole('collector');
                  setActiveTab('collector');
                  setShowNotificationsModal(false);
                }}
                className="w-full bg-slate-800 hover:bg-slate-700 text-slate-200 font-bold text-xs py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2"
              >
                <Truck className="h-4 w-4 text-emerald-400" /> Open Full Collector Dispatch View
              </button>
            )}
          </div>
        </div>
      )}

    </div>
  );
}
