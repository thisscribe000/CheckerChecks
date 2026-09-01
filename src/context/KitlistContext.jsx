import React, { createContext, useContext, useState } from 'react';

const KitlistContext = createContext(null);

const initialGigs = [
  {
    id: 'gig-1',
    name: 'Wedding Shoot',
    date: 'Saturday, Oct 12',
    time: '2:00 PM',
    location: 'Grand Ballroom, Hilton',
    status: 'IN PREP',
    type: 'Photography',
    size: 'Medium',
    items: {
      'CAMERA': [
        { id: 'item-1', name: 'Sony A7S III', detail: 'SN: SONY-A7S-001', icon: 'photo_camera', packed: true },
        { id: 'item-2', name: '35mm f/1.4 GM', detail: 'E-Mount • Prime', icon: 'camera_lens', packed: true },
        { id: 'item-3', name: '85mm f/1.8 GM', detail: 'E-Mount • Prime', icon: 'camera_lens', packed: false, missingAlert: true },
        { id: 'item-4', name: 'Canon R5 (Backup)', detail: 'SN: CANON-R5-002', icon: 'photo_camera', packed: true }
      ],
      'AUDIO': [
        { id: 'item-5', name: 'DJI Mic 2', detail: '2x Tx, 1x Rx', icon: 'mic', packed: true },
        { id: 'item-6', name: 'XLR Cables', detail: '2x 10ft, 1x 25ft', icon: 'cable', packed: true }
      ],
      'POWER': [
        { id: 'item-7', name: 'V-Mount Battery', detail: '98Wh', icon: 'battery_charging_full', packed: true },
        { id: 'item-8', name: 'NP-FZ100 (x4)', detail: 'Rechargeable Li-Ion', icon: 'battery_3_bar', packed: false, missingAlert: true }
      ],
      'LIGHTING': [
        { id: 'item-9', name: 'Aputure 60x COB', detail: 'Bi-Color Compact', icon: 'light', packed: true },
        { id: 'item-10', name: 'Dome Softbox', detail: '35-inch Quick Setup', icon: 'filter_drama', packed: true }
      ]
    }
  },
  {
    id: 'gig-2',
    name: 'Podcast Recording',
    date: 'Monday, Oct 14',
    time: '10:00 AM',
    location: 'Studio 42',
    status: 'IN PREP',
    type: 'Audio',
    size: 'Small',
    items: {
      'AUDIO': [
        { id: 'item-11', name: 'Shure SM7B (x2)', detail: 'Dynamic Vocal Mic', icon: 'mic', packed: true },
        { id: 'item-12', name: 'Rodecaster Pro II', detail: 'Integrated Audio Lab', icon: 'graphic_eq', packed: true },
        { id: 'item-13', name: 'Boom Arms (x2)', detail: 'Desktop Mount', icon: 'construction', packed: false }
      ],
      'POWER': [
        { id: 'item-14', name: 'Power Strip & Extension', detail: '25ft Heavy Duty', icon: 'power', packed: true }
      ]
    }
  },
  {
    id: 'gig-3',
    name: 'Church Livestream',
    date: 'Sunday, Oct 20',
    time: '8:00 AM',
    location: 'Main Sanctuary',
    status: 'NOT STARTED',
    type: 'Livestream',
    size: 'Large',
    items: {
      'CAMERA': [
        { id: 'item-15', name: 'Sony PTZ Camera 1', detail: '4K Optical Zoom', icon: 'videocam', packed: false },
        { id: 'item-16', name: 'Sony PTZ Camera 2', detail: '4K Optical Zoom', icon: 'videocam', packed: false }
      ],
      'SWITCHER': [
        { id: 'item-17', name: 'Blackmagic ATEM Mini Extreme', detail: '8-HDMI Live Switcher', icon: 'alt_route', packed: false }
      ]
    }
  }
];

