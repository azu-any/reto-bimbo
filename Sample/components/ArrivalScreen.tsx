import React from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton } from './Shared';
import { ChevronRight } from 'lucide-react';
export const ArrivalScreen = ({ onNext }: {onNext: () => void;}) => {
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
      className="absolute inset-0 bg-bimbo-cream flex flex-col items-center justify-center p-6">
      
      <motion.div
        animate={{
          y: [-10, 10, -10]
        }}
        transition={{
          repeat: Infinity,
          duration: 4,
          ease: 'easeInOut'
        }}
        className="relative w-48 h-48 mb-12">
        
        <div className="absolute inset-0 bg-white rounded-full shadow-2xl overflow-hidden border-4 border-white">
          <img
            src="/osito.jpg"
            alt="Osito Bimbo"
            className="w-full h-full object-cover" />
          
        </div>

        {/* Audio Waveform */}
        <div className="absolute -bottom-6 left-1/2 -translate-x-1/2 flex gap-1 items-end h-8">
          {[1, 2, 3, 4, 5].map((i) =>
          <motion.div
            key={i}
            animate={{
              height: ['20%', '100%', '30%', '80%', '20%']
            }}
            transition={{
              repeat: Infinity,
              duration: 1.5,
              delay: i * 0.1,
              ease: 'easeInOut'
            }}
            className="w-1.5 bg-bimbo-red rounded-full" />

          )}
        </div>
      </motion.div>

      <motion.div
        initial={{
          opacity: 0,
          y: 20
        }}
        animate={{
          opacity: 1,
          y: 0
        }}
        transition={{
          delay: 0.3
        }}
        className="bg-white p-6 rounded-3xl shadow-lg relative mb-12 w-full max-w-sm">
        
        {/* Speech Bubble Tail */}
        <div className="absolute -top-4 left-1/2 -translate-x-1/2 w-0 h-0 border-l-[12px] border-l-transparent border-r-[12px] border-r-transparent border-b-[16px] border-b-white"></div>

        <p className="text-lg text-gray-800 font-medium text-center leading-relaxed">
          ¡Hola Carlos! Llegamos a{' '}
          <span className="text-bimbo-navy font-bold">Doña Lupita</span> 🐻
          <br />
          <br />
          Vamos a empezar bajando el pedido de la semana pasada.
        </p>
      </motion.div>

      <div className="w-full mt-auto mb-8">
        <PrimaryButton onClick={onNext}>
          ¡Vámonos! <ChevronRight size={20} />
        </PrimaryButton>
      </div>
    </motion.div>);

};