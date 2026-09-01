import React, { useState } from 'react';
import { useKitlist } from '../context/KitlistContext';

export const AddItemModal = ({ isOpen, onClose }) => {
  const { addInventoryItem } = useKitlist();
  const [name, setName] = useState('');
  const [category, setCategory] = useState('CAMERAS');
  const [serial, setSerial] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) return;

    addInventoryItem({
      name,
      category,
      serial: serial.trim() || undefined
    });

    setName('');
    setSerial('');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-xs flex items-center justify-center p-md" onClick={onClose}>
      <div className="bg-surface border border-outline-variant rounded-lg p-lg w-full max-w-[480px] shadow-2xl flex flex-col gap-md" onClick={e => e.stopPropagation()}>
        <div className="flex justify-between items-center pb-sm border-b border-outline-variant">
          <h3 className="font-headline-lg text-headline-lg font-bold text-primary">Add Gear to Inventory</h3>
          <button onClick={onClose} className="text-on-surface-variant hover:text-primary">
            <span className="material-symbols-outlined">close</span>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-md">
          <div className="flex flex-col gap-xs">
            <label className="font-label-caps text-label-caps text-on-surface-variant">EQUIPMENT NAME</label>
            <input 
              type="text" 
              required
              value={name}
              onChange={e => setName(e.target.value)}
              placeholder="e.g. Red Komodo 6K or Canon 24-70mm" 
              className="w-full p-sm bg-surface-container-lowest border border-outline-variant rounded font-body-md text-primary focus:outline-none focus:border-primary"
            />
          </div>

          <div className="flex flex-col gap-xs">
            <label className="font-label-caps text-label-caps text-on-surface-variant">CATEGORY</label>
            <select 
              value={category}
              onChange={e => setCategory(e.target.value)}
              className="w-full p-sm bg-surface-container-lowest border border-outline-variant rounded font-body-md text-primary focus:outline-none focus:border-primary"
            >
              <option value="CAMERAS">CAMERAS</option>
              <option value="LENSES">LENSES</option>
              <option value="AUDIO">AUDIO</option>
              <option value="LIGHTING">LIGHTING</option>
              <option value="POWER">POWER</option>
              <option value="ACCESSORIES">ACCESSORIES</option>
            </select>
          </div>

          <div className="flex flex-col gap-xs">
            <label className="font-label-caps text-label-caps text-on-surface-variant">SERIAL NUMBER / SPECS</label>
            <input 
              type="text" 
              value={serial}
              onChange={e => setSerial(e.target.value)}
              placeholder="e.g. SN: SONY-A7S-991 or E-Mount • Zoom" 
              className="w-full p-sm bg-surface-container-lowest border border-outline-variant rounded font-body-md text-primary focus:outline-none focus:border-primary"
            />
          </div>

          <div className="flex justify-end gap-sm pt-md border-t border-outline-variant">
            <button 
              type="button" 
              onClick={onClose}
              className="px-md py-sm bg-surface-container-low border border-outline-variant rounded font-label-caps text-label-caps hover:bg-surface-container-high"
            >
              CANCEL
            </button>
            <button 
              type="submit"
              className="px-md py-sm bg-primary text-on-primary rounded font-label-caps text-label-caps hover:bg-inverse-surface"
            >
              ADD TO LIBRARY
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
