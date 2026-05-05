import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { PrimaryButton, StepHeader, OsitoFAB } from './Shared';
import {
  AlertTriangle,
  ChevronRight,
  Trash2,
  Tag,
  CheckCircle2 } from
'lucide-react';
const mockExpiring = [
{
  id: 1,
  name: 'Pan Blanco Wonder',
  days: 2,
  action: 'Retirar',
  handled: false
},
{
  id: 2,
  name: 'Submarinos Fresa',
  days: 4,
  action: 'Promoción 2x1',
  handled: false
}];

export const ExpiringScreen = ({ onNext }: {onNext: () => void;}) => {
  const [items, setItems] = useState(mockExpiring);
  const handleAction = (id: number) => {
    setItems(
      items.map((item) =>
      item.id === id ?
      {
        ...item,
        handled: true
      } :
      item
      )
    );
  };
  const allHandled = items.every((item) => item.handled);
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
        step={2}
        title="Revisión de anaquel"
        subtitle="Productos por caducar" />
      

      <div className="flex-1 overflow-y-auto p-6 pb-24">
        <div className="bg-orange-50 border border-orange-200 rounded-2xl p-4 mb-6 flex gap-3 items-start">
          <AlertTriangle
            className="text-orange-500 shrink-0 mt-0.5"
            size={20} />
          
          <p className="text-sm text-orange-800">
            Hay{' '}
            <strong>{items.filter((i) => !i.handled).length} productos</strong>{' '}
            que requieren atención en el anaquel.
          </p>
        </div>

        <div className="space-y-4">
          <AnimatePresence>
            {items.map(
              (item) =>
              !item.handled &&
              <motion.div
                key={item.id}
                initial={{
                  opacity: 0,
                  scale: 0.95
                }}
                animate={{
                  opacity: 1,
                  scale: 1
                }}
                exit={{
                  opacity: 0,
                  x: -100
                }}
                className="bg-white rounded-2xl p-4 shadow-sm border border-gray-100">
                
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h3 className="font-bold text-gray-800">{item.name}</h3>
                        <span
                      className={`inline-block px-2 py-1 rounded-md text-xs font-bold mt-1 ${item.days <= 2 ? 'bg-red-100 text-red-700' : 'bg-yellow-100 text-yellow-700'}`}>
                      
                          Caduca en {item.days} días
                        </span>
                      </div>
                    </div>

                    <button
                  onClick={() => handleAction(item.id)}
                  className={`w-full py-3 rounded-xl font-semibold flex items-center justify-center gap-2 transition-colors ${item.action === 'Retirar' ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-bimbo-navy text-white hover:bg-blue-800'}`}>
                  
                      {item.action === 'Retirar' ?
                  <Trash2 size={18} /> :

                  <Tag size={18} />
                  }
                      {item.action}
                    </button>
                  </motion.div>

            )}
          </AnimatePresence>

          {allHandled &&
          <motion.div
            initial={{
              opacity: 0
            }}
            animate={{
              opacity: 1
            }}
            className="text-center py-12">
            
              <div className="w-16 h-16 bg-green-100 text-green-500 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 size={32} />
              </div>
              <h3 className="text-xl font-bold text-gray-800 mb-2">
                ¡Anaquel limpio!
              </h3>
              <p className="text-gray-500">
                Todo en orden para acomodar lo nuevo.
              </p>
            </motion.div>
          }
        </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-gray-50 via-gray-50 to-transparent">
        <PrimaryButton onClick={onNext} disabled={!allHandled}>
          Continuar <ChevronRight size={20} />
        </PrimaryButton>
      </div>

      <OsitoFAB tip="Recuerda aplicar la regla PEPS: Primeras Entradas, Primeras Salidas." />
    </motion.div>);

};