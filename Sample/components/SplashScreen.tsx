import React, { useEffect } from 'react';
import { motion } from 'framer-motion';
export const SplashScreen = ({ onNext }: {onNext: () => void;}) => {
  useEffect(() => {
    const timer = setTimeout(onNext, 2500);
    return () => clearTimeout(timer);
  }, [onNext]);
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
      className="absolute inset-0 bg-white flex flex-col items-center justify-center z-50">
      
      <motion.img
        initial={{
          scale: 0.8,
          opacity: 0
        }}
        animate={{
          scale: 1,
          opacity: 1
        }}
        transition={{
          delay: 0.2,
          type: 'spring',
          stiffness: 200
        }}
        src="/logo_bimbo.png"
        alt="Bimbo Logo"
        className="w-48 mb-12" />
      

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
        className="text-center">
        
        <h2 className="text-2xl font-bold text-bimbo-navy mb-2">
          ¡Hola, Carlos!
        </h2>
        <div className="inline-flex items-center gap-2 bg-bimbo-cream px-4 py-2 rounded-full border border-bimbo-gray">
          <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
          <span className="text-sm font-medium text-gray-600">
            Ruta #4521 activa
          </span>
        </div>
      </motion.div>

      <motion.div
        initial={{
          opacity: 0
        }}
        animate={{
          opacity: 1
        }}
        transition={{
          delay: 1.5
        }}
        className="absolute bottom-12">
        
        <div className="w-8 h-8 border-4 border-bimbo-navy border-t-transparent rounded-full animate-spin"></div>
      </motion.div>
    </motion.div>);

};