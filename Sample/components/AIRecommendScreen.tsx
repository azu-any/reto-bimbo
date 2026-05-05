import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { PrimaryButton, StepHeader, OsitoFAB } from './Shared';
import { ChevronRight, Sparkles, TrendingUp } from 'lucide-react';
const aiRecommendations = [
{
  id: 1,
  name: 'Pan Bimbo Grande',
  qty: 4,
  reason: 'Histórico +12% lunes',
  active: true
},
{
  id: 2,
  name: 'Roles Canela',
  qty: 2,
  reason: 'Clima frío previsto',
  active: true
},
{
  id: 3,
  name: 'Donas Bimbo',
  qty: 3,
  reason: 'Alta demanda en la zona',
  active: true
}];

export const AIRecommendScreen = ({ onNext }: {onNext: () => void;}) => {
  const [items, setItems] = useState(aiRecommendations);
  const toggleItem = (id: number) => {
    setItems(
      items.map((i) =>
      i.id === id ?
      {
        ...i,
        active: !i.active
      } :
      i
      )
    );
  };
  const totalCajas = items.
  filter((i) => i.active).
  reduce((acc, curr) => acc + curr.qty, 0);
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
        step={4}
        title="Pedido Inteligente"
        subtitle="Recomendaciones con IA" />
      

      <div className="flex-1 overflow-y-auto p-6 pb-24">
        <div className="bg-gradient-to-br from-bimbo-navy to-blue-800 rounded-2xl p-5 text-white mb-6 shadow-lg relative overflow-hidden">
          <div className="absolute top-0 right-0 opacity-10">
            <Sparkles size={100} />
          </div>
          <div className="flex items-center gap-2 mb-2">
            <Sparkles size={20} className="text-yellow-400" />
            <h3 className="font-bold">Análisis de Doña Lupita</h3>
          </div>
          <p className="text-blue-100 text-sm mb-4">
            Basado en el clima, día de la semana y ventas históricas, este es el
            pedido óptimo.
          </p>
          <div className="flex justify-between items-end border-t border-blue-700 pt-4 mt-2">
            <div>
              <p className="text-xs text-blue-200">Total sugerido</p>
              <p className="text-2xl font-bold">{totalCajas} cajas</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-blue-200">Venta est.</p>
              <p className="text-lg font-bold text-green-400">$1,240</p>
            </div>
          </div>
        </div>

        <div className="space-y-3">
          {items.map((item, i) =>
          <motion.div
            key={item.id}
            initial={{
              opacity: 0,
              y: 10
            }}
            animate={{
              opacity: 1,
              y: 0
            }}
            transition={{
              delay: i * 0.1
            }}
            className={`p-4 rounded-2xl border-2 transition-all ${item.active ? 'bg-white border-bimbo-navy shadow-sm' : 'bg-gray-100 border-transparent opacity-60'}`}>
            
              <div className="flex justify-between items-start mb-2">
                <div>
                  <h4 className="font-bold text-gray-800">{item.name}</h4>
                  <p className="text-xs text-gray-500 flex items-center gap-1 mt-1">
                    <TrendingUp size={12} className="text-green-500" />
                    {item.reason}
                  </p>
                </div>

                {/* Toggle Switch */}
                <button
                onClick={() => toggleItem(item.id)}
                className={`w-12 h-6 rounded-full p-1 transition-colors ${item.active ? 'bg-bimbo-navy' : 'bg-gray-300'}`}>
                
                  <motion.div
                  className="w-4 h-4 bg-white rounded-full shadow-sm"
                  animate={{
                    x: item.active ? 24 : 0
                  }} />
                
                </button>
              </div>

              {item.active &&
            <div className="mt-3 flex items-center justify-between bg-gray-50 rounded-lg p-2">
                  <span className="text-sm font-medium text-gray-600">
                    Cantidad
                  </span>
                  <span className="font-bold text-bimbo-navy">
                    {item.qty} cajas
                  </span>
                </div>
            }
            </motion.div>
          )}
        </div>
      </div>

      <div className="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-gray-50 via-gray-50 to-transparent">
        <PrimaryButton onClick={onNext}>
          Revisar con tendero <ChevronRight size={20} />
        </PrimaryButton>
      </div>

      <OsitoFAB tip="La IA tiene un 94% de precisión en esta ruta. ¡Confía en las sugerencias!" />
    </motion.div>);

};