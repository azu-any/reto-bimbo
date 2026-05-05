import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { MapPin, Navigation, ChevronRight } from 'lucide-react';
import { PrimaryButton } from './Shared';
export const MapScreen = ({ onNext }: {onNext: () => void;}) => {
  const [distance, setDistance] = useState(320);
  // Simulate driving
  useEffect(() => {
    const timer = setInterval(() => {
      setDistance((prev) => Math.max(0, prev - 40));
    }, 1000);
    return () => clearInterval(timer);
  }, []);
  useEffect(() => {
    if (distance === 0) {
      setTimeout(onNext, 1000);
    }
  }, [distance, onNext]);
  return (
    <motion.div
      initial={{
        opacity: 0,
        x: 50
      }}
      animate={{
        opacity: 1,
        x: 0
      }}
      exit={{
        opacity: 0,
        x: -50
      }}
      className="absolute inset-0 bg-gray-100 flex flex-col">
      
      {/* Mock Map Background */}
      <div className="absolute inset-0 overflow-hidden">
        <svg
          width="100%"
          height="100%"
          xmlns="http://www.w3.org/2000/svg"
          className="opacity-20">
          
          <defs>
            <pattern
              id="grid"
              width="40"
              height="40"
              patternUnits="userSpaceOnUse">
              
              <path
                d="M 40 0 L 0 0 0 40"
                fill="none"
                stroke="#003DA5"
                strokeWidth="1" />
              
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#grid)" />

          {/* Route Line */}
          <path
            d="M 100 600 Q 150 400 200 200"
            fill="none"
            stroke="#003DA5"
            strokeWidth="6"
            strokeDasharray="10,10"
            className="opacity-50" />
          
        </svg>

        {/* Destination Pin */}
        <motion.div
          className="absolute top-[200px] left-[200px] -translate-x-1/2 -translate-y-full"
          animate={{
            y: [0, -10, 0]
          }}
          transition={{
            repeat: Infinity,
            duration: 2
          }}>
          
          <div className="relative w-12 h-12 bg-white rounded-full shadow-lg border-2 border-bimbo-navy overflow-hidden flex items-center justify-center">
            <img
              src="/osito.jpg"
              alt="Destino"
              className="w-full h-full object-cover" />
            
          </div>
          <div className="w-0 h-0 border-l-[8px] border-l-transparent border-r-[8px] border-r-transparent border-t-[12px] border-t-bimbo-navy mx-auto -mt-1"></div>
        </motion.div>

        {/* Current Position Pin */}
        <motion.div
          className="absolute bottom-[200px] left-[100px] -translate-x-1/2 -translate-y-1/2"
          animate={{
            x: distance === 0 ? 100 : 0,
            y: distance === 0 ? -400 : 0
          }}
          transition={{
            duration: 8,
            ease: 'linear'
          }}>
          
          <div className="w-6 h-6 bg-bimbo-red rounded-full border-4 border-white shadow-md relative z-10"></div>
          <div className="absolute inset-0 bg-bimbo-red rounded-full animate-ping opacity-50"></div>
        </motion.div>
      </div>

      {/* Top Card */}
      <div className="relative z-20 pt-14 px-4">
        <div className="bg-white rounded-2xl p-4 shadow-lg border border-gray-100">
          <div className="flex justify-between items-start mb-2">
            <div>
              <p className="text-sm text-gray-500 font-medium">
                Próxima parada
              </p>
              <h3 className="text-xl font-bold text-bimbo-navy">
                Tiendita Doña Lupita
              </h3>
            </div>
            <div className="bg-bimbo-cream text-bimbo-navy px-3 py-1 rounded-full text-sm font-bold">
              {Math.ceil(distance / 100)} min
            </div>
          </div>
          <p className="text-gray-600 text-sm flex items-center gap-1">
            <MapPin size={14} /> Av. Revolución 452
          </p>
        </div>
      </div>

      <div className="flex-1"></div>

      {/* Bottom Sheet */}
      <div className="relative z-20 bg-white rounded-t-3xl shadow-[0_-10px_40px_rgba(0,0,0,0.1)] p-6 pb-8">
        <div className="w-12 h-1.5 bg-gray-200 rounded-full mx-auto mb-6"></div>

        <div className="flex justify-between items-end mb-6">
          <div>
            <p className="text-3xl font-bold text-bimbo-navy">
              {distance}{' '}
              <span className="text-lg text-gray-500 font-medium">m</span>
            </p>
            <p className="text-sm text-gray-500">Distancia restante</p>
          </div>
          <div className="text-right">
            <p className="text-lg font-bold text-gray-800">10:45 AM</p>
            <p className="text-sm text-gray-500">ETA</p>
          </div>
        </div>

        <PrimaryButton
          onClick={onNext}
          disabled={distance > 0}
          className={distance === 0 ? 'animate-pulse' : ''}>
          
          {distance > 0 ? 'En camino...' : 'Llegué a la tienda'}
          <Navigation
            size={20}
            className={distance === 0 ? 'ml-2' : 'ml-2 opacity-50'} />
          
        </PrimaryButton>
      </div>
    </motion.div>);

};