const initialInventory = [
  { id: 'inv-1', name: 'Sony A7S III', category: 'CAMERAS', serial: 'SONY-A7S-001', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-2', name: 'Canon R5', category: 'CAMERAS', serial: 'CANON-R5-002', status: 'IN USE', img: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-3', name: '35mm f/1.4 GM', category: 'LENSES', serial: 'E-Mount • Prime', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-4', name: '85mm f/1.8 GM', category: 'LENSES', serial: 'E-Mount • Prime', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1617005082133-548c4dd27f35?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-5', name: 'DJI Mic 2 Set', category: 'AUDIO', serial: '2x Tx, 1x Rx', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-6', name: 'Shure SM7B Vocal Mic', category: 'AUDIO', serial: 'SHURE-SM7B-01', status: 'IN USE', img: 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-7', name: 'Aputure 60x Light', category: 'LIGHTING', serial: 'AP-60X-901', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1527011046414-4781f1f94f8c?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-8', name: 'V-Mount 98Wh Battery', category: 'POWER', serial: 'VM-98WH-03', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=150&auto=format&fit=crop&q=80' },
  { id: 'inv-9', name: 'Nanlite Pavotube 6C', category: 'LIGHTING', serial: 'NAN-PT6C-12', status: 'AVAILABLE', img: 'https://images.unsplash.com/photo-1527011046414-4781f1f94f8c?w=150&auto=format&fit=crop&q=80' }
];

export const KitlistProvider = ({ children }) => {
  const [activeTab, setActiveTab] = useState('home');
  const [activeGigId, setActiveGigId] = useState('gig-1');
  const [gigs, setGigs] = useState(initialGigs);
  const [inventory, setInventory] = useState(initialInventory);

  const activeGig = gigs.find(g => g.id === activeGigId) || gigs[0];

  const toggleItemPacked = (gigId, category, itemId) => {
    setGigs(prevGigs => prevGigs.map(gig => {
      if (gig.id !== gigId) return gig;
      const catItems = gig.items[category] || [];
      const updatedCatItems = catItems.map(item => {
        if (item.id === itemId) {
          return { ...item, packed: !item.packed, missingAlert: false };
        }
        return item;
      });
      return {
        ...gig,
        items: {
          ...gig.items,
          [category]: updatedCatItems
        }
      };
    }));
  };

  const createGig = (newGigData, suggestedItems) => {
    const newId = `gig-${Date.now()}`;
    
    // Default items grouped by category if not provided
    const items = suggestedItems || {
      'CAMERA': [
        { id: `item-${Date.now()}-1`, name: 'Sony A7S III', detail: 'SN: SONY-A7S-001', icon: 'photo_camera', packed: false },
        { id: `item-${Date.now()}-2`, name: '35mm f/1.4 GM', detail: 'E-Mount • Prime', icon: 'camera_lens', packed: false }
      ],
      'POWER': [
        { id: `item-${Date.now()}-3`, name: 'V-Mount Battery', detail: '98Wh', icon: 'battery_charging_full', packed: false }
      ]
    };

    const newGig = {
      id: newId,
      name: newGigData.name || 'New Production Gig',
      date: newGigData.date ? new Date(newGigData.date).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' }) : 'Upcoming',
      time: '9:00 AM',
      location: newGigData.location || 'Location TBD',
      status: 'IN PREP',
      type: newGigData.type || 'Photography',
      size: newGigData.size || 'Medium',
      items
    };

    setGigs(prev => [newGig, ...prev]);
    setActiveGigId(newId);
    setActiveTab('checklist');
  };

  const addInventoryItem = (newItem) => {
    const item = {
      id: `inv-${Date.now()}`,
      name: newItem.name,
      category: newItem.category.toUpperCase(),
      serial: newItem.serial || 'SN: ' + Math.random().toString(36).substring(7).toUpperCase(),
      status: 'AVAILABLE',
      img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=150&auto=format&fit=crop&q=80'
    };
    setInventory(prev => [item, ...prev]);
  };

  return (
    <KitlistContext.Provider value={{
      activeTab,
      setActiveTab,
      activeGigId,
      setActiveGigId,
      activeGig,
      gigs,
      inventory,
      toggleItemPacked,
      createGig,
      addInventoryItem
    }}>
      {children}
    </KitlistContext.Provider>
  );
};

export const useKitlist = () => {
  const context = useContext(KitlistContext);
  if (!context) {
    throw new Error('useKitlist must be used within a KitlistProvider');
  }
  return context;
};
