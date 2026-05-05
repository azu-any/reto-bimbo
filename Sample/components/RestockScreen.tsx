import React from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton, StepHeader, OsitoFAB } from './Shared';
import { ChevronRight, BrainCircuit, Eye } from 'lucide-react';
const suggestions = [
{
  id: 1,
  name: 'Gansito',
  reason: 'Color rojo en zona caja: +18% impulso',
  icon: <Eye size={16} />,
  qty: 2
},
{
  id: 2,
  name: 'Pan Bimbo',
  reason: 'Nivel de ojos del cliente',
  icon: <BrainCircuit size={16} />,
  qty: 4
}];

export const RestockScreen = ({ onNext }: {onNext: () => void;}) => {
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
      className="absolute inset-0 bg-gray-50 flex flex-col">
      
      <StepHeader
        step={3}
        title="Acomodo Estratégico"
        subtitle="Sugerencias de neuromarketing" />
      

      <div className="flex-1 overflow-y-auto p-6 pb-24">
        {/* Planogram Mini-diagram */}
        <div className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100 mb-8">
          <h3 className="text-sm font-bold text-gray-800 mb-3">
            Zonas Calientes
          </h3>
          <div className="flex gap-2 h-24">
            <div className="flex-1 bg-gray-100 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center text-xs text-gray-400">
              Bajo
            </div>
            <div className="flex-1 bg-red-50 rounded-lg border-2 border-bimbo-red flex items-center justify-center text-xs font-bold text-bimbo-red text-center px-2">
              Nivel de ojos
            </div>
            <div className="flex-1 bg-gray-100 rounded-lg border-2 border-dashed border-gray-300 flex items-center justify-center text-xs text-gray-400">
              Alto
            </div>
          </div>
        </div>

        <h3 className="font-bold text-gray-800 mb-4 px-1">
          Sugerencias para Doña Lupita
        </h3>

        <div className="flex overflow-x-auto gap-4 pb-4 -mx-6 px-6 snap-x">
          {suggestions.map((item, i) =>
          <motion.div
            key={item.id}
            initial={{
              opacity: 0,
              x: 20
            }}
            animate={{
              opacity: 1,
              x: 0
            }}
            transition={{
              delay: i * 0.2
            }}
            className="min-w-[260px] bg-white rounded-2xl p-5 shadow-sm border border-gray-100 snap-center">
            
              <div className="w-12 h-12 bg-bimbo-cream rounded-xl mb-4 flex items-center justify-center text-bimbo-navy font-bold text-xl">
                {item.name.charAt(0)}
              </div>
              <h4 className="font-bold text-lg text-gray-800 mb-2">
                {item.name}
              </h4>

              <div className="bg-blue-50 text-bimbo-navy text-xs font-medium px-3 py-2 rounded-lg flex items-start gap-2 mb-4">
                <div className="mt-0.5">{item.icon}</div>
                <span>{item.reason}</span>
              </div>

              <div className="flex items-center justify-between border-t border-gray-100 pt-4">
                <span className="text-sm text-gray-500">Sugerido</span>
                <div className="flex items-center gap-3">
                  <button className="w-8 h-8 rounded-full bg-gray-100 text-gray-600 font-bold">
                    -
                  </button>
                  <span className="font-bold text-lg">{item.qty}</span>
                  <button className="w-8 h-8 rounded-full bg-bimbo-navy text-white font-bold">
                    +
                  </button>
                </div>
              </div>
            </motion.div>
          )}
        </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-gray-50 via-gray-50 to-transparent">
        <PrimaryButton onClick={onNext}>
          Entendido <ChevronRight size={20} />
        </PrimaryButton>
      </div>

      <OsitoFAB tip="El color rojo atrae la mirada. Pon los Gansitos cerca de la caja para compras de impulso." />
    </motion.div>);

};