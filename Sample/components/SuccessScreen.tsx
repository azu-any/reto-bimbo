import React, { useEffect } from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton } from './Shared';
import { MapPin, CheckCircle2 } from 'lucide-react';
export const SuccessScreen = ({ onNext }: {onNext: () => void;}) => {
  // Simple confetti effect using framer-motion
  const confetti = Array.from({
    length: 30
  }).map((_, i) => ({
    id: i,
    x: Math.random() * 100 - 50 + 'vw',
    y: -20,
    color: ['#003DA5', '#E32726', '#10B981', '#F59E0B'][
    Math.floor(Math.random() * 4)],

    delay: Math.random() * 0.5
  }));
  return (
    <motion.div
      initial={{
        opacity: 0
      }}
      animate={{
        opacity: 1
      }}
      exit={{
        opacity: 0
      }}
      className="absolute inset-0 bg-bimbo-navy text-white flex flex-col items-center justify-center p-6 overflow-hidden">
      
      {/* Confetti */}
      {confetti.map((c) =>
      <motion.div
        key={c.id}
        initial={{
          x: c.x,
          y: '-10vh',
          opacity: 1
        }}
        animate={{
          y: '100vh',
          opacity: 0,
          rotate: 360
        }}
        transition={{
          duration: 2,
          delay: c.delay,
          ease: 'easeOut'
        }}
        className="absolute w-3 h-3 rounded-sm z-0"
        style={{
          backgroundColor: c.color
        }} />

      )}

      <motion.div
        initial={{
          scale: 0
        }}
        animate={{
          scale: 1
        }}
        transition={{
          type: 'spring',
          stiffness: 200,
          delay: 0.2
        }}
        className="w-24 h-24 bg-white rounded-full flex items-center justify-center mb-8 relative z-10">
        
        <CheckCircle2 size={48} className="text-green-500" />
      </motion.div>

      <motion.h2
        initial={{
          y: 20,
          opacity: 0
        }}
        animate={{
          y: 0,
          opacity: 1
        }}
        transition={{
          delay: 0.4
        }}
        className="text-3xl font-bold mb-2 text-center">
        
        ¡Visita completada!
      </motion.h2>

      <motion.p
        initial={{
          y: 20,
          opacity: 0
        }}
        animate={{
          y: 0,
          opacity: 1
        }}
        transition={{
          delay: 0.5
        }}
        className="text-blue-200 mb-12 text-center">
        
        Doña Lupita quedó surtida
      </motion.p>

      <motion.div
        initial={{
          y: 20,
          opacity: 0
        }}
        animate={{
          y: 0,
          opacity: 1
        }}
        transition={{
          delay: 0.6
        }}
        className="bg-white/10 backdrop-blur-md rounded-2xl p-6 w-full max-w-sm mb-12 border border-white/20">
        
        <div className="flex justify-between items-center mb-4 pb-4 border-b border-white/20">
          <span className="text-blue-100">Cajas entregadas</span>
          <span className="font-bold text-xl">11</span>
        </div>
        <div className="flex justify-between items-center">
          <span className="text-blue-100">Venta total</span>
          <span className="font-bold text-xl text-green-400">$1,240</span>
        </div>
      </motion.div>

      <motion.div
        initial={{
          y: 20,
          opacity: 0
        }}
        animate={{
          y: 0,
          opacity: 1
        }}
        transition={{
          delay: 0.8
        }}
        className="w-full mt-auto">
        
        <p className="text-center text-sm text-blue-200 mb-4 flex items-center justify-center gap-2">
          Próxima parada: <MapPin size={14} /> Abarrotes El Sol
        </p>
        <PrimaryButton
          onClick={onNext}
          className="bg-white text-bimbo-navy hover:bg-gray-100">
          
          Ir al mapa
        </PrimaryButton>
      </motion.div>
    </motion.div>);

};