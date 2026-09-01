import React, { useState } from 'react';
import { useKitlist } from '../context/KitlistContext';

export const NewGig = () => {
  const { createGig } = useKitlist();
  
  const [gigName, setGigName] = useState('');
  const [gigDate, setGigDate] = useState('');
  const [gigLocation, setGigLocation] = useState('');
  const [gigType, setGigType] = useState('Photography');
  const [gigSize, setGigSize] = useState('Medium');
  const [isAiGenerating, setIsAiGenerating] = useState(false);

  const gigTypes = [
    { id: 'Photography', label: 'Photography', icon: 'photo_camera' },
    { id: 'Video', label: 'Video', icon: 'videocam' },
    { id: 'Audio', label: 'Audio', icon: 'mic' },
    { id: 'Livestream', label: 'Livestream', icon: 'wifi_tethering' }
  ];

  const gigSizes = ['Small', 'Medium', 'Large'];

  const handleSubmit = (e) => {
    e.preventDefault();
    createGig({
      name: gigName || `${gigType} Project`,
      date: gigDate,
      location: gigLocation || 'Studio Studio',
      type: gigType,
      size: gigSize
    });
  };

  const handleAiSuggest = () => {
    setIsAiGenerating(true);
    setTimeout(() => {
      // Generate tailored items based on Gig Type & Size
      let aiItems = {};

      if (gigType === 'Photography') {
        aiItems = {
          'CAMERA': [
            { id: `ai-${Date.now()}-1`, name: 'Sony A7S III', detail: 'SN: SONY-A7S-001', icon: 'photo_camera', packed: false },
            { id: `ai-${Date.now()}-2`, name: '35mm f/1.4 GM', detail: 'Prime • Portrait & Wide', icon: 'camera_lens', packed: false },
            { id: `ai-${Date.now()}-3`, name: '85mm f/1.8 GM', detail: 'Prime • Close-Up Bokeh', icon: 'camera_lens', packed: false }
          ],
          'LIGHTING': [
            { id: `ai-${Date.now()}-4`, name: 'Aputure 60x COB', detail: 'Main Key Light', icon: 'light', packed: false },
            { id: `ai-${Date.now()}-5`, name: '35" Softbox Dome', detail: 'Diffuser Modifier', icon: 'filter_drama', packed: false }
          ],
          'POWER': [
            { id: `ai-${Date.now()}-6`, name: 'NP-FZ100 Batteries (x4)', detail: 'High Capacity', icon: 'battery_3_bar', packed: false }
          ]
        };
      } else if (gigType === 'Video') {
        aiItems = {
          'CAMERA': [
            { id: `ai-${Date.now()}-1`, name: 'Canon R5 (Cinema Rig)', detail: '4K 120fps Raw', icon: 'videocam', packed: false },
            { id: `ai-${Date.now()}-2`, name: '24-70mm f/2.8 II', detail: 'Versatile Zoom', icon: 'camera_lens', packed: false }
          ],
          'AUDIO': [
            { id: `ai-${Date.now()}-3`, name: 'DJI Mic 2 Wireless', detail: 'Dual Transmitter', icon: 'mic', packed: false }
          ],
          'STABILIZATION': [
            { id: `ai-${Date.now()}-4`, name: 'DJI RS 3 Pro Gimbal', detail: 'Carbon Fiber Arm', icon: 'videocam', packed: false }
          ],
          'POWER': [
            { id: `ai-${Date.now()}-5`, name: 'V-Mount Battery (x2)', detail: '98Wh Power Brick', icon: 'battery_charging_full', packed: false }
          ]
        };
      } else if (gigType === 'Audio') {
        aiItems = {
          'MICROPHONES': [
            { id: `ai-${Date.now()}-1`, name: 'Shure SM7B Vocal Mic', detail: 'Cardioid Dynamic', icon: 'mic', packed: false },
            { id: `ai-${Date.now()}-2`, name: 'Rode NTG5 Shotgun', detail: 'Location Boom', icon: 'graphic_eq', packed: false }
          ],
          'RECORDER': [
            { id: `ai-${Date.now()}-3`, name: 'Rodecaster Pro II Lab', detail: 'Multi-Track Interface', icon: 'speaker', packed: false }
          ],
          'CABLES & ACCESSORIES': [
            { id: `ai-${Date.now()}-4`, name: 'Mogami Gold XLR (x4)', detail: '25ft Low Noise', icon: 'cable', packed: false }
          ]
        };
      } else {
        aiItems = {
          'CAMERAS': [
            { id: `ai-${Date.now()}-1`, name: 'Sony PTZ 4K Camera', detail: 'NDI Streaming', icon: 'videocam', packed: false }
          ],
          'SWITCHER': [
            { id: `ai-${Date.now()}-2`, name: 'Blackmagic ATEM Mini', detail: 'Live Production Switcher', icon: 'alt_route', packed: false }
          ],
          'NETWORK': [
            { id: `ai-${Date.now()}-3`, name: 'Cat6 Ethernet (100ft)', detail: 'Gigabit Backbone', icon: 'cable', packed: false }
          ]
        };
      }

      setIsAiGenerating(false);
      createGig({
        name: gigName || `AI Manifest: ${gigType} (${gigSize})`,
        date: gigDate,
        location: gigLocation || 'AI Recommended Site',
        type: gigType,
        size: gigSize
      }, aiItems);
    }, 600);
  };

  return (
    <main className="pt-[80px] pb-[100px] px-margin-mobile md:px-margin-desktop w-full max-w-[800px] mx-auto flex flex-col gap-xl">
      {/* Header Section */}
      <section className="flex flex-col gap-xs">
        <h1 className="font-display text-display text-primary">New Gig</h1>
        <p className="font-body-md text-body-md text-on-surface-variant">
          Define the parameters of your next project to build a precise gear manifest.
        </p>
      </section>

      {/* Form Section */}
      <form onSubmit={handleSubmit} className="flex flex-col gap-xl">
        {/* Basic Details */}
        <section className="flex flex-col gap-md">
          <div className="flex flex-col gap-xs">
            <label className="font-label-caps text-label-caps text-on-surface-variant" htmlFor="gig-name">
              GIG NAME
            </label>
            <input 
              id="gig-name"
              type="text" 
              value={gigName}
              onChange={e => setGigName(e.target.value)}
              placeholder="e.g., Summer Editorial Campaign" 
              className="w-full bg-surface-container-lowest border border-surface-variant p-sm font-body-md text-body-md text-primary rounded-DEFAULT focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors placeholder:text-outline"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-md">
            <div className="flex flex-col gap-xs">
              <label className="font-label-caps text-label-caps text-on-surface-variant" htmlFor="gig-date">
                DATE
              </label>
              <input 
                id="gig-date"
                type="date" 
                value={gigDate}
                onChange={e => setGigDate(e.target.value)}
                className="w-full bg-surface-container-lowest border border-surface-variant p-sm font-body-md text-body-md text-primary rounded-DEFAULT focus:outline-none focus:border-primary transition-colors"
              />
            </div>

            <div className="flex flex-col gap-xs">
              <label className="font-label-caps text-label-caps text-on-surface-variant" htmlFor="gig-location">
                LOCATION
              </label>
              <input 
                id="gig-location"
                type="text" 
                value={gigLocation}
                onChange={e => setGigLocation(e.target.value)}
                placeholder="e.g., Studio 42" 
                className="w-full bg-surface-container-lowest border border-surface-variant p-sm font-body-md text-body-md text-primary rounded-DEFAULT focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-colors placeholder:text-outline"
              />
            </div>
          </div>
        </section>

        {/* Divider */}
        <div className="h-[1px] w-full bg-surface-variant"></div>

        {/* Gig Type Selection */}
        <section className="flex flex-col gap-sm">
          <label className="font-label-caps text-label-caps text-on-surface-variant">GIG TYPE</label>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-md">
            {gigTypes.map(t => {
              const isSelected = gigType === t.id;
              return (
                <button
                  key={t.id}
                  type="button"
                  onClick={() => setGigType(t.id)}
                  className={`relative flex flex-col items-start gap-sm p-md bg-surface-container-lowest border rounded-DEFAULT text-left transition-all cursor-pointer ${
                    isSelected ? 'border-primary shadow-xs' : 'border-surface-variant hover:border-outline'
                  }`}
                >
                  {isSelected && (
                    <div className="absolute top-sm right-sm w-[14px] h-[14px] rounded-full bg-primary flex items-center justify-center">
                      <span className="material-symbols-outlined text-[10px] text-on-primary font-bold">check</span>
                    </div>
                  )}
                  <span className={`material-symbols-outlined text-[24px] ${isSelected ? 'text-primary' : 'text-on-surface-variant'}`}>
                    {t.icon}
                  </span>
                  <span className={`font-headline-md text-headline-md ${isSelected ? 'text-primary font-semibold' : 'text-on-surface-variant'}`}>
                    {t.label}
                  </span>
                </button>
              );
            })}
          </div>
        </section>

        {/* Gig Size Selection */}
        <section className="flex flex-col gap-sm">
          <label className="font-label-caps text-label-caps text-on-surface-variant">GIG SIZE</label>
          <div className="flex w-full md:w-fit rounded-DEFAULT overflow-hidden border border-surface-variant">
            {gigSizes.map(s => {
              const isSelected = gigSize === s;
              return (
                <button
                  key={s}
                  type="button"
                  onClick={() => setGigSize(s)}
                  className={`flex-1 md:w-[120px] py-[10px] font-body-md text-body-md transition-colors cursor-pointer ${
                    isSelected 
                      ? 'bg-primary text-on-primary font-semibold' 
                      : 'bg-surface-container-lowest text-on-surface-variant hover:bg-surface-container-low'
                  }`}
                >
                  {s}
                </button>
              );
            })}
          </div>
        </section>

        {/* Action Area */}
        <section className="flex flex-col md:flex-row gap-md pt-md">
          <button 
            type="submit"
            className="w-full md:w-fit px-xl py-[12px] bg-primary text-on-primary font-body-md text-body-md rounded-DEFAULT hover:bg-inverse-surface transition-colors flex justify-center items-center cursor-pointer shadow-xs"
          >
            Build Checklist
          </button>

          <button 
            type="button"
            onClick={handleAiSuggest}
            disabled={isAiGenerating}
            className="w-full md:w-fit px-xl py-[12px] bg-surface-container-lowest border border-surface-variant text-primary font-body-md text-body-md rounded-DEFAULT hover:bg-surface-container-low transition-colors flex justify-center items-center gap-sm cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">
              {isAiGenerating ? 'hourglass_empty' : 'auto_awesome'}
            </span>
            {isAiGenerating ? 'Generating Manifest...' : 'Let AI suggest what I need'}
          </button>
        </section>
      </form>
    </main>
  );
};
