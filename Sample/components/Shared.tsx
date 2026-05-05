import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight, Volume2, VolumeX } from 'lucide-react';
export const PrimaryButton = ({
  onClick,
  children,
  disabled = false,
  variant = 'primary',
  className = ''






}: {onClick: () => void;children: React.ReactNode;disabled?: boolean;variant?: 'primary' | 'outline' | 'success';className?: string;}) => {
  const baseStyle =
  'w-full py-4 rounded-2xl font-semibold flex items-center justify-center transition-colors relative overflow-hidden';
  const variants = {
    primary: 'bg-bimbo-navy text-white',
    outline: 'border-2 border-bimbo-navy text-bimbo-navy bg-transparent',
    success: 'bg-green-500 text-white'
  };
  return (
    <motion.button
      whileTap={
      disabled ?
      {} :
      {
        scale: 0.98
      }
      }
      onClick={onClick}
      disabled={disabled}
      className={`${baseStyle} ${variants[variant]} ${disabled ? 'opacity-50 cursor-not-allowed' : ''} ${className}`}>
      
      <span className="relative z-10 flex items-center gap-2">{children}</span>
    </motion.button>);

};
export const OsitoFAB = ({ tip }: {tip?: string;}) => {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <div className="absolute bottom-6 left-6 z-50">
      <AnimatePresence>
        {isOpen && tip &&
        <motion.div
          initial={{
            opacity: 0,
            y: 10,
            scale: 0.9
          }}
          animate={{
            opacity: 1,
            y: 0,
            scale: 1
          }}
          exit={{
            opacity: 0,
            y: 10,
            scale: 0.9
          }}
          className="absolute bottom-16 left-0 bg-white p-4 rounded-2xl rounded-bl-none shadow-lg w-64 border border-bimbo-gray">
          
            <p className="text-sm text-gray-800 font-medium">{tip}</p>
          </motion.div>
        }
      </AnimatePresence>

      <motion.button
        whileHover={{
          scale: 1.05
        }}
        whileTap={{
          scale: 0.95
        }}
        onClick={() => setIsOpen(!isOpen)}
        className="relative w-14 h-14 rounded-full bg-white shadow-lg border-2 border-bimbo-gray overflow-hidden flex items-center justify-center">
        
        <img
          src="/osito.jpg"
          alt="Osito Bimbo"
          className="w-full h-full object-cover" />
        
        <motion.div
          animate={{
            opacity: [0.2, 0.6, 0.2]
          }}
          transition={{
            repeat: Infinity,
            duration: 2
          }}
          className="absolute inset-0 border-4 border-bimbo-red rounded-full" />
        
      </motion.button>
    </div>);

};
export const StepHeader = ({
  step,
  totalSteps = 9,
  title,
  subtitle





}: {step: number;totalSteps?: number;title: string;subtitle?: string;}) => {
  return (
    <div className="pt-12 pb-4 px-6 bg-white rounded-b-3xl shadow-sm z-20 relative">
      <div className="flex items-center justify-between mb-4">
        <div className="flex gap-1">
          {Array.from({
            length: totalSteps
          }).map((_, i) =>
          <div
            key={i}
            className={`h-1.5 rounded-full transition-all duration-300 ${i < step ? 'bg-bimbo-navy w-4' : 'bg-gray-200 w-1.5'}`} />

          )}
        </div>
        <div className="flex items-center gap-2 text-gray-400">
          <Volume2 size={18} />
        </div>
      </div>
      <h1 className="text-2xl font-bold text-bimbo-navy">{title}</h1>
      {subtitle && <p className="text-gray-500 text-sm mt-1">{subtitle}</p>}
    </div>);

};
export const PhoneFrame = ({ children }: {children: React.ReactNode;}) => {
  return (
    <div className="flex w-full min-h-screen items-center justify-center py-8">
      <div className="relative w-full max-w-[390px] h-[844px] bg-bimbo-cream rounded-[3rem] shadow-2xl overflow-hidden border-[8px] border-gray-900 flex flex-col">
        {/* Notch */}
        <div className="absolute top-0 inset-x-0 h-7 flex justify-center z-50">
          <div className="w-32 h-6 bg-gray-900 rounded-b-3xl"></div>
        </div>

        {/* Status Bar */}
        <div className="absolute top-0 inset-x-0 h-12 flex justify-between items-center px-6 pt-2 z-40 text-xs font-medium text-gray-800 pointer-events-none">
          <span>09:41</span>
          <div className="flex gap-1.5 items-center">
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z" />
            </svg>
            <svg className="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M15.67 4H14V2h-4v2H8.33C7.6 4 7 4.6 7 5.33v15.33C7 21.4 7.6 22 8.33 22h7.33c.74 0 1.34-.6 1.34-1.33V5.33C17 4.6 16.4 4 15.67 4z" />
            </svg>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 relative w-full h-full overflow-hidden flex flex-col">
          {children}
        </div>
      </div>
    </div>);

};