import React, { useState } from 'react';
import { useKitlist } from '../context/KitlistContext';
import { AddItemModal } from '../components/AddItemModal';

export const Inventory = () => {
  const { inventory } = useKitlist();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('ALL');
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  const categories = ['ALL', 'CAMERAS', 'LENSES', 'AUDIO', 'LIGHTING', 'POWER', 'ACCESSORIES'];

  const filteredInventory = inventory.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          item.serial.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'ALL' || item.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  // Group items by category
  const groupedInventory = filteredInventory.reduce((acc, item) => {
    const cat = item.category || 'OTHER';
    if (!acc[cat]) acc[cat] = [];
    acc[cat].push(item);
    return acc;
  }, {});

  return (
    <main className="max-w-7xl mx-auto px-margin-mobile md:px-margin-desktop pt-lg pb-[120px]">
      {/* Add Item Modal */}
      <AddItemModal isOpen={isAddModalOpen} onClose={() => setIsAddModalOpen(false)} />

      {/* Page Header & Search */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-md mb-lg">
        <div>
          <h1 className="font-display text-display text-primary mb-xs">Inventory</h1>
          <p className="font-body-md text-body-md text-on-surface-variant">Manage and track your gear library.</p>
        </div>

        <div className="relative w-full md:w-96">
          <span className="material-symbols-outlined absolute left-sm top-1/2 -translate-y-1/2 text-on-surface-variant">search</span>
          <input 
            type="text"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            placeholder="Search gear..." 
            className="w-full pl-xl pr-sm py-sm bg-surface-container-lowest border border-outline-variant rounded-DEFAULT font-body-md text-body-md text-on-surface placeholder:text-on-surface-variant focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors"
          />
        </div>
      </div>

      {/* Categories Filter (Horizontal Scroll) */}
      <div className="flex overflow-x-auto no-scrollbar gap-sm mb-lg pb-xs border-b border-outline-variant">
        {categories.map(cat => {
          const isSelected = selectedCategory === cat;
          return (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              className={`px-md py-xs rounded-full font-label-caps text-label-caps whitespace-nowrap transition-colors cursor-pointer ${
                isSelected
                  ? 'bg-primary text-on-primary font-bold'
                  : 'bg-surface-container-lowest text-on-surface border border-outline-variant hover:border-primary'
              }`}
            >
              {cat === 'ALL' ? 'All Gear' : cat.charAt(0) + cat.slice(1).toLowerCase()}
            </button>
          );
        })}
      </div>

      {/* Inventory List Grouped by Category */}
      {Object.keys(groupedInventory).length === 0 ? (
        <div className="bg-surface-container-lowest border border-outline-variant rounded-lg p-xl text-center">
          <span className="material-symbols-outlined text-[48px] text-on-surface-variant mb-sm">inventory_2</span>
          <h3 className="font-headline-md text-headline-md text-primary mb-xs">No Gear Found</h3>
          <p className="font-body-md text-body-md text-on-surface-variant mb-md">No equipment matched your search or category filter.</p>
          <button 
            onClick={() => setIsAddModalOpen(true)}
            className="px-md py-sm bg-primary text-on-primary rounded font-label-caps text-label-caps cursor-pointer"
          >
            ADD NEW EQUIPMENT
          </button>
        </div>
      ) : (
        <div className="bg-surface-container-lowest border border-outline-variant rounded-lg overflow-hidden flex flex-col shadow-xs">
          {Object.entries(groupedInventory).map(([cat, items]) => (
            <React.Fragment key={cat}>
              {/* Category Group Header */}
              <div className="bg-surface-container-low px-md py-sm border-b border-outline-variant flex justify-between items-center">
                <span className="font-label-caps text-label-caps text-on-surface-variant tracking-widest font-bold">
                  {cat}
                </span>
                <span className="font-mono-sm text-mono-sm text-on-surface-variant">
                  {items.length} item{items.length > 1 ? 's' : ''}
                </span>
              </div>

              {/* Items List */}
              {items.map(item => (
                <div 
                  key={item.id}
                  className="flex items-center justify-between p-md border-b border-outline-variant hover:bg-surface-container-low transition-colors group cursor-pointer"
                >
                  <div className="flex items-center gap-md">
                    <div className="w-12 h-12 bg-surface-variant border border-outline-variant rounded flex items-center justify-center overflow-hidden shrink-0">
                      <span className="material-symbols-outlined text-primary text-[24px]">
                        {cat === 'CAMERAS' ? 'photo_camera' : cat === 'LENSES' ? 'camera_lens' : cat === 'AUDIO' ? 'mic' : cat === 'LIGHTING' ? 'light' : 'inventory_2'}
                      </span>
                    </div>

                    <div>
                      <h3 className="font-body-md text-body-md font-semibold text-primary">{item.name}</h3>
                      <p className="font-mono-sm text-mono-sm text-on-surface-variant">{item.serial}</p>
                    </div>
                  </div>

                  <div className="flex items-center gap-sm">
                    <div className={`flex items-center gap-xs px-2.5 py-1 rounded-sm border ${
                      item.status === 'AVAILABLE' 
                        ? 'bg-surface border-outline-variant' 
                        : 'bg-surface-dim border-outline-variant'
                    }`}>
                      <span className={`w-1.5 h-1.5 rounded-full block ${
                        item.status === 'AVAILABLE' ? 'bg-primary' : 'bg-on-surface-variant'
                      }`}></span>
                      <span className="font-label-caps text-label-caps text-primary">
                        {item.status}
                      </span>
                    </div>

                    <button className="p-xs text-outline hover:text-primary transition-colors">
                      <span className="material-symbols-outlined">more_vert</span>
                    </button>
                  </div>
                </div>
              ))}
            </React.Fragment>
          ))}
        </div>
      )}

      {/* Floating Action Button (+ ADD ITEM) */}
      <div className="fixed bottom-20 md:bottom-8 right-4 md:right-8 z-40">
        <button 
          onClick={() => setIsAddModalOpen(true)}
          className="flex items-center gap-xs bg-primary text-on-primary px-lg py-md rounded-full shadow-[0_10px_30px_rgba(0,0,0,0.15)] hover:shadow-[0_15px_40px_rgba(0,0,0,0.2)] hover:scale-[1.02] active:scale-95 transition-all duration-200 group border border-primary cursor-pointer"
        >
          <span className="material-symbols-outlined font-light group-hover:rotate-90 transition-transform duration-300">add</span>
          <span className="font-label-caps text-label-caps hidden md:block">ADD ITEM</span>
        </button>
      </div>
    </main>
  );
};
